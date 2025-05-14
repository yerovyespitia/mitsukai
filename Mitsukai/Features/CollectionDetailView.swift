import SwiftUI

struct CollectionDetailView: View {
    // MARK: - Properties
    let collection: Collection
    @State private var animes: [Anime] = [] // TODO: Fetch actual anime data
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                // Header
                HStack {
                    Image(systemName: collection.systemImage)
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text(collection.name)
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(collection.count) items")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Anime Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
                    ], spacing: 16) {
                        ForEach(animes) { anime in
                            AnimeCardView(anime: anime, width: 160, height: 240)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(collection.name)
    }
}

#Preview {
    NavigationStack {
        CollectionDetailView(collection: Collection(
            name: "Favorites",
            count: 12,
            systemImage: "heart.fill"
        ))
    }
} 