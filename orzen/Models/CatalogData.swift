import Foundation

struct CatalogSection {
    let title: String
    let items: [CatalogItem]
}

let featuredItems: [CatalogItem] = placeholderItems(prefix: "featured", count: 5)

let lastWatched: [CatalogItem] = placeholderItems(prefix: "last-watched", count: 4)

let upcoming: [CatalogItem] = placeholderItems(prefix: "upcoming", count: 7)

let series: [CatalogItem] = placeholderItems(prefix: "series", count: 21)

let movies: [CatalogItem] = placeholderItems(prefix: "movies", count: 20)

private func placeholderItems(prefix: String, count: Int) -> [CatalogItem] {
    (0..<count).map { index in
        CatalogItem(
            id: "\(prefix)-placeholder-\(index)",
            title: "",
            description: ""
        )
    }
}
