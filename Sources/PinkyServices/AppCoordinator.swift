import Foundation
import Combine
import Domain
import Persistence
import Theme

/// Central application coordinator wiring stores and services together.
@MainActor
public final class AppCoordinator: ObservableObject {
    @Published public private(set) var settings: AppSettings
    @Published public private(set) var todayWaterCount: Int = 0
    @Published public private(set) var currentStreak: Int = 0
    @Published public private(set) var weeklyWaterCounts: [Int] = Array(repeating: 0, count: 7)
    @Published public private(set) var activeTheme: Theme

    public let settingsStore: SettingsStoreProtocol
    public let waterStore: WaterStoreProtocol

    public init(
        settingsStore: SettingsStoreProtocol = SettingsStore(),
        waterStore: WaterStoreProtocol = WaterStore()
    ) {
        let loadedSettings = settingsStore.load()
        self.settingsStore = settingsStore
        self.waterStore = waterStore
        self.settings = loadedSettings
        self.activeTheme = ThemeLoader.shared.loadTheme(id: loadedSettings.themeID) ?? ThemeLoader.fallbackTheme
        refreshStats()
    }

    public func updateSettings(_ settings: AppSettings) {
        self.settings = settings
        settingsStore.save(settings)
        activeTheme = ThemeLoader.shared.loadTheme(id: settings.themeID) ?? ThemeLoader.fallbackTheme
    }

    public func refreshStats() {
        todayWaterCount = waterStore.todayCount()
        currentStreak = waterStore.currentStreak()
        weeklyWaterCounts = waterStore.recentDailyCounts(days: 7)
    }

    public func recordWater() {
        waterStore.addRecord(WaterRecord())
        refreshStats()
    }
}
