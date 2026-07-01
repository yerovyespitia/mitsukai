import SwiftUI

struct HomeView: View {
    @ObservedObject private var catalogStore = HomeCatalogStore.shared
    @ObservedObject private var playbackStore = StreamPlaybackStore.shared
    @ObservedObject private var progressStore = PlaybackProgressStore.shared
    @ObservedObject private var collectionStore = CollectionStore.shared
    @ObservedObject private var addonStore = LocalAddonStore.shared

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        FeaturedCarousel(items: catalogStore.featured)

                        if catalogStore.isLoading {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                                .padding(.leading, OrzenLayout.current.contentLeadingInset)
                                .padding(.bottom, 12)
                        }

                        if !progressStore.watchingItems.isEmpty {
                            CatalogSectionView(
                                title: "Watching",
                                items: progressStore.watchingItems,
                                cardStyle: .watching,
                                showsDroppedContextAction: true,
                                onItemSelected: playSavedProgress
                            )
                        }

                        if !collectionStore.planToWatchItems.isEmpty {
                            CatalogSectionView(
                                title: "Watchlist",
                                items: collectionStore.planToWatchItems
                            )
                        }

                        ForEach(catalogStore.sections) { section in
                            CatalogSectionView(
                                title: section.title,
                                items: section.items
                            )
                        }
                    }
                    .frame(width: geometry.size.width, alignment: .leading)
                }
                .ignoresSafeArea(.container, edges: .top)
            }
            .ignoresSafeArea(.container, edges: .top)
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .task {
            catalogStore.loadIfNeeded()
        }
    }

    private func playSavedProgress(_ item: CatalogItem) {
        guard let entry = progressStore.entry(for: item) else { return }

        Task {
            playbackStore.request = await refreshedPlaybackRequest(for: entry)
        }
    }

    private func refreshedPlaybackRequest(for entry: PlaybackProgressEntry) async -> StreamPlaybackRequest {
        let storedRequest = entry.playbackRequest
        let matchingAddons = addonStore.streamAddons.filter {
            $0.name == entry.source.addonName && $0.sourceCategory == entry.source.sourceCategory
        }

        for addon in matchingAddons {
            let sources = await StreamSourceResolver.fetchAllSources(
                from: [addon],
                type: entry.contentType,
                id: entry.contentID
            )

            if let refreshedSource = StreamSourceResolver.matchingSource(for: entry.source, in: sources) {
                return StreamPlaybackRequest(
                    source: refreshedSource,
                    title: storedRequest.title,
                    subtitle: storedRequest.subtitle,
                    contentID: storedRequest.contentID,
                    contentType: storedRequest.contentType,
                    item: storedRequest.item,
                    episode: storedRequest.episode,
                    initialTrackSelections: storedRequest.initialTrackSelections
                )
            }
        }

        if entry.contentType == .series,
           let refreshedSource = await StreamSourceResolver.firstSource(
            from: addonStore.streamAddons,
            type: .series,
            id: entry.contentID
           ) {
            return StreamPlaybackRequest(
                source: refreshedSource,
                title: storedRequest.title,
                subtitle: storedRequest.subtitle,
                contentID: storedRequest.contentID,
                contentType: storedRequest.contentType,
                item: storedRequest.item,
                episode: storedRequest.episode,
                initialTrackSelections: storedRequest.initialTrackSelections
            )
        }

        return storedRequest
    }
}
