import SwiftUI

struct MoviesView: View {
    // MARK: - Properties
    @State private var selectedFilter: String = "Latest"
    let filters = ["Latest", "Popular", "Top Rated", "Upcoming"]
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Featured Movie
                VStack(alignment: .leading, spacing: 16) {
                    Text("Featured Movie")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .fontWeight(.bold)
                    
                    // Placeholder for featured movie
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 300)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filters, id: \.self) { filter in
                            FilterButton(
                                title: filter,
                                isSelected: selectedFilter == filter,
                                action: {
                                    withAnimation {
                                        selectedFilter = filter
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Movies Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
                    ], spacing: 16) {
                        ForEach(0..<20) { _ in
                            MovieCard()
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
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

// MARK: - Movie Card
struct MovieCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder for movie poster
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(2/3, contentMode: .fit)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Movie Title")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("2024 • Action • 2h 15m")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    MoviesView()
} 