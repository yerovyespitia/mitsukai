import SwiftUI

struct FeaturedCarousel: View {
    let items: [CatalogItem]
    @State private var selectedItemID: CatalogItem.ID?
    @State private var hoveredButtonImage: String?
    
    private let carouselAnimation = Animation.smooth(duration: 0.58, extraBounce: 0)
    
    var body: some View {
        GeometryReader { geometry in
            let pageWidth = geometry.size.width

            ZStack {
                if let selectedItem {
                    NavigationLink(destination: InfoView(item: selectedItem)) {
                        FeaturedCarouselPage(item: selectedItem)
                    }
                    .buttonStyle(.plain)
                    .frame(width: pageWidth, height: OrzenLayout.bannerHeight)
                    .contentShape(Rectangle())
                    .id(selectedItem.id)
                    .transition(.opacity)
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .zIndex(1)
                }

                if items.count > 1 {
                    carouselControls(pageWidth: pageWidth)
                        .zIndex(2)
                }
            }
            .onAppear(perform: selectInitialItemIfNeeded)
            .onChange(of: items.map(\.id)) { _, ids in
                guard selectedItemID.map({ ids.contains($0) }) != true else { return }
                selectedItemID = ids.first
            }
            .animation(carouselAnimation, value: selectedItemID)
        }
        .frame(height: OrzenLayout.bannerHeight)
        .padding(.bottom, 22)
        .preference(
            key: FeaturedBannerArtworkKey.self,
            value: selectedItem.map(FeaturedBannerArtwork.init)
        )
    }
    
    private var selectedItem: CatalogItem? {
        guard let selectedItemID,
              let item = items.first(where: { $0.id == selectedItemID }) else {
            return items.first
        }
        
        return item
    }
    
    private var selectedIndex: Int? {
        guard let selectedItemID else { return items.indices.first }
        return items.firstIndex { $0.id == selectedItemID }
    }
    
    private var canMoveBackward: Bool {
        guard let selectedIndex else { return false }
        return selectedIndex > items.startIndex
    }
    
    private var canMoveForward: Bool {
        guard let selectedIndex else { return false }
        return selectedIndex < items.index(before: items.endIndex)
    }

    private func selectInitialItemIfNeeded() {
        guard selectedItemID == nil else { return }
        selectedItemID = items.first?.id
    }
    
    private func moveSelection(by offset: Int) {
        guard !items.isEmpty else { return }
        
        let currentIndex = selectedIndex ?? items.startIndex
        let proposedIndex = currentIndex + offset
        let clampedIndex = min(max(proposedIndex, items.startIndex), items.index(before: items.endIndex))
        let nextID = items[clampedIndex].id
        
        withAnimation(carouselAnimation) {
            selectedItemID = nextID
        }
    }
    
    @ViewBuilder
    private func carouselButton(
        systemImage: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        if #available(macOS 26, *) {
            Button(action: action) {
                carouselButtonIcon(systemImage, isEnabled: isEnabled)
                    .background(carouselButtonBackground(systemImage: systemImage, isEnabled: isEnabled))
                    .glassEffect(isEnabled ? .regular.interactive() : .regular, in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.18)
            .contentShape(Circle())
            .onHover { hovering in
                hoveredButtonImage = hovering && isEnabled ? systemImage : nil
            }
            .animation(.easeInOut(duration: 0.12), value: hoveredButtonImage)
            .accessibilityLabel(systemImage == "chevron.left" ? "Previous featured title" : "Next featured title")
        } else {
            Button(action: action) {
                carouselButtonIcon(systemImage, isEnabled: isEnabled)
                    .background(carouselButtonBackground(systemImage: systemImage, isEnabled: isEnabled))
                    .shadow(color: .black.opacity(isEnabled ? 0.35 : 0.12), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.18)
            .contentShape(Circle())
            .onHover { hovering in
                hoveredButtonImage = hovering && isEnabled ? systemImage : nil
            }
            .animation(.easeInOut(duration: 0.12), value: hoveredButtonImage)
            .accessibilityLabel(systemImage == "chevron.left" ? "Previous featured title" : "Next featured title")
        }
    }

    private func carouselButtonBackground(systemImage: String, isEnabled: Bool) -> some View {
        let isHovered = hoveredButtonImage == systemImage && isEnabled

        return Circle()
            .fill(Color.white.opacity(isHovered ? 0.16 : 0.08))
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(isHovered ? 0.14 : 0.06), lineWidth: 1)
            )
    }

    private func carouselButtonIcon(_ systemImage: String, isEnabled: Bool) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white.opacity(isEnabled ? 1 : 0.42))
            .frame(width: 44, height: 44)
    }
    
    @ViewBuilder
    private func carouselControls(pageWidth: CGFloat) -> some View {
        if #available(macOS 26, *) {
            GlassEffectContainer(spacing: 0) {
                carouselControlsContent()
            }
            .padding(.horizontal, 18)
            .frame(width: pageWidth, height: OrzenLayout.bannerHeight)
            .contentShape(Rectangle())
            .allowsHitTesting(true)
        } else {
            carouselControlsContent()
                .padding(.horizontal, 18)
                .frame(width: pageWidth, height: OrzenLayout.bannerHeight)
                .contentShape(Rectangle())
                .allowsHitTesting(true)
        }
    }

    private func carouselControlsContent() -> some View {
        HStack {
            carouselButton(systemImage: "chevron.left", isEnabled: canMoveBackward) {
                moveSelection(by: -1)
            }

            Spacer()

            carouselButton(systemImage: "chevron.right", isEnabled: canMoveForward) {
                moveSelection(by: 1)
            }
        }
    }
    
}

private struct FeaturedCarouselPage: View {
    let item: CatalogItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear

            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 8)
                    .lineLimit(2)

                Text(metadata)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.86))
                    .lineLimit(1)
            }
            .padding(.leading, OrzenLayout.contentLeadingInset)
            .padding(.trailing, OrzenLayout.contentTrailingInset)
            .padding(.bottom, 32)
        }
    }

    private var metadata: String {
        [
            item.displayYear,
            item.genres.first,
            item.runtime
        ]
        .compactMap { value in
            guard let value, !value.isEmpty else { return nil }
            return value
        }
        .joined(separator: " • ")
    }
}

struct FeaturedCarousel_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedCarousel(items: featuredItems)
            .background(Color.black)
    }
} 
