import FoundationModels

/// The words the language model writes for a suggestion card: a short
/// title and one sentence under it.
///
/// The model fills this type directly (guided generation), so the shape is
/// guaranteed and nothing has to be parsed. The title is declared first
/// because the model writes the fields in order.
@Generable
struct SuggestionCopy {
    /// Two to four words: the action and, when there is one, the weight
    /// ("Hold 32.5 kg", "Stay at 20 kg", "Add one rep").
    ///
    /// > Important: The length is enforced by the pattern, not asked for.
    /// > The model cannot write a fifth word, so "for one or two sessions"
    /// > has to go in the message. The on-device model rejects bracket
    /// > classes like `[A-Z]` and `\S` in a pattern ("unsupported generation
    /// > guide"); `\w`, groups, `|` and `{1,3}` work.
    @Guide(
        description: "What to do, two to four words: the action and the weight only",
        .pattern(#/\w+( (\w|\.)+){1,3}/#)
    )
    var title: String

    @Guide(description: "One plain sentence, at most twenty words: how long or what comes next, and why. It never repeats the title")
    var message: String
}
