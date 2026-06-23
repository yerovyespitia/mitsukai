import SwiftUI

struct StreamPlayerChrome: View {
    let title: String
    let subtitle: String
    let isPaused: Bool
    let currentTime: Double
    let duration: Double
    let volume: Double
    let isMuted: Bool
    let isFullscreen: Bool
    let audioTracks: [PlayerMediaTrack]
    let subtitleTracks: [PlayerMediaTrack]
    let onBack: () -> Void
    let onPlayPause: () -> Void
    let onSeekBackward: () -> Void
    let onSeekForward: () -> Void
    let onSeek: (Double) -> Void
    let onVolumeChange: (Double) -> Void
    let onMute: () -> Void
    let onAudioTrackSelect: (PlayerMediaTrack) -> Void
    let onSubtitleTrackSelect: (PlayerMediaTrack) -> Void
    let onFullscreen: () -> Void
    @State private var hoveredCircularButton: String?

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer(minLength: 0)
            centerPlayButton
            Spacer(minLength: 0)
            controls
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
        .padding(.bottom, 18)
        .background {
            chromeGradient
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(spacing: 14) {
            backButton

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var backButton: some View {
        let hoverID = "player-back"
        circularButton(hoverID: hoverID, help: "Back", action: onBack) {
            backIcon
        }
    }

    private var backIcon: some View {
        Image(systemName: "chevron.left")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white.opacity(0.92))
            .frame(width: 34, height: 34)
    }

    @ViewBuilder
    private var centerPlayButton: some View {
        if #available(macOS 26, *) {
            GlassEffectContainer(spacing: 34) {
                centerTransportButtons
            }
        } else {
            centerTransportButtons
        }
    }

    private var centerTransportButtons: some View {
        HStack(spacing: 34) {
            centerTransportButton(
                systemName: "5.arrow.trianglehead.counterclockwise",
                size: .small,
                help: "Rewind 5 seconds",
                action: onSeekBackward
            )

            centerTransportButton(
                systemName: isPaused ? "play.fill" : "pause.fill",
                size: .large,
                help: isPaused ? "Play" : "Pause",
                action: onPlayPause
            )

            centerTransportButton(
                systemName: "5.arrow.trianglehead.clockwise",
                size: .small,
                help: "Forward 5 seconds",
                action: onSeekForward
            )
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            PlayerFlatSlider(
                value: Binding(
                    get: { min(currentTime, max(duration, 0)) },
                    set: { onSeek($0) }
                ),
                in: 0...max(duration, 1),
                accessibilityLabel: "Playback position"
            )

            HStack(spacing: 12) {
                PlayerIconButton(
                    systemName: isPaused ? "play.fill" : "pause.fill",
                    help: isPaused ? "Play" : "Pause",
                    action: onPlayPause
                )

                PlayerIconButton(
                    systemName: isMuted || volume == 0 ? "speaker.slash.fill" : "speaker.wave.2.fill",
                    help: isMuted ? "Unmute" : "Mute",
                    action: onMute
                )

                PlayerFlatSlider(
                    value: Binding(
                        get: { displayedVolume },
                        set: { onVolumeChange($0) }
                    ),
                    in: 0...100,
                    accessibilityLabel: "Volume"
                )
                .frame(width: 92)

                Text("\(formatTime(currentTime)) / \(formatTime(duration))")
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundColor(.white.opacity(0.86))
                    .frame(minWidth: 96, alignment: .leading)

                Spacer(minLength: 0)

                PlayerTrackMenu(
                    systemName: "captions.bubble",
                    help: "Subtitles",
                    emptyTitle: "No subtitles",
                    tracks: subtitleTracks,
                    onSelect: onSubtitleTrackSelect
                )

                PlayerTrackMenu(
                    systemName: "waveform",
                    help: "Audio",
                    emptyTitle: "No audio tracks",
                    tracks: audioTracks,
                    onSelect: onAudioTrackSelect
                )

                PlayerIconButton(
                    systemName: fullscreenIconName,
                    help: "Fullscreen",
                    action: onFullscreen
                )
            }
        }
    }

