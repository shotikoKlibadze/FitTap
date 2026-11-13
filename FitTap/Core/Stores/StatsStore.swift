import FactoryKit
import Foundation

/// What the Stats tab counts, read straight from the logged sets and
/// sessions in the database. Nothing is stored or cached: each call runs an
/// indexed fetch and counts in code, so an edited or failed set is reflected
/// the next time it's asked. One instance for the app (see
/// `Container.statsStore`).
@MainActor
@Observable
final class StatsStore {
    @ObservationIgnored @Injected(\.swiftDataManager) private var database
    @ObservationIgnored @Injected(\.exerciseStore) private var exerciseStore

    /// Changes whenever a session is saved or deleted; readers reload on it.
    var revision: Int { database.sessionsRevision }

    /// Exercises per muscle group in `start..<end`, by each exercise's main
    /// muscle: an exercise counts once per session it was logged in, however
    /// many sets it had (Leg Day with five leg exercises is 5 for Legs).
    /// Biceps and triceps count as Arms. Failed sets count: the effort was
    /// made. Every group is present, at zero if untrained.
    func exercisesPerGroup(from start: Date, to end: Date) -> [BalanceGroup: Int] {
        let muscles = Dictionary(
            exerciseStore.exercises.map { ($0.id, $0.mainMuscleGroup) },
            uniquingKeysWith: { first, _ in first },
        )
        var exercises = Dictionary(uniqueKeysWithValues: BalanceGroup.allCases.map { ($0, Set<SessionExercise>()) })
        for set in database.loggedSets(from: start, to: end) {
            guard let muscle = muscles[set.exerciseID] ?? nil, let group = BalanceGroup(muscle: muscle) else { continue }
            exercises[group, default: []].insert(SessionExercise(sessionID: set.sessionID, exerciseID: set.exerciseID))
        }
        return exercises.mapValues(\.count)
    }

    /// One exercise in one session — what the balance counts.
    private struct SessionExercise: Hashable {
        let sessionID: UUID
        let exerciseID: UUID
    }

    /// Every exercise trained in `start..<end`, most recently trained first:
    /// its best set in the latest session against the session before.
    func progress(from start: Date, to end: Date) -> [ExerciseProgress] {
        let calendar = WeekCalendar.calendar
        let sets = database.loggedSets(from: start, to: end).filter { !$0.failed }
        return Dictionary(grouping: sets, by: \.exerciseID)
            .compactMap { exerciseID, sets -> ExerciseProgress? in
                let byDay = Dictionary(grouping: sets) { calendar.startOfDay(for: $0.loggedAt) }
                let days = byDay.keys.sorted(by: >)
                guard let latestDay = days.first, let latest = best(of: byDay[latestDay] ?? []) else { return nil }
                let previous = days.dropFirst().first.flatMap { best(of: byDay[$0] ?? []) }
                return ExerciseProgress(exerciseID: exerciseID, latest: latest, previous: previous)
            }
            .sorted { $0.latest.loggedAt > $1.latest.loggedAt }
    }

    /// Every session the exercise was logged in, newest first.
    func history(ofExercise id: UUID) -> [ExerciseSessionLog] {
        database.exerciseHistory(exerciseID: id)
    }

    /// Cardio minutes from sessions that ended in `start..<end`.
    func cardioMinutes(from start: Date, to end: Date) -> Int {
        let seconds = database.cardioEntries(from: start, to: end).reduce(0) { $0 + $1.duration }
        return Int((seconds / 60).rounded())
    }

    /// The heaviest set, then the most reps, then the longest hold.
    private func best(of sets: [LoggedSet]) -> LoggedSet? {
        sets.max { $0.rank < $1.rank }
    }
}
