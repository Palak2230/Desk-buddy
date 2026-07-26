import Foundation

/// User-configurable application settings persisted locally.
public struct AppSettings: Codable, Sendable, Equatable {
    public var reminderIntervalMinutes: Int
    public var characterScale: Double
    public var themeID: String
    public var volume: Double
    public var launchAtLogin: Bool
    public var animationsEnabled: Bool
    public var speechSpeed: Double
    public var randomIdleActionsEnabled: Bool

    public static let `default` = AppSettings(
        reminderIntervalMinutes: 60,
        characterScale: 1.0,
        themeID: "strawberry-milk",
        volume: 0.8,
        launchAtLogin: false,
        animationsEnabled: true,
        speechSpeed: 1.0,
        randomIdleActionsEnabled: true
    )

    public init(
        reminderIntervalMinutes: Int = 60,
        characterScale: Double = 1.0,
        themeID: String = "strawberry-milk",
        volume: Double = 0.8,
        launchAtLogin: Bool = false,
        animationsEnabled: Bool = true,
        speechSpeed: Double = 1.0,
        randomIdleActionsEnabled: Bool = true
    ) {
        self.reminderIntervalMinutes = reminderIntervalMinutes
        self.characterScale = characterScale
        self.themeID = themeID
        self.volume = volume
        self.launchAtLogin = launchAtLogin
        self.animationsEnabled = animationsEnabled
        self.speechSpeed = speechSpeed
        self.randomIdleActionsEnabled = randomIdleActionsEnabled
    }
}
