import DesignSystem
import SwiftUI

/// Bottom-sheet content for one value: a set's reps or weight, or a cardio
/// exercise's duration or speed — at the one fixed height the sheet is sized for.
struct SetValuePickerView: View {
    let field: SetValuePickerContext.Field
    let title: String
    let customTitle: String
    let subtitle: String
    let values: [Double]
    @Binding var selection: Double?
    @Binding var isCustom: Bool
    @Binding var customText: String
    let onSaveCustom: (Double) -> Void

    var body: some View {
        Group {
            switch field {
            case .reps:
                RepsPicker(
                    subtitle: subtitle,
                    values: values,
                    selection: $selection,
                    isCustom: $isCustom,
                    customText: $customText,
                    onSaveCustom: onSaveCustom,
                )
            case .weight:
                WeightPicker(
                    title: title,
                    customTitle: customTitle,
                    subtitle: subtitle,
                    values: values,
                    selection: $selection,
                    isCustom: $isCustom,
                    customText: $customText,
                    onSaveCustom: onSaveCustom,
                )
            case .duration:
                DurationPicker(
                    subtitle: subtitle,
                    values: values,
                    selection: $selection,
                    isCustom: $isCustom,
                    customText: $customText,
                    onSaveCustom: onSaveCustom,
                )
            case .speed:
                SpeedPicker(subtitle: subtitle, text: $customText, onSet: onSaveCustom)
            }
        }
        .frame(height: SetValuePickerMetrics.contentHeight, alignment: .top)
        .padding(.horizontal, SetValuePickerMetrics.horizontalPadding)
        .padding(.bottom, SetValuePickerMetrics.bottomPadding)
    }
}

#if DEBUG
private struct SetValuePickerViewPreviewHost: View {
    @State private var field = SetValuePickerContext.Field.reps
    @State private var selection: Double? = 10
    @State private var isCustom = false
    @State private var customText = ""

    var body: some View {
        VStack(spacing: 16) {
            PillButton(title: field == .reps ? "Show kg picker" : "Show reps picker") {
                field = field == .reps ? .weight : .reps
                isCustom = false
            }
            .padding(.horizontal, SetValuePickerMetrics.horizontalPadding)

            SetValuePickerView(
                field: field,
                title: field == .reps ? "Select reps" : "Select weight",
                customTitle: field == .reps ? "Custom Reps" : "Custom Weight",
                subtitle: field == .reps ? "Bench Press — set 1" : "Bench Press — per side",
                values: field == .reps
                    ? Array(1...15).map(Double.init) + [20, 25, 30]
                    : Array(stride(from: 2.5, through: 50, by: 2.5)),
                selection: $selection,
                isCustom: $isCustom,
                customText: $customText,
                onSaveCustom: { value in
                    selection = value
                    isCustom = false
                },
            )
            .background(FTColors.surface)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    SetValuePickerViewPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SetValuePickerViewPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
