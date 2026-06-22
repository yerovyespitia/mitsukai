import Foundation

@MainActor
final class CinemetaCatalogStore: ObservableObject {
    private static var stores: [CatalogStoreKey: CinemetaCatalogStore] = [:]

    static func shared(
        title: String,
        type: CinemetaType,
        filters: [String],
        fallbackItems: [CatalogItem]
    ) -> CinemetaCatalogStore {
        let key = CatalogStoreKey(title: title, type: type)

        if let store = stores[key] {
            return store
        }

        let store = CinemetaCatalogStore(
            title: title,
            type: type,
            filters: filters,
            fallbackItems: fallbackItems
        )
        stores[key] = store
        return store
    }

    @Published var selectedFilter: String
    @Published private(set) var itemsByFilter: [String: [CatalogItem]] = [:]
    @Published private(set) var loadingFilters: Set<String> = []
    @Published private(set) var errorMessagesByFilter: [String: String] = [:]

    private let title: String
    private let type: CinemetaType
    private let filters: [String]
    private let fallbackItems: [CatalogItem]
    private var loadTasks: [String: Task<Void, Never>] = [:]

    var items: [CatalogItem] {
        itemsByFilter[selectedFilter] ?? []
    }

    var isLoading: Bool {
        loadingFilters.contains(selectedFilter)
    }

    var errorMessage: String? {
        errorMessagesByFilter[selectedFilter]
    }

    private init(title: String, type: CinemetaType, filters: [String], fallbackItems: [CatalogItem]) {
        self.title = title
        self.type = type
        self.filters = filters
        self.fallbackItems = fallbackItems
        self.selectedFilter = filters.first ?? "Popular"
    }

    func loadCatalog(forceRefresh: Bool = false) async {
        let filter = selectedFilter

        guard filters.contains(filter) else { return }
        guard forceRefresh || itemsByFilter[filter] == nil else { return }
        guard loadTasks[filter] == nil else { return }

        loadingFilters.insert(filter)
        errorMessagesByFilter[filter] = nil

        let task = Task { [title, type] in
            do {
                let result = try await CinemetaClient.fetchCatalogResult(
                    type: type,
                    catalog: Self.catalog(for: filter),
                    genre: Self.genre(for: filter),
                    forceRefresh: forceRefresh
                )

                await MainActor.run {
                    self.itemsByFilter[filter] = result.items
                }

                if !forceRefresh, result.source != .remote {
                    do {
                        let refreshedItems = try await CinemetaClient.fetchCatalog(
                            type: type,
                            catalog: Self.catalog(for: filter),
                            genre: Self.genre(for: filter),
                            forceRefresh: true
                        )

                        await MainActor.run {
                            self.itemsByFilter[filter] = refreshedItems
                        }
                    } catch {
                        // Cached catalogs are still useful when the background refresh fails.
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessagesByFilter[filter] = "Could not load \(title.lowercased()) from Cinemeta. Showing local items where available."
                    if self.itemsByFilter[filter] == nil {
                        self.itemsByFilter[filter] = self.fallbackItems
                    }
                }
            }
        }

        loadTasks[filter] = task
        await task.value
        loadTasks[filter] = nil
        loadingFilters.remove(filter)
    }

    private static func catalog(for filter: String) -> CinemetaCatalog {
        switch filter {
        case "New":
            .year
        case "Featured":
            .imdbRating
        default:
            .top
        }
    }

    private static func genre(for filter: String) -> String? {
        if filter == "New" {
            return String(Calendar.current.component(.year, from: Date()))
        }

        if ["Popular", "Featured"].contains(filter) {
            return nil
        }

        return filter
    }
}

private struct CatalogStoreKey: Hashable {
    let title: String
    let type: CinemetaType
}
