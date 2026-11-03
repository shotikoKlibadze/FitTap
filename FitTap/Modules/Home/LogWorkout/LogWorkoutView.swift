import DesignSystem
import SwiftUI

/// Placeholder for logging a past day's workout: "Coming soon", centered.
struct LogWorkoutView: View {
    var body: some View {
        Text("Coming soon")
            .font(FTFonts.body)
            .foregroundStyle(FTColors.textSecondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
            .background(FTColors.background)
    }
}

#if DEBUG
private struct LogWorkoutViewPreviewHost: View {
    var body: some View {
        LogWorkoutView()
    }
}

#Preview("Dark") {
    LogWorkoutViewPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    LogWorkoutViewPreviewHost()
        .preferredColorScheme(.light)
}
#endif
