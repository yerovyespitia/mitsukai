import Combine
import Foundation

@MainActor
final class MPVPlaybackController: ObservableObject {
    @Published var errorMessage: String?
    @Published var isStarting = false
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var volume: Double = 100
    @Published var isMuted = false
    @Published var audioTracks: [PlayerMediaTrack] = []
    @Published var subtitleTracks: [PlayerMediaTrack] = []

    private weak var playerView: MPVOpenGLPlayerView?

    func attach(_ playerView: MPVOpenGLPlayerView) {
        self.playerView = playerView
    }

    func detach(_ playerView: MPVOpenGLPlayerView) {
        guard self.playerView === playerView else { return }
        self.playerView = nil
    }

    func setError(_ message: String) {
        errorMessage = message
        isStarting = false
        isRunning = false
    }

    func clearError() {
        errorMessage = nil
    }

    func markStarting() {
        errorMessage = nil
        isStarting = true
        isRunning = false
    }

    func markRunning() {
        isStarting = false
        isRunning = true
        isPaused = false
    }

    func stop() {
        isStarting = false
        isRunning = false
        isPaused = false
        currentTime = 0
        duration = 0
    }

    func togglePlayPause() {
        playerView?.togglePlayPause()
    }

    func pause() {
        playerView?.pause()
    }

    func seek(to time: Double) {
        playerView?.seek(to: time)
    }

    func seek(by offset: Double) {
        playerView?.seek(by: offset)
    }

    func setVolume(_ value: Double) {
        playerView?.setVolume(value)
    }

    func toggleMute() {
        playerView?.toggleMute()
    }

    func selectAudioTrack(_ track: PlayerMediaTrack) {
        playerView?.selectAudioTrack(track)
    }

    func selectSubtitleTrack(_ track: PlayerMediaTrack) {
        playerView?.selectSubtitleTrack(track)
    }

    func refreshPlaybackState() {
        playerView?.refreshPlaybackState()
    }
}
