import Foundation
import NavigatorUI

struct NewWorkoutCheckpoints: NavigationCheckpoints {
    /// Exercises picked in Add Exercise, in list order.
    static var addExercises: NavigationCheckpoint<[UUID]> { checkpoint() }
}
