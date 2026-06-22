import SwiftUI

struct HomeView: View {
    @ObservedObject private var catalogStore = HomeCatalogStore.shared
    @ObservedObject private var playbackStore = StreamPlaybackStore.shared
    @ObservedObject private var progressStore = PlaybackProgressStore.shared

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        FeaturedCarousel(items: catalogStore.featured)

                        if catalogStore.isLoading {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                                .padding(.leading, OrzenLayout.contentLeadingInset)
                                .padding(.bottom, 12)
                        }

                        if !progressStore.watchingItems.isEmpty {
                            CatalogSectionView(
                                title: "Watching",
                                items: progressStore.watchingItems,
                                cardStyle: .watching,
                                showsDroppedContextAction: true,
                                onItemSelected: playSavedProgress
                            )
                        }

                        ForEach(catalogStore.sections) { section in
                            CatalogSectionView(
                                title: section.title,
                                items: section.items
                            )
                        }
                    }
                    .frame(width: geometry.size.width, alignment: .leading)
                }
                .ignoresSafeArea(.container, edges: .top)
            }
        }
        .task {
            catalogStore.loadIfNeeded()
        }
    }

    private func playSavedProgress(_ item: CatalogItem) {
        guard let request = progressStore.entry(for: item)?.playbackRequest else { return }
        playbackStore.request = request
    }
}
