import Foundation
import PinkyCore
import PinkyDomain
import PinkyCharacter

/// Water Reminder — the first built-in Pinky skill.
@MainActor
public final class WaterReminderSkill: PinkySkill, ObservableObject {
    public let id = "water"
    public let displayName = "Water Reminder"
    public let iconName = "drop.fill"

    @Published public var isReminderActive = false

    private let waterStore: WaterStoreProtocol
    private let stateMachine: CharacterStateMachine
    private var reminderTimer: Timer?

    public init(waterStore: WaterStoreProtocol, stateMachine: CharacterStateMachine) {
        self.waterStore = waterStore
        self.stateMachine = stateMachine
    }

    public func activate() async {
        PinkyLogger.log("WaterSkill", "Water Reminder skill activated")
    }

    public func deactivate() async {
        reminderTimer?.invalidate()
        reminderTimer = nil
    }

    /// Schedules the next water reminder after the given interval.
    public func scheduleReminder(afterMinutes minutes: Int) {
        reminderTimer?.invalidate()
        reminderTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(minutes * 60), repeats: false) { _ in
            Task { @MainActor [weak self] in
                self?.triggerReminder()
            }
        }
    }

    /// Triggers the water reminder sequence on the companion.
    public func triggerReminder() {
        isReminderActive = true
        stateMachine.transition(to: .walk)
    }

    /// Records a positive water intake response.
    public func confirmDrink() {
        waterStore.addRecord(WaterRecord())
        isReminderActive = false
        stateMachine.transition(to: .drink)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.stateMachine.transition(to: .happy)
        }
    }

    /// Snoozes the reminder for 5 minutes.
    public func snooze() {
        isReminderActive = false
        stateMachine.resetToIdle()
        scheduleReminder(afterMinutes: 5)
    }
}
