import Foundation

/// Why the language model can't write right now, in the app's own words.
///
/// Screens read this instead of Apple's availability type, so nothing
/// outside `CoachAI` has to know the Foundation Models framework. Each
/// case is something different for the user to do, which is why they are
/// kept apart.
enum CoachAIUnavailableReason: Hashable, Sendable {
    /// This iPhone can't run Apple Intelligence. Nothing the user can do.
    case notSupported
    /// The iPhone can run it, but the user has it switched off.
    case turnedOff
    /// It is switched on but not usable yet: the model is still
    /// downloading, or the Siri language doesn't match the iPhone's.
    case notReady
}
