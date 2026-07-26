# Desk Buddy

**An aesthetic desktop companion that lives on your Mac and helps you build healthy habits.**

Desk Buddy is a free, offline, open-source macOS desktop companion with a pastel coquette aesthetic. She lives on your desktop, performs idle animations, and reminds you to stay healthy — starting with water intake tracking.

## Features (Milestone 1)

- Floating desktop companion window (bottom-right corner)
- Menu bar integration with water stats
- Water Reminder skill (first built-in skill)
- Glassmorphism dashboard
- Settings panel (interval, theme, character size)
- JSON-driven theme engine (Strawberry Milk default)
- Character state machine with random idle behaviours
- Local-only persistence (UserDefaults)
- Modular Clean Architecture for unlimited future skills

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15+ or Swift 5.9+ toolchain

## Quick Start

```bash
git clone https://github.com/Palak2230/Desk-buddy.git
cd Desk-buddy
swift build
swift run DeskBuddy
```

See [docs/Installation.md](docs/Installation.md) for detailed setup.

## Architecture

Desk Buddy uses **Clean Architecture** with strict layer separation:

```
DeskBuddyApp  → Application entry point, DI, window management
Presentation  → Views, ViewModels, menu bar
UI            → Reusable UI components (glass cards, speech bubbles)
Domain        → Models, protocols, use cases
Services      → App coordinator, business logic
Skills        → Plugin system + built-in skills (Water)
Character     → Character state machine
Animations    → Frame-based animation engine
Theme         → JSON theme loader
Persistence   → Local storage (UserDefaults)
Notifications → Local UNUserNotificationCenter wrapper
Core          → Shared utilities, extensions, logging
```

See [docs/Architecture.md](docs/Architecture.md) for full details.

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture.md](docs/Architecture.md) | System design and layer responsibilities |
| [Installation.md](docs/Installation.md) | Build and run instructions |
| [Roadmap.md](docs/Roadmap.md) | Planned features and milestones |
| [Contributing.md](docs/Contributing.md) | How to contribute |
| [PluginGuide.md](docs/PluginGuide.md) | Creating new skills |
| [ThemeGuide.md](docs/ThemeGuide.md) | Creating custom themes |
| [CharacterGuide.md](docs/CharacterGuide.md) | Character states and behaviour |
| [AnimationGuide.md](docs/AnimationGuide.md) | Animation engine usage |

## Principles

- **100% free** — no subscriptions, no paid APIs
- **Fully offline** — no cloud backend, local storage only
- **Open source** — MIT License
- **Modular** — every feature is a Skill
- **Native** — SwiftUI + AppKit + SpriteKit

## License

MIT License — see [LICENSE](LICENSE).
