import SwiftUI

struct NavigationBar: View {
    @State private var isHomeHovered = false
    @State private var isSearchHovered = false
    @State private var isCollectionHovered = false
    @State private var selectedItem = "Home"
    
    var body: some View {
        HStack {
            HStack(spacing: 5) {
                Image(systemName: "house.fill")
                    .font(.system(size: 20))
                    .foregroundColor(selectedItem == "Home" ? .white : .gray)
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
                
                Image(systemName: "square.stack.fill")
                    .font(.system(size: 20))
                    .foregroundColor(selectedItem == "Collection" ? .white : .gray)
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
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(selectedItem == "Search" ? .white : .gray)
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
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 14)
        .padding(.top, 10)
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar()
            .background(Color.black)
    }
} 
