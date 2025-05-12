import SwiftUI

struct SearchView: View {
    // MARK: - Properties
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [Anime] = []
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search anime...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .onChange(of: searchText) { oldValue, newValue in
                            // TODO: Implement search functionality
                            isSearching = !newValue.isEmpty
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            isSearching = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(80)
                .padding(.horizontal)
                
                // Search Results
                if isSearching {
                    if searchResults.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No results found")
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 140, maximum: 200), spacing: 16)
                            ], spacing: 16) {
                                ForEach(searchResults) { anime in
                                    AnimeCardView(anime: anime, width: 140, height: 200)
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    // Popular Searches
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Popular Searches")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .fontWeight(.medium)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(["Action", "Romance", "Comedy", "Drama", "Fantasy", "Sci-Fi"], id: \.self) { genre in
                                    Text(genre)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    SearchView()
} 
