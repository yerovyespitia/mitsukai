import SwiftUI

#if os(iOS)
import UIKit

extension View {
    func interactivePopGestureEnabled() -> some View {
        background(InteractivePopGestureEnabler())
    }

    func edgeSwipeBackGesture() -> some View {
        modifier(EdgeSwipeBackModifier())
    }
}

private struct InteractivePopGestureEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.enableInteractivePopGesture()
    }

    final class Controller: UIViewController {
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            enableInteractivePopGesture()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            enableInteractivePopGesture()
        }

        func enableInteractivePopGesture() {
            guard let gesture = navigationController?.interactivePopGestureRecognizer else { return }

            gesture.isEnabled = true
            gesture.delegate = nil
        }
    }
}

private struct EdgeSwipeBackModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    private let edgeWidth: CGFloat = 28
    private let swipeThreshold: CGFloat = 72

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 24, coordinateSpace: .local)
                    .onEnded(handleSwipe)
            )
    }

    private func handleSwipe(_ value: DragGesture.Value) {
        let horizontalMovement = value.translation.width
        let verticalMovement = value.translation.height

        guard value.startLocation.x <= edgeWidth,
              horizontalMovement >= swipeThreshold,
              abs(horizontalMovement) > abs(verticalMovement) else {
            return
        }

        dismiss()
    }
}
#endif
