import Foundation

struct Anime: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String? // Nombre de la imagen local, si existe
    let description: String
} 