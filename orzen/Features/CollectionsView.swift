import SwiftUI

struct CollectionsView: View {
    // MARK: - Properties
    @ObservedObject private var collectionStore = CollectionStore.shared
    @ObservedObject private var episodeWatchStore = EpisodeWatchStore.shared
    private let contentHorizontalPadding: CGFloat = 16
    private let contentTopPadding: CGFloat = 8
    private let contentSpacing: CGFloat = 12
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
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
                                NavigationLink(destination: CollectionDetailView(collection: collection)) {
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
        }
    }
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
