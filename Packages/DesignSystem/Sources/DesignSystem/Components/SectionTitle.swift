import SwiftUI

/// A section's title on a screen — "Progression", "Ongoing Week" — bold in
/// the text colour, with "See All" at the trailing edge when the section
/// opens into more. The quieter `SectionHeader` is for form labels; this is
/// the row that heads a block of content.
public struct SectionTitle: View {
    let title: String
    let seeAllAction: (() -> Void)?

    public init(title: String, seeAllAction: (() -> Void)? = nil) {
        self.title = title
        self.seeAllAction = seeAllAction
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(FTFonts.subheadlineBold)
                .foregroundStyle(FTColors.textPrimary)
                .lineLimit(1)
            Spacer(minLength: 8)
            if let seeAllAction {
                TextButton(title: "See All", action: seeAllAction)
            }
        }
    }
}

#if DEBUG
private struct SectionTitlePreviewHost: View {
    @State private var taps = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Ongoing Week")
            SectionTitle(title: "Progression") { taps += 1 }
            Text("\(taps) See All taps")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    SectionTitlePreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SectionTitlePreviewHost()
        .preferredColorScheme(.dark)
}
#endif
