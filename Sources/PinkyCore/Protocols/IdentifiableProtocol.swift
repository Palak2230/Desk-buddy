import Foundation

/// Marker protocol for domain entities with stable identifiers.
public protocol EntityIdentifiable: Identifiable, Hashable, Sendable {
    var id: UUID { get }
}
