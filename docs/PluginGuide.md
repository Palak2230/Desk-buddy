# Plugin Guide — Creating Skills

Every Desk Buddy feature is a **Skill**. Skills are modular plugins that can be added without modifying existing code.

## Skill Protocol

```swift
public protocol Skill: AnyObject, Sendable {
    var id: String { get }           // Unique ID, e.g. "water"
    var displayName: String { get }  // "Water Reminder"
    var iconName: String { get }     // SF Symbol name
    func activate() async
    func deactivate() async
}
```

## Step-by-Step: Creating a Skill

### 1. Create the skill file

```
Sources/PinkySkills/YourSkill/YourSkill.swift
```

### 2. Implement the protocol

```swift
import Foundation
import Core
import Domain
import Character

@MainActor
public final class StretchReminderSkill: Skill, ObservableObject {
    public let id = "stretch"
    public let displayName = "Stretch Reminder"
    public let iconName = "figure.flexibility"

    private let stateMachine: CharacterStateMachine

    public init(stateMachine: CharacterStateMachine) {
        self.stateMachine = stateMachine
    }

    public func activate() async {
        AppLogger.log("StretchSkill", "Activated")
        // Schedule reminders, register observers, etc.
    }

    public func deactivate() async {
        // Clean up timers, observers
    }
}
```

### 3. Register in DependencyContainer

```swift
// In DependencyContainer.bootstrap()
let stretchSkill = StretchReminderSkill(stateMachine: stateMachine)
await skillRegistry.register(stretchSkill)
```

### 4. Add UI (optional)

If your skill needs dashboard widgets or settings, add views in `Presentation` and wire them through the coordinator.

## Skill Lifecycle

```
App Launch → DependencyContainer.bootstrap()
           → SkillRegistry.register(skill)
           → skill.activate()
           
App Quit   → SkillRegistry.unregister(id)
           → skill.deactivate()
```

## Best Practices

- Inject dependencies via initializer (no singletons)
- Use `CharacterStateMachine` for companion reactions
- Use `SpeechBubbleView` for user prompts
- Schedule reminders via `NotificationService` as fallback
- Persist skill data through protocol abstractions in `Domain`
- Keep skill logic in the skill class; don't leak into Presentation

## Future: External Plugins

Milestone 5 will support loading skills from external bundles:

```
~/Library/Application Support/DeskBuddy/Skills/
  └── my-custom-skill/
      ├── SkillManifest.json
      └── MyCustomSkill.swiftmodule
```

The `SkillRegistry` will scan this directory at launch.

## Example Skills to Build

| Skill | ID | Character States Used |
|-------|----|-----------------------|
| Water Reminder | `water` | walk, wave, drink, happy |
| Stretch | `stretch` | think, celebrate |
| Pomodoro | `pomodoro` | think, sleep, celebrate |
| Quotes | `quotes` | think, happy |
| Breathing | `breathing` | breathing, happy |
