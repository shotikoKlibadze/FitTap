import SwiftUI

/// Single-line text input in a capsule, with a clear button once there's
/// text. The compact field for forms inside sheets; the keyboard drops when
/// the user taps anywhere outside it.
public struct NameTextField: View {
    let placeholder: String
    @Binding var text: String

    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        _text = text
    }

    @FocusState private var isFocused: Bool

    public var body: some View {
        HStack(spacing: 10) {
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textPrimary)
                .submitLabel(.done)

            if !text.isEmpty {
                RoundButton(
                    icon: .close,
                    style: .normal,
                    size: .small,
                    iconColor: FTColors.surface,
                    backgroundColor: FTColors.textSecondary,
                ) {
                    text = ""
                }
                .transition(.opacity)
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 12)
        .frame(height: 48)
        .background(Capsule().fill(FTColors.surfaceSecondary))
        .contentShape(Capsule())
        .onTapGesture { isFocused = true }
        .onTapOutside { isFocused = false }
        .animation(.smooth(duration: 0.2), value: text.isEmpty)
    }
}

#if DEBUG
private struct AppTextFieldPreviewHost: View {
    @State private var empty = ""
    @State private var filled = "Landmine Press"

    var body: some View {
        VStack(spacing: 16) {
            NameTextField(placeholder: "Exercise name", text: $empty)
            NameTextField(placeholder: "Exercise name", text: $filled)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.surface)
    }
}

#Preview("Light") {
    AppTextFieldPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    AppTextFieldPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
