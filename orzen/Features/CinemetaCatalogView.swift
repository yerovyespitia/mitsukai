import SwiftUI

struct CinemetaCatalogView: View {
    let title: String
    let type: CinemetaType
    let filters: [String]
    let fallbackItems: [CatalogItem]

    @ObservedObject private var catalogStore: CinemetaCatalogStore

    init(title: String, type: CinemetaType, filters: [String], fallbackItems: [CatalogItem]) {
        self.title = title
        self.type = type
        self.filters = filters
        self.fallbackItems = fallbackItems
        _catalogStore = ObservedObject(wrappedValue: CinemetaCatalogStore.shared(
            title: title,
            type: type,
            filters: filters,
            fallbackItems: fallbackItems
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    header
                    filterBar
                    content
                }
            }
        }
        .task(id: catalogStore.selectedFilter) {
            await catalogStore.loadCatalog()
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            if catalogStore.isLoading {
                ProgressView()
                    .controlSize(.small)
                    .tint(.white)
            }

            Spacer()

            Button {
                Task { await catalogStore.loadCatalog(forceRefresh: true) }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
            .foregroundColor(.white.opacity(0.82))
            .help("Reload catalog")
        }
        .padding(.horizontal)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters, id: \.self) { filter in
                    FilterButton(
                        title: filter,
                        isSelected: catalogStore.selectedFilter == filter,
                        action: {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                catalogStore.selectedFilter = filter
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var content: some View {
        if let errorMessage = catalogStore.errorMessage, catalogStore.items.isEmpty {
            ContentUnavailableView {
                Label("Catalog unavailable", systemImage: "wifi.exclamationmark")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Retry") {
                    Task { await catalogStore.loadCatalog(forceRefresh: true) }
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 160, maximum: 220), spacing: 18)
                ], spacing: 20) {
                    ForEach(displayItems) { item in
                        NavigationLink(destination: InfoView(item: item)) {
                            CatalogPosterCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    private var displayItems: [CatalogItem] {
        catalogStore.items.isEmpty ? fallbackItems : catalogStore.items
    }
}
