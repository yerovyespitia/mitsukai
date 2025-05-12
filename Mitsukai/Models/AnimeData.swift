import Foundation

struct AnimeSection {
    let title: String
    let animes: [Anime]
}

let featuredAnimes: [Anime] = [
    Anime(title: "SPY x FAMILY Cour 2", imageName: nil, description: "Anya y su familia en nuevas aventuras."),
    Anime(title: "Chainsaw Man", imageName: nil, description: "Denji y su motosierra luchan contra demonios."),
    Anime(title: "BLEACH: Thousand-Year Blood War", imageName: nil, description: "Ichigo enfrenta una nueva guerra."),
    Anime(title: "Attack on Titan Final Season Part 2", imageName: nil, description: "El final se acerca."),
    Anime(title: "BLEACH: Thousand-Year Blood War", imageName: nil, description: "Ichigo enfrenta una nueva guerra."),
]

let lastWatched: [Anime] = [
    Anime(title: "Attack on Titan", imageName: nil, description: "La lucha por la humanidad continúa."),
    Anime(title: "Naruto: Shippuden", imageName: nil, description: "Naruto sigue su camino ninja."),
    Anime(title: "Attack on Titan Final Season Part 2", imageName: nil, description: "El final se acerca."),
    Anime(title: "BLEACH: Thousand-Year Blood War", imageName: nil, description: "Ichigo enfrenta una nueva guerra."),
]

let upcoming: [Anime] = [
    Anime(title: "Evangelion: 3.0+1.0", imageName: nil, description: "El final de Evangelion."),
    Anime(title: "Made in Abyss", imageName: nil, description: "Explora el abismo."),
    Anime(title: "Your Name", imageName: nil, description: "Un romance a través del tiempo."),
    Anime(title: "Violet Evergarden", imageName: nil, description: "Cartas y emociones."),
    Anime(title: "Fate/Zero", imageName: nil, description: "La guerra por el Santo Grial."),
    Anime(title: "Made in Abyss", imageName: nil, description: "Explora el abismo."),
    Anime(title: "Your Name", imageName: nil, description: "Un romance a través del tiempo."),
] 
