import SwiftUI

/// The one header for every section on every screen — "Progression",
/// "Ongoing Week", "Type", "8 Exercises" — bold in the text colour, with
/// "See All" at the trailing edge when the section opens into more.
public struct SectionHeader: View {
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
private struct SectionHeaderPreviewHost: View {
    @State private var taps = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Ongoing Week")
            SectionHeader(title: "Progression") { taps += 1 }
            SectionHeader(title: "Muscle Groups")
            Text("\(taps) See All taps")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    SectionHeaderPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    SectionHeaderPreviewHost()
        .preferredColorScheme(.light)
}
#endif
