import SwiftUI
import Domain
import Services
import Theme

/// Application settings panel.
public struct SettingsView: View {
    @ObservedObject private var coordinator: AppCoordinator
    private let availableThemes: [Theme]

    public init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.availableThemes = ThemeLoader.shared
            .allThemes()
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    public var body: some View {
        Form {
            Section("Reminders") {
                Stepper(
                    "Interval: \(coordinator.settings.reminderIntervalMinutes) min",
                    value: binding(\.reminderIntervalMinutes),
                    in: 15 ... 180,
                    step: 15
                )
            }

            Section("Companion") {
                Slider(value: binding(\.characterScale), in: 0.5 ... 2.0) {
                    Text("Character Size")
                }
                Toggle("Animations", isOn: binding(\.animationsEnabled))
                Toggle("Random Idle Actions", isOn: binding(\.randomIdleActionsEnabled))
            }

            Section("Theme") {
                Picker("Theme", selection: binding(\.themeID)) {
                    ForEach(availableThemes) { theme in
                        Text(theme.name).tag(theme.id)
                    }
                }
            }

            Section("System") {
                Toggle("Launch at Login", isOn: binding(\.launchAtLogin))
                Slider(value: binding(\.volume), in: 0 ... 1) {
                    Text("Volume")
                }
                Slider(value: binding(\.speechSpeed), in: 0.5 ... 2.0) {
                    Text("Speech Speed")
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 380)
    }

    private func binding(_ keyPath: WritableKeyPath<AppSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { coordinator.settings[keyPath: keyPath] },
            set: { newValue in
                var settings = coordinator.settings
                settings[keyPath: keyPath] = newValue
                coordinator.updateSettings(settings)
            }
        )
    }

    private func binding(_ keyPath: WritableKeyPath<AppSettings, Int>) -> Binding<Int> {
        Binding(
            get: { coordinator.settings[keyPath: keyPath] },
            set: { newValue in
                var settings = coordinator.settings
                settings[keyPath: keyPath] = newValue
                coordinator.updateSettings(settings)
            }
        )
    }

    private func binding(_ keyPath: WritableKeyPath<AppSettings, Double>) -> Binding<Double> {
        Binding(
            get: { coordinator.settings[keyPath: keyPath] },
            set: { newValue in
                var settings = coordinator.settings
                settings[keyPath: keyPath] = newValue
                coordinator.updateSettings(settings)
            }
        )
    }

    private func binding(_ keyPath: WritableKeyPath<AppSettings, String>) -> Binding<String> {
        Binding(
            get: { coordinator.settings[keyPath: keyPath] },
            set: { newValue in
                var settings = coordinator.settings
                settings[keyPath: keyPath] = newValue
                coordinator.updateSettings(settings)
            }
        )
    }
}
