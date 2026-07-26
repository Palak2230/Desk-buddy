import Foundation
import Core

/// A single water intake event.
public struct WaterRecord: EntityIdentifiable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let amountML: Int

    public init(id: UUID = UUID(), timestamp: Date = .now, amountML: Int = 250) {
        self.id = id
        self.timestamp = timestamp
        self.amountML = amountML
    }
}
