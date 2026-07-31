import SwiftUI
import Core

/// Speech bubble attached to the companion character.
public struct SpeechBubbleView: View {
    @Environment(\.appTheme) private var theme

    public let message: String
    public let primaryAction: (title: String, action: () -> Void)?
    public let secondaryAction: (title: String, action: () -> Void)?

    public init(
        message: String,
        primaryAction: (title: String, action: () -> Void)? = nil,
        secondaryAction: (title: String, action: () -> Void)? = nil
    ) {
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(message)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: theme.text))
                .frame(maxWidth: 270, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            if primaryAction != nil || secondaryAction != nil {
                HStack(spacing: 8) {
                    if let secondary = secondaryAction {
                        bubbleButton(title: secondary.title, style: .secondary, action: secondary.action)
                    }
                    if let primary = primaryAction {
                        bubbleButton(title: primary.title, style: .primary, action: primary.action)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: 290, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: theme.speechBubble))
                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
        }
        .overlay(alignment: .bottomLeading) {
            // Bubble tail
            Triangle()
                .fill(Color(hex: theme.speechBubble))
                .frame(width: 12, height: 8)
                .offset(x: 20, y: 7)
        }
    }

    private enum ButtonStyle { case primary, secondary }

    private func bubbleButton(title: String, style: ButtonStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    Capsule()
                        .fill(style == .primary ? Color(hex: theme.accent) : Color(hex: theme.secondary))
                }
                .foregroundStyle(style == .primary ? .white : Color(hex: theme.text))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
