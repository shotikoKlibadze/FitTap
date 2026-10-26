import SwiftUI

/// A chip that picks one option from a list. Empty, it's a dashed chip with
/// the placeholder ("Primary Muscle"); chosen, a filled chip sized to the
/// chosen title. Tapped, the chip itself grows in place into a fixed-size
/// list that scrolls when the options overflow and floats over whatever
/// sits below — the chip's slot in the layout never changes. Choosing closes
/// it; choosing the selected option again clears it.
public struct ChipPicker<Option: Hashable>: View {
    let placeholder: String
    let options: [Option]
    @Binding var selection: Option?
    let title: (Option) -> String
    var openWidth: CGFloat = 200
    var openHeight: CGFloat = 220

    public init(
        placeholder: String,
        options: [Option],
        selection: Binding<Option?>,
        title: @escaping (Option) -> String,
        openWidth: CGFloat = 200,
        openHeight: CGFloat = 220,
    ) {
        self.placeholder = placeholder
        self.options = options
        _selection = selection
        self.title = title
        self.openWidth = openWidth
        self.openHeight = openHeight
    }

    @State private var isOpen = false
    /// The solid raised fill. On from the moment it opens until the close
    /// has finished, so the shrinking card never turns see-through.
    @State private var isRaised = false
    @State private var chipSize: CGSize = .zero

    private let chipHeight: CGFloat = 36
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: isOpen ? 20 : chipHeight / 2, style: .continuous)
    }

    public var body: some View {
        // The invisible chip holds the slot; the visible one floats on top.
        chipLabel
            .hidden()
            .onGeometryChange(for: CGSize.self) { $0.size } action: { chipSize = $0 }
            .overlay(alignment: .topLeading) { card }
            .zIndex(isOpen ? 1 : 0)
    }

    private var chipLabel: some View {
        Text(selection.map(title) ?? placeholder)
            .font(selection == nil ? FTFonts.subheadline : FTFonts.subheadlineSemibold)
            .foregroundStyle(selection == nil ? FTColors.textSecondary : FTColors.textPrimary)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 14)
            .frame(height: chipHeight)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isOpen {
                header
                list
            } else {
                chipLabel
                    .transition(.opacity)
            }
        }
        .frame(
            width: isOpen ? openWidth : chipSize.width,
            height: isOpen ? openHeight : chipSize.height,
            alignment: .topLeading,
        )
        .clipShape(shape)
        .background {
            ZStack {
                shape.fill(selection == nil ? Color.clear : FTColors.secondary)
                if isRaised {
                    shape.fill(FTGradients.elevatedSurfaceBackground)
                }
            }
            .shadow(color: isOpen ? FTColors.elevatedSurfaceShadow : .clear, radius: 14, x: 0, y: 12)
        }
        .overlay { border }
        .contentShape(shape)
        // Tap-to-open only while closed — open, the rows own every tap.
        .gesture(TapGesture().onEnded(open), including: isOpen ? .subviews : .all)
        .onTapOutside { if isOpen { close() } }
    }

    @ViewBuilder
    private var border: some View {
        if isOpen {
            shape.strokeBorder(FTColors.elevatedSurfaceHairline, lineWidth: 0.5)
        } else if selection == nil {
            shape.strokeBorder(FTColors.separator, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(placeholder)
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
                .padding(.horizontal, 14)
                .frame(height: 40)
            Rectangle()
                .fill(FTColors.divider)
                .frame(height: 1)
                .padding(.horizontal, 10)
        }
        .transition(.opacity)
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    ChipPickerRow(title: title(option), isSelected: option == selection) {
                        choose(option)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        // The list is cut off by the fixed box, so the indicator shows and
        // flashes on open to say there's more below.
        .scrollIndicators(.visible)
        .scrollIndicatorsFlash(onAppear: true)
        .transition(.opacity)
    }

    private func open() {
        isRaised = true
        withAnimation(.bouncy(duration: 0.45, extraBounce: 0.05)) { isOpen = true }
    }

    private func close() {
        withAnimation(.smooth(duration: 0.3)) {
            isOpen = false
        } completion: {
            if !isOpen { isRaised = false }
        }
    }

    private func choose(_ option: Option) {
        withAnimation(.smooth(duration: 0.3)) {
            selection = option == selection ? nil : option
            isOpen = false
        } completion: {
            if !isOpen { isRaised = false }
        }
    }
}

/// One option in the open list: title, plus a check when it's the selection.
private struct ChipPickerRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    public var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(isSelected ? FTFonts.subheadlineSemibold : FTFonts.subheadline)
                    .foregroundStyle(FTColors.textPrimary)
                Spacer(minLength: 8)
                if isSelected {
                    FTIcons.check
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(FTColors.greenAccent)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 36)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
private struct ChipPickerPreviewHost: View {
    @State private var primary: String? = "Chest"
    @State private var secondary: String?

    private let muscles = ["Back", "Chest", "Shoulders", "Legs", "Abs", "Triceps", "Biceps", "Full Body"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ChipPicker(
                    placeholder: "Primary Muscle",
                    options: muscles,
                    selection: $primary,
                    title: { $0 },
                )
                ChipPicker(
                    placeholder: "Secondary Muscle",
                    options: muscles,
                    selection: $secondary,
                    title: { $0 },
                )
            }
            .zIndex(1)

            RoundedRectangle(cornerRadius: 16)
                .fill(FTColors.secondary)
                .frame(height: 200)
                .overlay {
                    Text("Content below the chips")
                        .font(FTFonts.footnote)
                        .foregroundStyle(FTColors.textSecondary)
                }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(FTColors.surface)
    }
}

#Preview("Light") {
    ChipPickerPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ChipPickerPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
