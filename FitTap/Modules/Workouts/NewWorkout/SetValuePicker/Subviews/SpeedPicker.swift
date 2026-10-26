import DesignSystem
import SwiftUI

/// Cardio speed in km/h: no presets, just the number pad and one Set button.
struct SpeedPicker: View {
    let subtitle: String
    @Binding var text: String
    let onSet: (Double) -> Void

    var body: some View {
        NumberEntryPanel(
            title: "Speed",
            subtitle: subtitle,
            unit: "km/h",
            allowsDecimal: true,
            text: $text,
            onSet: onSet,
        )
    }
}

#if DEBUG
private struct SpeedPickerPreviewHost: View {
    @State private var text = ""
    @State private var speed: Double?

    var body: some View {
        SpeedPicker(subtitle: "Running", text: $text) { speed = $0 }
            .frame(height: SetValuePickerMetrics.contentHeight, alignment: .top)
            .padding(.horizontal, SetValuePickerMetrics.horizontalPadding)
            .frame(maxHeight: .infinity)
            .background(FTColors.surface)
    }
}

#Preview("Light") {
    SpeedPickerPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SpeedPickerPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
