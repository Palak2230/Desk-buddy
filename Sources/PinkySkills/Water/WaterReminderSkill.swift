import Foundation
import Core
import Domain
import Character

/// Water Reminder — the first built-in Desk Buddy skill.
@MainActor
public final class WaterReminderSkill: Skill, ObservableObject {
    public let id = "water"
    public let displayName = "Water Reminder"
    public let iconName = "drop.fill"

    @Published public var isReminderActive = false

    private let waterStore: WaterStoreProtocol
    private let stateMachine: CharacterStateMachine
    private let playSound: (_ kind: SoundKind) -> Void
    private var reminderTimer: Timer?
    private var ignoreWorkItem: DispatchWorkItem?

    public enum SoundKind: Sendable {
        case reminder
        case success
        case snooze
    }

    public init(
        waterStore: WaterStoreProtocol,
        stateMachine: CharacterStateMachine,
        playSound: @escaping (_ kind: SoundKind) -> Void = { _ in }
    ) {
        self.waterStore = waterStore
        self.stateMachine = stateMachine
        self.playSound = playSound
    }

    public func activate() async {
        AppLogger.log("WaterSkill", "Water Reminder skill activated")
    }

    public func deactivate() async {
        ignoreWorkItem?.cancel()
        ignoreWorkItem = nil
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
        ignoreWorkItem?.cancel()
        isReminderActive = false
        playSound(.reminder)
        stateMachine.transition(to: .walk)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self else { return }
            stateMachine.transition(to: .wave)
            isReminderActive = true
            scheduleIgnoreFallback()
        }
    }

    /// Records a positive water intake response.
    public func confirmDrink() {
        ignoreWorkItem?.cancel()
        ignoreWorkItem = nil
        waterStore.addRecord(WaterRecord())
        playSound(.success)
        isReminderActive = false
        stateMachine.transition(to: .drink)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.stateMachine.transition(to: .happy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self?.stateMachine.transition(to: .walk)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.stateMachine.resetToIdle()
                }
            }
        }
    }

    /// Snoozes the reminder for 5 minutes.
    public func snooze() {
        ignoreWorkItem?.cancel()
        ignoreWorkItem = nil
        playSound(.snooze)
        isReminderActive = false
        stateMachine.resetToIdle()
        scheduleReminder(afterMinutes: 5)
    }

    private func scheduleIgnoreFallback() {
        ignoreWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self, isReminderActive else { return }

            isReminderActive = false
            stateMachine.transition(to: .peek)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.stateMachine.resetToIdle()
            }

            scheduleReminder(afterMinutes: 5)
        }

        ignoreWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: workItem)
    }
}
