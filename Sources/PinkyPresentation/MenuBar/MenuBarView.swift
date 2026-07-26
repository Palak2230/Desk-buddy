import SwiftUI
import PinkyTheme
import PinkyServices

/// Native menu bar extra for quick access to Pinky features.
public struct MenuBarView: View {
    @ObservedObject private var coordinator: AppCoordinator
    private let onOpenDashboard: () -> Void
    private let onTriggerReminder: () -> Void

    public init(
        coordinator: AppCoordinator,
        onOpenDashboard: @escaping () -> Void,
        onTriggerReminder: @escaping () -> Void
    ) {
        self.coordinator = coordinator
        self.onOpenDashboard = onOpenDashboard
        self.onTriggerReminder = onTriggerReminder
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            menuRow("Today's Water", value: "\(coordinator.todayWaterCount) glasses")
            menuRow("Current Streak", value: "\(coordinator.currentStreak) days 🔥")
            Divider()
            Button("Open Dashboard") { onOpenDashboard() }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            Button("Test Water Reminder") { onTriggerReminder() }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            Divider()
            Button("Quit Pinky") { NSApplication.shared.terminate(nil) }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
        }
        .padding(.vertical, 8)
        .frame(width: 220)
    }

    private var header: some View {
        HStack {
            Text("Pinky")
                .font(.system(size: 14, weight: .bold, design: .rounded))
            Spacer()
            Text("🌸")
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
    }

    private func menuRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, design: .rounded))
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}
