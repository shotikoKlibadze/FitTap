import FactoryKit
import Foundation

@MainActor
@Observable
final class NewWorkoutScreenModel {
    var destination: NewWorkoutScreenDestination?
    /// The set whose reps or weight is being picked; non-nil shows the sheet.
    var setValuePicker: SetValuePickerContext?
    var name = ""
    var color: WorkoutColor = .navy
    var type: WorkoutType = .strength {
        didSet { typeChanged() }
    }
    var primaryMuscleGroup: MuscleGroup?
    var secondaryMuscleGroup: MuscleGroup?
    var exercises: [WorkoutExercise] = []

    @ObservationIgnored
    @Injected(\.exerciseStore) private var exerciseStore

    /// Catalog lookup for the cards — exercises are referenced by id.
    var catalog: [UUID: Exercise] {
        Dictionary(uniqueKeysWithValues: exerciseStore.exercises.map { ($0.id, $0) })
    }

    /// Strength selections, remembered while cardio locks the cards.
    private var strengthPrimary: MuscleGroup?
    private var strengthSecondary: MuscleGroup?

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

    /// Anything the user entered that leaving would throw away.
    var hasUnsavedChanges: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            || !exercises.isEmpty
            || type == .cardio
            || primaryMuscleGroup != nil
            || secondaryMuscleGroup != nil
    }

    /// "Your changes to Push Day will be lost." — or generic when unnamed.
    var discardMessage: String {
        let typed = name.trimmingCharacters(in: .whitespaces)
        return typed.isEmpty
            ? "Your changes to this workout will be lost."
            : "Your changes to \(typed) will be lost."
    }

    /// One exercise is enough; a blank name gets a sensible default.
    var canCreate: Bool {
        !exercises.isEmpty
    }

    /// The typed name, or "Chest Day" from the primary muscle, or "Workout".
    private var resolvedName: String {
        let typed = name.trimmingCharacters(in: .whitespaces)
        if !typed.isEmpty { return typed }
        if let primaryMuscleGroup { return "\(primaryMuscleGroup.displayName) Day" }
        return "Workout"
    }

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
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == edit.workoutExerciseID }) else { return }
        switch edit.field {
        case .reps, .weight:
            guard let setIndex = exercises[exerciseIndex].sets.firstIndex(where: { $0.id == edit.setID }) else { return }
            if edit.field == .reps {
                exercises[exerciseIndex].sets[setIndex].reps = Int(edit.value)
            } else {
                exercises[exerciseIndex].sets[setIndex].weight = edit.value
            }
        case .duration:
            exercises[exerciseIndex].cardio?.duration = edit.value * 60
        case .speed:
            exercises[exerciseIndex].cardio?.speedKmh = edit.value
        }
    }

    private func openPicker(_ field: SetValuePickerContext.Field, workoutExerciseID: UUID, setID: UUID) {
        guard
            let workoutExercise = exercises.first(where: { $0.id == workoutExerciseID }),
            let setIndex = workoutExercise.sets.firstIndex(where: { $0.id == setID }),
            let exercise = catalog[workoutExercise.exerciseID]
        else { return }
        let set = workoutExercise.sets[setIndex]
        setValuePicker = SetValuePickerContext(
            field: field,
            workoutExerciseID: workoutExerciseID,
            setID: setID,
            exerciseName: exercise.name,
            setNumber: setIndex + 1,
            exerciseKind: exercise.kind,
            loadMode: exercise.loadMode,
            currentValue: field == .reps ? Double(set.reps) : set.weight,
        )
    }

    private func openCardioPicker(_ field: SetValuePickerContext.Field, workoutExerciseID: UUID) {
        guard
            let workoutExercise = exercises.first(where: { $0.id == workoutExerciseID }),
            let cardio = workoutExercise.cardio,
            let exercise = catalog[workoutExercise.exerciseID]
        else { return }
        setValuePicker = SetValuePickerContext(
            field: field,
            workoutExerciseID: workoutExerciseID,
            setID: nil,
            exerciseName: exercise.name,
            setNumber: nil,
            exerciseKind: exercise.kind,
            loadMode: nil,
            currentValue: field == .duration ? cardio.duration / 60 : cardio.speedKmh,
        )
    }

    func removeExercise(_ id: UUID) {
        exercises.removeAll { $0.id == id }
        for index in exercises.indices {
            exercises[index].order = index
        }
    }

    /// Everything collected on this screen — name, color, type, muscle
    /// groups, exercises with their sets — as the workout to save.
    var workout: WorkoutTemplate {
        WorkoutTemplate(
            name: resolvedName,
            color: color,
            type: type,
            primaryMuscleGroup: primaryMuscleGroup,
            secondaryMuscleGroup: secondaryMuscleGroup,
            exercises: exercises,
        )
    }

    func createWorkout() {
        // Persistence comes later: this is where `workout` gets saved.
        _ = workout
    }
}
