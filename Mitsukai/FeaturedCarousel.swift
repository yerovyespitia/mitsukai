import SwiftUI

struct FeaturedCarousel: View {
    let animes: [Anime]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(animes) { anime in
                        ZStack(alignment: .bottomLeading) {
                            Image("Wallpaper")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width - 32, height: 400)
                                .clipped()
                                .overlay(
                                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.6)]), startPoint: .center, endPoint: .bottom)
                                )
                                .cornerRadius(16)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(anime.title)
                                    .font(.title).bold()
                                    .foregroundColor(.white)
                                    .shadow(radius: 8)
                            }
                            .padding(24)
                        }
                        .frame(width: geometry.size.width - 32)
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(height: 400)
        .padding(.bottom, 16)
    }
}

struct FeaturedCarousel_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedCarousel(animes: featuredAnimes)
            .background(Color.black)
    }
} 