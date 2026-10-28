import DesignSystem
import FactoryKit
import Foundation

/// One workout, read or edited. An existing workout opens read-only and
/// `didTapEdit()` switches it to editing in place; a new one opens editing.
/// While editing, the fields below are a draft: saving writes them to the
/// store, cancelling reloads them from it.
@MainActor
@Observable
final class WorkoutScreenModel {
    var destination: WorkoutScreenDestination?
    /// The set whose reps or weight is being picked; non-nil shows the sheet.
    var setValuePicker: SetValuePickerContext?
    private(set) var isEditing: Bool

    var name = ""
    var color: WorkoutColor = .navy
    var type: WorkoutType = .strength {
        didSet { typeChanged() }
    }
    var primaryMuscleGroup: MuscleGroup?
    var secondaryMuscleGroup: MuscleGroup?
    var exercises: [WorkoutExercise] = []

    /// The Plan card is open; opening it starts on today.
    var isPlanning = false {
        didSet {
            if isPlanning, !oldValue { planDate = today }
        }
    }
    /// The day picked on the Plan card.
    var planDate: Date?
    let calendar = WeekCalendar.calendar

    /// Nil while creating — the workout gets its id when it's saved.
    private let workoutID: UUID?
    private let source: WorkoutScreenSource

    @ObservationIgnored
    @Injected(\.exerciseStore) private var exerciseStore
    @ObservationIgnored
    @Injected(\.workoutStore) private var workoutStore
    @ObservationIgnored
    @Injected(\.workoutSessionStore) private var sessionStore

    /// Strength selections, remembered while cardio locks the cards.
    private var strengthPrimary: MuscleGroup?
    private var strengthSecondary: MuscleGroup?

    init(workoutID: UUID?, source: WorkoutScreenSource) {
        self.workoutID = workoutID
        self.source = source
        isEditing = workoutID == nil
        if let stored = storedWorkout {
            load(stored)
        }
    }

    var isNew: Bool { workoutID == nil }

    private var storedWorkout: WorkoutTemplate? {
        workoutID.flatMap { workoutStore.template(id: $0) }
    }

    /// Catalog lookup for the cards — exercises are referenced by id.
    var catalog: [UUID: Exercise] {
        Dictionary(uniqueKeysWithValues: exerciseStore.exercises.map { ($0.id, $0) })
    }

    // MARK: - Reading

    /// Nil while reading: the name heads the content instead.
    var toolbarTitle: String? {
        guard isEditing else { return nil }
        return isNew ? "New Workout" : "Edit Workout"
    }

    /// "Strength · Chest, Shoulders".
    var subtitle: String {
        let muscles = [primaryMuscleGroup, secondaryMuscleGroup].compactMap { $0?.displayName }
        let typeName = type == .strength ? "Strength" : "Cardio"
        return muscles.isEmpty ? typeName : "\(typeName) · \(muscles.joined(separator: ", "))"
    }

    /// Strength: exercises, sets, rough minutes. Cardio: exercises, minutes,
    /// and the distance target when there is one.
    var stats: [StatsStrip.Stat] {
        let workout = workout
        let exerciseStat = StatsStrip.Stat(
            value: "\(workout.exercises.count)",
            label: workout.exercises.count == 1 ? "exercise" : "exercises",
        )
        switch workout.type {
        case .strength:
            return [
                exerciseStat,
                StatsStrip.Stat(value: "\(workout.setCount)", label: "sets"),
                StatsStrip.Stat(value: "~\(workout.estimatedMinutes)", label: "minutes"),
            ]
        case .cardio:
            var stats = [exerciseStat, StatsStrip.Stat(value: "\(workout.estimatedMinutes)", label: "minutes")]
            if let meters = workout.plannedDistanceMeters {
                let km = (meters / 1000).formatted(.number.precision(.fractionLength(0...1)))
                stats.append(StatsStrip.Stat(value: km, label: "km target"))
            }
            return stats
        }
    }

    /// Only the workout on its own can be planned; a session already has a day.
    var showsPlanButton: Bool {
        source == .library
    }

    /// The day of the session this was opened from, while it's still to come
    /// (or missed). Editing then asks first.
    var plannedDate: Date? {
        guard case .plannedSession(let date) = source else { return nil }
        return date
    }

