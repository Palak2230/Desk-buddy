import Foundation
import Services
import Character
import Skills
import Theme

/// Root dependency injection container for the Desk Buddy application.
@MainActor
public final class DependencyContainer: ObservableObject {
    public let coordinator: AppCoordinator
    public let stateMachine: CharacterStateMachine
    public let skillRegistry: SkillRegistry
    public let waterSkill: WaterReminderSkill
    public let theme: Theme

    public init() {
        let coordinator = AppCoordinator()
        let stateMachine = CharacterStateMachine {
            coordinator.settings.randomIdleActionsEnabled
        }
        let waterSkill = WaterReminderSkill(
            waterStore: coordinator.waterStore,
            stateMachine: stateMachine
        )
        let skillRegistry = SkillRegistry()
        let theme = ThemeLoader.shared.loadTheme(id: coordinator.settings.themeID)
            ?? ThemeLoader.fallbackTheme

        self.coordinator = coordinator
        self.stateMachine = stateMachine
        self.skillRegistry = skillRegistry
        self.waterSkill = waterSkill
        self.theme = theme
    }

    public func bootstrap() async {
        await skillRegistry.register(waterSkill)
        waterSkill.scheduleReminder(afterMinutes: coordinator.settings.reminderIntervalMinutes)
    }
}
