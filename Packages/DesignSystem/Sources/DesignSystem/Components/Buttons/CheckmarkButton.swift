import SwiftUI

/// A round check to mark something done — a set while working out. Not done,
/// it's a quiet gray ring around a gray check; done, both turn green. One tap
/// each way; what "done" means is the owner's.
public struct CheckmarkButton: View {
    let isChecked: Bool
    let action: () -> Void

    public init(isChecked: Bool, action: @escaping () -> Void) {
        self.isChecked = isChecked
        self.action = action
    }

    public static let diameter: CGFloat = 36

    public var body: some View {
        Button(action: action) {
            FTIcons.check
                .resizable()
                .scaledToFit()
                .frame(width: 13, height: 13)
                .foregroundStyle(isChecked ? FTColors.greenAccent : FTColors.textSecondary)
                .frame(width: Self.diameter, height: Self.diameter)
                .overlay {
                    Circle()
                        .strokeBorder(isChecked ? FTColors.greenAccent : FTColors.separator, lineWidth: 2)
                }
                .contentShape(Circle())
        }
        .buttonStyle(.press)
        .animation(.smooth(duration: 0.2), value: isChecked)
        .sensoryFeedback(.success, trigger: isChecked) { _, checked in checked }
    }
}

#if DEBUG
private struct CheckmarkButtonPreviewHost: View {
    @State private var checks = [true, true, false, false]

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                ForEach(checks.indices, id: \.self) { index in
                    CheckmarkButton(isChecked: checks[index]) { checks[index].toggle() }
                }
            }
            Text("\(checks.filter { $0 }.count) of \(checks.count) done")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.surface)
    }
}

#Preview("Light") {
    CheckmarkButtonPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    CheckmarkButtonPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
