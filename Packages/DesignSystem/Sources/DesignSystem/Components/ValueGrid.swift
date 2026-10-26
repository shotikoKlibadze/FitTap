import SwiftUI

/// A 4-column grid of preset values — the tap-first input for reps, weight,
/// duration. Tapping a value writes it into the binding; the selected value
/// is filled green. The owner reacts to the change (apply, dismiss) and says
/// how a value reads ("12.5", "1:30").
public struct ValueGrid: View {
    let values: [Double]
    @Binding var selection: Double?
    var cellHeight: CGFloat = 46
    let label: (Double) -> String

    public init(
        values: [Double],
        selection: Binding<Double?>,
        cellHeight: CGFloat = 46,
        label: @escaping (Double) -> String,
    ) {
        self.values = values
        _selection = selection
        self.cellHeight = cellHeight
        self.label = label
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    public var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(values, id: \.self) { value in
                let isSelected = value == selection
                Button {
                    selection = value
                } label: {
                    Text(label(value))
                        .font(isSelected ? FTFonts.bodySemibold : FTFonts.body)
                        // The selected fill is dark green in both modes.
                        .foregroundStyle(isSelected ? FTCoreColors.offWhite : FTColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: cellHeight)
                        .background(Capsule().fill(isSelected ? FTColors.greenAccent : FTColors.secondary))
                        .contentShape(Capsule())
                }
                .buttonStyle(.press)
            }
        }
    }
}

#if DEBUG
private struct ValueGridPreviewHost: View {
    @State private var reps: Double? = 10
    @State private var weight: Double? = 20

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionHeader(title: "Reps: \(reps.map(label) ?? "—")")
                ValueGrid(values: Array(1...15).map(Double.init) + [20, 25, 30], selection: $reps, label: label)
                SectionHeader(title: "Weight: \(weight.map(label) ?? "—")")
                ValueGrid(values: Array(stride(from: 2.5, through: 50, by: 2.5)), selection: $weight, label: label)
            }
            .padding()
        }
        .background(FTColors.surface)
    }

    private func label(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)))
    }
}

#Preview("Light") {
    ValueGridPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ValueGridPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