    private var chromeGradient: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [.black.opacity(0.86), .black.opacity(0.48), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 180)

            Spacer()

            LinearGradient(
                colors: [.clear, .black.opacity(0.62), .black.opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)
        }
        .allowsHitTesting(false)
    }

    private var fullscreenIconName: String {
        isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right"
    }

    private var displayedVolume: Double {
        isMuted ? 0 : volume
    }

    private func centerTransportButton(
        systemName: String,
        size: CenterTransportButtonSize,
        help: String,
        action: @escaping () -> Void
    ) -> some View {
        let hoverID = "transport-\(systemName)-\(size.buttonSize)"

        return circularButton(hoverID: hoverID, help: help, action: action) {
            centerTransportIcon(systemName: systemName, size: size)
        }
    }

    @ViewBuilder
    private func circularButton<Icon: View>(
        hoverID: String,
        help: String,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) -> some View {
        if #available(macOS 26, *) {
            Button(action: action) {
                icon()
                    .background(circularButtonBackground(hoverID: hoverID))
                    .glassEffect(.regular.interactive(), in: Circle())
            }
            .buttonStyle(.plain)
            .contentShape(Circle())
            .onHover { hovering in
                hoveredCircularButton = hovering ? hoverID : nil
            }
            .animation(.easeInOut(duration: 0.12), value: hoveredCircularButton)
            .help(help)
            .accessibilityLabel(help)
        } else {
            Button(action: action) {
                icon()
                    .background(circularButtonBackground(hoverID: hoverID))
            }
            .buttonStyle(.plain)
            .contentShape(Circle())
            .onHover { hovering in
                hoveredCircularButton = hovering ? hoverID : nil
            }
            .animation(.easeInOut(duration: 0.12), value: hoveredCircularButton)
            .help(help)
            .accessibilityLabel(help)
        }
    }

    private func circularButtonBackground(hoverID: String) -> some View {
        let isHovered = hoveredCircularButton == hoverID

        return Circle()
            .fill(Color.white.opacity(isHovered ? 0.16 : 0.08))
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(isHovered ? 0.14 : 0.06), lineWidth: 1)
            )
    }

    private func centerTransportIcon(systemName: String, size: CenterTransportButtonSize) -> some View {
        Image(systemName: systemName)
            .font(.system(size: size.iconSize, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: size.buttonSize, height: size.buttonSize)
    }

    private func formatTime(_ value: Double) -> String {
        guard value.isFinite, value > 0 else { return "0:00" }

        let totalSeconds = Int(value.rounded(.down))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%d:%02d", minutes, seconds)
    }
}

private enum CenterTransportButtonSize {
    case small
    case large

    var buttonSize: CGFloat {
        switch self {
        case .small:
            54
        case .large:
            76
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .small:
            23
        case .large:
            34
        }
    }
}

private struct PlayerFlatSlider: View {
    @Binding var value: Double

    let bounds: ClosedRange<Double>
    let accessibilityLabel: String

    private let trackHeight: CGFloat = 7

    init(value: Binding<Double>, in bounds: ClosedRange<Double>, accessibilityLabel: String) {
        _value = value
        self.bounds = bounds
        self.accessibilityLabel = accessibilityLabel
    }

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let sliderProgress = progress(for: value)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.22))

                Capsule()
                    .fill(.white.opacity(0.95))
                    .frame(width: max(trackHeight, width * sliderProgress))
            }
            .frame(height: trackHeight)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        value = value(for: gesture.location.x, width: width)
                    }
            )
        }
        .frame(height: trackHeight)
        .accessibilityElement()
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .accessibilityAdjustableAction { direction in
            adjustValue(direction)
        }
    }

    private var accessibilityValue: String {
        "\(Int(progress(for: value) * 100)) percent"
    }

    private func progress(for value: Double) -> Double {
        let lower = bounds.lowerBound
        let upper = bounds.upperBound
        guard upper > lower else { return 0 }

        let clampedValue = min(max(value, lower), upper)
        return (clampedValue - lower) / (upper - lower)
    }

    private func value(for locationX: CGFloat, width: CGFloat) -> Double {
        let progress = min(max(Double(locationX / max(width, 1)), 0), 1)
        return bounds.lowerBound + ((bounds.upperBound - bounds.lowerBound) * progress)
    }

    private func adjustValue(_ direction: AccessibilityAdjustmentDirection) {
        let step = (bounds.upperBound - bounds.lowerBound) / 20

        switch direction {
        case .increment:
            value = min(value + step, bounds.upperBound)
        case .decrement:
            value = max(value - step, bounds.lowerBound)
        @unknown default:
            break
        }
    }
}

