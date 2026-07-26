import Foundation
import PinkyDomain

/// UserDefaults-backed settings persistence.
public final class SettingsStore: SettingsStoreProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let key = "com.pinky.settings"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> AppSettings {
        guard let data = defaults.data(forKey: key),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    public func save(_ settings: AppSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: key)
    }
}
