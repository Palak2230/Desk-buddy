import Foundation
import Combine
import PinkyDomain
import PinkyPersistence

/// Central application coordinator wiring stores and services together.
@MainActor
public final class AppCoordinator: ObservableObject {
    @Published public private(set) var settings: AppSettings
    @Published public private(set) var todayWaterCount: Int = 0
    @Published public private(set) var currentStreak: Int = 0

    public let settingsStore: SettingsStoreProtocol
    public let waterStore: WaterStoreProtocol

    public init(
        settingsStore: SettingsStoreProtocol = SettingsStore(),
        waterStore: WaterStoreProtocol = WaterStore()
    ) {
        self.settingsStore = settingsStore
        self.waterStore = waterStore
        self.settings = settingsStore.load()
        refreshStats()
    }

    public func updateSettings(_ settings: AppSettings) {
        self.settings = settings
        settingsStore.save(settings)
    }

    public func refreshStats() {
        todayWaterCount = waterStore.todayCount()
        currentStreak = waterStore.currentStreak()
    }

    public func recordWater() {
        waterStore.addRecord(WaterRecord())
        refreshStats()
    }
}
