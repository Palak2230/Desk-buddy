import Foundation

/// JSON manifest describing sprite-sheet driven clips.
public struct SpriteSheetManifest: Codable, Sendable {
    public struct Clip: Codable, Sendable {
        public let id: String
        public let frameCount: Int
        public let frameDuration: TimeInterval
        public let loops: Bool
        public let priority: Int
    }

    public let id: String
    public let clips: [Clip]
}
