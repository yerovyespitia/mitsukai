import SwiftUI

struct NavigationBar: View {
    var body: some View {
        HStack(spacing: 32) {
            HStack(spacing: 20) {
                Text("Home")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(800)
                Text("Search")
                    .foregroundColor(.white)
                Text("Collection")
                    .foregroundColor(.white)
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
