import Foundation

/// One coaching rule: looks at an exercise's history and either gives its
/// suggestion or steps aside.
///
/// A rule checks a single case and knows nothing about the other rules;
/// `CoachEngine` decides the order they are asked in.
protocol CoachRule {
    /// - Parameter history: the exercise's sessions, newest first.
    /// - Returns: this rule's suggestion when its case applies, nil otherwise.
    func suggestion(for history: [ExerciseSessionLog]) -> Suggestion?
}
