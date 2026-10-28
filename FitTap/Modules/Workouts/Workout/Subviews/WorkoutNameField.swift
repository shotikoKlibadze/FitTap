import DesignSystem
import SwiftUI

/// Name input with the workout-color dot on the right; the dot morphs into
/// the color palette in place (see `WorkoutColorPicker`).
struct WorkoutNameField: View {
    @Binding var name: String
    @Binding var color: WorkoutColor

    @FocusState private var isFocused: Bool
    @State private var width: CGFloat = 0

    var body: some View {
        HStack(spacing: 10) {
            TextField("Workout Name", text: $name)
                .focused($isFocused)
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textPrimary)
            WorkoutColorPicker(color: $color, expandedWidth: max(width - 32, 0))
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .elevatedSurface(in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .onTapOutside { isFocused = false }
    }
}

#if DEBUG
private struct WorkoutNameFieldPreviewHost: View {
    @State private var name = ""
    @State private var color = WorkoutColor.navy

    var body: some View {
        ScrollView {
            WorkoutNameField(name: $name, color: $color)
                .padding()
        }
        .background(FTColors.background)
    }
}
#Preview("Light") {
    WorkoutNameFieldPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WorkoutNameFieldPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
