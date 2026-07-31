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
    private var pendingCompletion: (() -> Void)?

    private enum FacingDirection {
        case left
        case right
    }

    private enum Timing {
        static let turnDuration: TimeInterval = 0.46
        static let stopDuration: TimeInterval = 0.18
        static let landingBounceDuration: TimeInterval = 0.08
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
        move(to: destination, completion: nil)
    }

    func move(to destination: CGPoint, completion: (() -> Void)?) {
        guard let panel else { return }
        pendingCompletion = completion
        let start = panel.frame.origin
        let distance = hypot(destination.x - start.x, destination.y - start.y)

        guard distance > 1 else {
            currentDestination = nil
            isMoving = false
            transitionToStopPose()
            pendingCompletion?()
            pendingCompletion = nil
            return
        }

        let token = UUID()
        movementToken = token
        currentDestination = destination
        isMoving = true

        let newFacing: FacingDirection = destination.x >= start.x ? .right : .left
        let needsTurn = newFacing != facing
        facing = newFacing
        stateMachine.setFacingRight(newFacing == .right)

        // Slightly slower travel for a calmer, more readable walk.
        let speed = max(80, walkingSpeedProvider() * 0.72)
        let duration = distance / speed

        let startWalk: @MainActor () -> Void = { [weak self] in
            guard let self, let panel = self.panel, self.movementToken == token else { return }
            self.stateMachine.transition(to: .walk)
            self.animateWalk(panel: panel, to: destination, duration: duration, token: token)
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
        move(to: homePosition, completion: nil)
    }

    func moveToCursor(completion: (() -> Void)? = nil) {
        guard let panel else { return }
        let cursor = NSEvent.mouseLocation
        let panelSize = panel.frame.size

        let containingFrame = NSScreen.screens
            .map(\.visibleFrame)
            .first(where: { $0.contains(cursor) }) ?? NSScreen.main?.visibleFrame

        guard let frame = containingFrame else {
            move(to: homePosition, completion: completion)
            return
        }

        // Stop beside cursor instead of centering under it.
        let sideOffset: CGFloat = 30
        let targetX = cursor.x - panelSize.width - sideOffset
        let targetY = cursor.y - panelSize.height / 2
        let clampedX = min(max(targetX, frame.minX + 8), frame.maxX - panelSize.width - 8)
        let clampedY = min(max(targetY, frame.minY + 8), frame.maxY - panelSize.height - 8)
        move(to: CGPoint(x: clampedX, y: clampedY), completion: completion)
    }

    /// Teleports companion to the left edge of the current screen at cursor height,
    /// then walks to the cursor-side destination used by reminder prompts.
    func walkFromLeftEdgeToCursor(completion: (() -> Void)? = nil) {
        guard let panel else { return }
        let cursor = NSEvent.mouseLocation
        let panelSize = panel.frame.size

        let containingFrame = NSScreen.screens
            .map(\.visibleFrame)
            .first(where: { $0.contains(cursor) }) ?? NSScreen.main?.visibleFrame

        guard let frame = containingFrame else {
            moveToCursor(completion: completion)
            return
        }

        let sideOffset: CGFloat = 30
        let targetX = cursor.x - panelSize.width - sideOffset
        let targetY = cursor.y - panelSize.height / 2
        let destinationX = min(max(targetX, frame.minX + 8), frame.maxX - panelSize.width - 8)
        let destinationY = min(max(targetY, frame.minY + 8), frame.maxY - panelSize.height - 8)

        let startX = frame.minX + 8
        movementToken = UUID()
        pendingCompletion = nil
        isMoving = false
        currentDestination = nil
        facing = .right
        stateMachine.setFacingRight(true)
        panel.setFrameOrigin(CGPoint(x: startX, y: destinationY))

        move(to: CGPoint(x: destinationX, y: destinationY), completion: completion)
    }

    /// Teleports the buddy to the left edge of the current screen at cursor height,
    /// then walks straight across to the right edge.
    func walkAcrossScreen(completion: (() -> Void)? = nil) {
        guard let panel else { return }
        let cursor = NSEvent.mouseLocation
        let panelSize = panel.frame.size

        let containingFrame = NSScreen.screens
            .map(\.visibleFrame)
            .first(where: { $0.contains(cursor) }) ?? NSScreen.main?.visibleFrame

        guard let frame = containingFrame else { return }

        let walkY = min(
            max(cursor.y - panelSize.height / 2, frame.minY + 8),
            frame.maxY - panelSize.height - 8
        )
        let startX = frame.minX + 8
        let endX = frame.maxX - panelSize.width - 8

        movementToken = UUID()
        pendingCompletion = nil
        isMoving = false
        currentDestination = nil

        facing = .right
        stateMachine.setFacingRight(true)
        panel.setFrameOrigin(CGPoint(x: startX, y: walkY))

        move(to: CGPoint(x: endX, y: walkY), completion: completion)
    }

    func cancelMovement() {
        movementToken = UUID()
        isMoving = false
        currentDestination = nil
        transitionToStopPose()
        pendingCompletion = nil
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

    private func animateWalk(panel: NSPanel, to destination: CGPoint, duration: TimeInterval, token: UUID) {
        let start = panel.frame.origin
        let dx = destination.x - start.x
        let dy = destination.y - start.y
        let startTime = CACurrentMediaTime()
        let stepInterval: TimeInterval = 1.0 / 60.0

        func finishIfCurrentToken() {
            guard movementToken == token else { return }
            panel.setFrameOrigin(destination)
            currentDestination = nil
            isMoving = false
            transitionToStopPose()
            let completion = pendingCompletion
            pendingCompletion = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + Timing.landingBounceDuration) {
                completion?()
            }
        }

        func step() {
            guard movementToken == token else { return }

            if duration <= 0 {
                finishIfCurrentToken()
                return
            }

            let elapsed = CACurrentMediaTime() - startTime
            let t = min(1.0, max(0.0, elapsed / duration))
            // Smoothstep (ease-in/ease-out)
            let eased = t * t * (3.0 - 2.0 * t)
            let x = start.x + dx * eased
            let y = start.y + dy * eased
            panel.setFrameOrigin(CGPoint(x: x, y: y))

            if t >= 1.0 {
                finishIfCurrentToken()
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + stepInterval) {
                step()
            }
        }

        step()
    }

    private func transitionToStopPose() {
        // `stop` has lower priority than `run`; reset first so stop can apply.
        stateMachine.resetToIdle()
        stateMachine.transition(to: .stop)
        enqueueIdleReset()
    }
}
