import Foundation

/// What the language model is told when it writes a suggestion card.
///
/// The model never decides anything: the rules have already picked the
/// suggestion. It gets three short lines and turns them into the card:
/// the action (which becomes the title), the detail (which becomes the
/// message) and the reason (which the message may end with).
///
/// The lines are split this way on purpose. Given one whole sentence and
/// the user's session facts, the on-device model mixed up the advice and
/// made up numbers; given the title and the message as separate lines,
/// with no other numbers in sight, it keeps the meaning.
///
/// Edit the wording here and run `Scripts/suggestion-wording/run.py` to
/// see every case written out together.
enum SuggestionPrompt {
    /// The model's standing brief: its job, its limits and its tone. Kept
    /// short, because every token here is read before each answer.
    ///
    /// The example is about running, not lifting, so the model learns the
    /// shape of a card without having a lifting sentence to copy.
    static let instructions = """
        You write the text of one small suggestion card in a fitness logging app.
        A coach has already decided what to suggest. You only put it into words.

        You are given three lines:
        - Action: what to do. The title says this, in two to four words.
        - Detail: for how long, or what comes next. The message says this.
        - Why: the reason. The message may end with it in a few words.

        Rules:
        - The title is the action only. Keep its weight exactly as written.
        - The message is one sentence, at most twenty words. It keeps every part of the detail and changes none of its meaning.
        - The message does not say the action again and does not name the weight.
        - Write numbers as digits, exactly as given: "32.5 kg", never "thirty-two". Use no number that is not in the three lines.
        - Sound calm, plain and encouraging. Speak to the user as "you". No jargon, no exclamation marks, no emoji.

        Example
        Action: Add 5 minutes
        Detail: Keep the same pace for the next 2 runs. Or slow down if it feels hard.
        Why: The last 3 runs felt easy.
        Title: Add 5 minutes
        Message: Keep the same pace for your next 2 runs, or slow down if it feels hard, since the last 3 felt easy.
        """

    /// The request for one card.
    /// - Parameter weight: the weight of the latest session, already
    ///   formatted, e.g. "32.5 kg". It is the only number the model sees
    ///   besides the ones in the fixed lines below.
    static func prompt(for suggestion: Suggestion, weight: String) -> String {
        """
        Action: \(action(suggestion, weight: weight))
        Detail: \(detail(suggestion))
        Why: \(reason(suggestion))
        """
    }

    /// What to do, in the few words the title should carry.
    private static func action(_ suggestion: Suggestion, weight: String) -> String {
        switch suggestion {
        case .addReps: "Add one rep"
        case .addWeight: "Go up one step"
        case .stay: "Stay at \(weight)"
        case .stayUntilClean: "Stay at \(weight)"
        case .repeatUntilEasier: "Repeat \(weight)"
        case .newWeight: "Hold \(weight)"
        case .settleIn: "Stay at \(weight)"
        case .tryHeavier: "Go up one step"
        }
    }

    /// For how long, or what comes next: the part the message must keep.
    private static func detail(_ suggestion: Suggestion) -> String {
        switch suggestion {
        case .addReps: "One more rep on every set, at the same weight."
        case .addWeight: "Move to the next weight up. Fewer reps at first is fine."
        case .stay: "Keep it until every set is finished, and try a longer rest between sets."
        case .stayUntilClean: "Keep it until every set is finished. Or go down one step for one or two sessions."
        case .repeatUntilEasier: "Keep repeating it until it feels medium. Or add weight if you feel ready."
        case .newWeight: "Give it one or two more sessions before moving up."
        case .settleIn: "Give it one or two more sessions, until it feels normal."
        case .tryHeavier: "Move to the next weight up."
        }
    }

    /// Why, in one line, from `CoachingRules.md`.
    ///
    /// The wording of `settleIn` is deliberate: "finished for the first
    /// time at this weight" made the model's safety filter refuse the
    /// request every time, for no reason that can be seen from outside.
    private static func reason(_ suggestion: Suggestion) -> String {
        switch suggestion {
        case .addReps: "Every set was finished two sessions in a row."
        case .addWeight: "Every set was finished two sessions in a row at the top reps."
        case .stay: "Missing one or two sets means the weight is right at the limit."
        case .stayUntilClean: "Most sets were missed, so the weight is past the limit for now."
        case .repeatUntilEasier: "Every set was done, but it felt hard."
        case .newWeight: "One full session shows it can be done, not that it is settled."
        case .settleIn: "This was the first session with every set finished."
        case .tryHeavier: "The reps went up three sessions in a row."
        }
    }
}
