import Foundation

/// Contract every Pinky skill (feature plugin) must implement.
public protocol PinkySkill: AnyObject, Sendable {
    /// Unique identifier for the skill (e.g. `"water"`).
    var id: String { get }

    /// Human-readable name shown in UI.
    var displayName: String { get }

    /// SF Symbol or asset name for menu representation.
    var iconName: String { get }

    /// Called when the skill is registered at app launch.
    func activate() async

    /// Called when the skill is torn down (app quit or disable).
    func deactivate() async
}