    /// "Planned for Thu, Sep 10".
    var plannedAlertTitle: String {
        let day = plannedDate?.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()) ?? ""
        return "Planned for \(day)"
    }

    var plannedAlertMessage: String {
        "Edit \(name) or move it to another day."
    }

    /// "Last done Monday, Oct 26" — nil until a session of it is finished.
    var lastDoneText: String? {
        guard let workoutID else { return nil }
        let lastDone = sessionStore.sessions
            .filter { $0.workout.id == workoutID }
            .compactMap(\.endedAt)
            .max()
        return lastDone.map {
            "Last done \($0.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))"
        }
    }

    // MARK: - Editing

    /// The bottom button's word while editing.
    var saveTitle: String {
        isNew ? "Create workout" : "Save workout"
    }

    /// One exercise is enough; a blank name gets a sensible default. An
    /// existing workout also needs a change — saving it as it was does nothing.
    var canSave: Bool {
        !exercises.isEmpty && (isNew || hasUnsavedChanges)
    }

    /// Anything the user entered that leaving would throw away. New: anything
    /// at all. Existing: anything that differs from the stored workout.
    var hasUnsavedChanges: Bool {
        if let storedWorkout {
            return workout != storedWorkout
        }
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
            || !exercises.isEmpty
            || type == .cardio
            || primaryMuscleGroup != nil
            || secondaryMuscleGroup != nil
    }

    var discardTitle: String {
        isNew ? "Discard this workout?" : "Discard your changes?"
    }

    /// "Your changes to Push Day will be lost." — or generic when unnamed.
    var discardMessage: String {
        let typed = name.trimmingCharacters(in: .whitespaces)
        return typed.isEmpty
            ? "Your changes to this workout will be lost."
            : "Your changes to \(typed) will be lost."
    }

    func didTapEdit() {
        isEditing = true
    }

    /// Back to reading, with the stored workout's values.
    func cancelEditing() {
        if let storedWorkout {
            load(storedWorkout)
        }
        setValuePicker = nil
        isEditing = false
    }

    /// Writes the draft to the store. An existing workout goes back to
    /// reading; a new one is done — its screen closes.
    func save() {
        if isNew {
            workoutStore.add(workout)
        } else {
            workoutStore.update(workout)
            isEditing = false
        }
    }

    /// Opens the workout as a session. Opened from a planned session, that one
    /// starts; otherwise today's unfinished session of this workout carries on,
    /// or a new one begins.
    func didTapStartWorkout() {
        guard let storedWorkout else { return }
        let day = plannedDate ?? today
        let existing = sessionStore.sessions.first {
            $0.workout.id == storedWorkout.id && $0.endedAt == nil
                && calendar.isDate($0.scheduledFor, inSameDayAs: day)
        }
        if var session = existing {
            if session.startedAt == nil {
                session.startedAt = .now
                sessionStore.update(session)
            }
            destination = .session(session.id, startedFresh: false)
        } else {
            let session = WorkoutSession(workout: storedWorkout, scheduledFor: .now, startedAt: .now)
            sessionStore.add(session)
            destination = .session(session.id, startedFresh: true)
        }
    }

    var today: Date {
        calendar.startOfDay(for: .now)
    }

    /// "Plan Push Day".
    var planTitle: String {
        "Plan \(name)"
    }

    /// Puts the workout on the picked day — Home shows it from then on.
    func savePlan() {
        guard let planDate, let storedWorkout else { return }
        sessionStore.add(WorkoutSession(workout: storedWorkout, scheduledFor: planDate))
        isPlanning = false
        self.planDate = nil
    }

    func didTapChangeDate() {
        // Moving a session comes later: this is where its date picker opens.
    }

    // MARK: - Exercises

    func didTapAddExercise() {
        // A cardio workout goes straight to cardio activities.
        destination = .addExercise(type == .cardio ? .cardio : .all)
    }

    /// Each picked exercise arrives with one starter set: 10 reps, 10 kg
    /// (no weight for bodyweight moves). Cardio has no sets — it arrives as
    /// 30 minutes with no speed yet.
    func addExercises(_ ids: [UUID]) {
        let start = exercises.count
        let added = ids.enumerated().compactMap { offset, id -> WorkoutExercise? in
            guard let exercise = catalog[id] else { return nil }
            if exercise.kind == .cardio {
                return WorkoutExercise(
                    exerciseID: id,
                    order: start + offset,
                    cardio: CardioEntry(duration: 30 * 60),
                )
            }
            let weight: Double? = exercise.kind == .weightlifting ? 10 : nil
            return WorkoutExercise(
                exerciseID: id,
                order: start + offset,
                sets: [SetEntry(order: 0, reps: 10, weight: weight)],
            )
        }
        exercises.append(contentsOf: added)
    }

    func didTapReps(workoutExerciseID: UUID, setID: UUID) {
        openPicker(.reps, workoutExerciseID: workoutExerciseID, setID: setID)
    }

    func didTapWeight(workoutExerciseID: UUID, setID: UUID) {
        openPicker(.weight, workoutExerciseID: workoutExerciseID, setID: setID)
    }

    func didTapDuration(workoutExerciseID: UUID) {
        openCardioPicker(.duration, workoutExerciseID: workoutExerciseID)
    }

    func didTapSpeed(workoutExerciseID: UUID) {
        openCardioPicker(.speed, workoutExerciseID: workoutExerciseID)
    }

    /// Writes a value picked in the set value picker into its set and
    /// closes the picker.
    func applySetValue(_ edit: SetValueEdit) {
        setValuePicker = nil
        exercises.apply(edit)
    }

    func removeExercise(_ id: UUID) {
        exercises.removeAll { $0.id == id }
        for index in exercises.indices {
            exercises[index].order = index
        }
    }

    // MARK: - Helpers

    /// Everything on this screen as a workout, under the stored workout's id
    /// when there is one.
    private var workout: WorkoutTemplate {
        WorkoutTemplate(
            id: workoutID ?? UUID(),
            name: resolvedName,
            color: color,
            type: type,
            primaryMuscleGroup: primaryMuscleGroup,
            secondaryMuscleGroup: secondaryMuscleGroup,
            exercises: exercises,
        )
    }

    /// The typed name, or "Chest Day" from the primary muscle, or "Workout".
    private var resolvedName: String {
        let typed = name.trimmingCharacters(in: .whitespaces)
        if !typed.isEmpty { return typed }
        if let primaryMuscleGroup { return "\(primaryMuscleGroup.displayName) Day" }
        return "Workout"
    }

    private func load(_ template: WorkoutTemplate) {
        name = template.name
        color = template.color
        // Setting the type runs `typeChanged()`; the muscles below overwrite
        // whatever it guessed.
        type = template.type
        primaryMuscleGroup = template.primaryMuscleGroup
        secondaryMuscleGroup = template.secondaryMuscleGroup
        strengthPrimary = template.type == .strength ? template.primaryMuscleGroup : nil
        strengthSecondary = template.type == .strength ? template.secondaryMuscleGroup : nil
        exercises = template.exercises
    }

    /// Cardio is always full body with no secondary; switching back restores
    /// what the user had picked for strength.
    private func typeChanged() {
        switch type {
        case .cardio:
            strengthPrimary = primaryMuscleGroup
            strengthSecondary = secondaryMuscleGroup
            primaryMuscleGroup = .fullBody
            secondaryMuscleGroup = nil
        case .strength:
            primaryMuscleGroup = strengthPrimary
            secondaryMuscleGroup = strengthSecondary
        }
    }

    private func openPicker(_ field: SetValuePickerContext.Field, workoutExerciseID: UUID, setID: UUID) {
        guard
            let workoutExercise = exercises.first(where: { $0.id == workoutExerciseID }),
            let exercise = catalog[workoutExercise.exerciseID]
        else { return }
        setValuePicker = .set(field, of: workoutExercise, setID: setID, exercise: exercise)
    }

    private func openCardioPicker(_ field: SetValuePickerContext.Field, workoutExerciseID: UUID) {
        guard
            let workoutExercise = exercises.first(where: { $0.id == workoutExerciseID }),
            let exercise = catalog[workoutExercise.exerciseID]
        else { return }
        setValuePicker = .cardio(field, of: workoutExercise, exercise: exercise)
    }
}
