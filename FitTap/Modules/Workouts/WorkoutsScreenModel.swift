import FactoryKit
import Foundation

@MainActor
@Observable
final class WorkoutsScreenModel {
    var destination: WorkoutsScreenDestination?

    func didTapNewWorkout() {
        destination = .newWorkout
    }
}
