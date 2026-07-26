import Foundation

/// JSON manifest describing sprite-sheet driven clips.
public struct SpriteSheetManifest: Codable, Sendable {
    public struct Clip: Codable, Sendable {
        public let id: String
        public let frameCount: Int
        public let frameDuration: TimeInterval
        public let loops: Bool?
        public let playMode: AnimationPlaybackMode?
        public let priority: Int

        public var resolvedPlaybackMode: AnimationPlaybackMode {
            if let playMode {
                return playMode
            }
            return (loops ?? true) ? .loop : .once
        }
    }

    public let id: String
    public let clips: [Clip]
}
