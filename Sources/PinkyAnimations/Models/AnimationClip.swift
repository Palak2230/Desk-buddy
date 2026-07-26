import Foundation

/// A single frame in a sprite animation sequence.
public struct AnimationFrame: Sendable, Equatable {
    public let textureName: String
    public let duration: TimeInterval

    public init(textureName: String, duration: TimeInterval = 1.0 / 60.0) {
        self.textureName = textureName
        self.duration = duration
    }
}

/// Defines a complete animation clip with optional looping.
public struct AnimationClip: Sendable, Identifiable {
    public let id: String
    public let frames: [AnimationFrame]
    public let loops: Bool
    public let priority: Int

    public init(
        id: String,
        frames: [AnimationFrame],
        loops: Bool = true,
        priority: Int = 0
    ) {
        self.id = id
        self.frames = frames
        self.loops = loops
        self.priority = priority
    }
}
