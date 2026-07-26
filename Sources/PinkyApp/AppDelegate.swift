import AppKit
import SwiftUI
import Presentation
import Notifications

/// Application delegate handling lifecycle, windows, and menu bar setup.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var container: DependencyContainer!
    private var companionWindow: CompanionWindowController?
    private var dashboardWindow: NSWindow?
    private var settingsWindow: NSWindow?
    private var statusMenu: NSMenu?
    private var menuRefreshTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon — Desk Buddy lives in menu bar and on desktop
        NSApp.setActivationPolicy(.accessory)

        container = DependencyContainer()

        Task {
            _ = await NotificationService.shared.requestAuthorization()
            await container.bootstrap()
        }

        setupCompanionWindow()
        setupMenuBar()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    // MARK: - Setup

    private func setupCompanionWindow() {
        companionWindow = CompanionWindowController(container: container)
        companionWindow?.show()
    }

    private func setupMenuBar() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "heart.fill", accessibilityDescription: "Desk Buddy")
            button.image?.isTemplate = true
        }

        let menu = NSMenu()
        menu.addItem(makeMenuItem(title: "Today's Water: 0 glasses", action: nil))
        menu.addItem(.separator())

        menu.addItem(makeMenuItem(title: "Open Dashboard", action: #selector(openDashboard)))
        menu.addItem(makeMenuItem(title: "Settings", action: #selector(openSettings)))
        menu.addItem(makeMenuItem(title: "Test Water Reminder", action: #selector(testReminder)))
        menu.addItem(.separator())
        menu.addItem(makeMenuItem(title: "Quit Desk Buddy", action: #selector(quit)))

        statusItem.menu = menu
        statusMenu = menu

        menuRefreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshMenuBar()
            }
        }
    }

    private func refreshMenuBar() {
        guard let menu = statusMenu else { return }
        container.coordinator.refreshStats()
        if let item = menu.items.first {
            item.title = "Today's Water: \(container.coordinator.todayWaterCount) glasses"
        }
    }

    private func makeMenuItem(title: String, action: Selector?) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    // MARK: - Actions

    @objc private func openDashboard() {
        if dashboardWindow == nil {
            let view = DashboardView(coordinator: container.coordinator)
                .environment(\.appTheme, container.theme)

            let hosting = NSHostingController(rootView: view)
            let window = NSWindow(contentViewController: hosting)
            window.title = "Desk Buddy Dashboard"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.setContentSize(NSSize(width: 520, height: 400))
            window.center()
            dashboardWindow = window
        }

        dashboardWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let view = SettingsView(coordinator: container.coordinator)
                .environment(\.appTheme, container.theme)

            let hosting = NSHostingController(rootView: view)
            let window = NSWindow(contentViewController: hosting)
            window.title = "Desk Buddy Settings"
            window.styleMask = [.titled, .closable]
            window.setContentSize(NSSize(width: 440, height: 400))
            window.center()
            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func testReminder() {
        container.waterSkill.triggerReminder()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
