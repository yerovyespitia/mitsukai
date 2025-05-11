import SwiftUI

struct NavigationBar: View {
    @State private var isHomeHovered = false
    @State private var isSearchHovered = false
    @State private var isCollectionHovered = false
    @State private var selectedItem = "Home"
    
    var body: some View {
        HStack(spacing: 32) {
            HStack(spacing: 10) {
                Text("Home")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(selectedItem == "Home" ? Color.white.opacity(0.15) : Color.clear)
                    .cornerRadius(800)
                    .onHover { hovering in
                        isHomeHovered = hovering
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .onTapGesture {
                        selectedItem = "Home"
                    }
                Text("Search")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(selectedItem == "Search" ? Color.white.opacity(0.15) : Color.clear)
                    .cornerRadius(800)
                    .onHover { hovering in
                        isSearchHovered = hovering
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .onTapGesture {
                        selectedItem = "Search"
                    }
                Text("Collection")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(selectedItem == "Collection" ? Color.white.opacity(0.15) : Color.clear)
                    .cornerRadius(800)
                    .onHover { hovering in
                        isCollectionHovered = hovering
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .onTapGesture {
                        selectedItem = "Collection"
                    }
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 14)
        .padding(.top, 30)
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar()
            .background(Color.black)
    }
} 
