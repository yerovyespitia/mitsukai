enum CinemetaCatalogPresets {
    static let movieFilters = ["Popular", "New", "Featured", "Action", "Adventure", "Comedy", "Drama", "Sci-Fi"]
    static let seriesFilters = ["Popular", "New", "Featured", "Action", "Drama", "Comedy", "Sci-Fi", "Reality-TV"]

    @MainActor
    static func prefetchInitialCatalogs() async {
        async let movies: Void = moviesStore.loadCatalog()
        async let series: Void = seriesStore.loadCatalog()

        _ = await (movies, series)
    }

    @MainActor
    private static var moviesStore: CinemetaCatalogStore {
        CinemetaCatalogStore.shared(
            title: "Movies",
            type: .movie,
            filters: movieFilters,
            fallbackItems: movies
        )
    }

    @MainActor
    private static var seriesStore: CinemetaCatalogStore {
        CinemetaCatalogStore.shared(
            title: "Series",
            type: .series,
            filters: seriesFilters,
            fallbackItems: series
        )
    }
}
