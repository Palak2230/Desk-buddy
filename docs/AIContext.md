# AI Context — Current App State

This file is a concise source of truth for AI agents and contributors about what currently exists in Desk Buddy.

## Project Identity

- Product name: `Desk Buddy` (user-facing text)
- Swift package/product: `DeskBuddy`
- App entry target: `DeskBuddyApp`
- Platform: macOS 14+
- Stack: SwiftUI, AppKit, SpriteKit, Combine, UserNotifications, AVFoundation
- Persistence: local-only (UserDefaults)
- Offline-first: yes

## Architecture (Current)

The package uses clean modular targets:

- `DeskBuddyApp` (app lifecycle, windows, DI root)
- `Presentation` (window-level views: companion, dashboard, settings)
- `UI` (reusable components and companion rendering)
- `Domain` (models/protocols)
- `Services` (coordinator + system/audio services)
- `Skills` (feature skills, currently water)
- `Character` (state machine)
- `Animations` (animation engine + sprite manifest loader)
- `Theme` (JSON themes)
- `Persistence` (stores)
- `Notifications` (local notification wrapper)
- `Core` (shared utilities)

## Implemented Features

### App Shell

- Floating, transparent companion `NSPanel` (always on top, draggable)
- Menu bar item with quick actions
- Dashboard window
- Settings window
- Companion position persistence (`x/y`) in UserDefaults

### Companion + Animation

- Character finite state machine with priority-based transitions
- SpriteKit-based companion renderer (`SpriteView` + `SKScene`)
- Animation engine with clip registration, playback, queue, interruption
- Sprite-sheet manifest pipeline:
  - Manifest model
  - Catalog loader from bundled JSON
  - Default clip manifest: `deskbuddy-default.json`
  - Fallback procedural clips if manifest load fails

### Water Reminder Skill

- Scheduled reminders via timer
- Reminder sequence:
  - walk-in
  - prompt
  - first ignore timeout -> peek
  - second-chance prompt
  - second ignore timeout -> sad -> auto snooze
- Positive flow:
  - confirm drink -> drink -> happy -> walk back -> idle
- Snooze flow (5 min)
- Dynamic speech message binding
- Heart-burst trigger signal for UI feedback
- Sound hooks for reminder/success/snooze
- Internal phase model for deterministic flow control:
  - `idle`, `approaching`, `prompting`, `secondChance`, `completed`, `snoozed`

### Dashboard + Stats

- Today count
- Streak
- Weekly hydration bars (7-day)
- Achievement badges (computed from stats)

### Settings + Themes

- Reminder interval
- Character scale
- Animations toggle
- Random idle toggle
- Dynamic theme picker from bundled theme JSON files
- Volume slider
- Speech speed slider
- Launch-at-login toggle (wired in coordinator)

### Services

- `LaunchAtLoginService` (ServiceManagement-backed registration/unregistration)
- `CompanionSoundService` (synthesized tones with AVAudioEngine)
- Notification service with safe no-op outside app bundle context (prevents CLI crash)

## Bundled Themes (Current)

- `strawberry-milk`
- `sakura`
- `lavender`
- `cloud`
- `minimal`
- `dark`

## Persistence Keys (Not Exhaustive)

- Settings: `com.palakagarwal.deskbuddy.settings`
- Water records: `com.palakagarwal.deskbuddy.water.records`
- Companion window position:
  - `com.palakagarwal.deskbuddy.window.originX`
  - `com.palakagarwal.deskbuddy.window.originY`

## Test/Build Status (Current)

- `swift build`: passing
- `swift test`: passing in current environment
- Lint diagnostics on edited files: clean

## In Progress / Partial Areas

- Sprite-sheet loader is in place, but actual packed sprite image assets/atlases are not yet integrated.
- Companion movement is state-driven but not yet full screen-path choreography.
- Launch-at-login wiring exists in coordinator flow, but should be validated as a signed app behavior in production packaging.

## Major Remaining Work

- Full production sprite assets and state-to-texture mapping polish
- Reminder choreography polish to match final product UX spec exactly
- Additional built-in skills (e.g., Stretch/Pomodoro)
- External skill loading/plugin distribution flow
- Expanded automated tests (skill flow, services, state transitions)
- Packaging/release hardening for open-source distribution

## Notes for Future AI Work

- Preserve modular target boundaries (avoid cross-layer leakage).
- Prefer extending current `WaterReminderSkill` flow rather than replacing it.
- Keep user-facing naming as `Desk Buddy`; avoid old `Pinky` naming in new code.
- Avoid introducing cloud dependencies or subscription logic.
