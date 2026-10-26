import SwiftUI

/// Pill segmented control: equal-width options, accent fill on the selection.
/// Selection is a binding — the component changes it itself and the owner
/// observes the change.
public struct SegmentedToggle: View {
    let options: [String]
    @Binding var selectedIndex: Int

    public init(options: [String], selectedIndex: Binding<Int>) {
        self.options = options
        _selectedIndex = selectedIndex
    }

    @Namespace private var pill
    

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(options.indices, id: \.self) { index in
                let isSelected = index == selectedIndex

                Text(options[index])
                    .font(FTFonts.headline)
                    .foregroundStyle(isSelected ? FTCoreColors.offWhite : FTColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.smooth(duration: 0.25)) {
                            selectedIndex = index
                        }
                    }
                    .matchedGeometryEffect(id: index, in: pill, isSource: true)
            }
        }
        .background {
            Capsule()
                .fill(FTColors.green)
                .matchedGeometryEffect(id: selectedIndex, in: pill, isSource: false)
        }
        .padding(4)
        .elevatedSurface(in: Capsule())
    }
}

#if DEBUG
private struct SegmentedTogglePreviewHost: View {
    @State private var twoWay = 0
    @State private var threeWay = 1

    var body: some View {
        VStack(spacing: 16) {
            SegmentedToggle(options: ["Strength", "Cardio"], selectedIndex: $twoWay)
            SegmentedToggle(options: ["Week", "Month", "Year"], selectedIndex: $threeWay)
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(FTColors.background)
    }
}
#Preview("Light") {
    SegmentedTogglePreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SegmentedTogglePreviewHost()
        .preferredColorScheme(.dark)
}
#endif
