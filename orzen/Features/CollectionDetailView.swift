import SwiftUI

struct CollectionDetailView: View {
    // MARK: - Properties
    let collection: MediaCollection
    @ObservedObject private var collectionStore = CollectionStore.shared
    @ObservedObject private var episodeWatchStore = EpisodeWatchStore.shared
    @State private var detailItemFromContextMenu: CatalogItem?
    @State private var isShowingContextMenuDetail = false
    @Environment(\.dismiss) private var dismiss
    private let contentHorizontalPadding: CGFloat = 16
    private let contentTopPadding: CGFloat = 8
    private let contentSpacing: CGFloat = 12
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: contentSpacing) {
                // Header
                HStack {
                    Image(systemName: currentCollection.systemImage)
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text(currentCollection.name)
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(currentCollection.count) items")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // CatalogItem Grid
                if items.isEmpty {
                    DetailUnavailableView(
                        systemImage: currentCollection.systemImage,
                        title: "No items yet",
                        message: emptyMessage
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
                        ], spacing: 16) {
                            ForEach(items) { item in
                                NavigationLink(destination: InfoView(item: item)) {
                                    CatalogPosterCard(
                                        item: item,
                                        showsDroppedContextAction: showsDroppedContextAction,
                                        onViewDetails: {
                                            showContextMenuDetail(for: item)
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, contentHorizontalPadding)
            .padding(.top, contentTopPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .navigationTitle(currentCollection.name)
        .navigationDestination(isPresented: $isShowingContextMenuDetail) {
            if let detailItemFromContextMenu {
                InfoView(item: detailItemFromContextMenu)
            }
        }
        .escapeKeyShortcut {
            dismiss()
        }
    }

    private var currentCollection: MediaCollection {
        collectionStore.collection(id: collection.id) ?? collection
    }

    private var items: [CatalogItem] {
        collectionStore.items(in: collection.id)
    }

    private var showsDroppedContextAction: Bool {
        collection.id == CollectionStore.watchingID
    }

    private var emptyMessage: String {
        if collection.id == CollectionStore.favoritesID {
            return "Favorite movies or series from their info screen."
        }

        if collection.id == CollectionStore.planToWatchID {
            return "Add movies or series from their info screen."
        }

        if collection.id == CollectionStore.watchedID {
            return "Mark movies or series as watched from their info screen."
        }

        if collection.id == CollectionStore.watchingID {
            return "Series with partially watched episodes appear here."
        }

        if collection.id == CollectionStore.droppedID {
            return "Mark movies or series as dropped from their info screen."
        }

        return "This collection does not have any saved titles."
    }

    private func showContextMenuDetail(for item: CatalogItem) {
        detailItemFromContextMenu = item
        isShowingContextMenuDetail = true
    }
}

#Preview {
    NavigationStack {
        CollectionDetailView(collection: MediaCollection(
            id: "favorites",
            name: "Favorites",
            systemImage: "heart.fill",
            count: 12,
        ))
    }
} 
