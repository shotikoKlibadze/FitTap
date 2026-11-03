import SwiftUI

/// A round check to mark something done — a set while working out. Open,
/// it's a quiet gray ring around a gray check; done, both turn green;
/// failed, a red ring around a red ✕.
///
/// A tap flips between open and done (and takes a failed one back to open).
/// Holding it opens a second choice: the circle morphs into a capsule with
/// a green ✓ and a red ✕, so a set can be marked failed — attempted, not
/// completed. Picking one collapses it; left alone, it collapses on its own
/// after a few seconds with nothing changed. Holding a done or failed set
/// works the same, so a wrong pick can be corrected.
///
/// The button never owns its status: it reports the status the user chose
/// through `onChange`, and the owner writes it back. The capsule draws over
/// the neighbours to the left, so the row's layout never shifts.
public struct CompletionButton: View {
    public enum Status {
        case open
        case done
        case failed
    }

    let status: Status
    let onChange: (Status) -> Void

    public init(status: Status, onChange: @escaping (Status) -> Void) {
        self.status = status
        self.onChange = onChange
    }

    public static let diameter: CGFloat = 36

    /// Each choice in the open capsule.
    private let choiceDiameter: CGFloat = 30
    private let capsulePadding: CGFloat = 3
    /// How long the capsule waits for a pick before closing by itself.
    private let autoCloseDelay: Duration = .seconds(3)

    @State private var isExpanded = false
    @State private var isPressing = false

    public var body: some View {
        // The slot in the layout is always the collapsed circle; the capsule
        // floats over it, growing leftwards from the same trailing edge.
        Color.clear
            .frame(width: Self.diameter, height: Self.diameter)
            .overlay(alignment: .trailing) {
                if isExpanded {
                    choices
                        .transition(.scale(scale: 0.5, anchor: .trailing).combined(with: .opacity))
                } else {
                    mark
                        .transition(.scale(scale: 0.5, anchor: .trailing).combined(with: .opacity))
                }
            }
            .animation(.smooth(duration: 0.25), value: isExpanded)
            .animation(.smooth(duration: 0.2), value: status)
            .onChange(of: status) { isExpanded = false }
            .task(id: isExpanded) {
                guard isExpanded else { return }
                try? await Task.sleep(for: autoCloseDelay)
                isExpanded = false
            }
            .sensoryFeedback(.success, trigger: status) { _, new in new == .done }
            .sensoryFeedback(.warning, trigger: status) { _, new in new == .failed }
            .sensoryFeedback(.impact(weight: .light), trigger: isExpanded) { _, new in new }
    }

    /// The collapsed circle: tap to flip, hold to open the choices.
    private var mark: some View {
        glyph(for: status)
            .frame(width: Self.diameter, height: Self.diameter)
            .overlay {
                Circle()
                    .strokeBorder(ringColor, lineWidth: 2)
            }
            .contentShape(Circle())
            .scaleEffect(isPressing ? 0.9 : 1)
            .animation(.smooth(duration: 0.15), value: isPressing)
            .onTapGesture { onChange(status == .open ? .done : .open) }
            .onLongPressGesture(minimumDuration: 0.35) {
                isExpanded = true
            } onPressingChanged: { pressing in
                isPressing = pressing
            }
    }

    /// The open capsule: ✓ on the left, ✕ on the right.
    private var choices: some View {
        HStack(spacing: 4) {
            choice(.done)
            choice(.failed)
        }
        .padding(capsulePadding)
        .background(Capsule().fill(FTColors.secondary))
    }

    private func choice(_ picked: Status) -> some View {
        Button {
            isExpanded = false
            onChange(picked)
        } label: {
            glyph(for: picked, onFill: true)
                .frame(width: choiceDiameter, height: choiceDiameter)
                .background(Circle().fill(fill(for: picked)))
                .overlay {
                    if picked == .failed {
                        Circle().strokeBorder(FTColors.redAccent.opacity(0.5), lineWidth: 1)
                    }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.press)
    }

    /// The check or the ✕, in the status's colour — or, on a filled choice,
    /// dark on the green so it reads.
    private func glyph(for status: Status, onFill: Bool = false) -> some View {
        Group {
            switch status {
            case .open, .done:
                FTIcons.check
                    .resizable()
                    .scaledToFit()
                    .frame(width: 13, height: 13)
            case .failed:
                FTIcons.xMark
                    .resizable()
                    .scaledToFit()
                    .frame(width: 11, height: 11)
            }
        }
        .foregroundStyle(onFill && status == .done ? FTColors.textOnAccent : color(for: status))
    }

    private var ringColor: Color {
        status == .open ? FTColors.separator : color(for: status)
    }

    private func color(for status: Status) -> Color {
        switch status {
        case .open: FTColors.textSecondary
        case .done: FTColors.greenAccent
        case .failed: FTColors.redAccent
        }
    }

    private func fill(for status: Status) -> Color {
        switch status {
        case .done: FTColors.greenAccent
        case .failed: FTColors.redAccent.opacity(0.25)
        case .open: .clear
        }
    }
}

#if DEBUG
private struct CompletionButtonPreviewHost: View {
    @State private var statuses: [CompletionButton.Status] = [.done, .failed, .open, .open]

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                ForEach(statuses.indices, id: \.self) { index in
                    CompletionButton(status: statuses[index]) { statuses[index] = $0 }
                }
            }
            Text("\(statuses.filter { $0 != .open }.count) of \(statuses.count) logged · hold one to fail it")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.surface)
    }
}

#Preview("Dark") {
    CompletionButtonPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    CompletionButtonPreviewHost()
        .preferredColorScheme(.light)
}
#endif
