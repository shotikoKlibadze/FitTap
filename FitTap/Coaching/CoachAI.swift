import Foundation
import FoundationModels

/// The one door to the language model for everything the coach says.
///
/// Screens never touch a model session. They ask this for words and get
/// them back; which model runs, how it is briefed, and what happens when
/// it can't answer all stay in here. Today it writes the suggestion card
/// on the progress screen; the Analysis screen's cloud call belongs here
/// too when it is built.
///
/// The rules still decide. This only puts a decision that `CoachEngine`
/// already made into words, and when the model is missing or refuses it
/// hands back the fixed text from `SuggestionWording`, so a card is never
/// empty and never wrong about the advice.
///
/// Each card gets its own session, used once and thrown away. A session
/// remembers everything said in it: sharing one would let the last card's
/// wording leak into the next, and the on-device model's small memory
/// (about 4,096 tokens) would fill up after a few cards.
@MainActor
final class CoachAI {
    /// A session whose model is already loaded, waiting for the next card.
    private var warmSession: LanguageModelSession?

    /// Why the model can't write right now; nil when it can. Read fresh
    /// each time, since the user may turn Apple Intelligence on, or its
    /// download may finish, while the app is open.
    var unavailableReason: CoachAIUnavailableReason? {
        switch SystemLanguageModel.default.availability {
        case .available: nil
        case .unavailable(.deviceNotEligible): .notSupported
        case .unavailable(.appleIntelligenceNotEnabled): .turnedOff
        // Not ready, and any reason Apple adds later: both mean "on, but
        // not usable yet" as far as the user is concerned.
        case .unavailable: .notReady
        }
    }

    /// Loads the model ahead of time so the first words of a card come
    /// sooner. Call it when a card is likely soon, such as when the Stats
    /// tab opens; calling it again while a session is waiting does nothing.
    func prewarm() {
        guard warmSession == nil, case .available = SystemLanguageModel.default.availability else { return }
        let session = LanguageModelSession(instructions: SuggestionPrompt.instructions)
        session.prewarm()
        warmSession = session
    }

    /// Writes one suggestion card, piece by piece as the model produces it.
    ///
    /// Each value is the whole card so far: first a growing title, then the
    /// title with a growing message. Showing the latest value is all a
    /// screen has to do. The stream ends after the finished card.
    ///
    /// It never fails. If the model isn't available, refuses the request
    /// (its safety filter does that now and then, even for harmless text)
    /// or breaks off halfway, the last value is the fixed text for the same
    /// suggestion, replacing whatever was written so far.
    ///
    /// - Parameter weight: the weight of the latest session, already
    ///   formatted ("32.5 kg"). Nil skips the model and gives the fixed
    ///   text, since the title can't name a weight it doesn't have.
    func card(for suggestion: Suggestion, weight: String?) -> AsyncStream<SuggestionText> {
        let fixed = SuggestionWording.text(for: suggestion)
        let availability = SystemLanguageModel.default.availability
        guard let weight, case .available = availability else {
            Self.debugPrint("FIXED TEXT for \(suggestion). Weight: \(weight ?? "missing"). Model: \(availability)")
            return AsyncStream { continuation in
                continuation.yield(fixed)
                continuation.finish()
            }
        }

        let session = warmSession ?? LanguageModelSession(instructions: SuggestionPrompt.instructions)
        warmSession = nil
        let prompt = SuggestionPrompt.prompt(for: suggestion, weight: weight)
        Self.debugPrint("ASKING THE MODEL for \(suggestion), weight \(weight)")

        return AsyncStream { continuation in
            let writing = Task {
                do {
                    var latest: SuggestionText?
                    for try await snapshot in session.streamResponse(to: prompt, generating: SuggestionCopy.self) {
                        // Nothing to show until the title has its first word.
                        guard let title = snapshot.content.title, !title.isEmpty else { continue }
                        let text = SuggestionText(title: title, message: snapshot.content.message ?? "")
                        latest = text
                        continuation.yield(text)
                    }
                    Self.debugPrint("MODEL WROTE: \(latest?.title ?? "nothing") | \(latest?.message ?? "")")
                } catch is CancellationError {
                    // The screen went away; there is nobody to show a card to.
                    Self.debugPrint("STOPPED: the screen went away before the card was finished")
                } catch {
                    Self.debugPrint("FIXED TEXT for \(suggestion). The model failed: \(error)")
                    continuation.yield(fixed)
                }
                continuation.finish()
            }
            // Leaving the screen stops the model instead of letting it
            // finish a card nobody will read.
            continuation.onTermination = { _ in writing.cancel() }
        }
    }

    /// Says in the Xcode console which path a card took: written by the
    /// model, or the fixed text and why. The card looks the same to the
    /// user either way, so this is the only way to tell a model that isn't
    /// there from one that refused. Debug builds only.
    private nonisolated static func debugPrint(_ message: String) {
        #if DEBUG
        print("🟡 CoachAI: \(message)")
        #endif
    }
}
