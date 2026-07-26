import Foundation
import UserNotifications
import Core

/// Wraps `UNUserNotificationCenter` for local offline notifications.
public final class NotificationService: @unchecked Sendable {
    public static let shared = NotificationService()

    private let center: UNUserNotificationCenter?

    private init() {
        // `swift run` launches an executable without a full app bundle context;
        // requesting UNUserNotificationCenter in that mode can crash.
        if Bundle.main.bundleIdentifier == nil {
            center = nil
            AppLogger.log("Notifications", "Notification center unavailable outside app bundle context")
        } else {
            center = UNUserNotificationCenter.current()
        }
    }

    public func requestAuthorization() async -> Bool {
        guard let center else { return false }
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            AppLogger.log("Notifications", "Authorization failed: \(error)")
            return false
        }
    }

    public func scheduleWaterReminder(afterMinutes minutes: Int) {
        guard let center else { return }

        let content = UNMutableNotificationContent()
        content.title = "Desk Buddy"
        content.body = "Did you drink water? 💧"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(minutes * 60),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "water-reminder-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    public func cancelAll() {
        guard let center else { return }
        center.removeAllPendingNotificationRequests()
    }
}
