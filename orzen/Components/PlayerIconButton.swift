import SwiftUI

struct PlayerIconButton: View {
    let systemName: String
    let help: String
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(isEnabled ? 0.92 : 0.38))
                .frame(width: buttonSize, height: buttonSize)
        }
        .buttonStyle(.plain)
        .help(help)
        .accessibilityLabel(help)
        .disabled(!isEnabled)
    }

    private var buttonSize: CGFloat {
        #if os(iOS)
        return 34
        #else
        return 28
        #endif
    }
}
