import SwiftUI

struct AnimeCardView: View {
    let anime: Anime
    let width: CGFloat
    let height: CGFloat
    @State private var isHovered = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageName = anime.imageName, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image("Poster")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: width, height: height)
        .cornerRadius(8)
        .overlay(
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.4))
                    .cornerRadius(8)
                Text(anime.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(8)
                    .shadow(radius: 4)
                    .multilineTextAlignment(.center)
            }
            .opacity(isHovered ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: isHovered),
            alignment: .center
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .clipped()
    }
}

struct AnimeCardView_Previews: PreviewProvider {
    static var previews: some View {
        AnimeCardView(anime: lastWatched[0], width: 160, height: 240)
    }
} 
