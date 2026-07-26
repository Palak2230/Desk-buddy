import Foundation

/// All animation states the companion character can be in.
public enum CharacterState: String, CaseIterable, Codable, Sendable {
    case idle
    case turn
    case stop
    case blink
    case breathing
    case walk
    case run
    case wave
    case drink
    case sleep
    case happy
    case sad
    case think
    case peek
    case celebrate
    case greeting

    /// Whether this state loops indefinitely until interrupted.
    public var isLooping: Bool {
        switch self {
        case .idle, .breathing, .walk, .run, .sleep, .greeting:
            return true
        default:
            return false
        }
    }

    /// Priority for animation interruption (higher wins).
    public var priority: Int {
        switch self {
        case .celebrate, .drink, .wave, .greeting:
            return 100
        case .peek, .happy, .sad:
            return 80
        case .walk, .run:
            return 60
        case .turn, .stop, .blink, .think:
            return 40
        case .idle, .breathing, .sleep:
            return 10
        }
    }
}
