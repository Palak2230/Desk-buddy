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
- `Sources/PinkyApp/Resources/reference_fullbody.png`
  - Single reference-driven full-body mascot image used as highest-priority render path.

### Rendering/loader code

- `Sources/PinkyUI/Components/CompanionAtlasProvider.swift`
  - Added multi-atlas loading and texture lookup abstraction.
  - Added outfit support via `Outfit` enum (`classic`, `sporty`, `cozy`).
  - Added graceful fallback texture loading from PNG file URLs.
  - Added resource lookup across SwiftPM side bundles.

- `Sources/PinkyUI/Components/CompanionSpriteScene.swift`
  - Refactored scene into layered nodes (torso/head/hair/hood/feet/expression).
  - Added `frameSpriteNode` for frame-based and reference-based sprite rendering.
  - Added render-priority routing:
    1. `reference_fullbody`
    2. state frame textures (e.g. `idle_0`, `run_5`)
    3. procedural/layered fallback
  - Added per-state pose adaptation for reference rendering (`applyReferencePose`).

- `Package.swift`
  - Ensures app resources are included for runtime access:
    - `DeskBuddyApp` target has `.process("Resources")`.

## Runtime Render Pipeline (Current)

1. `CompanionCharacterView` creates `CompanionSpriteScene`.
2. On each animation tick, `scene.apply(state:frameIndex:theme:)` runs.
3. Scene tries to render in this order:
   - `reference_fullbody.png` (if available),
   - `CompanionFrames` state texture,
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
  - `CompanionFrames.atlas/*`
  - `reference_fullbody.png`
- If needed, force-check that `texture(named:)` resolves the expected texture key.

## Current Status

- Rendering pipeline supports:
  - base part textures,
  - expressions,
  - outfits,
  - frame-based animation textures,
  - reference full-body override.
- State integration and app behavior remain intact while mascot visuals are now asset-driven.
