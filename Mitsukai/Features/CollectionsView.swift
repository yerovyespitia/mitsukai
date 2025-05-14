import SwiftUI

struct CollectionsView: View {
    // MARK: - Properties
    @State private var collections: [Collection] = [
        Collection(name: "Favorites", count: 12, systemImage: "heart.fill"),
        Collection(name: "Watching", count: 5, systemImage: "play.fill"),
        Collection(name: "Completed", count: 24, systemImage: "checkmark.circle.fill"),
        Collection(name: "Plan to Watch", count: 18, systemImage: "clock.fill"),
        Collection(name: "Dropped", count: 3, systemImage: "xmark"),
        Collection(name: "On Hold", count: 7, systemImage: "pause")
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Text("Collections")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .fontWeight(.bold)
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 200, maximum: 300), spacing: 16)
                        ], spacing: 16) {
                            ForEach(collections) { collection in
                                NavigationLink(destination: CollectionDetailView(collection: collection)) {
                                    CollectionCard(collection: collection)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

// MARK: - Collection Model
struct Collection: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let systemImage: String
}

// MARK: - Collection Card View
struct CollectionCard: View {
    let collection: Collection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: collection.systemImage)
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("\(collection.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fontWeight(.bold)
            }
            
            Text(collection.name)
                .font(.headline)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    CollectionsView()
} 
