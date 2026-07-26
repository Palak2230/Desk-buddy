import Foundation
import os.log

/// Lightweight logging utility for Desk Buddy modules.
public enum AppLogger {
    private static let subsystem = "com.palakagarwal.deskbuddy"

    public static func log(_ category: String, _ message: String) {
        #if DEBUG
        let logger = Logger(subsystem: subsystem, category: category)
        logger.debug("\(message, privacy: .public)")
        #endif
    }
}
