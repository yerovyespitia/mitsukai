import SwiftUI

struct InfoView: View {
    let item: CatalogItem
    @ObservedObject private var addonStore = LocalAddonStore.shared
    @ObservedObject private var playbackStore = StreamPlaybackStore.shared
    @ObservedObject private var episodeWatchStore = EpisodeWatchStore.shared
    @ObservedObject private var collectionStore = CollectionStore.shared
    @State private var detail = CatalogDetail.empty
    @State private var isLoadingDetail = false
    @State private var hasLoadedDetail = false
    @State private var selectedSeason = 1
    @State private var detailErrorMessage: String?
    @State private var selectedEpisodeID: CatalogEpisode.ID?
    @State private var sources: [StreamSource] = []
    @State private var isLoadingSources = false
    @State private var hasLoadedSources = false
    @State private var sourceErrorMessage: String?
    @State private var sourceRequestID: String?
    @State private var selectedSourceFilter = SourceFilter.all
    @State private var isSourcesBackHovered = false
    @State private var pendingEpisodeScrollID: CatalogEpisode.ID?
    @State private var hasAutoScrolledToWatchedEpisode = false
    private let contentHorizontalPadding: CGFloat = 72

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
                            detail: detail,
                            horizontalPadding: contentHorizontalPadding
                        )
                        detailListSection
                    }
                    .padding(.bottom, 40)
                }
                .onChange(of: pendingEpisodeScrollID) { _, episodeID in
                    scrollToPendingEpisode(episodeID, with: scrollProxy)
                }
            }
        }
        .background(Color.black)
        .toolbarBackground(.visible, for: .windowToolbar)
        .task(id: item.id) {
            await loadDetail()
        }
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
        } else if selectedEpisodeID != nil {
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

                if isLoadingDetail {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                }
            }

            if !detail.episodes.isEmpty {
                seasonSelector

                if selectedSeasonEpisodes.isEmpty {
                    DetailUnavailableView(
                        systemImage: "list.bullet.rectangle",
                        title: "No episodes in Season \(selectedSeason)",
                        message: "Cinemeta did not return episode metadata for this season."
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(selectedSeasonEpisodes) { episode in
                            Button {
                                selectEpisode(episode)
                            } label: {
                                EpisodeRow(
                                    episode: episode,
                                    isSelected: selectedEpisodeID == episode.id,
                                    isWatched: episodeWatchStore.isWatched(episode)
                                )
                            }
                            .buttonStyle(.plain)
                            .id(episode.id)
                            .contextMenu {
                                Button {
                                    episodeWatchStore.toggleWatched(episode, in: item, episodes: detail.episodes)
                                    syncSeriesCollectionState()
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
            } else if let detailErrorMessage {
                DetailUnavailableView(
                    systemImage: "wifi.exclamationmark",
                    title: "Episode details unavailable",
                    message: detailErrorMessage
                )
            } else if !isLoadingDetail && hasLoadedDetail {
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

                if isLoadingSources {
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

    @ViewBuilder
    private var sourcesBackButton: some View {
        Button {
            showEpisodes()
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

                    if isLoadingSources {
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
        if hasSpanishSources {
            SourceFilterPicker(selection: $selectedSourceFilter)
        }
    }

    @ViewBuilder
    private var sourcesList: some View {
        if !visibleSources.isEmpty {
            LazyVStack(spacing: 12) {
                ForEach(visibleSources) { source in
                    Button {
                        playSource(source)
                    } label: {
                        SourceRow(source: source)
                    }
                    .buttonStyle(.plain)
                }
            }
        } else if let sourceErrorMessage {
            DetailUnavailableView(
                systemImage: "wifi.exclamationmark",
                title: "Sources unavailable",
                message: sourceErrorMessage
            )
        } else if !isLoadingSources && hasLoadedSources {
            DetailUnavailableView(
                systemImage: "tray",
                title: "No sources found",
                message: "The enabled addons did not return sources for this title."
            )
        }
    }

    private var seasonSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(availableSeasons, id: \.self) { season in
                    SeasonButton(
                        season: season,
                        isSelected: selectedSeason == season,
                        action: {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                selectedSeason = season
                            }
                        }
                    )
                }
            }
        }
    }

    private var availableSeasons: [Int] {
        let seasons = Set(detail.episodes.map { $0.season ?? 1 })
        return seasons.sorted()
    }

    private var selectedSeasonEpisodes: [CatalogEpisode] {
        detail.episodes.filter { ($0.season ?? 1) == selectedSeason }
    }

    private var selectedEpisode: CatalogEpisode? {
        guard let selectedEpisodeID else { return nil }
        return detail.episodes.first { $0.id == selectedEpisodeID }
    }

    private var hasSpanishSources: Bool {
        sources.contains { $0.sourceCategory == .spanish }
    }

    private var visibleSources: [StreamSource] {
        switch selectedSourceFilter {
        case .all:
            return sources
        case .spanish:
            return sources.filter { $0.sourceCategory == .spanish }
        }
    }

    private func loadDetail() async {
        selectedSeason = 1
        pendingEpisodeScrollID = nil
        hasAutoScrolledToWatchedEpisode = false
        selectedEpisodeID = nil
        sources = []
        selectedSourceFilter = .all
        hasLoadedSources = false
        sourceErrorMessage = nil
        sourceRequestID = nil
        hasLoadedDetail = false

        guard item.cinemetaType != nil else {
            detail = .empty
            detailErrorMessage = nil
            hasLoadedDetail = true
            await loadMovieSourcesIfNeeded()
            return
        }

        if let cachedDetail = await CinemetaClient.cachedDetail(for: item) {
            setDetail(cachedDetail)
            detailErrorMessage = nil
            hasLoadedDetail = true
            await loadMovieSourcesIfNeeded()
            return
        }

        isLoadingDetail = true
        detailErrorMessage = nil

        do {
            setDetail(try await CinemetaClient.fetchDetail(for: item))
        } catch {
            detail = .empty
            detailErrorMessage = "Try again later or open another title."
        }

        hasLoadedDetail = true
        isLoadingDetail = false
        await loadMovieSourcesIfNeeded()
    }

    private func setDetail(_ loadedDetail: CatalogDetail) {
        detail = loadedDetail
        episodeWatchStore.registerSeries(item, episodes: loadedDetail.episodes)
        prepareInitialWatchedEpisodeScroll()
    }

    private func syncSeriesCollectionState() {
        guard item.cinemetaType == .series else { return }

        if episodeWatchStore.hasWatchedEpisodes(for: item) {
            collectionStore.setDropped(item, isDropped: false)
        }

        collectionStore.setWatched(
            item,
            isWatched: episodeWatchStore.isSeriesFullyWatched(item, episodes: detail.episodes)
        )
    }

    private func prepareInitialWatchedEpisodeScroll() {
        guard !hasAutoScrolledToWatchedEpisode,
              selectedEpisodeID == nil,
              !episodeWatchStore.isSeriesFullyWatched(item, episodes: detail.episodes),
              let episode = episodeWatchStore.lastWatchedEpisode(in: detail.episodes) else {
            return
        }

        selectedSeason = episode.season ?? 1
        pendingEpisodeScrollID = episode.id
        hasAutoScrolledToWatchedEpisode = true
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
            pendingEpisodeScrollID = nil
        }
    }

    private func loadMovieSourcesIfNeeded() async {
        guard item.cinemetaType == .movie else { return }
        await loadSources(for: item.id, type: .movie)
    }

    private func selectEpisode(_ episode: CatalogEpisode) {
        selectedEpisodeID = episode.id
        sources = []
        selectedSourceFilter = .all
        hasLoadedSources = false
        sourceErrorMessage = nil
        sourceRequestID = episode.id

        guard let type = item.cinemetaType else { return }

        Task {
            await loadSources(for: episode.id, type: type)
        }
    }

    private func showEpisodes() {
        selectedEpisodeID = nil
        sources = []
        selectedSourceFilter = .all
        isLoadingSources = false
        hasLoadedSources = false
        sourceErrorMessage = nil
        sourceRequestID = nil
    }

    private func playSource(_ source: StreamSource) {
        guard let type = item.cinemetaType else { return }

        playbackStore.request = StreamPlaybackRequest(
            source: source,
            title: selectedEpisode?.playbackTitle ?? item.title,
            subtitle: item.title,
            contentID: selectedEpisode?.id ?? item.id,
            contentType: type,
            item: item,
            episode: selectedEpisode
        )
    }

    private func loadSources(for id: String, type: CinemetaType) async {
        sourceRequestID = id

        guard !addonStore.streamAddons.isEmpty else {
            guard sourceRequestID == id else { return }
            sources = []
            sourceErrorMessage = "Add Torrentio from Addons to see available sources."
            hasLoadedSources = true
            return
        }

        isLoadingSources = true
        sourceErrorMessage = nil

        let streamAddons = addonStore.streamAddons
        let loadedSources = await withTaskGroup(of: [StreamSource].self) { group in
            for addon in streamAddons {
                group.addTask {
                    (try? await StremioStreamClient.fetchSources(from: addon, type: type, id: id)) ?? []
                }
            }

            var allSources: [StreamSource] = []
            for await addonSources in group {
                allSources.append(contentsOf: addonSources)
            }
            return allSources
        }

        guard sourceRequestID == id else { return }
        sources = loadedSources
        if !hasSpanishSources {
            selectedSourceFilter = .all
        }
        if loadedSources.isEmpty {
            sourceErrorMessage = nil
        }

        hasLoadedSources = true
        isLoadingSources = false
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(item: lastWatched.first!)
    }
}
