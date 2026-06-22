import AVKit
import SwiftUI

struct StreamPlayerView: View {
    let request: StreamPlaybackRequest
    let onBack: () -> Void

    @ObservedObject private var addonStore = LocalAddonStore.shared
    @ObservedObject private var subtitlePreferences = SubtitlePreferencesStore.shared
    @ObservedObject private var progressStore = PlaybackProgressStore.shared
    @ObservedObject private var collectionStore = CollectionStore.shared
    @ObservedObject private var episodeWatchStore = EpisodeWatchStore.shared
    @State private var player: AVPlayer?
    @State private var nativeTime: Double = 0
    @State private var nativeDuration: Double = 0
    @State private var nativeIsPaused = false
    @State private var nativeVolume: Double = 100
    @State private var nativeIsMuted = false
    @State private var nativeAudioTracks: [PlayerMediaTrack] = []
    @State private var nativeSubtitleTracks: [PlayerMediaTrack] = []
    @State private var externalSubtitleTracks: [ExternalSubtitleTrack] = []
    @State private var nativeTimeObserver: Any?
    @State private var isFullscreen = false
    @State private var isClosing = false
    @State private var shouldBackAfterFullscreenExit = false
    @State private var activePlaybackEngine: StreamPlaybackEngine?
    @State private var pendingResumePosition: Double?
    @State private var pendingTrackSelections: PlaybackTrackSelections?
    @State private var hasAppliedSavedProgress = false
    @State private var appliedSavedAudioTrackID: String?
    @State private var appliedSavedSubtitleTrackID: String?
    @State private var lastSavedProgressPosition: Double = 0
    @StateObject private var playbackObserver = StreamPlaybackObserver()
    @StateObject private var mpvController = MPVPlaybackController()
    @StateObject private var chromeVisibility = StreamPlayerChromeVisibilityController()

