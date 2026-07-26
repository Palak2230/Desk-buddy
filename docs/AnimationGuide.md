# Animation Guide

Desk Buddy uses a custom frame-based animation engine built for sprite sequences at 60 FPS.

## Core Concepts

### AnimationFrame

A single frame in a sequence:

```swift
let frame = AnimationFrame(textureName: "idle_01", duration: 1.0 / 60.0)
```

### AnimationClip

A complete animation with frames, looping, and priority:

```swift
let idleClip = AnimationClip(
    id: "idle",
    frames: (0...59).map { AnimationFrame(textureName: "idle_\($0)") },
    loops: true,
    priority: 10
)
```

### AnimationEngine

Drives playback with queueing and interruption:

```swift
@MainActor
let engine = AnimationEngine()

engine.register(idleClip)
engine.register(waveClip)

engine.play("idle")                          // Start idle loop
engine.play("wave", onComplete: {              // Interrupt with wave
    engine.play("idle")                        // Return to idle
})
```

## Features

| Feature | Description |
|---------|-------------|
| Frame sequences | Ordered list of frames with per-frame duration |
| Idle loops | Continuous looping animations |
| Walking loops | Directional walk cycles |
| Sprite sheets | Texture names map to sprite sheet regions (Milestone 2) |
| Animation queue | Lower-priority clips queue instead of interrupting |
| Interruptions | Higher-priority clips interrupt current playback |
| Priority | Numeric priority per clip (higher wins) |
| Smooth transitions | State machine handles transition timing |
| 60 FPS | Default frame duration: 1/60 second |

## Registering Animations

```swift
// Single clip
engine.register(AnimationClip(id: "blink", frames: blinkFrames, loops: false, priority: 40))

// Batch registration
engine.register([
    idleClip, blinkClip, walkClip, waveClip, drinkClip
])
```

## Playback API

```swift
// Play a clip
engine.play("walk")

// Play with completion handler
engine.play("wave") {
    print("Wave complete!")
}

// Stop everything
engine.stop()
```

## Priority Interruption

When a new clip has **lower** priority than the current clip, it is queued:

```swift
engine.play("idle")     // priority 10, looping
engine.play("blink")    // priority 40, interrupts idle
engine.play("idle")     // priority 10, queued until blink finishes
```

## Integration with Character State Machine

```swift
// In character renderer (Milestone 2):
stateMachine.$currentState
    .sink { state in
        engine.play(state.rawValue)
    }
```

## SpriteKit Integration (Milestone 2)

The animation engine will drive a SpriteKit `SKSpriteNode`:

```swift
engine.$currentFrameIndex
    .sink { index in
        sprite.texture = textures[index]
    }
```

Sprite sheets will be loaded from `Resources/Animations/`.

## Performance Guidelines

- Target 60 FPS (16.67ms per frame)
- Keep sprite textures at 2x resolution for Retina
- Use texture atlases to minimize draw calls
- Limit active animations to 1 character + effects
- Pause engine when companion is off-screen (future)

## File Organization

```
Sources/PinkyAnimations/
├── Engine/
│   └── AnimationEngine.swift    # Playback engine
└── Models/
    └── AnimationClip.swift      # Frame and clip models

Resources/Animations/            # Sprite sheets (Milestone 2)
├── idle.png
├── walk.png
└── ...
```
