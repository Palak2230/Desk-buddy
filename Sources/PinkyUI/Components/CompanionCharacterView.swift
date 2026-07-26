import SwiftUI
import Core
import Theme
import Character
import Domain

/// Environment key for injecting the active app theme.
private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Theme = ThemeLoader.fallbackTheme
}

public extension EnvironmentValues {
    var appTheme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

/// Placeholder companion character view — will be replaced with SpriteKit in a future milestone.
public struct CompanionCharacterView: View {
    @ObservedObject private var stateMachine: CharacterStateMachine
    private let scale: Double

    public init(stateMachine: CharacterStateMachine, scale: Double = 1.0) {
        self.stateMachine = stateMachine
        self.scale = scale
    }

    public var body: some View {
        VStack(spacing: 4) {
            characterBody
            stateLabel
        }
        .scaleEffect(scale)
        .animation(.easeInOut(duration: 0.3), value: stateMachine.currentState)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var characterBody: some View {
        ZStack {
            // Body placeholder — pastel coquette aesthetic
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FFB6C1"), Color(hex: "#FFC0CB")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 80, height: 100)

            VStack(spacing: 0) {
                // Head
                Circle()
                    .fill(Color(hex: "#FFE4E1"))
                    .frame(width: 50, height: 50)
                    .overlay(
                        HStack(spacing: 12) {
                            eye
                            eye
                        }
                        .offset(y: -2)
                    )
                    .overlay(
                        Text("♥")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(hex: "#FF69B4"))
                            .offset(x: 18, y: -18)
                    )

                // Hoodie body
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#FFB6C1"))
                    .frame(width: 60, height: 40)
            }
        }
        .shadow(color: Color(hex: "#FFB6C1").opacity(0.4), radius: 8, y: 4)
    }

    private var eye: some View {
        Circle()
            .fill(Color(hex: "#4A3040"))
            .frame(width: stateMachine.currentState == .blink ? 2 : 6, height: 6)
            .animation(.easeInOut(duration: 0.1), value: stateMachine.currentState)
    }

    private var stateLabel: some View {
        Text(stateMachine.currentState.rawValue.capitalized)
            .font(.system(size: 9, weight: .medium, design: .rounded))
            .foregroundStyle(Color(hex: "#4A3040").opacity(0.6))
    }
}
