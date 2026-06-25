import AVKit

@MainActor
final class StreamPlaybackObserver: ObservableObject {
    @Published var errorMessage: String?
    @Published var didFinishToEnd = false

    private var statusObservation: NSKeyValueObservation?
    private var failedToPlayObserver: NSObjectProtocol?
    private var didPlayToEndObserver: NSObjectProtocol?

    func observe(playerItem: AVPlayerItem) {
        stop()
        errorMessage = nil
        didFinishToEnd = false

        statusObservation = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            Task { @MainActor in
                guard item.status == .failed else { return }
                self?.errorMessage = Self.message(from: item.error)
            }
        }

        failedToPlayObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] notification in
            let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
            Task { @MainActor in
                self?.errorMessage = Self.message(from: error)
            }
        }

        didPlayToEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.didFinishToEnd = true
            }
        }
    }

    func stop() {
        statusObservation?.invalidate()
        statusObservation = nil

        if let failedToPlayObserver {
            NotificationCenter.default.removeObserver(failedToPlayObserver)
            self.failedToPlayObserver = nil
        }

        if let didPlayToEndObserver {
            NotificationCenter.default.removeObserver(didPlayToEndObserver)
            self.didPlayToEndObserver = nil
        }
    }

    private static func message(from error: Error?) -> String {
        error?.localizedDescription ?? "The native player could not play this stream."
    }
}
