import DesignSystem
import SwiftUI

/// Rep count presets with "Custom…" as the escape hatch. Custom pushes the
/// number entry panel in from the right; its back button pops it out the
/// same way.
struct RepsPicker: View {
    let subtitle: String
    let values: [Double]
    @Binding var selection: Double?
    @Binding var isCustom: Bool
    @Binding var customText: String
    let onSaveCustom: (Double) -> Void

    @State private var pageWidth: CGFloat = 0

    /// A page travels its own width plus the sheet's side padding, so it
    /// leaves the sheet completely.
    private var travel: CGFloat { pageWidth + SetValuePickerMetrics.horizontalPadding }

    var body: some View {
        ZStack(alignment: .top) {
            if isCustom {
                NumberEntryPanel(
                    title: "Custom Reps",
                    subtitle: subtitle,
                    unit: nil,
                    allowsDecimal: false,
                    text: $customText,
                    onSet: onSaveCustom,
                    onDismiss: { setCustom(false) },
                )
                .geometryGroup()
                .transition(.offset(x: travel))
            } else {
                presets
                    .geometryGroup()
                    .transition(.offset(x: -travel))
            }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { pageWidth = $0 }
    }

    private var presets: some View {
        VStack(alignment: .leading, spacing: SetValuePickerMetrics.sectionSpacing) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Select reps")
                    .font(FTFonts.title3Semibold)
                    .foregroundStyle(FTColors.textPrimary)
                Text(subtitle)
                    .font(FTFonts.footnote)
                    .foregroundStyle(FTColors.textSecondary)
            }

            ValueGrid(values: values, selection: $selection, cellHeight: SetValuePickerMetrics.gridCellHeight, label: LoadDisplayFormatter.trimmed)

            Spacer(minLength: 0)

            PillButton(title: "Custom…", color: .neutral) { setCustom(true) }
        }
    }

    private func setCustom(_ custom: Bool) {
        withAnimation(.smooth(duration: 0.35)) { isCustom = custom }
    }
}

#if DEBUG
private struct RepsPickerPreviewHost: View {
    @State private var selection: Double? = 10
    @State private var isCustom = false
    @State private var customText = ""

    var body: some View {
        RepsPicker(
            subtitle: "Bench Press — set 1",
            values: Array(1...15).map(Double.init) + [20, 25, 30],
            selection: $selection,
            isCustom: $isCustom,
            customText: $customText,
            onSaveCustom: { value in
                selection = value
                isCustom = false
            },
        )
        .frame(height: SetValuePickerMetrics.contentHeight, alignment: .top)
        .padding(.horizontal, SetValuePickerMetrics.horizontalPadding)
        .frame(maxHeight: .infinity)
        .background(FTColors.surface)
    }
}

#Preview("Light") {
    RepsPickerPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    RepsPickerPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
