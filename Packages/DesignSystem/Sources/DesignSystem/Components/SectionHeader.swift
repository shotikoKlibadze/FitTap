import SwiftUI

/// The one way section titles are drawn ("Type", "Muscle Groups",
/// "8 Exercises") — same font and color everywhere.
public struct SectionHeader: View {
    let title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(FTFonts.footnote)
            .foregroundStyle(FTColors.textSecondary)
    }
}

#if DEBUG
private struct SectionHeaderPreviewHost: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Type")
            SectionHeader(title: "Muscle Groups")
            SectionHeader(title: "8 Exercises")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(FTColors.background)
    }
}
#Preview("Light") {
    SectionHeaderPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SectionHeaderPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
