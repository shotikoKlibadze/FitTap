import FactoryKit
import Foundation

@MainActor
@Observable
final class WorkoutsScreenModel {
    var destination: WorkoutsScreenDestination?

    @ObservationIgnored
    @Injected(\.workoutStore) private var workoutStore

    var workouts: [WorkoutCardItem] {
        workoutStore.templates.map { WorkoutCardItem(workout: $0) }
    }

    func didTapNewWorkout() {
        destination = .newWorkout
    }

    func didTapWorkout(id: UUID) {
        destination = .workout(id)
    }
}
