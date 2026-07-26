import Foundation
import Combine
import Domain
import Character
import Animations

/// Bridges `CharacterStateMachine` updates to the reusable `AnimationEngine`.
@MainActor
final class CharacterAnimationController: ObservableObject {
    @Published private(set) var activeState: CharacterState = .idle
    @Published private(set) var frameIndex: Int = 0

    private let animationEngine = AnimationEngine()
    private var cancellables = Set<AnyCancellable>()

    init(stateMachine: CharacterStateMachine) {
        registerStateClips()

        stateMachine.$currentState
            .removeDuplicates()
            .sink { [weak self] state in
                guard let self else { return }
                activeState = state
                animationEngine.play(state.rawValue)
            }
            .store(in: &cancellables)

        animationEngine.$currentFrameIndex
            .sink { [weak self] index in
                self?.frameIndex = index
            }
            .store(in: &cancellables)

        animationEngine.play(CharacterState.idle.rawValue)
    }

    private func registerStateClips() {
        let clips = CharacterState.allCases.map { state in
            let frameCount = frameCount(for: state)
            let frameDuration = frameDuration(for: state)
            let frames = (0 ..< frameCount).map {
                AnimationFrame(
                    textureName: "\(state.rawValue)_\($0)",
                    duration: frameDuration
                )
            }

            return AnimationClip(
                id: state.rawValue,
                frames: frames,
                loops: state.isLooping,
                priority: state.priority
            )
        }

        animationEngine.register(clips)
    }

    private func frameCount(for state: CharacterState) -> Int {
        switch state {
        case .idle, .breathing:
            return 24
        case .walk, .run:
            return 16
        case .blink:
            return 6
        case .sleep:
            return 20
        case .wave, .drink, .happy, .sad, .think, .peek, .celebrate:
            return 12
        }
    }

    private func frameDuration(for state: CharacterState) -> TimeInterval {
        switch state {
        case .run:
            return 1.0 / 30.0
        case .blink:
            return 1.0 / 24.0
        default:
            return 1.0 / 18.0
        }
    }
}
