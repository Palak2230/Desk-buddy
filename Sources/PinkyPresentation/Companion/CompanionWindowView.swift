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
    @State private var showHearts = false
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
                .transition(.scale.combined(with: .opacity))
            }

            ZStack {
                CompanionCharacterView(stateMachine: stateMachine, scale: scale)
                if showHearts {
                    Text("💖 💧 💖")
                        .font(.system(size: 18))
                        .offset(y: -72)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding(12)
        .background(Color.clear)
        .animation(.spring(response: 0.4), value: waterSkill.isReminderActive)
        .onChange(of: waterSkill.heartBurstID) { _, _ in
            withAnimation(.easeOut(duration: 0.2)) {
                showHearts = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                withAnimation(.easeOut(duration: 0.25)) {
                    showHearts = false
                }
            }
        }
    }
}
