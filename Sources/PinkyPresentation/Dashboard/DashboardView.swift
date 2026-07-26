import SwiftUI
import Core
import Theme
import UI
import Services

/// Glassmorphism dashboard showing water stats and streaks.
public struct DashboardView: View {
    @Environment(\.appTheme) private var theme
    @ObservedObject private var coordinator: AppCoordinator

    public init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        VStack(spacing: 20) {
            header
            statsGrid
            Spacer()
        }
        .padding(24)
        .frame(minWidth: 480, minHeight: 360)
        .background(Color(hex: theme.background))
        .onAppear { coordinator.refreshStats() }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Desk Buddy Dashboard")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: theme.text))
                Text("Your wellness companion ✨")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Color(hex: theme.text).opacity(0.6))
            }
            Spacer()
            Text("💧")
                .font(.system(size: 32))
        }
    }

    private var statsGrid: some View {
        HStack(spacing: 16) {
            statCard(title: "Today", value: "\(coordinator.todayWaterCount)", unit: "glasses", icon: "drop.fill")
            statCard(title: "Streak", value: "\(coordinator.currentStreak)", unit: "days", icon: "flame.fill")
            statCard(title: "Goal", value: "8", unit: "glasses/day", icon: "target")
        }
    }

    private func statCard(title: String, value: String, unit: String, icon: String) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: icon)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: theme.accent))
                Text(value)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: theme.text))
                Text(unit)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color(hex: theme.text).opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
