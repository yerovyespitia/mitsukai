//
//  Sidebar.swift
//  Mitsukai
//
//  Created by Yerovy Espitia on 11/05/25.
//

import SwiftUI

struct SidebarItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let systemImage: String
}

struct SidebarView<DetailContent: View>: View {
    @State private var selection: SidebarItem? = items[0]
    let detailContent: (SidebarItem?) -> DetailContent
    
    init(@ViewBuilder detailContent: @escaping (SidebarItem?) -> DetailContent) {
        self.detailContent = detailContent
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(items) { item in
                    HStack {
                        Image(systemName: item.systemImage)
                            .foregroundColor(.gray)
                            .frame(width: 20)

                        Text(item.title)
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .background {
                        if selection == item {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            selection = item
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .background(.black)
        } detail: {
            ZStack {
                Color.black.ignoresSafeArea()
                detailContent(selection)
            }
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}

let items: [SidebarItem] = [
    SidebarItem(title: "Home", systemImage: "house"),
    SidebarItem(title: "Series", systemImage: "tv"),
    SidebarItem(title: "Movies", systemImage: "film"),
    SidebarItem(title: "Collections", systemImage: "square.stack"),
    SidebarItem(title: "Search", systemImage: "magnifyingglass"),
]

#Preview {
    SidebarView { selectedItem in
        switch selectedItem?.title {
        case "Home":
            Text("Home Content")
        case "Series":
            Text("Series Content")
        case "Movies":
            Text("Movies Content")
        case "Collections":
            Text("Collections Content")
        case "Search":
            Text("Search Content")
        default:
            Text("Select an item")
        }
    }
}
