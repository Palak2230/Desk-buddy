import Foundation
import Domain

/// UserDefaults-backed water intake persistence.
public final class WaterStore: WaterStoreProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let key = "com.palakagarwal.deskbuddy.water.records"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func records(for date: Date) -> [WaterRecord] {
        allRecords().filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
    }

    public func addRecord(_ record: WaterRecord) {
        var records = allRecords()
        records.append(record)
        persist(records)
    }

    public func todayCount() -> Int {
        records(for: .now).count
    }

    public func currentStreak() -> Int {
        var streak = 0
        var day = Calendar.current.startOfDay(for: .now)

        while true {
            let count = records(for: day).count
            guard count >= 8 else { break } // 8 glasses = daily goal
            streak += 1
            guard let previous = Calendar.current.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }

        return streak
    }

    public func recentDailyCounts(days: Int) -> [Int] {
        guard days > 0 else { return [] }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        return (0 ..< days).reversed().map { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else {
                return 0
            }
            return records(for: date).count
        }
    }

    // MARK: - Private

    private func allRecords() -> [WaterRecord] {
        guard let data = defaults.data(forKey: key),
              let records = try? JSONDecoder().decode([WaterRecord].self, from: data) else {
            return []
        }
        return records
    }

    private func persist(_ records: [WaterRecord]) {
        guard let data = try? JSONEncoder().encode(records) else { return }
        defaults.set(data, forKey: key)
    }
}
