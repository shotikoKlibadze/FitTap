import DesignSystem
import SwiftUI

/// One exercise on the full progression list, as a card of its own: the
/// progression row — name, latest best set, trend and chevron — on a raised
/// surface, 55 pt tall and as wide as the screen allows.
struct ProgressionExerciseCard: View {
    let item: StatsProgressionItem
    let action: () -> Void

    private let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

    var body: some View {
        ProgressionListItem(title: item.title, value: item.value, trend: item.trend, action: action)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            // Clip the press highlight to the corners; the surface and its
            // shadow sit under the clip.
            .clipShape(shape)
            .elevatedSurface(in: shape)
    }
}

#if DEBUG
private struct ProgressionExerciseCardPreviewHost: View {
    @State private var taps = 0

    var body: some View {
        VStack(spacing: 10) {
            ForEach(StatsProgressionItem.samples.prefix(3)) { item in
                ProgressionExerciseCard(item: item) { taps += 1 }
            }
            Text("\(taps) taps")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding(16)
        .frame(maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    ProgressionExerciseCardPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    ProgressionExerciseCardPreviewHost()
        .preferredColorScheme(.light)
}
#endif
