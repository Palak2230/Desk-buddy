import Foundation
import Combine
import Domain
import Persistence
import Theme

/// Central application coordinator wiring stores and services together.
@MainActor
public final class AppCoordinator: ObservableObject {
    public struct AchievementBadge: Identifiable, Sendable {
        public let id: String
        public let title: String
        public let icon: String
        public let isUnlocked: Bool
    }

    @Published public private(set) var settings: AppSettings
    @Published public private(set) var todayWaterCount: Int = 0
    @Published public private(set) var currentStreak: Int = 0
    @Published public private(set) var weeklyWaterCounts: [Int] = Array(repeating: 0, count: 7)
    @Published public private(set) var activeTheme: Theme
    @Published public private(set) var achievements: [AchievementBadge] = []

    public let settingsStore: SettingsStoreProtocol
    public let waterStore: WaterStoreProtocol
    public let launchAtLoginService: LaunchAtLoginService
    public let soundService: CompanionSoundService

    public init(
        settingsStore: SettingsStoreProtocol = SettingsStore(),
        waterStore: WaterStoreProtocol = WaterStore(),
        launchAtLoginService: LaunchAtLoginService? = nil,
        soundService: CompanionSoundService? = nil
    ) {
        let loadedSettings = settingsStore.load()
        self.settingsStore = settingsStore
        self.waterStore = waterStore
        self.launchAtLoginService = launchAtLoginService ?? LaunchAtLoginService()
        self.soundService = soundService ?? CompanionSoundService()
        self.settings = loadedSettings
        self.activeTheme = ThemeLoader.shared.loadTheme(id: loadedSettings.themeID) ?? ThemeLoader.fallbackTheme
        refreshStats()
    }

    public func updateSettings(_ settings: AppSettings) {
        let previous = self.settings
        self.settings = settings
        settingsStore.save(settings)
        activeTheme = ThemeLoader.shared.loadTheme(id: settings.themeID) ?? ThemeLoader.fallbackTheme

        if previous.launchAtLogin != settings.launchAtLogin {
            launchAtLoginService.setEnabled(settings.launchAtLogin)
        }
    }

    public func refreshStats() {
        todayWaterCount = waterStore.todayCount()
        currentStreak = waterStore.currentStreak()
        weeklyWaterCounts = waterStore.recentDailyCounts(days: 7)
        achievements = buildAchievements()
    }

    public func recordWater() {
        waterStore.addRecord(WaterRecord())
        refreshStats()
    }

    private func buildAchievements() -> [AchievementBadge] {
        [
            AchievementBadge(
                id: "first-glass",
                title: "First Sip",
                icon: "drop.fill",
                isUnlocked: todayWaterCount >= 1
            ),
            AchievementBadge(
                id: "daily-goal",
                title: "Daily Goal",
                icon: "target",
                isUnlocked: todayWaterCount >= 8
            ),
            AchievementBadge(
                id: "streak-3",
                title: "3-Day Streak",
                icon: "flame.fill",
                isUnlocked: currentStreak >= 3
            ),
            AchievementBadge(
                id: "streak-7",
                title: "7-Day Streak",
                icon: "sparkles",
                isUnlocked: currentStreak >= 7
            ),
        ]
    }
}
