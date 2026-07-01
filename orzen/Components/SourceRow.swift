import SwiftUI

struct SourceRow: View {
    let source: StreamSource

    var body: some View {
        HStack(alignment: .top, spacing: rowSpacing) {
            ZStack {
                SourceRowStyle.cardShape
                    .fill(Color.white.opacity(0.1))

                Image(systemName: source.playbackURL == nil ? "exclamationmark.triangle.fill" : "play.circle.fill")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundColor(.white.opacity(0.72))
            }
            .frame(width: artworkWidth, height: artworkHeight)
            .overlay {
                SourceRowStyle.cardShape
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(source.title)
                    .font(titleFont)
                    .foregroundColor(.white)
                    .lineLimit(2)

                if !source.metadata.isEmpty {
                    Text(source.metadata.joined(separator: " • "))
                        .font(metadataFont)
                        .foregroundColor(.white.opacity(0.62))
                        .lineLimit(1)
                }

                Text(source.description)
                    .font(descriptionFont)
                    .foregroundColor(.white.opacity(0.78))
                    .lineLimit(descriptionLineLimit)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(rowPadding)
        .frame(minHeight: minimumHeight, alignment: .top)
        .sourceRowBackground()
    }

    private var artworkWidth: CGFloat {
        #if os(iOS)
        return 58
        #else
        return 190
        #endif
    }

    private var artworkHeight: CGFloat {
        #if os(iOS)
        return 58
        #else
        return 123
        #endif
    }

    private var iconSize: CGFloat {
        #if os(iOS)
        return 22
        #else
        return 28
        #endif
    }

    private var rowSpacing: CGFloat {
        #if os(iOS)
        return 10
        #else
        return 16
        #endif
    }

    private var rowPadding: CGFloat {
        #if os(iOS)
        return 10
        #else
        return 12
        #endif
    }

    private var minimumHeight: CGFloat {
        #if os(iOS)
        return 78
        #else
        return 147
        #endif
    }

    private var titleFont: Font {
        #if os(iOS)
        return .subheadline.weight(.semibold)
        #else
        return .headline
        #endif
    }

    private var metadataFont: Font {
        #if os(iOS)
        return .caption2
        #else
        return .caption
        #endif
    }

    private var descriptionFont: Font {
        #if os(iOS)
        return .caption
        #else
        return .callout
        #endif
    }

    private var descriptionLineLimit: Int {
        #if os(iOS)
        return 2
        #else
        return 3
        #endif
    }
}

private enum SourceRowStyle {
    static var cornerRadius: CGFloat {
        #if os(iOS)
        return 10
        #else
        return 14
        #endif
    }
    static let cardShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
}

private extension View {
    @ViewBuilder
    func sourceRowBackground() -> some View {
        let shape = SourceRowStyle.cardShape

        if #available(macOS 26, *) {
            self
                .glassEffect(.regular.tint(Color.white.opacity(0.02)), in: shape)
                .overlay {
                    shape.stroke(Color.white.opacity(0.04), lineWidth: 1)
                }
        } else {
            self
                .background(Color.white.opacity(0.045), in: shape)
                .overlay {
                    shape.stroke(Color.white.opacity(0.04), lineWidth: 1)
                }
        }
    }
}
