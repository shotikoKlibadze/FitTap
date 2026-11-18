#if DEBUG
import FoundationModels
import Playgrounds

/// One made-up case to try the prompt on: what the rules decided and the
/// weight of the latest session.
private struct SuggestionWritingSample {
    let suggestion: Suggestion
    let weight: String

    static let all: [SuggestionWritingSample] = [
        .init(suggestion: .newWeight, weight: "32.5 kg"),
        .init(suggestion: .stay, weight: "22.5 kg"),
        .init(suggestion: .stayUntilClean, weight: "15 kg"),
        .init(suggestion: .repeatUntilEasier, weight: "40 kg"),
        .init(suggestion: .settleIn, weight: "11 kg"),
        .init(suggestion: .tryHeavier, weight: "15 kg"),
        .init(suggestion: .addWeight, weight: "40 kg"),
        .init(suggestion: .addReps, weight: "20 kg"),
    ]
}

// Run in the canvas (Editor > Canvas). Every case in
// `SuggestionWritingSample.all` is written in turn, each in a fresh session
// so one answer cannot colour the next. Read `report` at the end: the
// model's title and message next to the fixed text for the same case.
#Playground("Suggestion card wording") {
    var report = ""

    for (index, sample) in SuggestionWritingSample.all.enumerated() {
        let session = LanguageModelSession(instructions: SuggestionPrompt.instructions)
        let prompt = SuggestionPrompt.prompt(for: sample.suggestion, weight: sample.weight)
        let fixed = SuggestionWording.text(for: sample.suggestion)

        // A refused case is written into the report instead of stopping
        // the run, so it is clear which case the model would not write.
        let written: String
        do {
            let copy = try await session.respond(
                to: prompt,
                generating: SuggestionCopy.self,
                options: GenerationOptions(temperature: 0.5)
            ).content
            written = "\(copy.title) | \(copy.message)"
        } catch {
            written = "FAILED: \(error)"
        }

        report += """
        \(index) \(sample.suggestion)
          model: \(written)
          fixed: \(fixed.title) | \(fixed.message)


        """
    }
}
#endif
