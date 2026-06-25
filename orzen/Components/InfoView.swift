import SwiftUI

struct InfoView: View {
    let item: CatalogItem
    @ObservedObject private var episodeWatchStore = EpisodeWatchStore.shared
    @ObservedObject private var playbackProgressStore = PlaybackProgressStore.shared
    @ObservedObject private var playbackStore = StreamPlaybackStore.shared
    @StateObject private var viewModel: InfoViewModel
    @State private var isSourcesBackHovered = false
    @Environment(\.dismiss) private var dismiss
    private let contentHorizontalPadding: CGFloat = 72

    init(item: CatalogItem) {
        self.item = item
        _viewModel = StateObject(wrappedValue: InfoViewModel(item: item))
    }

    var body: some View {
        ZStack(alignment: .top) {
            backgroundImage
                .frame(maxWidth: .infinity, maxHeight: OrzenLayout.bannerHeight)
                .clipped()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.82), Color.black.opacity(0.28), Color.black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()

            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        InfoHeroView(
                            item: item,
                            detail: viewModel.detail,
                            horizontalPadding: contentHorizontalPadding
                        )
                        detailListSection
                    }
                    .padding(.bottom, 40)
                }
                .onChange(of: viewModel.pendingEpisodeScrollID) { _, episodeID in
                    scrollToPendingEpisode(episodeID, with: scrollProxy)
                }
                .onChange(of: viewModel.selectedSeason) { _, _ in
                    scrollToCurrentWatchingEpisodeIfNeeded(with: scrollProxy)
                }
                .onChange(of: viewModel.selectedSeasonEpisodes.map(\.id)) { _, _ in
                    scrollToCurrentWatchingEpisodeIfNeeded(with: scrollProxy)
                }
                .onChange(of: viewModel.hasLoadedDetail) { _, hasLoadedDetail in
                    guard hasLoadedDetail else { return }
                    scrollToCurrentWatchingEpisode(with: scrollProxy)
                }
                .onChange(of: currentWatchingEpisodeID) { _, _ in
                    scrollToCurrentWatchingEpisode(with: scrollProxy)
                }
            }
        }
        .background(Color.black)
        .toolbarBackground(.visible, for: .windowToolbar)
        .task(id: item.id) {
            await viewModel.loadDetail()
        }
        .escapeKeyShortcut(performBackAction)
    }

    @ViewBuilder
    private var backgroundImage: some View {
        if let backgroundURL = item.backgroundURL {
            CachedRemoteImage(url: backgroundURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                OrzenArtworkPlaceholder(style: .backdrop)
            }
        } else {
            OrzenArtworkPlaceholder(style: .backdrop)
        }
    }

    @ViewBuilder
    private var detailListSection: some View {
        if item.cinemetaType == .movie {
            sourcesSection
        } else if viewModel.selectedEpisodeID != nil {
            seriesSourcesSection
        } else {
            seriesEpisodesSection
        }
    }

    @ViewBuilder
    private var seriesEpisodesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Text("Episodes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                if viewModel.isLoadingDetail {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                }
            }

            if !viewModel.detail.episodes.isEmpty {
                seasonSelector

                if viewModel.selectedSeasonEpisodes.isEmpty {
                    DetailUnavailableView(
                        systemImage: "list.bullet.rectangle",
                        title: "No episodes in Season \(viewModel.selectedSeason)",
                        message: "Cinemeta did not return episode metadata for this season."
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.selectedSeasonEpisodes) { episode in
                            Button {
                                viewModel.selectEpisode(episode)
                            } label: {
                                EpisodeRow(
                                    episode: episode,
                                    isSelected: viewModel.selectedEpisodeID == episode.id,
                                    isWatched: episodeWatchStore.isWatched(episode),
                                    isCurrent: currentWatchingEpisodeID == episode.id
                                )
                            }
                            .buttonStyle(.plain)
                            .id(episode.id)
                            .contextMenu {
                                Button {
                                    episodeWatchStore.toggleWatched(episode, in: item, episodes: viewModel.detail.episodes)
                                    viewModel.syncSeriesCollectionState()
                                } label: {
                                    Label(
                                        episodeWatchStore.isWatched(episode) ? "Remove from Watched" : "Mark as Watched",
                                        systemImage: episodeWatchStore.isWatched(episode) ? "eye.slash.fill" : "eye.fill"
                                    )
                                }
                            }
                        }
                    }
                }
            } else if let detailErrorMessage = viewModel.detailErrorMessage {
                DetailUnavailableView(
                    systemImage: "wifi.exclamationmark",
                    title: "Episode details unavailable",
                    message: detailErrorMessage
                )
            } else if !viewModel.isLoadingDetail && viewModel.hasLoadedDetail {
                DetailUnavailableView(
                    systemImage: "list.bullet.rectangle",
                    title: "No episode details",
                    message: "Cinemeta did not return episode metadata for this title."
                )
            }
        }
        .padding(.horizontal, contentHorizontalPadding)
    }

    private var seriesSourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                sourcesBackButton

                Text("Sources")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                if viewModel.isLoadingSources {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                }
            }

            sourceFilter
            sourcesList
        }
        .padding(.horizontal, contentHorizontalPadding)
    }

    private var currentWatchingEpisodeID: CatalogEpisode.ID? {
        if playbackStore.request?.item?.id == item.id {
            return playbackStore.request?.episode?.id
        }

        return playbackProgressStore.entry(for: item)?.episode?.id
    }

    private var currentWatchingEpisode: CatalogEpisode? {
        guard let currentWatchingEpisodeID else { return nil }
        return viewModel.detail.episodes.first { $0.id == currentWatchingEpisodeID }
    }

    @ViewBuilder
    private var sourcesBackButton: some View {
        Button {
            viewModel.showEpisodes()
        } label: {
            if #available(macOS 26, *) {
                sourcesBackIcon
                    .background(sourcesBackBackground)
                    .glassEffect(.regular.interactive(), in: Circle())
            } else {
                sourcesBackIcon
                    .background(sourcesBackBackground)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .onHover { hovering in
            isSourcesBackHovered = hovering
        }
        .animation(.easeInOut(duration: 0.12), value: isSourcesBackHovered)
        .help("Back to episodes")
        .accessibilityLabel("Back to episodes")
    }

    private var sourcesBackBackground: some View {
        Circle()
            .fill(Color.white.opacity(isSourcesBackHovered ? 0.16 : 0.08))
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(isSourcesBackHovered ? 0.14 : 0.06), lineWidth: 1)
            )
    }

    private var sourcesBackIcon: some View {
        Image(systemName: "chevron.left")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white.opacity(0.88))
            .frame(width: 28, height: 28)
    }

    @ViewBuilder
    private var sourcesSection: some View {
        if item.cinemetaType != nil {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Text("Sources")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if viewModel.isLoadingSources {
                        ProgressView()
                            .controlSize(.small)
                        .tint(.white)
                    }
                }

                sourceFilter
                sourcesList
            }
            .padding(.horizontal, contentHorizontalPadding)
        }
    }

    @ViewBuilder
    private var sourceFilter: some View {
        if viewModel.hasSpanishSources {
            SourceFilterPicker(selection: $viewModel.selectedSourceFilter)
        }
    }

    @ViewBuilder
    private var sourcesList: some View {
        if !viewModel.visibleSources.isEmpty {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.visibleSources) { source in
                    Button {
                        viewModel.playSource(source)
                    } label: {
                        SourceRow(source: source)
                    }
                    .buttonStyle(.plain)
                }
            }
        } else if let sourceErrorMessage = viewModel.sourceErrorMessage {
            DetailUnavailableView(
                systemImage: "wifi.exclamationmark",
                title: "Sources unavailable",
                message: sourceErrorMessage
            )
        } else if !viewModel.isLoadingSources && viewModel.hasLoadedSources {
            DetailUnavailableView(
                systemImage: "tray",
                title: "No sources found",
                message: "The enabled addons did not return sources for this title."
            )
        }
    }

    private var seasonSelector: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.availableSeasons, id: \.self) { season in
                        SeasonButton(
                            season: season,
                            isSelected: viewModel.selectedSeason == season,
                            action: {
                                withAnimation(.easeInOut(duration: 0.18)) {
                                    viewModel.selectedSeason = season
                                }
                            }
                        )
                        .id(season)
                    }
                }
            }
            .onChange(of: viewModel.selectedSeason) { _, season in
                scrollToSelectedSeasonButton(season, with: scrollProxy)
            }
            .onChange(of: viewModel.availableSeasons) { _, _ in
                scrollToSelectedSeasonButton(viewModel.selectedSeason, with: scrollProxy)
            }
            .onAppear {
                scrollToSelectedSeasonButton(viewModel.selectedSeason, with: scrollProxy)
            }
        }
    }

    private func scrollToPendingEpisode(
        _ episodeID: CatalogEpisode.ID?,
        with scrollProxy: ScrollViewProxy
    ) {
        guard let episodeID else { return }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(120))
            withAnimation(.easeInOut(duration: 0.38)) {
                scrollProxy.scrollTo(episodeID, anchor: .top)
            }
            viewModel.clearPendingEpisodeScroll()
        }
    }

    private func scrollToCurrentWatchingEpisode(with scrollProxy: ScrollViewProxy) {
        guard let currentWatchingEpisode else { return }

        Task { @MainActor in
            viewModel.selectedSeason = currentWatchingEpisode.season ?? 1
            try? await Task.sleep(for: .milliseconds(220))
            withAnimation(.easeInOut(duration: 0.38)) {
                scrollProxy.scrollTo(currentWatchingEpisode.id, anchor: .top)
            }
        }
    }

    private func scrollToCurrentWatchingEpisodeIfNeeded(with scrollProxy: ScrollViewProxy) {
        guard currentWatchingEpisode?.season == viewModel.selectedSeason else { return }
        scrollToCurrentWatchingEpisode(with: scrollProxy)
    }

    private func scrollToSelectedSeasonButton(
        _ season: Int,
        with scrollProxy: ScrollViewProxy
    ) {
        guard viewModel.availableSeasons.contains(season) else { return }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(80))
            withAnimation(.easeInOut(duration: 0.18)) {
                scrollProxy.scrollTo(season, anchor: .leading)
            }
        }
    }

    private func performBackAction() {
        if viewModel.selectedEpisodeID != nil {
            viewModel.showEpisodes()
        } else {
            dismiss()
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(item: lastWatched.first!)
    }
}
