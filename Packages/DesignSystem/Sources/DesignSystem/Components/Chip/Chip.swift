import SwiftUI

/// Filter chip: capsule that inverts when selected. A single chip is just a
/// button — which chip in a row is selected is the owner's state.
public struct Chip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(isSelected ? FTFonts.subheadlineSemibold : FTFonts.subheadline)
                .foregroundStyle(isSelected ? FTColors.background : FTColors.textSecondary)
                .padding(.horizontal, 15)
                .frame(height: 40)
                .background(
                    Capsule().fill(isSelected ? FTColors.textPrimary : FTColors.surface)
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.press)
    }
}

#if DEBUG
private struct ChipPreviewHost: View {
    @State private var selected = "Chest"

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["All", "Chest", "Back", "Shoulders", "Legs", "Arms", "Abs"], id: \.self) { title in
                    Chip(title: title, isSelected: selected == title) { selected = title }
                }
            }
            .padding()
        }
        .frame(maxHeight: .infinity)
        .background(FTColors.background)
    }
}
#Preview("Light") {
    ChipPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ChipPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
