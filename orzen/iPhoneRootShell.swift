import SwiftUI

#if os(iOS)
struct iPhoneRootShell: View {
    @ObservedObject private var playbackStore = StreamPlaybackStore.shared

    var body: some View {
        ZStack {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }

                SeriesView()
                    .tabItem {
                        Label("Series", systemImage: "tv")
                    }

                MoviesView()
                    .tabItem {
                        Label("Movies", systemImage: "film")
                    }

                iPhoneMoreView()
                    .tabItem {
                        Label("More", systemImage: "ellipsis")
                    }
            }
            .tint(.white)
            .ignoresSafeArea(.container, edges: .top)

            if let playbackRequest = playbackStore.request {
                StreamPlayerView(
                    request: playbackRequest,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            playbackStore.request = nil
                        }
                    }
                )
                .id(playbackRequest.id)
                .zIndex(10)
                .transition(.opacity)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

private struct iPhoneMoreView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    moreLink(
                        title: "Collections",
                        systemImage: "square.stack.fill",
                        destination: CollectionsView(ownsNavigationStack: false)
                    )

                    Divider()
                        .overlay(Color.white.opacity(0.12))

                    moreLink(
                        title: "Addons",
                        systemImage: "puzzlepiece.extension.fill",
                        destination: AddonsView(ownsNavigationStack: false)
                    )
                }
                .padding(.horizontal, 16)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 12)
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func moreLink<Destination: View>(
        title: String,
        systemImage: String,
        destination: Destination
    ) -> some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white.opacity(0.84))
                    .frame(width: 24)

                Text(title)
                    .font(.body)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.42))
            }
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
#endif
