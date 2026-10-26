import DesignSystem
import SwiftUI

struct StatsView: View {
    var body: some View {
        Text("Stats")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
private struct StatsViewPreviewHost: View {
    var body: some View {
        StatsView()
            .background(FTColors.background)
    }
}
#Preview("Light") {
    StatsViewPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    StatsViewPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
