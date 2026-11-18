import SwiftUI

/// The small coloured square that stands for one kind of bar in a legend
/// ("■ Clean").
///
/// It is drawn the same way as the bar it stands for: solid green or
/// hollow red. The chart's bars read their colours from here too,
/// so a legend can never drift from the chart.
public struct SessionBarSwatch: View {
    let kind: SessionBar.Kind

    public init(kind: SessionBar.Kind) {
        self.kind = kind
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(Self.fill(for: kind))
            .strokeBorder(Self.outline(for: kind), lineWidth: 1.5)
            .frame(width: 12, height: 12)
    }

    static func fill(for kind: SessionBar.Kind) -> Color {
        switch kind {
        case .clean: FTColors.greenAccent
        case .failed: FTColors.redAccentSurface
        }
    }

    /// Only a failed bar has an outline that differs from its fill; a
    /// clean one is outlined in its own colour, which leaves it solid.
    static func outline(for kind: SessionBar.Kind) -> Color {
        switch kind {
        case .clean: FTColors.greenAccent
        case .failed: FTColors.redAccent
        }
    }
}

#if DEBUG
private struct SessionBarSwatchPreviewHost: View {
    var body: some View {
        HStack(spacing: 16) {
            SessionBarSwatch(kind: .clean)
            SessionBarSwatch(kind: .failed)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    SessionBarSwatchPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    SessionBarSwatchPreviewHost()
        .preferredColorScheme(.light)
}
#endif
