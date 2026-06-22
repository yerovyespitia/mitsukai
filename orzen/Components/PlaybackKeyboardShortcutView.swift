import SwiftUI

struct PlaybackKeyboardShortcutView: NSViewRepresentable {
    let onEscape: () -> Void
    let onSpace: () -> Void
    let onFullscreen: () -> Void
    let onMute: () -> Void
    let onSeekBackward: () -> Void
    let onSeekForward: () -> Void

    func makeNSView(context: Context) -> KeyboardShortcutNSView {
        let view = KeyboardShortcutNSView()
        updateHandlers(on: view)

        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }

        return view
    }

    func updateNSView(_ nsView: KeyboardShortcutNSView, context: Context) {
        updateHandlers(on: nsView)

        DispatchQueue.main.async {
            nsView.window?.makeFirstResponder(nsView)
        }
    }

    private func updateHandlers(on view: KeyboardShortcutNSView) {
        view.onSpace = onSpace
        view.onEscape = onEscape
        view.onFullscreen = onFullscreen
        view.onMute = onMute
        view.onSeekBackward = onSeekBackward
        view.onSeekForward = onSeekForward
    }

    final class KeyboardShortcutNSView: NSView {
        var onEscape: (() -> Void)?
        var onSpace: (() -> Void)?
        var onFullscreen: (() -> Void)?
        var onMute: (() -> Void)?
        var onSeekBackward: (() -> Void)?
        var onSeekForward: (() -> Void)?

        override var acceptsFirstResponder: Bool {
            true
        }

        override func keyDown(with event: NSEvent) {
            if event.keyCode == 53 {
                onEscape?()
                return
            }

            switch event.charactersIgnoringModifiers?.lowercased() {
            case " ":
                onSpace?()
            case "f":
                onFullscreen?()
            case "m":
                onMute?()
            case String(UnicodeScalar(NSLeftArrowFunctionKey)!):
                onSeekBackward?()
            case String(UnicodeScalar(NSRightArrowFunctionKey)!):
                onSeekForward?()
            default:
                super.keyDown(with: event)
            }
        }
    }
}
