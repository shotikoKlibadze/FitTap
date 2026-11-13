import Foundation

/// Turns the coach's decision into the words on screen.
///
/// For now each suggestion has one fixed title and sentence, with no numbers in
/// them. This is the step the on-device model takes over later: it will get
/// the same `Suggestion` plus the user's sets and write the sentence itself, and
/// nothing before or after this step has to change.
enum SuggestionWording {
    static func text(for suggestion: Suggestion) -> SuggestionText {
        switch suggestion {
        case .addReps:
            SuggestionText(
                title: "Time to add reps",
                message: "This weight is going well. Try one more rep per set.",
            )
        case .addWeight:
            SuggestionText(
                title: "Time to add weight",
                message: "Your top reps are going well. Go up one step; fewer reps is fine.",
            )
        case .stay:
            SuggestionText(
                title: "Stay at this weight",
                message: "You finished most of your sets. Try a longer rest between them, and get them all before moving up.",
            )
        case .stayUntilClean:
            SuggestionText(
                title: "Stay at this weight",
                message: "Most sets were missed this time. Keep this weight until you finish every set, or go down a step for one or two sessions.",
            )
        case .repeatUntilEasier:
            SuggestionText(
                title: "Done, but it was hard",
                message: "Repeat this until it feels medium, or add weight if you feel ready.",
            )
        case .newWeight:
            SuggestionText(
                title: "New weight achieved",
                message: "Hold it for one or two more sessions before moving up.",
            )
        case .settleIn:
            SuggestionText(
                title: "You got all your sets",
                message: "Stay at this weight for one or two more sessions and let your body get used to it.",
            )
        case .tryHeavier:
            SuggestionText(
                title: "Try heavier",
                message: "Your reps keep going up at this weight. Go up a step, you can do it.",
            )
        }
    }
}
