import DesignSystem
import SwiftUI

/// How each `Effort` shows on the "How did it feel?" strip: its label and
/// its colour — green easy, yellow medium, red hard. The strip lives in the
/// design system and knows nothing about `Effort`; this is the translation.
extension Effort {
    var title: String {
        switch self {
        case .easy: "Easy"
        case .medium: "Medium"
        case .hard: "Hard"
        }
    }

    var color: Color {
        switch self {
        case .easy: FTColors.greenAccent
        case .medium: FTColors.yellowFill
        case .hard: FTColors.redAccent
        }
    }

    /// The three options, in order, ready for `RatingStrip`.
    static var ratingOptions: [RatingStrip.Option] {
        allCases.map { RatingStrip.Option(id: $0.rawValue, title: $0.title, color: $0.color) }
    }
}

extension Binding where Value == Effort? {
    /// The same effort as the strip's string id — reads and writes go
    /// straight through, so a tap lands on the exercise at once.
    var ratingID: Binding<String?> {
        Binding<String?>(
            get: { wrappedValue?.rawValue },
            set: { wrappedValue = $0.flatMap(Effort.init(rawValue:)) },
        )
    }
}
