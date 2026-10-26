import SwiftUI

public extension View {
    /// Runs `action` when a tap lands anywhere in the window outside this view.
    /// Typical use: a text field dropping focus (and the keyboard) when the
    /// user taps elsewhere. Taps on other controls still reach them.
    func onTapOutside(perform action: @escaping () -> Void) -> some View {
        modifier(OnTapOutsideModifier(action: action))
    }
}

private struct OnTapOutsideModifier: ViewModifier {
    let action: () -> Void
    @State private var frame: CGRect = .zero

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame = $0 }
            .background {
                WindowTapObserver { location in
                    if !frame.contains(location) { action() }
                }
            }
    }
}

/// Zero-sized probe that listens for taps on the whole window without
/// consuming them, so buttons and scrolling keep working.
private struct WindowTapObserver: UIViewRepresentable {
    let onTap: (CGPoint) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onTap: onTap) }

    func makeUIView(context: Context) -> UIView {
        let view = ProbeView()
        view.isUserInteractionEnabled = false
        view.onAttach = { window in context.coordinator.attach(to: window) }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onTap = onTap
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        public var onTap: (CGPoint) -> Void
        private weak var window: UIWindow?
        private var recognizer: UITapGestureRecognizer?

        init(onTap: @escaping (CGPoint) -> Void) { self.onTap = onTap }

        func attach(to window: UIWindow) {
            guard self.window !== window else { return }
            detach()
            let tap = UITapGestureRecognizer(target: self, action: #selector(handle(_:)))
            tap.cancelsTouchesInView = false
            tap.delegate = self
            window.addGestureRecognizer(tap)
            self.window = window
            recognizer = tap
        }

        func detach() {
            if let recognizer, let window { window.removeGestureRecognizer(recognizer) }
            recognizer = nil
            window = nil
        }

        deinit { detach() }

        @objc private func handle(_ gesture: UITapGestureRecognizer) {
            onTap(gesture.location(in: nil))
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer,
        ) -> Bool { true }
    }

    private final class ProbeView: UIView {
        public var onAttach: ((UIWindow) -> Void)?
        override func didMoveToWindow() {
            super.didMoveToWindow()
            if let window { onAttach?(window) }
        }
    }
}
