import Foundation

@MainActor
final class HomeCatalogStore: ObservableObject {
    static let shared = HomeCatalogStore()

    @Published private(set) var featured: [CatalogItem] = featuredItems
    @Published private(set) var sections: [HomeCatalogSection] = HomeCatalogSection.fallbackSections
    @Published private(set) var isLoading = false

    private var hasLoadedRemoteCatalogs = false
    private var loadTask: Task<Void, Never>?

    private init() {}

    func loadIfNeeded() {
        guard !hasLoadedRemoteCatalogs, loadTask == nil else { return }
        loadTask = Task {
            await loadCatalogs()
        }
    }

    func prefetchIfNeeded() async {
        loadIfNeeded()
        await loadTask?.value
    }

    private func loadCatalogs() async {
        isLoading = true
        defer {
            isLoading = false
            loadTask = nil
        }

        for attempt in 0..<2 {
            let snapshot = await loadCatalogSnapshot()
            apply(snapshot)

            if snapshot.hasRemoteContent {
                hasLoadedRemoteCatalogs = true
                return
            }

            if snapshot.needsRemoteRefresh {
                let refreshedSnapshot = await loadCatalogSnapshot(forceRefresh: true)
                apply(refreshedSnapshot)

                if refreshedSnapshot.hasRemoteContent {
                    hasLoadedRemoteCatalogs = true
                    return
                }
            }

            if attempt == 0 {
                try? await Task.sleep(for: .milliseconds(900))
            }
        }
    }

    private func loadCatalogSnapshot(forceRefresh: Bool = false) async -> HomeCatalogSnapshot {
        async let popularMovies = loadCatalog(type: .movie, catalog: .top, fallback: movies, forceRefresh: forceRefresh)
        async let popularSeries = loadCatalog(type: .series, catalog: .top, fallback: series, forceRefresh: forceRefresh)
        async let featuredMovies = loadCatalog(type: .movie, catalog: .imdbRating, fallback: [], forceRefresh: forceRefresh)
        async let featuredSeries = loadCatalog(type: .series, catalog: .imdbRating, fallback: featuredItems, forceRefresh: forceRefresh)
        async let actionMovies = loadCatalog(type: .movie, catalog: .top, genre: "Action", fallback: movies, forceRefresh: forceRefresh)
        async let dramaSeries = loadCatalog(type: .series, catalog: .top, genre: "Drama", fallback: series, forceRefresh: forceRefresh)
        async let comedySeries = loadCatalog(type: .series, catalog: .top, genre: "Comedy", fallback: series, forceRefresh: forceRefresh)
        async let sciFiMovies = loadCatalog(type: .movie, catalog: .top, genre: "Sci-Fi", fallback: movies, forceRefresh: forceRefresh)

        return await HomeCatalogSnapshot(
            popularMovies: popularMovies,
            popularSeries: popularSeries,
            featuredMovies: featuredMovies,
            featuredSeries: featuredSeries,
            actionMovies: actionMovies,
            dramaSeries: dramaSeries,
            comedySeries: comedySeries,
            sciFiMovies: sciFiMovies
        )
    }

    private func loadCatalog(
        type: CinemetaType,
        catalog: CinemetaCatalog,
        genre: String? = nil,
        fallback: [CatalogItem],
        forceRefresh: Bool = false
    ) async -> HomeCatalogLoadResult {
        do {
            let result = try await CinemetaClient.fetchCatalogResult(
                type: type,
                catalog: catalog,
                genre: genre,
                forceRefresh: forceRefresh
            )
            return HomeCatalogLoadResult(
                items: result.items,
                didLoadRemote: !result.items.isEmpty && result.source == .remote,
                needsRemoteRefresh: result.source != .remote
            )
        } catch {
            return HomeCatalogLoadResult(items: fallback, didLoadRemote: false, needsRemoteRefresh: false)
        }
    }

    private func apply(_ snapshot: HomeCatalogSnapshot) {
        let featuredItems = [
            snapshot.featuredMovies.items,
            snapshot.featuredSeries.items,
            snapshot.popularMovies.items,
            snapshot.popularSeries.items
        ]
        .flatMap { $0 }

        featured = Array(featuredItems.prefix(6))
        sections = [
            HomeCatalogSection(title: "Popular Movies", items: snapshot.popularMovies.items),
            HomeCatalogSection(title: "Popular Series", items: snapshot.popularSeries.items),
            HomeCatalogSection(title: "Featured Movies", items: snapshot.featuredMovies.items),
            HomeCatalogSection(title: "Featured Series", items: snapshot.featuredSeries.items),
            HomeCatalogSection(title: "Action Movies", items: snapshot.actionMovies.items),
            HomeCatalogSection(title: "Drama Series", items: snapshot.dramaSeries.items),
            HomeCatalogSection(title: "Comedy Series", items: snapshot.comedySeries.items),
            HomeCatalogSection(title: "Sci-Fi Movies", items: snapshot.sciFiMovies.items)
        ]
    }
}

struct HomeCatalogSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [CatalogItem]

    static let fallbackSections: [HomeCatalogSection] = [
        HomeCatalogSection(title: "Popular Movies", items: movies),
        HomeCatalogSection(title: "Popular Series", items: series),
        HomeCatalogSection(title: "Featured", items: featuredItems),
        HomeCatalogSection(title: "Upcoming", items: upcoming)
    ]
}

private struct HomeCatalogLoadResult {
    let items: [CatalogItem]
    let didLoadRemote: Bool
    let needsRemoteRefresh: Bool
}

private struct HomeCatalogSnapshot {
    let popularMovies: HomeCatalogLoadResult
    let popularSeries: HomeCatalogLoadResult
    let featuredMovies: HomeCatalogLoadResult
    let featuredSeries: HomeCatalogLoadResult
    let actionMovies: HomeCatalogLoadResult
    let dramaSeries: HomeCatalogLoadResult
    let comedySeries: HomeCatalogLoadResult
    let sciFiMovies: HomeCatalogLoadResult

    var hasRemoteContent: Bool {
        [
            popularMovies,
            popularSeries,
            featuredMovies,
            featuredSeries,
            actionMovies,
            dramaSeries,
            comedySeries,
            sciFiMovies
        ]
        .contains { $0.didLoadRemote }
    }

    var needsRemoteRefresh: Bool {
        [
            popularMovies,
            popularSeries,
            featuredMovies,
            featuredSeries,
            actionMovies,
            dramaSeries,
            comedySeries,
            sciFiMovies
        ]
        .contains { $0.needsRemoteRefresh }
    }
}
