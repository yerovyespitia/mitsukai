import SwiftUI

struct SourceRow: View {
    let source: StreamSource

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                SourceRowStyle.cardShape
                    .fill(Color.white.opacity(0.1))

                Image(systemName: source.playbackURL == nil ? "exclamationmark.triangle.fill" : "play.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white.opacity(0.72))
            }
            .frame(width: 190, height: 123)
            .overlay {
                SourceRowStyle.cardShape
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(source.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)

                if !source.metadata.isEmpty {
                    Text(source.metadata.joined(separator: " • "))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.62))
                        .lineLimit(1)
                }

                Text(source.description)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.78))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(minHeight: 147, alignment: .top)
        .sourceRowBackground()
    }
}

private enum SourceRowStyle {
    static let cornerRadius: CGFloat = 14
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
