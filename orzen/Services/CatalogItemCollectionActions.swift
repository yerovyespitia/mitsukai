import Foundation

enum CatalogItemCollectionWatchedResult {
    case none
    case confirmMarkAll([CatalogEpisode])
}

@MainActor
struct CatalogItemCollectionActions {
    let item: CatalogItem
    let episodes: [CatalogEpisode]

    private let collectionStore: CollectionStore
    private let episodeWatchStore: EpisodeWatchStore

    init(item: CatalogItem, episodes: [CatalogEpisode] = []) {
        self.item = item
        self.episodes = episodes
        self.collectionStore = .shared
        self.episodeWatchStore = .shared
    }

    var listToggleTitle: String {
        isAddedToList ? "Remove from Watchlist" : "Add to Watchlist"
    }

    var favoriteToggleTitle: String {
        isFavorite ? "Remove from Favorites" : "Add to Favorites"
    }

    var watchedToggleTitle: String {
        if item.cinemetaType == .series {
            return isWatched ? "Remove watched episodes" : "Mark all episodes as watched"
        }

        return isWatched ? "Remove from Watched" : "Add to Watched"
    }

    var droppedToggleTitle: String {
        isDropped ? "Undrop" : "Drop"
    }

    var isAddedToList: Bool {
        collectionStore.isInPlanToWatch(item)
    }

    var isFavorite: Bool {
        collectionStore.isFavorite(item)
    }

    var isWatched: Bool {
        guard item.cinemetaType == .series, !episodes.isEmpty else {
            return collectionStore.isWatched(item)
        }

        return episodeWatchStore.isSeriesFullyWatched(item, episodes: episodes)
    }

    var isDropped: Bool {
        collectionStore.isDropped(item)
    }

    func togglePlanToWatch() {
        collectionStore.togglePlanToWatch(item)
    }

    func toggleFavorite() {
        collectionStore.toggleFavorite(item)
    }

    func applyWatchedAction() -> CatalogItemCollectionWatchedResult {
        guard item.cinemetaType == .series else {
            collectionStore.toggleWatched(item)
            return .none
        }

        guard !episodes.isEmpty else { return .none }

        if episodeWatchStore.isSeriesFullyWatched(item, episodes: episodes) {
            episodeWatchStore.clearWatched(item, episodes: episodes)
            collectionStore.setWatched(item, isWatched: false)
            return .none
        }

        if episodeWatchStore.hasWatchedEpisodes(for: item) {
            return .confirmMarkAll(episodes)
        }

        markSeriesWatched(episodes: episodes)
        return .none
    }

    func markSeriesWatched(episodes: [CatalogEpisode]) {
        episodeWatchStore.markAllWatched(item, episodes: episodes)
        collectionStore.setWatched(item, isWatched: true)
    }

    func applyDroppedAction() {
        guard item.cinemetaType == .series, !isDropped else {
            collectionStore.toggleDropped(item)
            return
        }

        if episodes.isEmpty {
            episodeWatchStore.clearWatched(item)
        } else {
            episodeWatchStore.clearWatched(item, episodes: episodes)
        }

        collectionStore.toggleDropped(item)
    }
}
