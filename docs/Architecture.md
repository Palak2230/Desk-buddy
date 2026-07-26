# Architecture

Pinky follows **Clean Architecture** with dependency inversion. Inner layers never depend on outer layers.

## Layer Diagram

```
┌─────────────────────────────────────────────────┐
│                   PinkyApp                       │
│         (Entry Point, DI, AppDelegate)           │
├─────────────────────────────────────────────────┤
│              PinkyPresentation                   │
│     (CompanionWindow, Dashboard, Settings)       │
├─────────────────────────────────────────────────┤
│                  PinkyUI                         │
│   (CompanionCharacterView, GlassCard, Speech)    │
├──────────┬──────────┬──────────┬─────────────────┤
│ Pinky    │ Pinky    │ Pinky    │ PinkyTheme      │
│ Skills   │ Character│ Animations│                │
├──────────┴──────────┴──────────┴─────────────────┤
│              PinkyServices                       │
│            (AppCoordinator)                    │
├─────────────────────────────────────────────────┤
│     PinkyPersistence  │  PinkyNotifications     │
├─────────────────────────────────────────────────┤
│               PinkyDomain                        │
│    (Models, Protocols, Use Cases)                │
├─────────────────────────────────────────────────┤
│                PinkyCore                         │
│      (Extensions, Logger, Utilities)             │
└─────────────────────────────────────────────────┘
```

## Module Responsibilities

### PinkyApp
| File | Responsibility |
|------|----------------|
| `PinkyApp.swift` | SwiftUI `@main` entry point |
| `AppDelegate.swift` | Lifecycle, menu bar, window management |
| `CompanionWindowController.swift` | Floating NSPanel for desktop companion |
| `DI/DependencyContainer.swift` | Root dependency injection container |

### PinkyPresentation
| File | Responsibility |
|------|----------------|
| `Companion/CompanionWindowView.swift` | Main companion view (character + speech bubble) |
| `Dashboard/DashboardView.swift` | Glassmorphism stats dashboard |
| `MenuBar/MenuBarView.swift` | Menu bar popover content |
| `Settings/SettingsView.swift` | User settings form |

### PinkyUI
| File | Responsibility |
|------|----------------|
| `Components/CompanionCharacterView.swift` | Character placeholder (→ SpriteKit later) |
| `Components/GlassCard.swift` | Reusable glassmorphism card |
| `SpeechBubble/SpeechBubbleView.swift` | Speech bubble with action buttons |

### PinkyDomain
| File | Responsibility |
|------|----------------|
| `Models/CharacterState.swift` | Character animation states enum |
| `Models/WaterRecord.swift` | Water intake record entity |
| `Models/AppSettings.swift` | User settings model |
| `Protocols/SkillProtocol.swift` | Skill plugin contract |
| `Protocols/SettingsStoreProtocol.swift` | Settings persistence abstraction |
| `Protocols/WaterStoreProtocol.swift` | Water data persistence abstraction |

### PinkyServices
| File | Responsibility |
|------|----------------|
| `AppCoordinator.swift` | Central app state coordinator |

### PinkySkills
| File | Responsibility |
|------|----------------|
| `Core/SkillRegistry.swift` | Skill registration and lifecycle |
| `Water/WaterReminderSkill.swift` | Water reminder skill implementation |

### PinkyCharacter
| File | Responsibility |
|------|----------------|
| `StateMachine/CharacterStateMachine.swift` | Reusable character FSM |

### PinkyAnimations
| File | Responsibility |
|------|----------------|
| `Engine/AnimationEngine.swift` | Frame sequencer with queue/priority |
| `Models/AnimationClip.swift` | Animation clip and frame models |

### PinkyTheme
| File | Responsibility |
|------|----------------|
| `Models/PinkyTheme.swift` | Theme data model |
| `Loader/ThemeLoader.swift` | JSON theme loader |
| `Resources/Themes/*.json` | Bundled theme definitions |

### PinkyPersistence
| File | Responsibility |
|------|----------------|
| `Stores/SettingsStore.swift` | UserDefaults settings store |
| `Stores/WaterStore.swift` | UserDefaults water records store |

### PinkyNotifications
| File | Responsibility |
|------|----------------|
| `NotificationService.swift` | Local notification scheduling |

### PinkyCore
| File | Responsibility |
|------|----------------|
| `Extensions/Color+Hex.swift` | Hex color parsing |
| `Protocols/IdentifiableProtocol.swift` | Domain entity marker protocol |
| `Utilities/Logger.swift` | Debug logging utility |

## Dependency Injection

`DependencyContainer` is the composition root. It wires all dependencies at app launch:

```swift
let container = DependencyContainer()
await container.bootstrap()  // Registers skills, schedules reminders
```

No singleton abuse — stores and services are injected via protocols. Exceptions: `ThemeLoader.shared` and `NotificationService.shared` (system wrappers).

## Data Flow

```
User Action → Presentation View → Service/Skill → Domain Protocol → Persistence Store
                     ↓
              Character State Machine → Animation Engine → UI Update
```

## Future Milestones

- SpriteKit character rendering (replace placeholder)
- Speech bubble typing effect
- Plugin bundle loading for external skills
- Core Data migration from UserDefaults
- Launch at Login (ServiceManagement)
