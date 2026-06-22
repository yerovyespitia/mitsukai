import SwiftUI

struct MoviesView: View {
    var body: some View {
        CinemetaCatalogView(
            title: "Movies",
            type: .movie,
            filters: CinemetaCatalogPresets.movieFilters,
            fallbackItems: movies
        )
    }
}

#Preview {
    MoviesView()
}
