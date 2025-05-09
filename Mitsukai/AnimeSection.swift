import SwiftUI

struct AnimeSectionView: View {
    let title: String
    let animes: [Anime]
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title2).bold()
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(animes) { anime in
                        AnimeCardView(anime: anime, width: cardWidth, height: cardHeight)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
    }
}

struct AnimeSectionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AnimeSectionView(
                title: "Last Watched",
                animes: lastWatched,
                cardWidth: 160,
                cardHeight: 220
            )
            AnimeSectionView(
                title: "Upcoming",
                animes: upcoming,
                cardWidth: 160,
                cardHeight: 220
            )
        }
        .background(Color.black)
    }
} 
