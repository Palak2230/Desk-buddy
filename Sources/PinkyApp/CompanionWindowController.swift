import AppKit
import SwiftUI
import Presentation

/// Manages the floating companion window using AppKit for precise desktop positioning.
@MainActor
final class CompanionWindowController: NSWindowController {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container

        let contentView = CompanionWindowView(
            stateMachine: container.stateMachine,
            waterSkill: container.waterSkill,
            scale: container.coordinator.settings.characterScale
        )
        .environment(\.appTheme, container.theme)

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

        // Position in bottom-right corner
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.maxX - 180
            let y = screenFrame.minY + 20
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        super.init(window: panel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        window?.orderFrontRegardless()
    }
}
