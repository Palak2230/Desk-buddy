import Foundation

/// Abstraction over local settings persistence.
public protocol SettingsStoreProtocol: Sendable {
    func load() -> AppSettings
    func save(_ settings: AppSettings)
}
