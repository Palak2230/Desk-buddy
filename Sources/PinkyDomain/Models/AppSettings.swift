import Foundation

/// User-configurable application settings persisted locally.
public struct AppSettings: Codable, Sendable, Equatable {
    public var reminderIntervalMinutes: Int
    public var characterScale: Double
    public var walkingSpeed: Double
    public var themeID: String
    public var volume: Double
    public var launchAtLogin: Bool
    public var animationsEnabled: Bool
    public var speechSpeed: Double
    public var randomIdleActionsEnabled: Bool

    public static let `default` = AppSettings(
        reminderIntervalMinutes: 60,
        characterScale: 1.0,
        walkingSpeed: 220,
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
        walkingSpeed: Double = 220,
        themeID: String = "strawberry-milk",
        volume: Double = 0.8,
        launchAtLogin: Bool = false,
        animationsEnabled: Bool = true,
        speechSpeed: Double = 1.0,
        randomIdleActionsEnabled: Bool = true
    ) {
        self.reminderIntervalMinutes = reminderIntervalMinutes
        self.characterScale = characterScale
        self.walkingSpeed = walkingSpeed
        self.themeID = themeID
        self.volume = volume
        self.launchAtLogin = launchAtLogin
        self.animationsEnabled = animationsEnabled
        self.speechSpeed = speechSpeed
        self.randomIdleActionsEnabled = randomIdleActionsEnabled
    }

    private enum CodingKeys: String, CodingKey {
        case reminderIntervalMinutes
        case characterScale
        case walkingSpeed
        case themeID
        case volume
        case launchAtLogin
        case animationsEnabled
        case speechSpeed
        case randomIdleActionsEnabled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reminderIntervalMinutes = try container.decodeIfPresent(Int.self, forKey: .reminderIntervalMinutes) ?? 60
        characterScale = try container.decodeIfPresent(Double.self, forKey: .characterScale) ?? 1.0
        walkingSpeed = try container.decodeIfPresent(Double.self, forKey: .walkingSpeed) ?? 220
        themeID = try container.decodeIfPresent(String.self, forKey: .themeID) ?? "strawberry-milk"
        volume = try container.decodeIfPresent(Double.self, forKey: .volume) ?? 0.8
        launchAtLogin = try container.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? false
        animationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .animationsEnabled) ?? true
        speechSpeed = try container.decodeIfPresent(Double.self, forKey: .speechSpeed) ?? 1.0
        randomIdleActionsEnabled = try container.decodeIfPresent(Bool.self, forKey: .randomIdleActionsEnabled) ?? true
    }
}
