import SwiftUI

struct HomeView: View {
    @ObservedObject private var catalogStore = HomeCatalogStore.shared
    @ObservedObject private var playbackStore = StreamPlaybackStore.shared
    @ObservedObject private var progressStore = PlaybackProgressStore.shared
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
                                .padding(.leading, OrzenLayout.contentLeadingInset)
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
        }
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
            let sources = (try? await StremioStreamClient.fetchSources(
                from: addon,
                type: entry.contentType,
                id: entry.contentID
            )) ?? []

            if let refreshedSource = matchingSource(for: entry.source, in: sources) {
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

        return storedRequest
    }

    private func matchingSource(for storedSource: StreamSource, in sources: [StreamSource]) -> StreamSource? {
        sources.first { $0.id == storedSource.id }
            ?? sources.first { $0.playbackURL == storedSource.playbackURL }
            ?? sources.first { $0.title == storedSource.title }
            ?? sources.first
    }
}
