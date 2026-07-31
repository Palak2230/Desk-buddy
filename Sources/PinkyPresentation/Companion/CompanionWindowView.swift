import SwiftUI
import Theme
import UI
import Services
import Character
import Skills

/// Main companion window content — character + optional speech bubble.
public struct CompanionWindowView: View {
    @Environment(\.appTheme) private var theme
    @ObservedObject private var stateMachine: CharacterStateMachine
    @ObservedObject private var waterSkill: WaterReminderSkill
    private let scale: Double

    public init(
        stateMachine: CharacterStateMachine,
        waterSkill: WaterReminderSkill,
        scale: Double
    ) {
        self.stateMachine = stateMachine
        self.waterSkill = waterSkill
        self.scale = scale
    }

    public var body: some View {
        VStack(spacing: 8) {
            if waterSkill.isReminderActive {
                SpeechBubbleView(
                    message: waterSkill.reminderMessage,
                    primaryAction: ("Yes!", { waterSkill.confirmDrink() }),
                    secondaryAction: ("Remind me in 5 min", { waterSkill.snooze() })
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity)
            }

            ZStack {
                CompanionCharacterView(stateMachine: stateMachine, scale: scale)
            }
        }
        .padding(12)
        .background(Color.clear)
        .animation(.easeInOut(duration: 0.2), value: waterSkill.isReminderActive)
    }
}
