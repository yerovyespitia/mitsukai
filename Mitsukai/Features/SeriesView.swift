import SwiftUI

struct SeriesView: View {
    // MARK: - Properties
    @State private var selectedCategory: String = "All"
    let categories = ["All", "Action", "Drama", "Comedy", "Sci-Fi", "Romance"]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Text("Series")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .fontWeight(.bold)
                    
                    // Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                CategoryButton(
                                    title: category,
                                    isSelected: selectedCategory == category,
                                    action: {
                                        withAnimation {
                                            selectedCategory = category
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Series Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
                        ], spacing: 16) {
                            ForEach(series) { anime in
                                NavigationLink(destination: InfoView(anime: anime)) {
                                    SeriesCard(anime: anime)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.white : Color.white.opacity(0.1))
                .cornerRadius(20)
                .fontWeight(.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Series Card
struct SeriesCard: View {
    let anime: Anime
    @State private var isHovered = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                // Placeholder for series poster
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(2/3, contentMode: .fit)
                    .cornerRadius(8)
            }
        }
        .cornerRadius(8)
        .overlay(
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.4))
                    .cornerRadius(8)

                VStack(alignment: .center, spacing: 4) {
                    Text(anime.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(8)
                        .shadow(radius: 4)
                        .multilineTextAlignment(.center)
                    
                    Text("2024 • Action • 2h 15m")
                        .font(.caption)
                        .foregroundColor(.white)

                }
            }
            .opacity(isHovered ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: isHovered),
            alignment: .center
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .clipped()
    }
}

#Preview {
    SeriesView()
} 