    init(request: StreamPlaybackRequest, onBack: @escaping () -> Void) {
        self.request = request
        self.onBack = onBack
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            playerSurface
            playerChrome
            startingOverlay
            errorOverlay
            keyboardShortcuts
        }
        .background(Color.black)
        .contentShape(Rectangle())
        .onContinuousHover { phase in
            guard case .active = phase else { return }
            chromeVisibility.reveal()
            scheduleChromeHideIfNeeded()
        }
        .onAppear {
            pendingResumePosition = progressStore.resumePosition(for: request)
            pendingTrackSelections = progressStore.trackSelections(for: request)
            progressStore.beginPlayback(for: request)
            startPlaybackIfPossible()
            refreshFullscreenState()
            scheduleChromeHideIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didEnterFullScreenNotification)) { _ in
            refreshFullscreenState()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didExitFullScreenNotification)) { _ in
            refreshFullscreenState()
            completePendingBackAfterFullscreenExit()
        }
        .task(id: request.id) {
            await loadExternalSubtitles()
        }
        .onReceive(mpvController.$errorMessage) { errorMessage in
            guard errorMessage != nil else { return }
            chromeVisibility.keepVisible()
            startNativeFallbackIfPossible()
        }
        .onChange(of: isPaused) { _, isPaused in
            if isPaused {
                chromeVisibility.keepVisible()
            } else {
                scheduleChromeHideIfNeeded()
            }
        }
        .onChange(of: playbackErrorMessage) { _, errorMessage in
            if errorMessage == nil {
                scheduleChromeHideIfNeeded()
            } else {
                chromeVisibility.keepVisible()
            }
        }
        .onChange(of: duration) { _, _ in
            applySavedProgressIfPossible()
        }
        .onChange(of: audioTracks) { _, _ in
            applySavedTrackSelectionsIfPossible()
        }
        .onChange(of: subtitleTracks) { _, _ in
            applySavedTrackSelectionsIfPossible()
        }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { _ in
            saveCurrentProgress()
        }
        .onDisappear {
            saveCurrentProgress(force: true)
            chromeVisibility.cancelAutoHide()
            player?.pause()
            removeNativeTimeObserver()
            playbackObserver.stop()
            mpvController.stop()
        }
    }

    @ViewBuilder
    private var playerSurface: some View {
        if activePlaybackEngine == .mpv, let playbackURL = request.source.playbackURL {
            MPVPlayerView(
                url: playbackURL,
                externalSubtitles: externalSubtitleTracks,
                controller: mpvController
            )
                .background(Color.black)
                .ignoresSafeArea()
        } else if activePlaybackEngine == .native, let player {
            NativePlayerView(player: player)
                .background(Color.black)
                .ignoresSafeArea()
        } else {
            Color.black.ignoresSafeArea()
        }
    }

    private var playerChrome: some View {
        StreamPlayerChrome(
            title: request.title,
            subtitle: request.subtitle,
            isPaused: isPaused,
            currentTime: currentTime,
            duration: duration,
            volume: volume,
            isMuted: isMuted,
            isFullscreen: isFullscreen,
            audioTracks: audioTracks,
            subtitleTracks: subtitleTracks,
            onBack: handleBack,
            onPlayPause: togglePlayPause,
            onSeekBackward: {
                seek(by: -5)
            },
            onSeekForward: {
                seek(by: 5)
            },
            onSeek: seek(to:),
            onVolumeChange: setVolume(_:),
            onMute: toggleMute,
            onAudioTrackSelect: selectAudioTrack(_:),
            onSubtitleTrackSelect: selectSubtitleTrack(_:),
            onFullscreen: toggleFullscreen
        )
        .opacity(isChromePresented ? 1 : 0)
        .allowsHitTesting(isChromePresented)
        .animation(.easeInOut(duration: 0.24), value: isChromePresented)
    }

    @ViewBuilder
    private var startingOverlay: some View {
        if activePlaybackEngine == .mpv, mpvController.isStarting {
            ProgressView()
                .controlSize(.large)
                .tint(.white)
                .padding(24)
                .background(Color.black.opacity(0.42), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    @ViewBuilder
    private var errorOverlay: some View {
        if let errorMessage = playbackErrorMessage {
            DetailUnavailableView(
                systemImage: "exclamationmark.triangle",
                title: "Playback failed",
                message: errorMessage
            )
            .padding(24)
        }
    }

    private var keyboardShortcuts: some View {
        StreamPlayerKeyboardControls(
            onEscape: handleEscape,
            onBack: handleBack,
            onPlayPause: togglePlayPause,
            onFullscreen: toggleFullscreen,
            onMute: toggleMute,
            onSeekBackward: {
                seek(by: -5)
            },
            onSeekForward: {
                seek(by: 5)
            }
        )
    }

    private var isPaused: Bool {
        activePlaybackEngine == .mpv ? mpvController.isPaused : nativeIsPaused
    }

    private var currentTime: Double {
        activePlaybackEngine == .mpv ? mpvController.currentTime : nativeTime
    }

    private var duration: Double {
        activePlaybackEngine == .mpv ? mpvController.duration : nativeDuration
    }

    private var volume: Double {
        activePlaybackEngine == .mpv ? mpvController.volume : nativeVolume
    }

    private var isMuted: Bool {
        activePlaybackEngine == .mpv ? mpvController.isMuted : nativeIsMuted
    }

    private var audioTracks: [PlayerMediaTrack] {
        activePlaybackEngine == .mpv ? mpvController.audioTracks : nativeAudioTracks
    }

    private var subtitleTracks: [PlayerMediaTrack] {
        activePlaybackEngine == .mpv ? mpvController.subtitleTracks : nativeSubtitleTracks
    }

    private var playbackErrorMessage: String? {
        switch activePlaybackEngine {
        case .mpv:
            mpvController.errorMessage
        case .native:
            playbackObserver.errorMessage
        case nil:
            playbackObserver.errorMessage ?? mpvController.errorMessage
        }
    }

    private var isChromePresented: Bool {
        chromeVisibility.isVisible || isPaused || playbackErrorMessage != nil
    }

    private var shouldAutoHideChrome: Bool {
        !isPaused && playbackErrorMessage == nil
    }

    private var currentTrackSelections: PlaybackTrackSelections {
        PlaybackTrackSelections(
            audio: selectedTrackChoice(from: audioTracks, kind: .audio),
            subtitle: selectedTrackChoice(from: subtitleTracks, kind: .subtitle)
        )
    }

    private func scheduleChromeHideIfNeeded() {
        chromeVisibility.scheduleAutoHide(isAllowed: shouldAutoHideChrome)
    }

    private func performPlayerAction(_ action: () -> Void) {
        guard !isClosing else { return }
        chromeVisibility.reveal()
        action()
        scheduleChromeHideIfNeeded()
    }

    private func handleBack() {
        guard !isClosing else { return }
        if exitFullscreenIfNeeded() {
            shouldBackAfterFullscreenExit = true
            return
        }

        closePlayer()
    }

    private func handleEscape() {
        guard !isClosing else { return }
        guard !exitFullscreenIfNeeded() else { return }

        closePlayer()
    }

    private func completePendingBackAfterFullscreenExit() {
        guard shouldBackAfterFullscreenExit else { return }
        shouldBackAfterFullscreenExit = false
        closePlayer()
    }

    private func closePlayer() {
        guard !isClosing else { return }
        isClosing = true
        saveCurrentProgress(force: true)
        chromeVisibility.cancelAutoHide()
        player?.pause()
        mpvController.pause()
        onBack()
    }

    private func startPlaybackIfPossible() {
        guard player == nil else { return }

        if let nativePlaybackError = request.source.nativePlaybackError {
            playbackObserver.errorMessage = nativePlaybackError
            return
        }

        guard let playbackURL = request.source.playbackURL else {
            playbackObserver.errorMessage = "This source does not expose a direct video URL. The native player can only open direct HTTP or HTTPS video streams returned by the addon."
            return
        }

        guard request.source.preferredPlaybackEngine == .native else {
            activePlaybackEngine = .mpv
            playbackObserver.stop()
            playbackObserver.errorMessage = nil
            return
        }

        startNativePlayback(with: playbackURL)
    }

    private func startNativeFallbackIfPossible() {
        guard activePlaybackEngine == .mpv,
              let playbackURL = request.source.playbackURL,
              player == nil else { return }

        mpvController.clearError()
        startNativePlayback(with: playbackURL)
    }

    private func startNativePlayback(with playbackURL: URL) {
        let item = AVPlayerItem(url: playbackURL)
        let player = AVPlayer(playerItem: item)
        activePlaybackEngine = .native
        self.player = player
        nativeIsPaused = false
        nativeVolume = Double(player.volume * 100)
        nativeIsMuted = player.isMuted
        playbackObserver.observe(playerItem: item)
        installNativeTimeObserver(player)
        refreshNativeMediaTracks()
        player.play()
    }

    private func applySavedProgressIfPossible() {
        guard !hasAppliedSavedProgress,
              let pendingResumePosition,
              activePlaybackEngine != nil,
              duration > 0,
              pendingResumePosition < max(duration - 5, 0) else {
            return
        }

        hasAppliedSavedProgress = true
        seek(to: pendingResumePosition)
    }

    private func saveCurrentProgress(force: Bool = false) {
        guard activePlaybackEngine != nil,
              playbackErrorMessage == nil,
              currentTime.isFinite,
              duration.isFinite else {
            return
        }

        if progressStore.isComplete(position: currentTime, duration: duration, contentType: request.contentType) {
            completeCurrentContent()
            return
        }

        guard force || abs(currentTime - lastSavedProgressPosition) >= 1 else { return }

        progressStore.saveProgress(
            for: request,
            position: currentTime,
            duration: duration,
            trackSelections: currentTrackSelections,
            force: force
        )
        lastSavedProgressPosition = currentTime
    }

    private func completeCurrentContent() {
        guard let item = request.item else {
            progressStore.clearProgress(contentID: request.contentID, contentType: request.contentType)
            return
        }

        switch request.contentType {
        case .movie:
            collectionStore.setWatched(item, isWatched: true)
        case .series:
            if let episode = request.episode {
                episodeWatchStore.markWatched(episode, in: item)
            }
            collectionStore.setDropped(item, isDropped: false)
            collectionStore.setWatched(item, isWatched: episodeWatchStore.isStoredSeriesFullyWatched(item))
        }

        progressStore.clearProgress(contentID: request.contentID, contentType: request.contentType)
    }

    private func loadExternalSubtitles() async {
        guard !addonStore.subtitleAddons.isEmpty else {
            externalSubtitleTracks = []
            return
        }

        let subtitleAddons = addonStore.subtitleAddons
        let allowedLanguageCodes = subtitlePreferences.selectedLanguageCodes
        let loadedSubtitles = await withTaskGroup(of: [ExternalSubtitleTrack].self) { group in
            for addon in subtitleAddons {
                group.addTask {
                    (try? await StremioSubtitleClient.fetchSubtitles(
                        from: addon,
                        type: request.contentType,
                        id: request.contentID,
                        allowedLanguageCodes: allowedLanguageCodes
                    )) ?? []
                }
            }

            var allSubtitles: [ExternalSubtitleTrack] = []
            for await addonSubtitles in group {
                allSubtitles.append(contentsOf: addonSubtitles)
            }
            return allSubtitles
        }

        externalSubtitleTracks = loadedSubtitles
    }

    private func togglePlayPause() {
        performPlayerAction {
            switch activePlaybackEngine {
            case .mpv:
                mpvController.togglePlayPause()
            case .native:
                guard let player else { return }
                if player.timeControlStatus == .playing {
                    player.pause()
                    nativeIsPaused = true
                } else {
                    player.play()
                    nativeIsPaused = false
                }
            case nil:
                break
            }
        }
    }

    private func seek(to time: Double) {
        performPlayerAction {
            switch activePlaybackEngine {
            case .mpv:
                mpvController.seek(to: time)
            case .native:
                let target = CMTime(seconds: time, preferredTimescale: 600)
                player?.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero)
                nativeTime = time
            case nil:
                break
            }
        }
    }

    private func seek(by offset: Double) {
        performPlayerAction {
            switch activePlaybackEngine {
            case .mpv:
                mpvController.seek(by: offset)
            case .native:
                let targetTime = min(max(nativeTime + offset, 0), max(nativeDuration, 0))
                seek(to: targetTime)
            case nil:
                break
            }
        }
    }

    private func setVolume(_ value: Double) {
        performPlayerAction {
            let clampedValue = min(max(value, 0), 100)

            switch activePlaybackEngine {
            case .mpv:
                mpvController.setVolume(clampedValue)
            case .native:
                player?.volume = Float(clampedValue / 100)
                player?.isMuted = clampedValue == 0
                nativeVolume = clampedValue
                nativeIsMuted = player?.isMuted ?? nativeIsMuted
            case nil:
                break
            }
        }
    }

    private func toggleMute() {
        performPlayerAction {
            switch activePlaybackEngine {
            case .mpv:
                mpvController.toggleMute()
            case .native:
                guard let player else { return }
                player.isMuted.toggle()
                nativeIsMuted = player.isMuted
            case nil:
                break
            }
        }
    }

    private func selectAudioTrack(_ track: PlayerMediaTrack) {
        performPlayerAction {
            switch activePlaybackEngine {
            case .mpv:
                mpvController.selectAudioTrack(track)
            case .native:
                selectNativeTrack(track, characteristic: .audible)
            case nil:
                break
            }

            saveCurrentProgress(force: true)
        }
    }

    private func selectSubtitleTrack(_ track: PlayerMediaTrack) {
        performPlayerAction {
            switch activePlaybackEngine {
            case .mpv:
                mpvController.selectSubtitleTrack(track)
            case .native:
                selectNativeTrack(track, characteristic: .legible)
            case nil:
                break
            }

            saveCurrentProgress(force: true)
        }
    }

    private func toggleFullscreen() {
        performPlayerAction {
            NSApp.keyWindow?.toggleFullScreen(nil)
        }
    }

    private func exitFullscreenIfNeeded() -> Bool {
        guard let window = NSApp.keyWindow,
              window.styleMask.contains(.fullScreen) else { return false }

        chromeVisibility.reveal()
        window.toggleFullScreen(nil)
        return true
    }

    private func refreshFullscreenState() {
        isFullscreen = NSApp.keyWindow?.styleMask.contains(.fullScreen) == true
    }

    private func installNativeTimeObserver(_ player: AVPlayer) {
        removeNativeTimeObserver()
        nativeTimeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.4, preferredTimescale: 600),
            queue: .main
        ) { [weak player] time in
            Task { @MainActor in
                nativeTime = time.seconds.isFinite ? time.seconds : 0
                let duration = player?.currentItem?.duration.seconds ?? 0
                nativeDuration = duration.isFinite ? duration : 0
                nativeIsPaused = player?.timeControlStatus != .playing
                nativeVolume = Double((player?.volume ?? 1) * 100)
                nativeIsMuted = player?.isMuted ?? false
                refreshNativeMediaTracks()
            }
        }
    }

    private func removeNativeTimeObserver() {
        if let nativeTimeObserver {
            player?.removeTimeObserver(nativeTimeObserver)
            self.nativeTimeObserver = nil
        }
    }

    private func refreshNativeMediaTracks() {
        guard activePlaybackEngine == .native else { return }
        nativeAudioTracks = NativePlayerTrackResolver.tracks(
            in: player?.currentItem,
            for: .audible,
            kind: .audio,
            includesOffOption: false
        )
        nativeSubtitleTracks = NativePlayerTrackResolver.tracks(
            in: player?.currentItem,
            for: .legible,
            kind: .subtitle,
            includesOffOption: true
        )
    }

    private func selectNativeTrack(_ track: PlayerMediaTrack, characteristic: AVMediaCharacteristic) {
        NativePlayerTrackResolver.select(track, in: player?.currentItem, for: characteristic)
        refreshNativeMediaTracks()
    }

    private func applySavedTrackSelectionsIfPossible() {
        guard let pendingTrackSelections, activePlaybackEngine != nil else { return }

        if let audioChoice = pendingTrackSelections.audio,
           appliedSavedAudioTrackID != audioChoice.id,
           let audioTrack = matchingTrack(for: audioChoice, in: audioTracks) {
            selectStoredTrack(audioTrack)
            appliedSavedAudioTrackID = audioChoice.id
        }

        if let subtitleChoice = pendingTrackSelections.subtitle,
           appliedSavedSubtitleTrackID != subtitleChoice.id,
           let subtitleTrack = matchingTrack(for: subtitleChoice, in: subtitleTracks) {
            selectStoredTrack(subtitleTrack)
            appliedSavedSubtitleTrackID = subtitleChoice.id
        }
    }

    private func selectStoredTrack(_ track: PlayerMediaTrack) {
        switch activePlaybackEngine {
        case .mpv:
            if track.kind == .audio {
                mpvController.selectAudioTrack(track)
            } else {
                mpvController.selectSubtitleTrack(track)
            }
        case .native:
            selectNativeTrack(track, characteristic: track.kind == .audio ? .audible : .legible)
        case nil:
            break
        }
    }

    private func matchingTrack(for choice: PlaybackTrackChoice, in tracks: [PlayerMediaTrack]) -> PlayerMediaTrack? {
        tracks.first { $0.id == choice.id }
            ?? tracks.first {
                $0.isOff == choice.isOff
                    && $0.language == choice.language
                    && $0.title == choice.title
            }
    }

    private func selectedTrackChoice(from tracks: [PlayerMediaTrack], kind: PlayerMediaTrack.Kind) -> PlaybackTrackChoice? {
        guard let track = tracks.first(where: { $0.kind == kind && $0.isSelected }) else { return nil }

        return PlaybackTrackChoice(
            id: track.id,
            title: track.title,
            language: track.language,
            isOff: track.isOff
        )
    }
}
