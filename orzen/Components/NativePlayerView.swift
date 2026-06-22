import AVKit
import SwiftUI

struct NativePlayerView: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> NativePlayerNSView {
        let view = NativePlayerNSView()
        view.player = player
        return view
    }

    func updateNSView(_ nsView: NativePlayerNSView, context: Context) {
        nsView.player = player
    }

    final class NativePlayerNSView: NSView {
        override var wantsUpdateLayer: Bool {
            true
        }

        var player: AVPlayer? {
            get {
                playerLayer.player
            }
            set {
                playerLayer.player = newValue
            }
        }

        private var playerLayer: AVPlayerLayer {
            layer as! AVPlayerLayer
        }

        override func makeBackingLayer() -> CALayer {
            let layer = AVPlayerLayer()
            layer.videoGravity = .resizeAspect
            layer.backgroundColor = NSColor.black.cgColor
            return layer
        }
    }
}
