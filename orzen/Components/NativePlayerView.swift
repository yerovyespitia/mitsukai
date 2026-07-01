import AVKit
import SwiftUI

#if os(macOS)
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
#else
struct NativePlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> NativePlayerUIView {
        let view = NativePlayerUIView()
        view.player = player
        return view
    }

    func updateUIView(_ uiView: NativePlayerUIView, context: Context) {
        uiView.player = player
    }

    final class NativePlayerUIView: UIView {
        override static var layerClass: AnyClass {
            AVPlayerLayer.self
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

        override init(frame: CGRect) {
            super.init(frame: frame)
            configureLayer()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            configureLayer()
        }

        private func configureLayer() {
            playerLayer.videoGravity = .resizeAspect
            playerLayer.backgroundColor = UIColor.black.cgColor
        }
    }
}
#endif
