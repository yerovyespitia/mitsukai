import SwiftUI

struct ContentView: View {
    var body: some View {
        SidebarView { selectedItem in
            switch selectedItem?.title {
            case "Home":
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(alignment: .leading, spacing: 0) {
                        ScrollView {
                            FeaturedCarousel(animes: featuredAnimes)
                            
                            AnimeSectionView(
                                title: "Last Watched",
                                animes: lastWatched,
                                cardWidth: 257,
                                cardHeight: 140
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
            case "Series":
                SeriesView()
            case "Movies":
                MoviesView()
            case "Collections":
                CollectionsView()
            case "Search":
                SearchView()
            default:
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack {
                        Text("Select an item from the sidebar")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 1280, height: 980)
    }
} 
