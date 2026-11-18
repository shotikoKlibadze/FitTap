import Foundation

/// What the progress screen tells the user when the suggestion card had to
/// use standard wording because the language model couldn't write it.
///
/// It comes in two parts so the screen stays calm. The `note` is one small
/// gray line above the card with a "More info" link. Only a tap on it
/// brings up an alert, with `alertTitle` and `alertMessage` saying what is
/// going on and what to do about it.
struct ModelHintItem: Hashable {
    let note: String
    let alertTitle: String
    let alertMessage: String
    /// Whether the alert offers a Settings button. False when there is
    /// nothing in Settings that would help, such as an iPhone that can't
    /// run Apple Intelligence at all.
    let offersSettings: Bool

    init(reason: CoachAIUnavailableReason) {
        switch reason {
        // One message for both, on purpose: "off" and "not ready" have
        // several causes (switched off, still downloading, a language
        // that doesn't match), and the Settings app explains the exact
        // one better than a guess here could.
        case .turnedOff, .notReady:
            note = "This suggestion uses standard wording."
            alertTitle = "Get suggestions written for you"
            alertMessage = "FitTap uses Apple Intelligence to write each suggestion in its own words. It isn't available right now, so you're seeing standard wording. Check in Settings that Siri and Apple Intelligence are turned on and ready.\n\nSettings > Siri"
            offersSettings = true
        case .notSupported:
            note = "This iPhone doesn't support Apple Intelligence, so suggestions use standard wording."
            alertTitle = "Apple Intelligence isn't available"
            alertMessage = "This iPhone can't run Apple Intelligence, which FitTap uses to write suggestions in its own words. Your suggestions follow the same rules; only the wording is standard."
            offersSettings = false
        }
    }
}

#if DEBUG
extension ModelHintItem {
    static let sample = ModelHintItem(reason: .turnedOff)
}
#endif
