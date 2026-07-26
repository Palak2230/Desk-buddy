import CoreGraphics

/// Movement controller contract for physically moving the desktop companion.
@MainActor
public protocol CompanionMovementControlling: AnyObject {
    var currentDestination: CGPoint? { get }
    var isMoving: Bool { get }

    func move(to destination: CGPoint)
    func walkHome()
    func cancelMovement()
}
