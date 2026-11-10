import SwiftUI

/// The last row of a list card that shows its rows a few at a time: "Show
/// less ⌃" and "Show more ⌄" side by side, each taking half the row, split
/// by a short hairline. Only the ones that apply show; a lone one takes the
/// whole row. Quiet, so it reads as part of the list. The card puts its
/// usual hairline above it and decides how many rows each tap adds or takes.
public struct ShowMoreFooter: View {
    let canShowLess: Bool
    let canShowMore: Bool
    let onShowLess: () -> Void
    let onShowMore: () -> Void

    public init(
        canShowLess: Bool,
        canShowMore: Bool,
        onShowLess: @escaping () -> Void,
        onShowMore: @escaping () -> Void,
    ) {
        self.canShowLess = canShowLess
        self.canShowMore = canShowMore
        self.onShowLess = onShowLess
        self.onShowMore = onShowMore
    }

    public static let height: CGFloat = 48

    public var body: some View {
        HStack(spacing: 0) {
            if canShowLess {
                half(title: "Show less", icon: FTIcons.chevronUp, action: onShowLess)
                    .transition(.opacity)
            }
            if canShowLess && canShowMore {
                Rectangle()
                    .fill(FTColors.divider)
                    .frame(width: 1, height: 22)
            }
            if canShowMore {
                half(title: "Show more", icon: FTIcons.chevronDown, action: onShowMore)
                    .transition(.opacity)
            }
        }
        .frame(height: Self.height)
    }

    private func half(title: String, icon: Image, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(FTFonts.subheadlineSemibold)
                icon
                    .font(FTFonts.caption2Semibold)
            }
            .foregroundStyle(FTColors.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: Self.height)
            .contentShape(Rectangle())
        }
        .buttonStyle(.press)
    }
}

#if DEBUG
private struct ShowMoreFooterPreviewHost: View {
    @State private var shown = 2

    private let rows = ["Bench Press", "Deadlift", "Back Squat", "Pull-Ups", "Arnold Press", "Leg Curls"]
    private let step = 2

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.prefix(shown).enumerated()), id: \.offset) { index, row in
                if index > 0 {
                    Rectangle().fill(FTColors.divider).frame(height: 1)
                }
                Text(row)
                    .font(FTFonts.calloutSemibold)
                    .foregroundStyle(FTColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
            }
            Rectangle().fill(FTColors.divider).frame(height: 1)
            ShowMoreFooter(
                canShowLess: shown > step,
                canShowMore: shown < rows.count,
                onShowLess: { withAnimation(.smooth(duration: 0.35)) { shown = max(step, shown - step) } },
                onShowMore: { withAnimation(.smooth(duration: 0.35)) { shown = min(rows.count, shown + step) } },
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    ShowMoreFooterPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    ShowMoreFooterPreviewHost()
        .preferredColorScheme(.light)
}
#endif
