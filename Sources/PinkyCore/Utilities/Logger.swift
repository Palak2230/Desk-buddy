import Foundation
import os.log

/// Lightweight logging utility for Pinky modules.
public enum PinkyLogger {
    private static let subsystem = "com.pinky.app"

    public static func log(_ category: String, _ message: String) {
        #if DEBUG
        let logger = Logger(subsystem: subsystem, category: category)
        logger.debug("\(message, privacy: .public)")
        #endif
    }
}
