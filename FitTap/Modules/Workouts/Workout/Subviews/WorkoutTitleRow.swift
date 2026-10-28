import DesignSystem
import SwiftUI

/// The workout's name as a heading, with its color dot at the right end —
/// the read-only twin of `WorkoutNameField`, laid out the same way so the
/// one can morph into the other.
struct WorkoutTitleRow: View {
    let name: String
    let color: WorkoutColor

    private let dotSize: CGFloat = 26

    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(FTFonts.largeTitleBold)
                .foregroundStyle(FTColors.textPrimary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            // The collapsed look of `WorkoutColorPicker`: a ring around a dot.
            Circle()
                .stroke(color.color, lineWidth: 2.5)
                .frame(width: dotSize, height: dotSize)
                .overlay {
                    Circle()
                        .fill(color.color)
                        .frame(width: 14, height: 14)
                }
        }
    }
}

#if DEBUG
private struct WorkoutTitleRowPreviewHost: View {
    @State private var color = WorkoutColor.navy

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            WorkoutTitleRow(name: "Push Day", color: color)
            WorkoutTitleRow(name: "A long workout name that wraps", color: .rose)
            PillButton(title: "Next color", style: .secondary, size: .compact) {
                let all = WorkoutColor.allCases
                color = all[(all.firstIndex(of: color)! + 1) % all.count]
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    WorkoutTitleRowPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WorkoutTitleRowPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
