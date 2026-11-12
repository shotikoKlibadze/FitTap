import Foundation

/// Turns the coach's decision into the words on screen.
///
/// For now each nudge has one fixed title and sentence, with no numbers in
/// them. This is the step the on-device model takes over later: it will get
/// the same `Nudge` plus the user's sets and write the sentence itself, and
/// nothing before or after this step has to change.
enum NudgeWording {
    static func text(for nudge: Nudge) -> NudgeText {
        switch nudge {
        case .addReps:
            NudgeText(
                title: "Time to add reps",
                message: "This weight is going well. Try one more rep per set.",
            )
        case .addWeight:
            NudgeText(
                title: "Time to add weight",
                message: "Your top reps are going well. Go up one step; fewer reps is fine.",
            )
        case .stay:
            NudgeText(
                title: "Stay at this weight",
                message: "You finished most of your sets. Try a longer rest between them, and get them all before moving up.",
            )
        case .repeatUntilEasier:
            NudgeText(
                title: "Done, but it was hard",
                message: "Repeat this until it feels medium, or add weight if you feel ready.",
            )
        }
    }
}
