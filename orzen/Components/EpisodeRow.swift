import SwiftUI

struct EpisodeRow: View {
    let episode: CatalogEpisode
    var isSelected = false
    var isWatched = false
    var isCurrent = false

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            thumbnail
                .frame(width: 190, height: 123)
                .clipShape(EpisodeRowStyle.cardShape)
                .overlay {
                    EpisodeRowStyle.cardShape
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                }
                .overlay(alignment: .topLeading) {
                    if isCurrent || isWatched {
                        statusBadges
                            .padding(.top, 12)
                            .padding(.leading, 12)
                    }
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(episode.displayTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)

                if !episode.metadata.isEmpty {
                    Text(episode.metadata.joined(separator: " • "))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.62))
                        .lineLimit(1)
                }

                Text(episode.description ?? "No description available.")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.78))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(minHeight: 147, alignment: .top)
        .rowBackground(isSelected: isSelected)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let thumbnailURL = episode.thumbnailURL {
            CachedRemoteImage(url: thumbnailURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                thumbnailPlaceholder
            }
        } else {
            thumbnailPlaceholder
        }
    }

    private var statusBadges: some View {
        HStack(spacing: 6) {
            if isCurrent {
                badge(title: "Now", systemImage: "play.fill")
            }

            if isWatched {
                badge(title: "Watched", systemImage: "eye.fill")
            }
        }
    }

    private func badge(title: String, systemImage: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.system(size: 11, weight: .semibold))

            Text(title)
                .font(.caption2.weight(.semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .foregroundColor(.black.opacity(0.86))
        .background(Color.white.opacity(0.94), in: Capsule())
        .fixedSize()
        .overlay {
            Capsule()
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.3), radius: 5, y: 2)
    }

    private var thumbnailPlaceholder: some View {
        ZStack {
            OrzenArtworkPlaceholder(style: .backdrop)

            Image(systemName: "play.rectangle")
                .font(.title2)
                .foregroundColor(.white.opacity(0.64))
        }
    }
}

private enum EpisodeRowStyle {
    static let cornerRadius: CGFloat = 14
    static let cardShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
}

private extension View {
    @ViewBuilder
    func rowBackground(isSelected: Bool) -> some View {
        let shape = EpisodeRowStyle.cardShape

        if #available(macOS 26, *) {
            self
                .glassEffect(.regular.tint(Color.white.opacity(isSelected ? 0.05 : 0.02)), in: shape)
                .overlay {
                    shape.stroke(isSelected ? Color.white.opacity(0.18) : Color.white.opacity(0.04), lineWidth: 1)
                }
        } else {
            self
                .background(Color.white.opacity(isSelected ? 0.1 : 0.045), in: shape)
                .overlay {
                    shape.stroke(isSelected ? Color.white.opacity(0.18) : Color.white.opacity(0.04), lineWidth: 1)
                }
        }
    }
}
