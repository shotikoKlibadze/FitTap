import SwiftUI

/// Content of New Workout's set value bottom sheet. Hands the picked value
/// back through `onPick`; the owner applies it and closes the sheet.
struct SetValuePickerScreen: View {
    @State private var screenModel: SetValuePickerScreenModel
    let onPick: (SetValueEdit) -> Void

    init(context: SetValuePickerContext, onPick: @escaping (SetValueEdit) -> Void) {
        _screenModel = State(initialValue: SetValuePickerScreenModel(context: context))
        self.onPick = onPick
    }

    var body: some View {
        SetValuePickerView(
            field: screenModel.context.field,
            title: screenModel.title,
            customTitle: screenModel.customTitle,
            subtitle: screenModel.subtitle,
            values: screenModel.values,
            selection: $screenModel.selection,
            isCustom: $screenModel.isCustom,
            customText: $screenModel.customText,
            onSaveCustom: pick,
        )
        // A grid tap is the whole interaction: apply and close.
        .onChange(of: screenModel.selection) { _, newValue in
            guard let newValue, !screenModel.isCustom else { return }
            pick(newValue)
        }
    }

    private func pick(_ value: Double) {
        onPick(screenModel.edit(with: value))
    }
}
