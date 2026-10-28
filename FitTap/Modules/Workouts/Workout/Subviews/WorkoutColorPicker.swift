import DesignSystem
import SwiftUI

/// The workout-color dot that morphs into a palette. Collapsed it is the
/// 26 pt ring-and-dot; tapped, the ring itself grows into the border of a
/// card holding every `WorkoutColor`, floating over whatever sits below —
/// the dot's slot in the layout never changes size.
struct WorkoutColorPicker: View {
    @Binding var color: WorkoutColor
    /// Width of the open card; the owner knows how much room there is.
    var expandedWidth: CGFloat = 320
    /// Colors per row. Ten rows the 28 colors in three lines, which keeps the
    /// open card short enough to stop above the muscle-group cards.
    var columns = 10

    @State private var isOpen = false

    private let dotSize: CGFloat = 26
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: isOpen ? 20 : dotSize / 2, style: .continuous)
    }

    var body: some View {
        Color.clear
            .frame(width: dotSize, height: dotSize)
            .overlay(alignment: .topTrailing) { card }
            .zIndex(isOpen ? 1 : 0)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isOpen {
                header
                palette
            }
        }
        .padding(isOpen ? 12 : 0)
        .frame(width: isOpen ? expandedWidth : dotSize, alignment: .topLeading)
        .frame(height: isOpen ? nil : dotSize)
        // The overlay proposes the dot's 26 pt; take the content's own height instead.
        .fixedSize(horizontal: false, vertical: true)
        .background {
            shape
                .fill(isOpen ? FTColors.surface : .clear)
                .stroke(color.color, lineWidth: isOpen ? 1.5 : 2.5)
        }
        .overlay {
            if !isOpen {
                Circle()
                    .fill(color.color)
                    .frame(width: 14, height: 14)
                    .transition(.opacity)
            }
        }
        .clipShape(shape)
        .contentShape(shape)
        .onTapGesture { if !isOpen { open() } }
        .onTapOutside { if isOpen { close() } }
    }

    private var header: some View {
        HStack {
            Text("Workout Color")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
            Spacer(minLength: 8)
            Text(color.rawValue.capitalized)
                .font(FTFonts.footnoteSemibold)
                .foregroundStyle(color.color)
        }
        .transition(.opacity)
    }

    private var palette: some View {
        VStack(spacing: 8) {
            ForEach(rows, id: \.first) { row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { option in
                        WorkoutColorSwatch(color: option, isSelected: option == color) {
                            choose(option)
                        }
                    }
                    // Pad a short last row so its swatches keep the column width.
                    ForEach(0..<(columns - row.count), id: \.self) { _ in
                        Color.clear.frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .transition(.opacity)
    }

    private var rows: [[WorkoutColor]] {
        stride(from: 0, to: WorkoutColor.allCases.count, by: columns).map {
            Array(WorkoutColor.allCases[$0..<min($0 + columns, WorkoutColor.allCases.count)])
        }
    }

    private func open() {
        withAnimation(.bouncy(duration: 0.45, extraBounce: 0.05)) { isOpen = true }
    }

    private func close() {
        withAnimation(.smooth(duration: 0.3)) { isOpen = false }
    }

    private func choose(_ option: WorkoutColor) {
        withAnimation(.smooth(duration: 0.3)) {
            color = option
            isOpen = false
        }
    }
}

/// One palette entry: a small colored circle, ringed when selected.
private struct WorkoutColorSwatch: View {
    let color: WorkoutColor
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Circle()
                .fill(color.color)
                .frame(width: 22, height: 22)
                .padding(3)
                .background {
                    if isSelected {
                        Circle().stroke(FTColors.textPrimary, lineWidth: 1.5)
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
private struct WorkoutColorPickerPreviewHost: View {
    @State private var color = WorkoutColor.navy

    var body: some View {
        ScrollView {
            HStack {
                Text("Workout Name")
                    .font(FTFonts.body)
                    .foregroundStyle(FTColors.textSecondary)
                Spacer()
                WorkoutColorPicker(color: $color, expandedWidth: 330)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(FTColors.surface))
            .padding()
        }
        .background(FTColors.background)
    }
}
#Preview("Light") {
    WorkoutColorPickerPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WorkoutColorPickerPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
