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
    @Published public private(set) var reminderMessage = "Did you drink water? 💧"
    @Published public private(set) var heartBurstID = UUID()
    @Published public private(set) var phase: ReminderPhase = .idle
    /// Optional host callback that moves companion near cursor before prompting.
    public var requestReminderApproach: (((@escaping () -> Void) -> Void))?
    /// Optional host callback to return companion to home after reminder flow.
    public var requestReturnHome: (() -> Void)?

    private let waterStore: WaterStoreProtocol
    private let stateMachine: CharacterStateMachine
    private let playSound: (_ kind: SoundKind) -> Void
    private var reminderTimer: Timer?
    private var flowWorkItems: [DispatchWorkItem] = []
    private var regularReminderIntervalMinutes = 60

    private enum Constants {
        static let walkInDuration: TimeInterval = 1.2
        static let greetingWaveDuration: TimeInterval = 5.0
        static let greetingClosedEyeHold: TimeInterval = 0.25
        static let greetingPostOpenDelay: TimeInterval = 0.05
        static let greetingTotalDuration: TimeInterval = greetingWaveDuration + greetingClosedEyeHold + greetingPostOpenDelay
        static let afterDrinkHappyDelay: TimeInterval = 1.5
        static let afterHappyWalkBackDelay: TimeInterval = 1.2
        static let walkBackResetDelay: TimeInterval = 1.0
        static let firstIgnoreTimeout: TimeInterval = 30
        static let peekDuration: TimeInterval = 1.0
        static let secondChanceTimeout: TimeInterval = 20
        static let snoozeMinutes = 5
    }

    public enum SoundKind: Sendable {
        case reminder
        case success
        case snooze
    }

    public enum ReminderPhase: Sendable, Equatable {
        case idle
        case approaching
        case prompting
        case secondChance
        case completed
        case snoozed
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
        cancelFlow(resetPhase: true)
        reminderTimer?.invalidate()
    }

    /// Schedules the next water reminder after the given interval.
    public func scheduleReminder(afterMinutes minutes: Int) {
        reminderTimer?.invalidate()
        regularReminderIntervalMinutes = max(minutes, Constants.snoozeMinutes)
        reminderTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(minutes * 60), repeats: false) { _ in
            Task { @MainActor [weak self] in
                self?.triggerReminder()
            }
        }
    }

    /// Triggers the water reminder sequence on the companion.
    public func triggerReminder(shouldApproach: Bool = true) {
        reminderTimer?.invalidate()
        cancelFlow(resetPhase: false)
        phase = .approaching
        isReminderActive = false
        reminderMessage = "Did you drink water? 💧"
        playSound(.reminder)
        guard shouldApproach else {
            startGreetingThenPrompt()
            return
        }
        if let requestReminderApproach {
            requestReminderApproach { [weak self] in
                guard let self else { return }
                self.startGreetingThenPrompt()
            }
            return
        }

        stateMachine.transition(to: .walk)
        enqueueFlow(after: Constants.walkInDuration) { [weak self] in
            self?.startGreetingThenPrompt()
        }
    }

    /// Records a positive water intake response.
    public func confirmDrink() {
        cancelFlow(resetPhase: false)
        waterStore.addRecord(WaterRecord())
        playSound(.success)
        heartBurstID = UUID()
        phase = .completed
        isReminderActive = false
        stateMachine.transition(to: .drink)

        enqueueFlow(after: Constants.afterDrinkHappyDelay) { [weak self] in
            self?.stateMachine.transition(to: .happy)
        }

        enqueueFlow(after: Constants.afterDrinkHappyDelay + Constants.afterHappyWalkBackDelay) { [weak self] in
            self?.stateMachine.transition(to: .walk)
        }

        enqueueFlow(
            after: Constants.afterDrinkHappyDelay + Constants.afterHappyWalkBackDelay + Constants.walkBackResetDelay
        ) { [weak self] in
            self?.stateMachine.resetToIdle()
            self?.phase = .idle
            self?.requestReturnHome?()
            guard let self else { return }
            scheduleReminder(afterMinutes: regularReminderIntervalMinutes)
        }
    }

    /// Snoozes the reminder for 5 minutes.
    public func snooze() {
        cancelFlow(resetPhase: false)
        playSound(.snooze)
        isReminderActive = false
        phase = .snoozed
        stateMachine.resetToIdle()
        requestReturnHome?()
        scheduleSnoozeReminder()
    }

    private func scheduleFirstIgnoreFallback() {
        enqueueFlow(after: Constants.firstIgnoreTimeout) { [weak self] in
            guard let self, isReminderActive else { return }
            isReminderActive = false
            stateMachine.transition(to: .peek)
            phase = .secondChance

            enqueueFlow(after: Constants.peekDuration) { [weak self] in
                guard let self else { return }
                stateMachine.resetToIdle()
                reminderMessage = "Let's drink some water soon 💧"
                isReminderActive = true
                scheduleSecondChanceFallback()
            }
        }
    }

    private func presentReminderPrompt() {
        phase = .prompting
        isReminderActive = true
        scheduleFirstIgnoreFallback()
    }

    private func startGreetingThenPrompt() {
        stateMachine.transition(to: .greeting)
        enqueueFlow(after: Constants.greetingTotalDuration) { [weak self] in
            self?.presentReminderPrompt()
        }
    }

    private func scheduleSecondChanceFallback() {
        enqueueFlow(after: Constants.secondChanceTimeout) { [weak self] in
            guard let self, isReminderActive else { return }
            isReminderActive = false
            stateMachine.transition(to: .sad)
            phase = .snoozed

            enqueueFlow(after: Constants.peekDuration) { [weak self] in
                self?.stateMachine.resetToIdle()
                self?.requestReturnHome?()
                self?.scheduleSnoozeReminder()
            }
        }
    }

    private func scheduleSnoozeReminder() {
        reminderTimer?.invalidate()
        reminderTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(Constants.snoozeMinutes * 60),
            repeats: false
        ) { _ in
            Task { @MainActor [weak self] in
                self?.triggerReminder()
            }
        }
    }

    private func enqueueFlow(after delay: TimeInterval, _ action: @escaping () -> Void) {
        let workItem = DispatchWorkItem(block: action)
        flowWorkItems.append(workItem)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func cancelFlow(resetPhase: Bool) {
        flowWorkItems.forEach { $0.cancel() }
        flowWorkItems.removeAll()
        isReminderActive = false
        if resetPhase {
            phase = .idle
        }
    }
}
