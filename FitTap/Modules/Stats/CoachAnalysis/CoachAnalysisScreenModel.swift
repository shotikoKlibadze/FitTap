import Foundation

/// The coach's deeper look at one exercise, opened from the suggestion on
/// its progress screen.
///
/// Nothing happens here yet: the screen only says "coming soon". This is
/// where the larger cloud model will be asked to read the exercise's whole
/// history and explain it, so the exercise is already handed in.
@MainActor
@Observable
final class CoachAnalysisScreenModel {
    let exerciseID: UUID

    init(exerciseID: UUID) {
        self.exerciseID = exerciseID
    }
}
