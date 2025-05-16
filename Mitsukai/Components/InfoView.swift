import SwiftUI

// MARK: - InfoView: Muestra la información detallada de un anime
struct InfoView: View {
    let anime: Anime
    
    var body: some View {
        ZStack(alignment: .top) {
            // Banner de fondo
            Image("Wallpaper")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 500)
                .clipped()
                .overlay(
                    // Gradiente para mejor legibilidad
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0.2), Color.clear]),
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                Spacer().frame(height: 180) // Espacio para el banner
                HStack(alignment: .top, spacing: 32) {
                    // Poster del anime
                    Image("Poster")
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fit)
                        .frame(width: 220, height: 320)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.leading, 40)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Título
                        Text(anime.title)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                        // Descripción
                        Text(anime.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 8)
                        Spacer()
                    }
                    .padding(.trailing, 40)
                }
                Spacer()
            }
        }
        .background(Color.black)
        // Debug log
        .onAppear { print("[DEBUG] InfoView loaded for: \(anime.title)") }
    }
}

// MARK: - Preview
struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(anime: lastWatched.first!)
    }
} 