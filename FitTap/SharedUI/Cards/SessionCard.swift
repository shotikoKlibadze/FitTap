import DesignSystem
import SwiftUI

/// One session of an exercise as its own small card: the day, the top set's
/// weight and sets × reps, with an edge in the colour of how it felt — green
/// easy, yellow medium, red hard. A session with a failed set always gets
/// the red edge, plus the red ring. Unrated and nothing failed: no colour.
struct SessionCard: View {
    let item: ExerciseSessionItem

    private let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)

    var body: some View {
        ProgressionListItem(
            title: item.title,
            value: item.value,
            accessory: .sets(item.sets, failed: item.failed),
        )
        .elevatedSurface(in: shape, elevation: .compact)
        .tintedEdge(edgeColor, in: shape)
    }

    private var edgeColor: Color? {
        item.failed ? Effort.hard.color : item.effort?.color
    }
}

#if DEBUG
private struct SessionCardPreviewHost: View {
    var body: some View {
        VStack(spacing: 8) {
            ForEach(ExerciseSessionItem.samples.prefix(5)) { item in
                SessionCard(item: item)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    SessionCardPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    SessionCardPreviewHost()
        .preferredColorScheme(.light)
}
#endif
