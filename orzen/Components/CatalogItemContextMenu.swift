import SwiftUI

struct CatalogItemContextMenuModifier: ViewModifier {
    let item: CatalogItem
    let showsDroppedAction: Bool
    @ObservedObject private var collectionStore = CollectionStore.shared
    @ObservedObject private var episodeWatchStore = EpisodeWatchStore.shared
    @State private var isShowingDetails = false
    @State private var isConfirmingMarkAllWatched = false
    @State private var pendingWatchedEpisodes: [CatalogEpisode] = []

    func body(content: Content) -> some View {
        content
            .navigationDestination(isPresented: $isShowingDetails) {
                InfoView(item: item)
            }
            .contextMenu {
                Button {
                    isShowingDetails = true
                } label: {
                    Label("View Details", systemImage: "info.circle")
                }

                Button {
                    collectionStore.togglePlanToWatch(item)
                } label: {
                    Label(listToggleTitle, systemImage: isAddedToList ? "checkmark" : "text.badge.plus")
                }

                Button {
                    collectionStore.toggleFavorite(item)
                } label: {
                    Label(favoriteToggleTitle, systemImage: isFavorite ? "heart.fill" : "heart")
                }

                Button {
                    handleWatchedAction()
                } label: {
                    Label(watchedToggleTitle, systemImage: isWatched ? "eye.slash.fill" : "eye.fill")
                }

                if showsDroppedAction {
                    Button {
                        handleDroppedAction()
                    } label: {
                        Label(droppedToggleTitle, systemImage: isDropped ? "archivebox.fill" : "archivebox")
                    }
                }
            }
            .alert("Mark all episodes as watched?", isPresented: $isConfirmingMarkAllWatched) {
                Button("Cancel", role: .cancel) {
                    pendingWatchedEpisodes = []
                }
                Button("Mark All", action: markPendingSeriesWatched)
            } message: {
                Text("This series already has watched episodes. Marking all will mark every episode as watched.")
            }
    }

    private var listToggleTitle: String {
        isAddedToList ? "Remove from Watchlist" : "Add to Watchlist"
    }

    private var favoriteToggleTitle: String {
        isFavorite ? "Remove from Favorites" : "Add to Favorites"
    }

    private var watchedToggleTitle: String {
        if item.cinemetaType == .series {
            return isWatched ? "Remove watched episodes" : "Mark all episodes as watched"
        }

        return isWatched ? "Remove from Watched" : "Add to Watched"
    }

    private var droppedToggleTitle: String {
        isDropped ? "Undrop" : "Drop"
    }

    private var isAddedToList: Bool {
        collectionStore.isInPlanToWatch(item)
    }

    private var isFavorite: Bool {
        collectionStore.isFavorite(item)
    }

    private var isWatched: Bool {
        collectionStore.isWatched(item)
    }

    private var isDropped: Bool {
        collectionStore.isDropped(item)
    }

    private func handleWatchedAction() {
        guard item.cinemetaType == .series else {
            collectionStore.toggleWatched(item)
            return
        }

        Task {
            let detail = await loadDetailForWatchedAction()
            applySeriesWatchedAction(episodes: detail.episodes)
        }
    }

    private func handleDroppedAction() {
        guard item.cinemetaType == .series, !isDropped else {
            collectionStore.toggleDropped(item)
            return
        }

        Task {
            let detail = await loadDetailForWatchedAction()
            clearWatchedEpisodesBeforeDropping(episodes: detail.episodes)
        }
    }

    private func loadDetailForWatchedAction() async -> CatalogDetail {
        if let cachedDetail = await CinemetaClient.cachedDetail(for: item) {
            return cachedDetail
        }

        do {
            return try await CinemetaClient.fetchDetail(for: item)
        } catch {
            return .empty
        }
    }

    @MainActor
    private func applySeriesWatchedAction(episodes: [CatalogEpisode]) {
        guard !episodes.isEmpty else { return }

        if episodeWatchStore.isSeriesFullyWatched(item, episodes: episodes) {
            episodeWatchStore.clearWatched(item, episodes: episodes)
            collectionStore.setWatched(item, isWatched: false)
        } else if episodeWatchStore.hasWatchedEpisodes(for: item) {
            pendingWatchedEpisodes = episodes
            isConfirmingMarkAllWatched = true
        } else {
            markSeriesWatched(episodes: episodes)
        }
    }

    private func markPendingSeriesWatched() {
        markSeriesWatched(episodes: pendingWatchedEpisodes)
        pendingWatchedEpisodes = []
    }

    private func markSeriesWatched(episodes: [CatalogEpisode]) {
        episodeWatchStore.markAllWatched(item, episodes: episodes)
        collectionStore.setWatched(item, isWatched: true)
    }

    @MainActor
    private func clearWatchedEpisodesBeforeDropping(episodes: [CatalogEpisode]) {
        if episodes.isEmpty {
            episodeWatchStore.clearWatched(item)
        } else {
            episodeWatchStore.clearWatched(item, episodes: episodes)
        }

        collectionStore.toggleDropped(item)
    }
}

extension View {
    func catalogItemContextMenu(item: CatalogItem, showsDroppedAction: Bool = false) -> some View {
        modifier(CatalogItemContextMenuModifier(item: item, showsDroppedAction: showsDroppedAction))
    }
}
