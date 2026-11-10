import SwiftUI

/// Dashed "add something" card: plus circle, title, optional subtitle.
/// It sizes to its content and fills whatever the layout hands it — square
/// it in a grid with `.aspectRatio(1, contentMode: .fit)` at the call site.
public struct AddButton: View {
    public enum Layout {
        /// Plus over the title, centered — grid tiles and empty-state cards.
        case stacked
        /// Plus beside the title on one short row — the first row of a list.
        case inline
        /// Plus beside the title, as tall as a `WorkoutSessionCard` — an
        /// empty slot in a list of session cards.
        case row
    }

    let title: String
    var subtitle: String?
    let layout: Layout
    let action: () -> Void

    /// `subtitle` shows only in the stacked layout.
    public init(title: String, subtitle: String? = nil, layout: Layout = .stacked, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.layout = layout
        self.action = action
    }

    /// The stacked card is tall enough for a soft 30; the short inline row
    /// would read as a capsule, so it rounds less; the row matches the
    /// session cards it sits among.
    private var shape: RoundedRectangle {
        let radius: CGFloat = switch layout {
        case .stacked: 30
        case .inline: 20
        case .row: 28
        }
        return RoundedRectangle(cornerRadius: radius, style: .continuous)
    }

    private var horizontalPadding: CGFloat {
        layout == .row ? 16 : 20
    }

    private var verticalPadding: CGFloat {
        switch layout {
        case .stacked: 20
        case .inline: 16
        case .row: 15
        }
    }

    public var body: some View {
        Button(action: action) {
            content
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
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

    @ViewBuilder
    private var content: some View {
        switch layout {
        case .stacked:
            VStack(spacing: 10) {
                plusCircle(diameter: 44, glyph: 22)
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
        case .inline:
            HStack(spacing: 10) {
                plusCircle(diameter: 28, glyph: 14)
                Text(title)
                    .font(FTFonts.headline)
                    .foregroundStyle(FTColors.textPrimary)
            }
        case .row:
            HStack(spacing: 12) {
                plusCircle(diameter: 34, glyph: 16)
                Text(title)
                    .font(FTFonts.headlineBold)
                    .foregroundStyle(FTColors.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            // A session card is a bold title line over a footnote line; the
            // same two lines, unseen, give the row its height at any text size.
            .background {
                VStack(spacing: 9) {
                    Text(verbatim: "Title").font(FTFonts.headlineBold)
                    Text(verbatim: "Stats").font(FTFonts.footnote)
                }
                .hidden()
            }
        }
    }

    private func plusCircle(diameter: CGFloat, glyph: CGFloat) -> some View {
        Circle()
            .fill(FTColors.green)
            .frame(width: diameter, height: diameter)
            .overlay {
                Image(systemName: "plus")
                    .font(.system(size: glyph, weight: .semibold))
                    .foregroundStyle(FTCoreColors.offWhite)
            }
    }
}

#if DEBUG
private struct AddButtonPreviewHost: View {
    @State private var tapCount = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("Taps: \(tapCount)")
                    .font(FTFonts.body)
                    .foregroundStyle(FTColors.textSecondary)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    AddButton(title: "New workout") { tapCount += 1 }
                        .aspectRatio(1, contentMode: .fit)
                }
                AddButton(title: "Plan workout for today") { tapCount += 1 }
                AddButton(
                    title: "Add Exercise",
                    subtitle: "Add your first exercise to start building the workout.",
                ) { tapCount += 1 }
                AddButton(title: "New workout", layout: .inline) { tapCount += 1 }
                AddButton(title: "Plan workout", layout: .row) { tapCount += 1 }
            }
            .padding()
        }
        .background(FTColors.background)
    }
}
#Preview("Dark") {
    AddButtonPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    AddButtonPreviewHost()
        .preferredColorScheme(.light)
}
#endif
