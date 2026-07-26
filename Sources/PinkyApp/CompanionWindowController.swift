import AppKit
import SwiftUI
import Presentation
import Character

/// Manages the floating companion window using AppKit for precise desktop positioning.
@MainActor
final class CompanionWindowController: NSWindowController {
    private let container: DependencyContainer
    private let defaults = UserDefaults.standard
    private var moveObserver: NSObjectProtocol?
    private var movementController: CompanionMovementController?

    private enum Keys {
        static let originX = "com.palakagarwal.deskbuddy.window.originX"
        static let originY = "com.palakagarwal.deskbuddy.window.originY"
    }

    init(container: DependencyContainer) {
        self.container = container

        let contentView = CompanionWindowView(
            stateMachine: container.stateMachine,
            waterSkill: container.waterSkill,
            scale: container.coordinator.settings.characterScale
        )
        .environment(\.appTheme, container.coordinator.activeTheme)

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame.size = CGSize(width: 160, height: 200)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 160, height: 200),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.contentView = hostingView
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        panel.hasShadow = false
        panel.isMovableByWindowBackground = true

        let x = defaults.double(forKey: Keys.originX)
        let y = defaults.double(forKey: Keys.originY)
        let homePosition: NSPoint
        if x > 0, y > 0 {
            homePosition = NSPoint(x: x, y: y)
        } else if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            homePosition = NSPoint(x: screenFrame.maxX - 180, y: screenFrame.minY + 20)
        } else {
            homePosition = NSPoint(x: 20, y: 20)
        }

        // Start just outside the right screen edge, then walk to home.
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(x: screenFrame.maxX + 8, y: homePosition.y))
        } else {
            panel.setFrameOrigin(homePosition)
        }

        super.init(window: panel)
        movementController = CompanionMovementController(
            panel: panel,
            stateMachine: container.stateMachine,
            homePosition: homePosition,
            walkingSpeedProvider: { [weak container] in
                container?.coordinator.settings.walkingSpeed ?? 220
            }
        )
        observeWindowMoves(panel: panel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        window?.orderFrontRegardless()
        movementController?.walkHome()
    }

    deinit {
        if let moveObserver {
            NotificationCenter.default.removeObserver(moveObserver)
        }
    }

    private func observeWindowMoves(panel: NSPanel) {
        moveObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: panel,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor [weak self] in
                guard
                    let self,
                    let window = notification.object as? NSWindow
                else { return }

                let origin = window.frame.origin
                defaults.set(origin.x, forKey: Keys.originX)
                defaults.set(origin.y, forKey: Keys.originY)
                movementController?.updateHomePosition(origin)
            }
        }
    }
}
