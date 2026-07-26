import SwiftUI
import PinkyCore
import PinkyTheme

/// Glassmorphism card container used across dashboard and settings.
public struct GlassCard<Content: View>: View {
    @Environment(\.pinkyTheme) private var theme
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: theme.primary).opacity(0.3), lineWidth: 1)
                    )
            }
            .shadow(color: Color(hex: theme.primary).opacity(0.15), radius: 12, y: 4)
    }
}
