import AppKit
import QuartzCore
import Character

/// Moves the floating companion window with smooth, non-teleporting transitions.
@MainActor
final class CompanionMovementController: CompanionMovementControlling {
    private weak var panel: NSPanel?
    private let stateMachine: CharacterStateMachine
    private let walkingSpeedProvider: () -> Double

    private(set) var currentDestination: CGPoint?
    private(set) var isMoving = false

    private var homePosition: CGPoint
    private var movementToken = UUID()
    private var facing: FacingDirection = .right

    private enum FacingDirection {
        case left
        case right
    }

    private enum Timing {
        static let turnDuration: TimeInterval = 0.2
        static let stopDuration: TimeInterval = 0.18
    }

    init(
        panel: NSPanel,
        stateMachine: CharacterStateMachine,
        homePosition: CGPoint,
        walkingSpeedProvider: @escaping () -> Double
    ) {
        self.panel = panel
        self.stateMachine = stateMachine
        self.homePosition = homePosition
        self.walkingSpeedProvider = walkingSpeedProvider
    }

    func move(to destination: CGPoint) {
        guard let panel else { return }
        let start = panel.frame.origin
        let distance = hypot(destination.x - start.x, destination.y - start.y)

        guard distance > 1 else {
            currentDestination = nil
            isMoving = false
            stateMachine.transition(to: .stop)
            enqueueIdleReset()
            return
        }

        let token = UUID()
        movementToken = token
        currentDestination = destination
        isMoving = true

        let newFacing: FacingDirection = destination.x >= start.x ? .right : .left
        let needsTurn = newFacing != facing
        facing = newFacing

        let speed = max(80, walkingSpeedProvider())
        let duration = distance / speed

        let startWalk: @MainActor () -> Void = { [weak self] in
            guard let self, let panel = self.panel, self.movementToken == token else { return }
            self.stateMachine.transition(to: .walk)

            NSAnimationContext.runAnimationGroup { context in
                context.duration = duration
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut) // accel/decel
                panel.animator().setFrameOrigin(destination)
            } completionHandler: { [weak self] in
                Task { @MainActor [weak self] in
                    guard let self, self.movementToken == token else { return }
                    self.currentDestination = nil
                    self.isMoving = false
                    self.stateMachine.transition(to: .stop)
                    self.enqueueIdleReset()
                }
            }
        }

        if needsTurn {
            stateMachine.transition(to: .turn)
            DispatchQueue.main.asyncAfter(deadline: .now() + Timing.turnDuration) {
                Task { @MainActor in
                    startWalk()
                }
            }
        } else {
            startWalk()
        }
    }

    func walkHome() {
        move(to: homePosition)
    }

    func cancelMovement() {
        movementToken = UUID()
        isMoving = false
        currentDestination = nil
        stateMachine.transition(to: .stop)
        enqueueIdleReset()
    }

    func updateHomePosition(_ point: CGPoint) {
        guard !isMoving else { return }
        homePosition = point
    }

    private func enqueueIdleReset() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.stopDuration) { [weak self] in
            guard let self else { return }
            if !isMoving {
                stateMachine.resetToIdle()
            }
        }
    }
}
