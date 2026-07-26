import Foundation
import UserNotifications
import Core

/// Wraps `UNUserNotificationCenter` for local offline notifications.
public final class NotificationService: @unchecked Sendable {
    public static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    public func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            AppLogger.log("Notifications", "Authorization failed: \(error)")
            return false
        }
    }

    public func scheduleWaterReminder(afterMinutes minutes: Int) {
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
        center.removeAllPendingNotificationRequests()
    }
}
