import SwiftUI

struct AnimeSectionView: View {
    let title: String
    let animes: [Anime]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title2).bold()
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
            ], spacing: 16) {
                ForEach(animes) { anime in
                    SeriesCard(anime: anime)
                }
            }
            .padding()
        }
    }
}

#Preview {
    AnimeSectionView(
        title: "Last Watched",
        animes: lastWatched
    )
} 