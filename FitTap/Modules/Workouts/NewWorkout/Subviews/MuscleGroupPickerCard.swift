import DesignSystem
import SwiftUI

/// Primary / Secondary muscle-group selector card. Collapsed it shows the
/// selection (dashed "Choose" when empty); tapped, it morphs in place into
/// a list of muscle groups that floats over whatever sits below — the card's
/// slot in the layout never changes size, so nothing underneath moves.
struct MuscleGroupPickerCard: View {
    let label: String
    let isOptional: Bool
    @Binding var selection: MuscleGroup?
    /// Locked cards can't open or change their selection, but an open one
    /// can still be closed.
    var isLocked = false

    @State private var isOpen = false

    private let collapsedHeight: CGFloat = 78
    private let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)

    var body: some View {
        Color.clear
            .frame(height: collapsedHeight)
            .overlay(alignment: .top) { card }
            .zIndex(isOpen ? 1 : 0)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if isOpen {
                options
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(shape)
        .elevatedSurface(in: shape, dashed: selection == nil && !isOpen)
        .onTapOutside {
            guard isOpen else { return }
            withAnimation(.smooth(duration: 0.3)) { isOpen = false }
        }
    }

    private var header: some View {
        Button(action: toggle) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isOptional ? "\(label) (optional)" : label)
                        .font(FTFonts.footnote)
                        .foregroundStyle(FTColors.textSecondary)
                    if !isOpen {
                        Text(selection?.displayName ?? "Choose")
                            .font(FTFonts.headline)
                            .foregroundStyle(selection == nil ? FTColors.textSecondary : FTColors.textPrimary)
                            .transition(.opacity)
                    }
                }
                Spacer(minLength: 0)
                if isOpen {
                    Image(systemName: "chevron.up")
                        .font(FTFonts.caption2Semibold)
                        .foregroundStyle(FTColors.textSecondary)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 18)
            .frame(height: isOpen ? 44 : collapsedHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var options: some View {
        VStack(spacing: 2) {
            MuscleGroupPickerRow(title: "None", isSelected: selection == nil) {
                choose(nil)
            }
            ForEach(MuscleGroup.allCases, id: \.self) { group in
                MuscleGroupPickerRow(title: group.displayName, isSelected: group == selection) {
                    choose(group)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .disabled(isLocked)
    }

    private func toggle() {
        guard isOpen || !isLocked else { return }
        // Bouncy on the way open, smooth on the way back (no overshoot while collapsing).
        let curve: Animation = isOpen ? .smooth(duration: 0.3) : .bouncy(duration: 0.45, extraBounce: 0.05)
        withAnimation(curve) { isOpen.toggle() }
    }

    private func choose(_ group: MuscleGroup?) {
        withAnimation(.smooth(duration: 0.3)) {
            selection = group
            isOpen = false
        }
    }
}

/// One selectable row inside the open picker: title plus a radio indicator.
/// "None" is a row like any other and is selected while nothing is chosen.
private struct MuscleGroupPickerRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(isSelected ? FTFonts.bodySemibold : FTFonts.body)
                    .foregroundStyle(FTColors.textPrimary)
                Spacer(minLength: 8)
                Circle()
                    .stroke(isSelected ? FTColors.textPrimary : FTColors.separator, lineWidth: 1.5)
                    .frame(width: 20, height: 20)
                    .overlay {
                        if isSelected {
                            Circle()
                                .fill(FTColors.textPrimary)
                                .padding(5)
                        }
                    }
            }
            .padding(.horizontal, 12)
            .frame(height: 38)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
private struct MuscleGroupPickerCardPreviewHost: View {
    @State private var primary: MuscleGroup?
    @State private var secondary: MuscleGroup?

    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 10) {
                MuscleGroupPickerCard(label: "Primary", isOptional: false, selection: $primary)
                MuscleGroupPickerCard(label: "Secondary", isOptional: true, selection: $secondary)
            }
            .padding()
        }
        .background(FTColors.background)
    }
}
#Preview("Light") {
    MuscleGroupPickerCardPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    MuscleGroupPickerCardPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
