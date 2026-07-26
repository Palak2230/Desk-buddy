# Character & Mascot Rendering Notes

This document explains how the Desk Buddy mascot character was built, what was added, and how rendering currently works.

## Goal

- Replace the old placeholder capsule with a production-style pastel mascot.
- Keep existing app logic unchanged (state machine, animation engine, reminder flow).
- Only change rendering assets and rendering-layer code.

## What Was Added

### New/expanded resources

- `Sources/PinkyApp/Resources/CompanionBase.atlas`
  - Base part textures (`companion_head`, `companion_hair`, `companion_feet`, etc.).
- `Sources/PinkyApp/Resources/CompanionExpressions.atlas`
  - Expression textures (`expression_neutral`, `expression_smile`, `expression_happy`, etc.).
- `Sources/PinkyApp/Resources/CompanionOutfits.atlas`
  - Outfit variants (e.g. `companion_torso_classic`, `companion_hood_sporty`).
- `Sources/PinkyApp/Resources/CompanionFrames.atlas`
  - State frame textures (`idle_0`, `walk_3`, `sleep_10`, etc.).
- `Sources/PinkyApp/Resources/Character/`
  - Data-driven state folders for sprite animation frames:
    - `Idle/`, `Walk/`, `Blink/`, `Drink/`, `Wave/`, `Happy/`, `Sad/`, `Sleep/`, `Peek/`, `Think/`, `Celebrate/`
  - Temporary placeholders are generated from existing state frames and can be replaced by final artwork one-to-one.

### Rendering/loader code

- `Sources/PinkyUI/Components/CompanionAtlasProvider.swift`
  - Added multi-atlas loading and texture lookup abstraction.
  - Added outfit support via `Outfit` enum (`classic`, `sporty`, `cozy`).
  - Added graceful fallback texture loading from PNG file URLs.
  - Added resource lookup across SwiftPM side bundles.

- `Sources/PinkyUI/Components/CompanionSpriteScene.swift`
  - Refactored scene into layered nodes (torso/head/hair/hood/feet/expression).
  - Added `frameSpriteNode` for frame-based sprite rendering.
  - Added render-priority routing:
    1. discovered state sprite frames
    2. procedural/layered fallback

- `Package.swift`
  - Ensures app resources are included for runtime access:
    - `DeskBuddyApp` target has `.process("Resources")`.

## Runtime Render Pipeline (Current)

1. `CompanionCharacterView` creates `CompanionSpriteScene`.
2. On each animation tick, `scene.apply(state:frameIndex:theme:)` runs.
3. Scene tries to render in this order:
   - discovered state frame texture (`Character/<State>/*.png`, or legacy `<state>_NN.png`),
   - layered SpriteKit mascot (base + expression + outfit + theme tint).
4. Character state and frame index still come from existing animation/state systems.

## Why This Preserves Existing Logic

- No changes were made to:
  - `CharacterStateMachine` behavior,
  - animation sequencing APIs,
  - skill/reminder business logic.
- The state machine still drives the same states; only visual output changed.

## Important Implementation Details

- Sprite resources under SwiftPM may be emitted into generated side bundles during `swift run`.
- Because of this, resource lookup does **not** rely only on `Bundle.main`.
- `CompanionAtlasProvider` now searches:
  - loaded bundles (`Bundle.main`, all bundles, all frameworks),
  - executable sibling `.bundle` directories for direct PNG filenames.

## Troubleshooting Guide

If mascot visuals do not update as expected:

- Ensure only one app instance is running (stale process can mask changes).
- Rebuild and relaunch:
  - `swift build`
  - `swift run DeskBuddy`
- Confirm resource files exist:
  - `Character/<State>/*.png` (preferred),
  - or legacy frame files like `idle_0.png` (fallback source).
- If needed, check `stateTexture(for:frameIndex:)` resolution in `CompanionAtlasProvider`.

## Current Status

- Rendering pipeline supports:
  - base part textures,
  - expressions,
  - outfits,
  - frame-based animation textures,
  - state-folder sprite discovery.
- State integration and app behavior remain intact while mascot visuals are now asset-driven.
