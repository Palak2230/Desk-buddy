import Foundation

/// Playback policy for animation clips.
public enum AnimationPlaybackMode: String, Codable, Sendable {
    case loop
    case once
    case pingPong
}

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
    public let playbackMode: AnimationPlaybackMode
    public let priority: Int
    
    /// Backward-compatible convenience for existing call sites.
    public var loops: Bool {
        switch playbackMode {
        case .loop, .pingPong:
            return true
        case .once:
            return false
        }
    }

    public init(
        id: String,
        frames: [AnimationFrame],
        playbackMode: AnimationPlaybackMode = .loop,
        priority: Int = 0
    ) {
        self.id = id
        self.frames = frames
        self.playbackMode = playbackMode
        self.priority = priority
    }

    public init(
        id: String,
        frames: [AnimationFrame],
        loops: Bool,
        priority: Int = 0
    ) {
        self.init(
            id: id,
            frames: frames,
            playbackMode: loops ? .loop : .once,
            priority: priority
        )
    }
}
