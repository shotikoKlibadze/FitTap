import SwiftUI

/// Dashed "add something" card: plus circle, title, optional subtitle.
/// With `height` it takes that height; without it stays square (grid cell).
public struct CardAddButton: View {
    let title: String
    var subtitle: String?
    var height: CGFloat?
    let action: () -> Void

    public init(title: String, subtitle: String? = nil, height: CGFloat? = nil, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.height = height
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            card
                .overlay {
                    VStack(spacing: 10) {
                        Circle()
                            .fill(FTColors.green)
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(FTCoreColors.offWhite)
                            }
                        Text(title)
                            .font(FTFonts.headline)
                            .foregroundStyle(FTColors.textPrimary)
                        if let subtitle {
                            Text(subtitle)
                                .font(FTFonts.footnote)
                                .foregroundStyle(FTColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        }
        .buttonStyle(.press)
    }

    @ViewBuilder
    private var card: some View {
        let shape = RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(FTColors.surface)
            .stroke(FTColors.separator, style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
        if let height {
            shape
                .frame(maxWidth: .infinity)
                .frame(height: height)
        } else {
            shape
                .aspectRatio(1, contentMode: .fit)
        }
    }
}

#if DEBUG
private struct CardAddButtonPreviewHost: View {
    @State private var tapCount = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("Taps: \(tapCount)")
                    .font(FTFonts.body)
                    .foregroundStyle(FTColors.textSecondary)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    CardAddButton(title: "New workout") { tapCount += 1 }
                }
                CardAddButton(
                    title: "Add Exercise",
                    subtitle: "Add your first exercise to start building the workout.",
                    height: 170,
                ) { tapCount += 1 }
            }
            .padding()
        }
        .background(FTColors.background)
    }
}
#Preview("Light") {
    CardAddButtonPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    CardAddButtonPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
