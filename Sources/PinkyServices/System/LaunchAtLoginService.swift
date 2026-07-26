import Foundation
import ServiceManagement
import Core

/// Handles launch-at-login registration for the main app.
@MainActor
public final class LaunchAtLoginService {
    public init() {}

    public func setEnabled(_ enabled: Bool) {
        guard #available(macOS 13.0, *) else { return }

        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            AppLogger.log("LaunchAtLogin", "Failed to update launch-at-login: \(error)")
        }
    }
}
