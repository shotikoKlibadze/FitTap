import Foundation
import NavigatorUI

struct WorkoutCheckpoints: NavigationCheckpoints {
    /// Exercises picked in Add Exercise, in list order.
    static var addExercises: NavigationCheckpoint<[UUID]> { checkpoint() }
}
