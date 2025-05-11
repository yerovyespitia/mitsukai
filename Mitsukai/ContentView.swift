import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                NavigationBar()
                
                ScrollView {
                    FeaturedCarousel(animes: featuredAnimes)
                    
                    AnimeSectionView(
                        title: "Last Watched",
                        animes: lastWatched,
                        cardWidth: 140,
                        cardHeight: 220
                    )
                    
                    AnimeSectionView(
                        title: "Upcoming",
                        animes: upcoming,
                        cardWidth: 140,
                        cardHeight: 200
                    )
                    
                    AnimeSectionView(
                        title: "Winter Season",
                        animes: upcoming,
                        cardWidth: 140,
                        cardHeight: 200
                    )
                    
                    AnimeSectionView(
                        title: "Airing",
                        animes: upcoming,
                        cardWidth: 140,
                        cardHeight: 200
                    )
                }
                
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 
