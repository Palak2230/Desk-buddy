import Foundation

/// Marker protocol for domain entities with stable identifiers.
public protocol PinkyIdentifiable: Identifiable, Hashable, Sendable {
    var id: UUID { get }
}
