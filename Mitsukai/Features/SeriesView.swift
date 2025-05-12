import SwiftUI

struct SeriesView: View {
    // MARK: - Properties
    @State private var selectedCategory: String = "All"
    let categories = ["All", "Action", "Drama", "Comedy", "Sci-Fi", "Romance"]
    
    // MARK: - Body
    var body: some View {
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
                        ForEach(0..<20) { _ in
                            SeriesCard()
                        }
                    }
                    .padding()
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
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder for series poster
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(2/3, contentMode: .fit)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Series Title")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("2024 • Action • 24 Episodes")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    SeriesView()
} 
