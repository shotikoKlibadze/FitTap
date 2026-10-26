import DesignSystem
import SwiftUI

struct HomeView: View {
    var body: some View {
        Text("Home")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
private struct HomeViewPreviewHost: View {
    var body: some View {
        HomeView()
            .background(FTColors.background)
    }
}
#Preview("Light") {
    HomeViewPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    HomeViewPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
