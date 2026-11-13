import DesignSystem
import FactoryKit
import Foundation

/// One workout, read or edited. An existing workout opens read-only and
/// `didTapEdit()` switches it to editing in place; a new one opens editing.
/// While editing, the fields below are a draft: saving writes them to the
/// store, cancelling reloads them from it.
///
/// Opened from a session on Home — planned, missed or done — it shows and
/// edits that session's workout: saving changes only that day, never the
/// general workout. A done session shows what was logged, ratings included.
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

    /// What the screen shows and edits: the planned session's workout when
    /// opened from one, otherwise the general workout.
    private var storedWorkout: WorkoutTemplate? {
        if let openedSession {
            return openedSession.workout
        }
        return workoutID.flatMap { workoutStore.template(id: $0) }
    }

    /// The session this was opened from on Home, whatever its state.
    private var openedSession: WorkoutSession? {
        switch source {
        case .plannedSession(let id), .finishedSession(let id): sessionStore.session(id: id)
        case .library, .planning, .logging: nil
        }
    }

    /// Opened from a finished session — done, or logged for a past day.
    /// Editing it fixes the record, as while working out: sets are checked
    /// off, failed or unchecked and ratings changed; nothing is reordered.
    var isLoggedWorkout: Bool {
        guard case .finishedSession = source else { return false }
        return true
    }

    /// The session this was opened from, while it's still to come (or missed).
    private var plannedSession: WorkoutSession? {
        guard case .plannedSession(let id) = source else { return nil }
        return sessionStore.session(id: id)
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
    var stats: [WorkoutSummaryStrip.Stat] {
        let workout = workout
        let exerciseStat = WorkoutSummaryStrip.Stat(
            value: "\(workout.exercises.count)",
            label: workout.exercises.count == 1 ? "exercise" : "exercises",
        )
        switch workout.type {
        case .strength:
            return [
                exerciseStat,
                WorkoutSummaryStrip.Stat(value: "\(workout.setCount)", label: "sets"),
                WorkoutSummaryStrip.Stat(value: "~\(strengthMinutes(workout))", label: "minutes"),
            ]
        case .cardio:
            var stats = [exerciseStat, WorkoutSummaryStrip.Stat(value: "\(workout.estimatedMinutes)", label: "minutes")]
            if let meters = workout.plannedDistanceMeters {
                let km = (meters / 1000).formatted(.number.precision(.fractionLength(0...1)))
                stats.append(WorkoutSummaryStrip.Stat(value: km, label: "km target"))
            }
            return stats
        }
    }

    /// How long the user's sessions of it usually take, else the per-set guess.
    private func strengthMinutes(_ workout: WorkoutTemplate) -> Int {
        sessionStore.sessions.typicalMinutes(ofWorkout: workout.id) ?? workout.estimatedMinutes
    }

    /// Start only where there's still something to do: the workout on its
    /// own, or a session still planned. A done or missed day has none.
    var showsStartButton: Bool {
        if sheetDay != nil { return false }
        guard let openedSession else { return true }
        return openedSession.status == .planned
    }

    /// Opened from Home's sheet: the day, and whether it's logged (a past
    /// day) rather than planned.
    private var sheetDay: (day: Date, logs: Bool)? {
        switch source {
        case .planning(let day): (day, false)
        case .logging(let day): (day, true)
        case .library, .plannedSession, .finishedSession: nil
        }
    }

    /// Opened from Home's sheet: the one main button — "Plan for Tue 15"
    /// (or "Plan for Today"), or for a past day "Log for Mon 2". Nil
    /// otherwise.
    var planDayTitle: String? {
        guard let sheetDay else { return nil }
        if sheetDay.logs {
            return "Log for \(sheetDay.day.formatted(.dateTime.weekday(.abbreviated).day()))"
        }
        if calendar.isDateInToday(sheetDay.day) { return "Plan for Today" }
        return "Plan for \(sheetDay.day.formatted(.dateTime.weekday(.abbreviated).day()))"
    }

    /// Puts the workout on the sheet's day, then the Screen goes back to Home.
    /// Planned, it follows later edits to the workout until it's started.
    /// Logged, it's a finished session: every set done at its planned
    /// values, starting at 18:00 and lasting as long as the workout usually
    /// takes.
    func planForDay() {
        guard let sheetDay, let storedWorkout else { return }
        guard sheetDay.logs else {
            sessionStore.add(WorkoutSession(workout: storedWorkout, scheduledFor: sheetDay.day, followsWorkout: true))
            return
        }
        sessionStore.add(loggedSession(of: storedWorkout, on: sheetDay.day))
    }

    /// The workout as done on `day`: its own copy, every set checked off in
    /// turn across the session, cardio started at the top.
    private func loggedSession(of template: WorkoutTemplate, on day: Date) -> WorkoutSession {
        let start = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: day) ?? day
        let minutes = sessionStore.sessions.typicalMinutes(ofWorkout: template.id) ?? template.estimatedMinutes
        let duration = TimeInterval(minutes * 60)
        var workout = template.withFreshEntryIDs()
        let setCount = max(workout.setCount, 1)
        let gap = duration / Double(setCount + 1)
        var logged = 0
        for exercise in workout.exercises.indices {
            workout.exercises[exercise].cardio?.startedAt = start
            for set in workout.exercises[exercise].sets.indices {
                logged += 1
                workout.exercises[exercise].sets[set].loggedAt = start.addingTimeInterval(gap * Double(logged))
                workout.exercises[exercise].sets[set].failed = false
            }
        }
        return WorkoutSession(
            workout: workout,
            scheduledFor: day,
            startedAt: start,
            endedAt: start.addingTimeInterval(duration),
        )
    }

    /// Only the workout on its own can be planned; a session already has a day.
    var showsPlanButton: Bool {
        source == .library
    }

    /// The day of the session this was opened from, while it's still to come
    /// (or missed). Editing then asks first.
    var plannedDate: Date? {
        plannedSession?.scheduledFor
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

    /// Save asks first where the edit could go more than one way. From a
    /// day still to come (or missed): this day only, every session of the
    /// workout, or a new workout. The workout on its own: update it, or a
    /// new workout. A finished day is its own record — fixing it never
    /// touches the workout — and a new workout has nothing to choose.
    var asksSaveScope: Bool {
        guard !isNew, generalWorkout != nil else { return false }
        return isEditingDay || openedSession == nil
    }

    /// Editing one planned (or missed) day of a workout that still exists.
    var isEditingDay: Bool {
        plannedSession != nil && generalWorkout != nil
    }

    /// The workout itself ("Leg Day"), as on the Workouts tab.
    private var generalWorkout: WorkoutTemplate? {
        workoutID.flatMap { workoutStore.template(id: $0) }
    }

    /// The workout's name for the save question.
    var generalWorkoutName: String {
        generalWorkout?.name ?? name
    }

    /// Writes the draft to the store. An existing workout goes back to
    /// reading; a new one is done — its screen closes. Opened from a day on
    /// Home, that day changes; with `everywhere`, the workout itself takes
    /// the same plan too, so every planned day following it shows it.
    func save(everywhere: Bool = false) {
        if isNew {
            workoutStore.add(workout)
            return
        }
        if let openedSession {
            let edited = isLoggedWorkout ? workout.dated(within: openedSession) : workout
            sessionStore.updateWorkout(ofSession: openedSession.id, to: edited)
            if everywhere, generalWorkout != nil {
                workoutStore.update(workout.asPlan())
            }
        } else {
            workoutStore.update(workout)
        }
        // Reload what was stored: a session's copy gets fresh entry ids.
        if let storedWorkout {
            load(storedWorkout)
        }
        isEditing = false
    }

    /// Keeps the workout as it was and saves the edits as a new workout on
    /// the Workouts tab — "Shoulder Day 2" when the name wasn't changed.
    /// Editing a planned day, that day also takes the edits, for itself
    /// only, as with "This Day Only"; it stays a day of the original
    /// workout. On its own, the workout keeps its stored values and the
    /// Screen closes.
    func saveAsNew() {
        let new = WorkoutTemplate(
            name: newWorkoutName,
            color: color,
            type: type,
            primaryMuscleGroup: primaryMuscleGroup,
            secondaryMuscleGroup: secondaryMuscleGroup,
            exercises: exercises,
        ).asPlan()
        workoutStore.add(new)
        if isEditingDay {
            save()
        } else {
            cancelEditing()
        }
    }

    /// The draft's name, numbered past the workouts that already use it.
    private var newWorkoutName: String {
        let base = resolvedName
        let taken = Set(workoutStore.templates.map(\.name))
        guard taken.contains(base) else { return base }
        var number = 2
        while taken.contains("\(base) \(number)") { number += 1 }
        return "\(base) \(number)"
    }

    /// Opens the workout as a session. Opened from a planned session, that one
    /// starts; otherwise today's unfinished session of this workout carries on,
    /// or a new one begins. Starting freezes the session's copy of the workout.
    func didTapStartWorkout() {
        guard let storedWorkout else { return }
        let day = plannedDate ?? today
        let existing = plannedSession ?? sessionStore.sessions.first {
            $0.workout.id == storedWorkout.id && $0.endedAt == nil
                && calendar.isDate($0.scheduledFor, inSameDayAs: day)
        }
        if let session = existing {
            sessionStore.start(id: session.id)
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

    /// Puts the workout on the picked day — Home shows it from then on, and
    /// it follows later edits to the workout until it's started.
    func savePlan() {
        guard let planDate, let storedWorkout else { return }
        sessionStore.add(WorkoutSession(workout: storedWorkout, scheduledFor: planDate, followsWorkout: true))
        isPlanning = false
        self.planDate = nil
    }

    /// Delete while editing — always available, no confirmation; the Screen
    /// closes afterwards. Opened from a day on Home, only that day's session
    /// goes and the workout stays. Opened on its own (or to plan a day), the
    /// workout goes; days already planned with it keep their own copy. A new
    /// workout was never saved, so there's nothing to remove.
    func delete() {
        switch source {
        case .plannedSession(let id), .finishedSession(let id):
            sessionStore.remove(id: id)
        case .library, .planning, .logging:
            guard let workoutID else { return }
            workoutStore.remove(id: workoutID)
        }
    }

    func didTapChangeDate() {
        // Moving a session comes later: this is where its date picker opens.
    }

    // MARK: - Exercises

    func didTapAddExercise() {
        // A cardio workout goes straight to cardio activities.
        destination = .addExercise(type == .cardio ? .cardio : .all)
    }

    /// Each picked exercise arrives with a starter set (see `add(_:from:)`).
    func addExercises(_ ids: [UUID]) {
        exercises.add(ids, from: catalog)
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
