import SwiftUI

/// A muscle group's set count as a small tile: the number large, the name
/// under it. On track, it's a quiet faint tile. Behind — fewer sets than the
/// user's usual — the fill goes, a red dashed border runs around it and the
/// number and name turn red, the same dashed warning as a missed workout.
/// Tapping opens that muscle group; the owner decides where.
public struct CountTileButton: View {
    public enum Status {
        /// Around the usual — a plain tile.
        case onTrack
        /// Short of the usual — red, dashed.
        case behind
    }

    let title: String
    let count: Int
    let status: Status
    let action: () -> Void

    public init(title: String, count: Int, status: Status, action: @escaping () -> Void) {
        self.title = title
        self.count = count
        self.status = status
        self.action = action
    }

    private let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Text("\(count)")
                    .font(FTFonts.title2Bold)
                    .monospacedDigit()
                Text(title)
                    .font(FTFonts.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(status == .behind ? FTColors.redAccent : FTColors.textPrimary)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background {
                if status == .onTrack {
                    shape.fill(FTColors.secondary)
                }
            }
            .overlay {
                if status == .behind {
                    shape.strokeBorder(FTColors.redAccent, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                }
            }
            .contentShape(shape)
        }
        .buttonStyle(.press)
        .animation(.smooth(duration: 0.25), value: status == .behind)
    }
}

#if DEBUG
private struct CountTileButtonPreviewHost: View {
    @State private var legsBehind = true
    @State private var lastTapped = "—"

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: columns, spacing: 8) {
                CountTileButton(title: "Chest", count: 48, status: .onTrack) { lastTapped = "Chest" }
                CountTileButton(title: "Back", count: 52, status: .onTrack) { lastTapped = "Back" }
                CountTileButton(title: "Shoulders", count: 30, status: .onTrack) { lastTapped = "Shoulders" }
                CountTileButton(title: "Legs", count: 8, status: legsBehind ? .behind : .onTrack) {
                    legsBehind.toggle()
                }
            }
            Text("Tapped: \(lastTapped) · tap Legs to flip its status")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.surface)
    }
}

#Preview("Dark") {
    CountTileButtonPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    CountTileButtonPreviewHost()
        .preferredColorScheme(.light)
}
#endif
