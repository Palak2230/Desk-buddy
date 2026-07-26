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

## Session Achievements (Jul 26, 2026)

This section records what was completed in the latest implementation/debug session.

### Mascot Rendering Pipeline

- Upgraded the companion rendering path to support a rigged multi-part character flow in `UI`:
  - `CharacterRig.swift` for part hierarchy and texture binding
  - `CharacterRigAnimator.swift` for state-driven pose logic
  - `CompanionSpriteScene.swift` applying rig output per frame
- Added/used part-based loading through `CompanionAtlasProvider.characterPartTexture(group:name:)`.
- Preserved fallback behavior for missing assets (no hard crash).

### Character Parts Updated

- Replaced and cleaned multiple character assets (transparent PNG conversion, crop fixes, orientation fixes where needed), including:
  - Head set: `head`, `hair_front`, `hair_back`, `heart_clip`
  - Body set: `hoodie`, `left_hand`, `right_hand`
  - Legs set: `left_leg`, `right_leg`
  - Extras: `heart` (used for side-heart effect)
- Asset cleanup repeatedly handled black/checkerboard backgrounds and label/text artifacts from generated source images.

### Current Visual Mode

- `CharacterRig` currently runs with:
  - `useHandsOnlyArms = true` (arm sprites hidden, hand sprites shown directly)
  - `partValidationStage` currently set to a non-nil debug stage value in code (partial reveal mode)
- Heart clip visibility was explicitly tuned (position/z-order/size) and forced visible during staged validation.
- Side-effect nodes (`heart`, `bottle`, `sweat`) now preserve state-driven visibility even while staged validation is active.

### Water Reminder UX Flow Enhancements

- Added movement integration hooks in `WaterReminderSkill`:
  - `requestReminderApproach` callback (move near cursor before prompting)
  - `requestReturnHome` callback (walk back home at flow end)
- Reminder behavior now supports:
  - approach to cursor
  - prompt at cursor location
  - return home after completion/snooze/timeout branch

### Movement System Improvements

- `CompanionMovementController` now supports:
  - completion-aware movement (`move(to:completion:)`)
  - cursor-targeted movement (`moveToCursor`)
  - explicit fallback to destination if platform animation skips movement
- Replaced pure AppKit animator movement with explicit frame-stepped movement (`~60 FPS`) for visible walk travel.

### App/Runtime Controls

- Menu bar item now retained correctly in `AppDelegate` (status item lifecycle bug fixed).
- Added menu actions for local debugging/verification:
  - `Move Buddy To Cursor`
  - `Test Water Reminder`
- `Test Water Reminder` path updated to deterministic move-then-prompt behavior.

### Reliability / Process Fixes

- Resolved duplicate app-instance confusion by killing stale DeskBuddy processes and restarting cleanly.
- Rebuilt repeatedly after each functional change; recent `swift build` runs are passing.

### Known Active Caveats

- Because staged validation is still enabled in `CharacterRig` (non-nil `partValidationStage`), full normal rendering may be intentionally restricted until reset to `nil`.
- Some face and shoe assets have required iterative correction due to noisy generated source sheets; continue validating each texture visually in-app.
