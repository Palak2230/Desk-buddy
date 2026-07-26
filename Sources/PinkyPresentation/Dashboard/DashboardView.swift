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
            weeklyProgressCard
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

    private var weeklyProgressCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("7-Day Hydration", systemImage: "chart.bar.fill")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: theme.accent))

                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(coordinator.weeklyWaterCounts.enumerated()), id: \.offset) { index, count in
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: theme.primary).opacity(index == 6 ? 0.95 : 0.6))
                                .frame(width: 24, height: barHeight(for: count))
                            Text(shortDayLabel(offsetFromToday: 6 - index))
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(hex: theme.text).opacity(0.65))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("Goal: 8 glasses/day")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color(hex: theme.text).opacity(0.6))
            }
        }
    }

    private func barHeight(for count: Int) -> Double {
        let clamped = min(max(count, 0), 10)
        return 14 + Double(clamped) * 7
    }

    private func shortDayLabel(offsetFromToday: Int) -> String {
        guard let date = Calendar.current.date(byAdding: .day, value: -offsetFromToday, to: .now) else {
            return "-"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}
