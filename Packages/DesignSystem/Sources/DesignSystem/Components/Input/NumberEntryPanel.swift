import SwiftUI

/// Inline number entry: title, subtitle, a value field with an optional
/// unit ("kg", or none for a plain count like reps), its own keypad, and two
/// actions — set the value, or dismiss. Not a sheet: it renders wherever the
/// owner places it. The typed text is the owner's state through the binding.
public struct NumberEntryPanel: View {
    let title: String
    let subtitle: String
    /// Shown after the number ("kg"); nil for a plain count.
    var unit: String?
    /// Reps are whole numbers — no decimal key then.
    var allowsDecimal = true
    var dismissTitle = "Back To Presets"
    @Binding var text: String
    let onSet: (Double) -> Void
    /// nil hides the dismiss button — Set alone fills the row.
    let onDismiss: (() -> Void)?

    public init(
        title: String,
        subtitle: String,
        unit: String? = nil,
        allowsDecimal: Bool = true,
        dismissTitle: String = "Back To Presets",
        text: Binding<String>,
        onSet: @escaping (Double) -> Void,
        onDismiss: (() -> Void)? = nil,
    ) {
        self.title = title
        self.subtitle = subtitle
        self.unit = unit
        self.allowsDecimal = allowsDecimal
        self.dismissTitle = dismissTitle
        _text = text
        self.onSet = onSet
        self.onDismiss = onDismiss
    }

    /// Every height below the title block is static, so owners can size a
    /// container to fit the panel exactly (e.g. a fixed-height sheet).
    public enum Metrics {
        public static let sectionSpacing: CGFloat = 16
        public static let fieldHeight: CGFloat = 72
        public static let keyHeight: CGFloat = 54
        public static let keySpacing: CGFloat = 10
        public static let keyRows: CGFloat = 4
        public static let buttonHeight: CGFloat = 54

        /// Field + keypad + buttons, with the spacing between them and the header.
        public static var heightBelowHeader: CGFloat {
            sectionSpacing + fieldHeight
                + sectionSpacing + keyHeight * keyRows + keySpacing * (keyRows - 1)
                + sectionSpacing + buttonHeight
        }
    }

    private let maxLength = 6
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Metrics.keySpacing), count: 3)

    private var value: Double? {
        guard let value = Double(text), value > 0 else { return nil }
        return value
    }

    private var setTitle: String {
        guard value != nil else { return "Set" }
        return ["Set", text, unit].compactMap(\.self).joined(separator: " ")
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(FTFonts.title3Bold)
                    .foregroundStyle(FTColors.textPrimary)
                Text(subtitle)
                    .font(FTFonts.footnote)
                    .foregroundStyle(FTColors.textSecondary)
            }

            valueField

            LazyVGrid(columns: columns, spacing: Metrics.keySpacing) {
                ForEach(1...9, id: \.self) { digit in
                    digitKey(digit)
                }
                functionKey(isEnabled: allowsDecimal, action: appendDecimal) {
                    Text(allowsDecimal ? "." : "")
                        .font(FTFonts.title2)
                }
                digitKey(0)
                functionKey(isEnabled: !text.isEmpty, action: deleteLast) {
                    Image(systemName: "delete.left")
                        .font(FTFonts.title3)
                }
            }

            HStack(spacing: 10) {
                if let onDismiss {
                    PillButton(title: dismissTitle, color: .neutral, action: onDismiss)
                }

                PillButton(title: setTitle, disabled: value == nil) {
                    if let value { onSet(value) }
                }
            }
        }
    }

    // MARK: - Field

    private var valueField: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(text.isEmpty ? "0" : text)
                .font(FTFonts.largeTitleBold)
                .foregroundStyle(text.isEmpty ? FTColors.textSecondary : FTColors.textPrimary)
                .contentTransition(.numericText())
            if let unit {
                Text(unit)
                    .font(FTFonts.body)
                    .foregroundStyle(FTColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: Metrics.fieldHeight)
        .background(Capsule().stroke(FTColors.separator, lineWidth: 1))
        .animation(.smooth(duration: 0.15), value: text)
    }

    // MARK: - Keys

    private func digitKey(_ digit: Int) -> some View {
        Button {
            append("\(digit)")
        } label: {
            VStack(spacing: 0) {
                Text("\(digit)")
                    .font(FTFonts.title2)
                    .foregroundStyle(FTColors.textPrimary)
                if let letters = Self.letters[digit] {
                    Text(letters)
                        .font(FTFonts.caption2)
                        .foregroundStyle(FTColors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Metrics.keyHeight)
            .background(Capsule().fill(FTColors.surfaceSecondary))
            .contentShape(Capsule())
        }
        .buttonStyle(.press)
    }

    private func functionKey(
        isEnabled: Bool,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> some View,
    ) -> some View {
        Button(action: action) {
            label()
                .foregroundStyle(FTColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: Metrics.keyHeight)
                .background(Capsule().fill(FTColors.secondary))
                .contentShape(Capsule())
        }
        .buttonStyle(.press)
        .disabled(!isEnabled)
    }

    private static let letters: [Int: String] = [
        2: "ABC", 3: "DEF", 4: "GHI", 5: "JKL", 6: "MNO", 7: "PQRS", 8: "TUV", 9: "WXYZ",
    ]

    // MARK: - Editing

    private func append(_ digit: String) {
        guard text.count < maxLength else { return }
        if text == "0" { text = digit } else { text += digit }
    }

    private func appendDecimal() {
        guard allowsDecimal, !text.contains("."), text.count < maxLength else { return }
        text = text.isEmpty ? "0." : text + "."
    }

    private func deleteLast() {
        guard !text.isEmpty else { return }
        text.removeLast()
    }
}

#if DEBUG
private struct NumberEntryPanelPreviewHost: View {
    @State private var weightText = "23.5"
    @State private var repsText = ""
    @State private var speedText = ""
    @State private var lastAction = "—"

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("Last: \(lastAction)")
                    .font(FTFonts.footnote)
                    .foregroundStyle(FTColors.textSecondary)
                NumberEntryPanel(
                    title: "Custom Weight",
                    subtitle: "Bench Press — per side",
                    unit: "kg",
                    text: $weightText,
                    onSet: { lastAction = "set \($0)" },
                    onDismiss: { lastAction = "dismiss" },
                )
                NumberEntryPanel(
                    title: "Custom Reps",
                    subtitle: "Bench Press — set 1",
                    allowsDecimal: false,
                    text: $repsText,
                    onSet: { lastAction = "set \(Int($0)) reps" },
                    onDismiss: { lastAction = "dismiss" },
                )
                // No dismiss: Set alone fills the row.
                NumberEntryPanel(
                    title: "Speed",
                    subtitle: "Running",
                    unit: "km/h",
                    text: $speedText,
                    onSet: { lastAction = "set \($0) km/h" },
                )
            }
            .padding(20)
        }
        .background(FTColors.surface)
    }
}

#Preview("Light") {
    NumberEntryPanelPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    NumberEntryPanelPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
