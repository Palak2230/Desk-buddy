import SwiftUI
import SpriteKit
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

/// SpriteKit-powered companion character view.
public struct CompanionCharacterView: View {
    @Environment(\.appTheme) private var theme
    @ObservedObject private var stateMachine: CharacterStateMachine
    @StateObject private var animationController: CharacterAnimationController
    private let scale: Double
    private let scene = CompanionSpriteScene(size: CGSize(width: 140, height: 170))

    public init(stateMachine: CharacterStateMachine, scale: Double = 1.0) {
        self.stateMachine = stateMachine
        self.scale = scale
        _animationController = StateObject(wrappedValue: CharacterAnimationController(stateMachine: stateMachine))
    }

    public var body: some View {
        VStack(spacing: 4) {
            characterBody
            stateLabel
        }
        .scaleEffect(scale)
        .animation(.easeInOut(duration: 0.3), value: stateMachine.currentState)
        .onAppear {
            scene.apply(
                state: animationController.activeState,
                frameIndex: animationController.frameIndex,
                theme: theme
            )
        }
        .onChange(of: animationController.frameIndex) { _, newFrame in
            scene.apply(
                state: animationController.activeState,
                frameIndex: newFrame,
                theme: theme
            )
        }
        .onChange(of: animationController.activeState) { _, newState in
            scene.apply(
                state: newState,
                frameIndex: animationController.frameIndex,
                theme: theme
            )
        }
        .onChange(of: theme.id) { _, _ in
            scene.apply(
                state: animationController.activeState,
                frameIndex: animationController.frameIndex,
                theme: theme
            )
        }
    }

    // MARK: - Subviews

    private var characterBody: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
            .frame(width: 130, height: 160)
            .background(Color.clear)
    }

    private var stateLabel: some View {
        Text(stateMachine.currentState.rawValue.capitalized)
            .font(.system(size: 9, weight: .medium, design: .rounded))
            .foregroundStyle(Color(hex: "#4A3040").opacity(0.6))
    }
}
