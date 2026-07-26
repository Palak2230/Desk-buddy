# Character Guide

Desk Buddy's companion is an original pastel character — soft, coquette aesthetic with a strawberry milk palette.

## Visual Design

| Attribute | Description |
|-----------|-------------|
| Style | Soft pastel, coquette aesthetic |
| Outfit | Pink hoodie, white skirt, cute sneakers |
| Accessory | Heart hair clip |
| Features | Soft blush, expressive eyes |
| Palette | Strawberry milk (#FFB6C1, #FFF0F5, #FF69B4) |

**Important:** The Desk Buddy companion is original. No copyrighted anime or existing IP.

## Character States

| State | Type | Description |
|-------|------|-------------|
| `idle` | Loop | Default sitting/standing pose |
| `blink` | One-shot | Quick eye blink |
| `breathing` | Loop | Subtle breathing motion |
| `walk` | Loop | Walking animation |
| `run` | Loop | Running animation |
| `wave` | One-shot | Friendly wave |
| `drink` | One-shot | Drinking water |
| `sleep` | Loop | Sleeping with Zzz |
| `happy` | One-shot | Happy reaction with hearts |
| `sad` | One-shot | Sad/disappointed |
| `think` | One-shot | Thinking pose |
| `peek` | One-shot | Peeking from screen edge |
| `celebrate` | One-shot | Celebration animation |

## State Machine

The `CharacterStateMachine` manages transitions:

```swift
let sm = CharacterStateMachine()
sm.transition(to: .wave)    // Triggers wave animation
sm.resetToIdle()             // Returns to idle
```

### Priority System

Higher priority states interrupt lower ones:

```
celebrate, drink, wave  → 100
peek, happy, sad        →  80
walk, run               →  60
blink, think            →  40
idle, breathing, sleep  →  10
```

### Random Idle Behaviour

When enabled in settings, the character randomly performs idle actions every 8–20 seconds:

- Blink
- Breathe
- Think
- Wave
- Sleep

## Companion Behaviour Map

```
Normal:     idle ←→ blink, breathing, think, wave, sleep
Reminder:   idle → walk → wave → [speech bubble]
Confirmed:  drink → happy → idle
Snoozed:    idle (reminder in 5 min)
Ignored:    peek → [speech bubble again]
```

## Implementation Status

| Component | Status |
|-----------|--------|
| State enum + priorities | ✅ Done |
| State machine (FSM) | ✅ Done |
| Random idle scheduler | ✅ Done |
| Placeholder SwiftUI character | ✅ Done |
| SpriteKit renderer | 🔜 Milestone 2 |
| Sprite sheet animations | 🔜 Milestone 2 |
| Walk-across-screen | 🔜 Milestone 2 |

## Adding New States

1. Add case to `CharacterState` enum in `Domain`
2. Set `isLooping` and `priority` properties
3. Create animation clip in `Animations`
4. Register clip with `AnimationEngine`
5. Map state to clip in character renderer (Milestone 2)

## Positioning

The companion lives in a floating `NSPanel`:
- Default: bottom-right corner
- Draggable by user
- Always on top (`level = .floating`)
- Visible on all Spaces
- Non-activating (doesn't steal focus)

Position persistence is planned for Milestone 4.
