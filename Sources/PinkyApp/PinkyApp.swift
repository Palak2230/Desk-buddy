import SwiftUI

@main
struct DeskBuddyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // Settings scene required for SwiftUI App lifecycle; actual UI is managed by AppDelegate.
        Settings {
            EmptyView()
        }
    }
}
