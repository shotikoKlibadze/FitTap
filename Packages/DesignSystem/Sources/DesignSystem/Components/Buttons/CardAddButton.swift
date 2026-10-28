import SwiftUI

/// Dashed "add something" card: plus circle, title, optional subtitle.
/// It sizes to its content and fills whatever the layout hands it — square
/// it in a grid with `.aspectRatio(1, contentMode: .fit)` at the call site.
public struct CardAddButton: View {
    let title: String
    var subtitle: String?
    let action: () -> Void

    public init(title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    private let shape = RoundedRectangle(cornerRadius: 30, style: .continuous)

    public var body: some View {
        Button(action: action) {
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
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                shape
                    .fill(FTColors.surface)
                    .stroke(FTColors.separator, style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
            }
            .contentShape(shape)
        }
        .buttonStyle(.press)
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
                        .aspectRatio(1, contentMode: .fit)
                }
                CardAddButton(title: "Plan workout for today") { tapCount += 1 }
                CardAddButton(
                    title: "Add Exercise",
                    subtitle: "Add your first exercise to start building the workout.",
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
