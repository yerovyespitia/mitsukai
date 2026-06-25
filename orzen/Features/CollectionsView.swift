import SwiftUI

struct CollectionsView: View {
    // MARK: - Properties
    @ObservedObject private var collectionStore = CollectionStore.shared
    @ObservedObject private var episodeWatchStore = EpisodeWatchStore.shared
    @State private var navigationPath: [CollectionRoute] = []
    private let contentHorizontalPadding: CGFloat = 16
    private let contentTopPadding: CGFloat = 8
    private let contentSpacing: CGFloat = 12
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .topLeading) {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: contentSpacing) {
                    Text("Collections")
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 160, maximum: 220), spacing: 18)
                        ], spacing: 20) {
                            ForEach(collectionStore.collections) { collection in
                                NavigationLink(value: CollectionRoute.collection(collection.id)) {
                                    CollectionCard(collection: collection)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.horizontal, contentHorizontalPadding)
                .padding(.top, contentTopPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .navigationDestination(for: CollectionRoute.self, destination: destination)
        }
    }

    @ViewBuilder
    private func destination(for route: CollectionRoute) -> some View {
        switch route {
        case let .collection(collectionID):
            if let collection = collectionStore.collection(id: collectionID) {
                CollectionDetailView(
                    collection: collection,
                    onItemSelected: { item in
                        navigationPath.append(.item(item.id, collectionID: collection.id))
                    }
                )
            } else {
                DetailUnavailableView(
                    systemImage: "square.stack",
                    title: "Collection unavailable",
                    message: "This collection could not be found."
                )
            }
        case let .item(itemID, collectionID):
            if let item = collectionStore.item(id: itemID, in: collectionID) {
                InfoView(item: item)
            } else {
                DetailUnavailableView(
                    systemImage: "film",
                    title: "Title unavailable",
                    message: "This title is no longer in the collection."
                )
            }
        }
    }
}

private enum CollectionRoute: Hashable {
    case collection(MediaCollection.ID)
    case item(CatalogItem.ID, collectionID: MediaCollection.ID)
}

// MARK: - Collection Card View
struct CollectionCard: View {
    let collection: MediaCollection
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.1))

            Image(systemName: collection.systemImage)
                .font(.system(size: 46, weight: .medium))
                .foregroundColor(.white.opacity(0.38))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Text("\(collection.count)")
                .font(.caption.weight(.bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            LinearGradient(
                colors: [
                    Color.black.opacity(0),
                    Color.black.opacity(0.72)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            Text(collection.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(2)
                .shadow(radius: 4)
                .padding(12)
        }
        .aspectRatio(2 / 3, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
}

#Preview {
    CollectionsView()
} 
