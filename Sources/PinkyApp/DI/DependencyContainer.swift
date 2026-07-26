import Foundation
import Services
import Character
import Skills

/// Root dependency injection container for the Desk Buddy application.
@MainActor
public final class DependencyContainer: ObservableObject {
    public let coordinator: AppCoordinator
    public let stateMachine: CharacterStateMachine
    public let skillRegistry: SkillRegistry
    public let waterSkill: WaterReminderSkill

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

        self.coordinator = coordinator
        self.stateMachine = stateMachine
        self.skillRegistry = skillRegistry
        self.waterSkill = waterSkill
    }

    public func bootstrap() async {
        await skillRegistry.register(waterSkill)
        waterSkill.scheduleReminder(afterMinutes: coordinator.settings.reminderIntervalMinutes)
    }
}
