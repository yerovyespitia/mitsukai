import SwiftUI

struct SeriesView: View {
    var body: some View {
        CinemetaCatalogView(
            title: "Series",
            type: .series,
            filters: CinemetaCatalogPresets.seriesFilters,
            fallbackItems: series
        )
    }
}

struct SeriesCard: View {
    let item: CatalogItem
    var showsDroppedContextAction = false
    var onViewDetails: (() -> Void)?
    
    var body: some View {
        CatalogPosterCard(
            item: item,
            showsDroppedContextAction: showsDroppedContextAction,
            onViewDetails: onViewDetails
        )
    }
}

#Preview {
    SeriesView()
}
