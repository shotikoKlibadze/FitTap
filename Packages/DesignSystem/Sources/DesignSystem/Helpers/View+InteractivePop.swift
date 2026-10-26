import SwiftUI
import UIKit

public extension View {
    /// Puts swipe-from-the-left-edge-to-go-back back on a screen that hides
    /// the system back button. `AppToolbar` applies it; screens never call it
    /// directly.
    func restoresInteractivePop() -> some View {
        background(InteractivePopEnabler().frame(width: 0, height: 0))
    }
}

/// `NavigationStack` is backed by `UINavigationController`, which ties the
/// edge-swipe to its own back button: hide that button and UIKit switches the
/// swipe off. This takes over the recognizer's delegate for the one
/// navigation controller the screen sits in while the screen is on screen,
/// and hands it back to UIKit's own delegate when it leaves. Deliberately not
/// an `extension UINavigationController` — that compiles to a category that
/// changes every navigation controller in the process.
private struct InteractivePopEnabler: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UIView {
        let view = ProbeView()
        view.isUserInteractionEnabled = false
        view.onAttach = { [coordinator = context.coordinator] navigationController in
            coordinator.attach(to: navigationController)
        }
        view.onDetach = { [coordinator = context.coordinator] in
            coordinator.detach()
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private weak var navigationController: UINavigationController?
        private weak var gesture: UIGestureRecognizer?
        /// UIKit's own delegate, restored when this screen leaves. Inherited
        /// from the screen below when it already holds the recognizer.
        private(set) weak var systemDelegate: UIGestureRecognizerDelegate?
        /// From pop begin until the pop *transition* finishes — after lift,
        /// `transitionCoordinator` is often nil while the animation still runs.
        private var isPopInFlight = false
        private var didBindTransitionCompletion = false

        func attach(to navigationController: UINavigationController) {
            guard let gesture = navigationController.interactivePopGestureRecognizer else { return }
            self.navigationController = navigationController
            if let holder = gesture.delegate as? Coordinator {
                if holder !== self { systemDelegate = holder.systemDelegate }
            } else {
                systemDelegate = gesture.delegate
            }
            gesture.delegate = self
            if self.gesture !== gesture {
                self.gesture?.removeTarget(self, action: #selector(handlePop(_:)))
                gesture.addTarget(self, action: #selector(handlePop(_:)))
                self.gesture = gesture
            }
        }

        func detach() {
            guard let gesture else { return }
            gesture.removeTarget(self, action: #selector(handlePop(_:)))
            if gesture.delegate === self { gesture.delegate = systemDelegate }
            self.gesture = nil
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let navigationController else { return false }
            // Root: nothing underneath. Coordinator present or pop in flight:
            // a transition already owns the stack.
            return navigationController.viewControllers.count > 1
                && navigationController.transitionCoordinator == nil
                && !isPopInFlight
        }

        @objc private func handlePop(_ gesture: UIGestureRecognizer) {
            switch gesture.state {
            case .began:
                isPopInFlight = true
                bindTransitionCompletion()
            case .cancelled, .failed:
                clearPopInFlight()
            case .ended:
                bindTransitionCompletion()
                // UIKit sometimes never hands a coordinator; leaving the flag
                // up would block every later swipe on this screen.
                if !didBindTransitionCompletion { clearPopInFlight() }
            default:
                bindTransitionCompletion()
            }
        }

        private func bindTransitionCompletion() {
            guard !didBindTransitionCompletion,
                  let coordinator = navigationController?.transitionCoordinator
            else { return }
            didBindTransitionCompletion = true
            coordinator.animate(alongsideTransition: nil) { [weak self] _ in
                self?.clearPopInFlight()
            }
        }

        private func clearPopInFlight() {
            isPopInFlight = false
            didBindTransitionCompletion = false
        }
    }

    /// Zero-sized view that finds its navigation controller through the
    /// responder chain when it enters the window, and reports leaving it.
    private final class ProbeView: UIView {
        public var onAttach: ((UINavigationController) -> Void)?
        public var onDetach: (() -> Void)?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard window != nil else { return onDetach?() ?? () }
            guard let navigationController = enclosingNavigationController() else { return }
            onAttach?(navigationController)
        }

        private func enclosingNavigationController() -> UINavigationController? {
            var responder: UIResponder? = self
            while let current = responder {
                if let viewController = current as? UIViewController,
                   let navigationController = viewController.navigationController {
                    return navigationController
                }
                responder = current.next
            }
            return nil
        }
    }
}
