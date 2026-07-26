import Foundation
import Combine
import Domain

/// Reusable finite state machine for companion character behaviour.
@MainActor
public final class CharacterStateMachine: ObservableObject {
    @Published public private(set) var currentState: CharacterState = .idle

    private var idleTimer: Timer?
    private let randomIdleEnabled: () -> Bool

    public init(randomIdleEnabled: @escaping () -> Bool = { true }) {
        self.randomIdleEnabled = randomIdleEnabled
        scheduleRandomIdleAction()
    }

    // MARK: - State Transitions

    /// Transitions to a new state if the target has equal or higher priority.
    public func transition(to newState: CharacterState) {
        guard newState.priority >= currentState.priority || currentState == .idle else { return }
        currentState = newState

        if newState.isLooping {
            scheduleRandomIdleAction()
        } else {
            // Return to idle after one-shot animations (handled by animation engine callback in future milestones)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.currentState = .idle
                self?.scheduleRandomIdleAction()
            }
        }
    }

    public func resetToIdle() {
        currentState = .idle
        scheduleRandomIdleAction()
    }

    // MARK: - Random Idle Behaviour

    private func scheduleRandomIdleAction() {
        idleTimer?.invalidate()
        guard randomIdleEnabled() else { return }

        let delay = Double.random(in: 8 ... 20)
        idleTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            Task { @MainActor [weak self] in
                self?.performRandomIdleAction()
            }
        }
    }

    private func performRandomIdleAction() {
        guard currentState == .idle else { return }

        let actions: [CharacterState] = [.blink, .breathing, .think, .wave, .sleep]
        if let action = actions.randomElement() {
            transition(to: action)
        }
    }
}
