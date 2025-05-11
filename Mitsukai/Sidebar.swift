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
    let count: Int
}

struct SidebarView: View {
    @State private var selection: SidebarItem? = items[0]
    
    var body: some View {
        NavigationSplitView {
                   List(selection: $selection) {
                       ForEach(items) { item in
                           HStack {
                               Image(systemName: item.systemImage)
                                   .foregroundColor(.yellow)
                                   .frame(width: 20)

                               Text(item.title)
                                   .foregroundColor(.primary)

                               Spacer()

                               Text("\(item.count)")
                                   .foregroundColor(.secondary)
                           }
                           .padding(8)
                           .background {
                               if selection == item {
                                   RoundedRectangle(cornerRadius: 8)
                                       .fill(Color.white.opacity(0.1))
                               }
                           }

                       }
                   }
                   .listStyle(.sidebar)
                   .background(.ultraThinMaterial)
               } detail: {
                   Text("You picked: \(selection?.title ?? "")")
               }
               .frame(minWidth: 300, minHeight: 500)
           }
    }

let items: [SidebarItem] = [
    SidebarItem(title: "Home", systemImage: "house.fill", count: 3),
    SidebarItem(title: "Collection", systemImage: "square.stack.fill", count: 2),
    SidebarItem(title: "Search", systemImage: "magnifyingglass", count: 0),
]

#Preview {
    SidebarView()
}
