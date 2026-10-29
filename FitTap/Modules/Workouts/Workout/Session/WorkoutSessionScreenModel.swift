import FactoryKit
import Foundation

/// A workout being done. Every check and every changed value is saved to the
/// session as it happens; finishing stamps the end time. Ending it early
/// throws the session away: one started just now is removed, a planned one
/// goes back to planned with nothing logged.
@MainActor
@Observable
final class WorkoutSessionScreenModel {
    /// The set whose reps or weight is being picked; non-nil shows the sheet.
    var setValuePicker: SetValuePickerContext?
    /// The ✕ has opened into "End this workout?".
    var isConfirmingExit = false
    var exercises: [WorkoutExercise] = [] {
        didSet { save() }
    }
    private(set) var title = ""
    private(set) var color: WorkoutColor = .green
    private(set) var startedAt = Date.now

    private let sessionID: UUID
    /// Created by tapping Start, rather than planned beforehand.
    private let startedFresh: Bool

    @ObservationIgnored
    @Injected(\.workoutSessionStore) private var sessionStore
    @ObservationIgnored
    @Injected(\.exerciseStore) private var exerciseStore

    init(sessionID: UUID, startedFresh: Bool) {
        self.sessionID = sessionID
        self.startedFresh = startedFresh
        guard let session = sessionStore.session(id: sessionID) else { return }
        title = session.workout.name
        color = session.workout.color
        startedAt = session.startedAt ?? .now
        exercises = session.workout.exercises
    }

    /// Catalog lookup for the cards — exercises are referenced by id.
    var catalog: [UUID: Exercise] {
        Dictionary(uniqueKeysWithValues: exerciseStore.exercises.map { ($0.id, $0) })
    }

    // MARK: - Progress

    private var setCount: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }

    private var loggedCount: Int {
        exercises.reduce(0) { $0 + $1.sets.filter { $0.loggedAt != nil }.count }
    }

    var progress: Double {
        setCount == 0 ? 0 : Double(loggedCount) / Double(setCount)
    }

    /// "3 of 7 sets".
    var progressTitle: String {
        "\(loggedCount) of \(setCount) sets"
    }

    /// "2 exercises left" — exercises with a set still to log. Cardio has no
    /// sets to log yet, so it doesn't count.
    var progressSubtitle: String {
        let left = exercises.filter { $0.sets.contains { $0.loggedAt == nil } }.count
        switch left {
        case 0: return "All sets done"
        case 1: return "1 exercise left"
        default: return "\(left) exercises left"
        }
    }

    // MARK: - Intents

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

    /// Writes a value picked in the set value picker and closes the picker.
    func applySetValue(_ edit: SetValueEdit) {
        setValuePicker = nil
        exercises.apply(edit)
    }

    /// Nothing logged yet means nothing to lose — leaving needn't ask.
    var hasLoggedSets: Bool {
        loggedCount > 0
    }

    /// "You've logged 3 of 7 sets. Unfinished workouts aren't saved."
    var exitMessage: String {
        "You've logged \(loggedCount) of \(setCount) sets. Unfinished workouts aren't saved."
    }

    /// Throws the session away: removed if it was started just now, back to
    /// planned — nothing logged, not started — if it was planned.
    func discard() {
        if startedFresh {
            sessionStore.remove(id: sessionID)
            return
        }
        guard var session = sessionStore.session(id: sessionID) else { return }
        for exercise in session.workout.exercises.indices {
            for set in session.workout.exercises[exercise].sets.indices {
                session.workout.exercises[exercise].sets[set].loggedAt = nil
            }
        }
        session.startedAt = nil
        sessionStore.update(session)
    }

    /// Stamps the end — the session counts as done from here on.
    func finish() {
        guard var session = sessionStore.session(id: sessionID) else { return }
        session.endedAt = .now
        sessionStore.update(session)
    }

    // MARK: - Helpers

    private func save() {
        guard var session = sessionStore.session(id: sessionID) else { return }
        session.workout.exercises = exercises
        sessionStore.update(session)
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
