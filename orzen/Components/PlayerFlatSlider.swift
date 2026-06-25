import SwiftUI

struct PlayerFlatSlider: View {
    @Binding var value: Double

    let bounds: ClosedRange<Double>
    let accessibilityLabel: String

    private let trackHeight: CGFloat = 7

    init(value: Binding<Double>, in bounds: ClosedRange<Double>, accessibilityLabel: String) {
        _value = value
        self.bounds = bounds
        self.accessibilityLabel = accessibilityLabel
    }

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let sliderProgress = progress(for: value)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.22))

                Capsule()
                    .fill(.white.opacity(0.95))
                    .frame(width: max(trackHeight, width * sliderProgress))
            }
            .frame(height: trackHeight)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        value = value(for: gesture.location.x, width: width)
                    }
            )
        }
        .frame(height: trackHeight)
        .accessibilityElement()
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .accessibilityAdjustableAction { direction in
            adjustValue(direction)
        }
    }

    private var accessibilityValue: String {
        "\(Int(progress(for: value) * 100)) percent"
    }

    private func progress(for value: Double) -> Double {
        let lower = bounds.lowerBound
        let upper = bounds.upperBound
        guard upper > lower else { return 0 }

        let clampedValue = min(max(value, lower), upper)
        return (clampedValue - lower) / (upper - lower)
    }

    private func value(for locationX: CGFloat, width: CGFloat) -> Double {
        let progress = min(max(Double(locationX / max(width, 1)), 0), 1)
        return bounds.lowerBound + ((bounds.upperBound - bounds.lowerBound) * progress)
    }

    private func adjustValue(_ direction: AccessibilityAdjustmentDirection) {
        let step = (bounds.upperBound - bounds.lowerBound) / 20

        switch direction {
        case .increment:
            value = min(value + step, bounds.upperBound)
        case .decrement:
            value = max(value - step, bounds.lowerBound)
        @unknown default:
            break
        }
    }
}
