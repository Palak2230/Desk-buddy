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
        hostingView.frame.size = CGSize(width: 320, height: 220)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 220),
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

        let storedX = defaults.double(forKey: Keys.originX)
        let storedY = defaults.double(forKey: Keys.originY)
        let homePosition = Self.normalizedHomePosition(
            stored: NSPoint(x: storedX, y: storedY),
            panelSize: panel.frame.size
        )

        // Start slightly right of home, then walk in (no teleport pop-in).
        panel.setFrameOrigin(NSPoint(x: homePosition.x + panel.frame.width + 20, y: homePosition.y))

        super.init(window: panel)
        movementController = CompanionMovementController(
            panel: panel,
            stateMachine: container.stateMachine,
            homePosition: homePosition,
            walkingSpeedProvider: { [weak container] in
                container?.coordinator.settings.walkingSpeed ?? 220
            }
        )
        container.waterSkill.requestReminderApproach = { [weak self] completion in
            Task { @MainActor [weak self] in
                self?.movementController?.walkFromLeftEdgeToCursor(completion: completion)
            }
        }
        container.waterSkill.requestReturnHome = { [weak self] in
            Task { @MainActor [weak self] in
                self?.movementController?.walkHome()
            }
        }
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

    func moveBuddyToCursor(completion: (() -> Void)? = nil) {
        movementController?.moveToCursor(completion: completion)
    }

    func walkBuddyAcrossScreen(completion: (() -> Void)? = nil) {
        movementController?.walkAcrossScreen(completion: completion)
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

    private static func normalizedHomePosition(stored: NSPoint, panelSize: NSSize) -> NSPoint {
        let candidate: NSPoint
        if stored.x > 0, stored.y > 0 {
            candidate = stored
        } else if let main = NSScreen.main?.visibleFrame {
            candidate = NSPoint(x: main.maxX - panelSize.width - 20, y: main.minY + 20)
        } else {
            candidate = NSPoint(x: 20, y: 20)
        }

        let availableFrames = NSScreen.screens.map(\.visibleFrame)
        guard let frame = availableFrames.first(where: { frame in
            candidate.x >= frame.minX - 40 &&
                candidate.x <= frame.maxX + 40 &&
                candidate.y >= frame.minY - 40 &&
                candidate.y <= frame.maxY + 40
        }) ?? NSScreen.main?.visibleFrame else {
            return candidate
        }

        let clampedX = min(max(candidate.x, frame.minX + 8), frame.maxX - panelSize.width - 8)
        let clampedY = min(max(candidate.y, frame.minY + 8), frame.maxY - panelSize.height - 8)
        return NSPoint(x: clampedX, y: clampedY)
    }
}
