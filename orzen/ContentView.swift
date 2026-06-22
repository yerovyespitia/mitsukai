import SwiftUI

struct ContentView: View {
    var body: some View {
        SidebarView { selectedItem in
            switch selectedItem?.title {
            case "Home":
                HomeView()
            case "Series":
                SeriesView()
            case "Movies":
                MoviesView()
            case "Collections":
                CollectionsView()
            case "Search":
                SearchView()
            case "Addons":
                AddonsView()
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