private struct PlayerIconButton: View {
    let systemName: String
    let help: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.92))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
        .help(help)
        .accessibilityLabel(help)
    }
}

private struct PlayerTrackMenu: View {
    let systemName: String
    let help: String
    let emptyTitle: String
    let tracks: [PlayerMediaTrack]
    let onSelect: (PlayerMediaTrack) -> Void

    var body: some View {
        Menu {
            if tracks.isEmpty {
                Text(emptyTitle)
            } else if tracks.contains(where: { $0.kind == .subtitle }) {
                subtitleMenuItems
            } else {
                ForEach(tracks) { track in
                    trackButton(track, title: track.title)
                }
            }
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(tracks.isEmpty ? 0.55 : 0.92))
                .frame(width: 28, height: 28)
        }
        .menuStyle(.borderlessButton)
        .buttonStyle(.plain)
        .help(helpText)
        .accessibilityLabel(helpText)
        .disabled(tracks.isEmpty)
    }

    @ViewBuilder
    private var subtitleMenuItems: some View {
        ForEach(offTracks) { track in
            trackButton(track, title: track.title)
        }

        if !originalSubtitleTracks.isEmpty {
            Section("Original") {
                ForEach(originalSubtitleTracks) { track in
                    trackButton(track, title: track.title)
                }
            }
        }

        ForEach(addonSubtitleGroups, id: \.name) { group in
            Section(group.name) {
                ForEach(group.tracks) { track in
                    trackButton(track, title: addonSubtitleTitle(for: track))
                }
            }
        }
    }

    private func trackButton(_ track: PlayerMediaTrack, title: String) -> some View {
        Button {
            onSelect(track)
        } label: {
            if track.isSelected {
                Label(title, systemImage: "checkmark")
            } else {
                Text(title)
            }
        }
    }

    private var selectedTrack: PlayerMediaTrack? {
        tracks.first(where: { $0.isSelected && !$0.isOff })
    }

    private var helpText: String {
        if let selectedTrack {
            return "\(help): \(selectedTrack.title)"
        }

        if tracks.contains(where: \.isOff) {
            return "\(help): Off"
        }

        return help
    }

    private var offTracks: [PlayerMediaTrack] {
        tracks.filter(\.isOff)
    }

    private var originalSubtitleTracks: [PlayerMediaTrack] {
        tracks.filter { !$0.isOff && addonName(for: $0) == nil }
    }

    private var addonSubtitleGroups: [(name: String, tracks: [PlayerMediaTrack])] {
        let groupedTracks = Dictionary(grouping: tracks.filter { !$0.isOff }) { track in
            addonName(for: track)
        }

        return groupedTracks.compactMap { name, tracks in
            guard let name else { return nil }
            return (name, tracks)
        }
        .sorted { $0.name < $1.name }
    }

    private func addonName(for track: PlayerMediaTrack) -> String? {
        guard track.kind == .subtitle,
              let separatorRange = track.title.range(of: ": ") else {
            return nil
        }

        let prefix = String(track.title[..<separatorRange.lowerBound])
        return prefix.isEmpty ? nil : prefix
    }

    private func addonSubtitleTitle(for track: PlayerMediaTrack) -> String {
        guard let separatorRange = track.title.range(of: ": ") else {
            return track.title
        }

        return String(track.title[separatorRange.upperBound...])
    }
}
