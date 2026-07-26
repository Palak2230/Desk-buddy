import Foundation

/// JSON-driven theme definition loaded from bundle resources.
public struct Theme: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let primary: String
    public let secondary: String
    public let accent: String
    public let background: String
    public let surface: String
    public let text: String
    public let speechBubble: String

    public init(
        id: String,
        name: String,
        primary: String,
        secondary: String,
        accent: String,
        background: String,
        surface: String,
        text: String,
        speechBubble: String
    ) {
        self.id = id
        self.name = name
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.background = background
        self.surface = surface
        self.text = text
        self.speechBubble = speechBubble
    }
}
