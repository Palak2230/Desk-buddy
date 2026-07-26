import Foundation

/// Abstraction over water intake persistence.
public protocol WaterStoreProtocol: Sendable {
    func records(for date: Date) -> [WaterRecord]
    func addRecord(_ record: WaterRecord)
    func todayCount() -> Int
    func currentStreak() -> Int
    func recentDailyCounts(days: Int) -> [Int]
}
