import SpriteKit
import Domain

@MainActor
final class CharacterRigAnimator {
    private var previousState: CharacterState?
    private var turnStartFacingRight = true

    private enum WalkTuning {
        static let legSwing: CGFloat = 20.0 * (.pi / 180.0)
        static let armSwing: CGFloat = 12.0 * (.pi / 180.0)
        static let forearmSwing: CGFloat = 8.0 * (.pi / 180.0)
        static let bodyBob: CGFloat = 1.8
        static let headBob: CGFloat = 0.45
        static let headTilt: CGFloat = 1.0 * (.pi / 180.0)
        static let hairLagPhase: CGFloat = 0.52
    }

    func apply(state: CharacterState, frameIndex: Int, rig: CharacterRig, facingRight: inout Bool) {
        let t = CGFloat(frameIndex)
        let wave = sin(t * 0.34)
        let quick = sin(t * 0.75)

        resetPose(rig)
        rig.setGreetingWaveActive(state == .greeting)
        let hideFrontShoulders = (
            state == .idle ||
            state == .breathing ||
            state == .blink ||
            state == .sleep ||
            state == .greeting
        )
        rig.setFrontShoulderSleevesHidden(hideFrontShoulders)
        // Keep side assets active across turn/walk/run/stop to avoid abrupt popping.
        let usesSideProfile = (state == .turn || state == .walk || state == .run || state == .stop)
        rig.setSideHeadActive(usesSideProfile)
        rig.setSideBodyActive(usesSideProfile)
        rig.setSideVisibleHandFacingRight(usesSideProfile ? facingRight : nil)

        switch state {
        case .idle:
            rig.torsoNode.position.y += wave * 1.4
            rig.neckPivot.position.y += wave * 1.3
            rig.hairFrontNode.position.y -= wave * 0.8
            rig.hairBackNode.position.y -= wave * 1.1
            rig.neckPivot.zRotation = wave * 0.03
            rig.torsoNode.yScale = 1 + wave * 0.01
            applyIdleArmMicroMotion(rig: rig, t: t)
            rig.setEyesTexture(frameIndex % 90 > 82 ? "eyes_closed" : "eyes_open")
            rig.setMouthTexture(frameIndex % 140 > 118 ? "mouth_open" : "mouth_smile")
        case .breathing:
            rig.torsoNode.yScale = 1 + wave * 0.02
            rig.neckPivot.position.y += wave * 1.2
            rig.hairBackNode.position.y -= wave * 0.6
            applyIdleArmMicroMotion(rig: rig, t: t)
            rig.setEyesTexture("eyes_open")
            rig.setMouthTexture("mouth_smile")
        case .blink:
            rig.setEyesTexture(frameIndex % 6 > 1 ? "eyes_closed" : "eyes_open")
            rig.setMouthTexture("mouth_smile")
        case .walk:
            applySideWalkPose(
                rig: rig,
                frameIndex: frameIndex,
                cadence: 0.40,
                intensity: 0.9,
                enableDepthSwap: false
            )
            applyProfileSquash(rig: rig, facingRight: facingRight)
            rig.setEyesTexture("eyes_open")
            rig.setMouthTexture("mouth_smile")
        case .run:
            applySideWalkPose(
                rig: rig,
                frameIndex: frameIndex,
                cadence: 0.54,
                intensity: 1.05,
                enableDepthSwap: true
            )
            applyProfileSquash(rig: rig, facingRight: facingRight)
            rig.setEyesTexture("eyes_open")
            rig.setMouthTexture("mouth_open")
        case .turn:
            // Facing is driven by movement controller through state machine.
            if previousState != .turn {
                turnStartFacingRight = rig.rootNode.xScale >= 0
            }
            rig.neckPivot.zRotation = wave * 0.14
            rig.torsoNode.zRotation = -wave * 0.08
            applySmoothTurnScale(rig: rig, frameIndex: frameIndex, targetFacingRight: facingRight)
            rig.setEyesTexture("eyes_open")
            rig.setMouthTexture("mouth_smile")
        case .stop:
            applyLandingStopPose(rig: rig, frameIndex: frameIndex)
            rig.setEyesTexture("eyes_open")
            rig.setMouthTexture("mouth_smile")
        case .wave:
            rig.rightArmPivot.zRotation = -0.55 + sin(t * 0.9) * 0.4
            rig.rightHandNode.zRotation = sin(t * 1.2) * 0.18
            rig.neckPivot.zRotation = wave * 0.05
            rig.setEyesTexture("eyes_happy")
            rig.setMouthTexture("mouth_smile")
        case .drink:
            rig.setBottleVisible(true)
            rig.setHeartVisible(true)
            rig.rightArmPivot.zRotation = -0.95 + sin(t * 0.5) * 0.08
            rig.rightHandNode.zRotation = -0.35
            rig.bottleNode.zRotation = -0.65
            rig.bottleNode.position = CGPoint(x: 30, y: 108)
            rig.neckPivot.zRotation = -0.08
            rig.setEyesTexture("eyes_open")
            rig.setMouthTexture("mouth_open")
        case .happy:
            rig.setHeartVisible(true)
            rig.torsoNode.position.y += abs(quick) * 4.0
            rig.neckPivot.position.y += abs(quick) * 2.0
            rig.setEyesTexture("eyes_happy")
            rig.setMouthTexture("mouth_smile")
        case .celebrate:
            rig.leftArmPivot.zRotation = -0.8 + sin(t * 0.8) * 0.18
            rig.rightArmPivot.zRotation = 0.8 - sin(t * 0.8) * 0.18
            rig.torsoNode.position.y += abs(quick) * 4.2
            rig.neckPivot.position.y += abs(quick) * 2.4
            rig.setEyesTexture("eyes_happy")
            rig.setMouthTexture("mouth_open")
        case .sad:
            rig.torsoNode.position.y -= 2
            rig.neckPivot.position.y -= 1
            rig.neckPivot.zRotation = -0.07
            rig.leftArmPivot.zRotation = 0.2
            rig.rightArmPivot.zRotation = -0.2
            rig.setEyesTexture("eyes_sad")
            rig.setMouthTexture("mouth_sad")
        case .sleep:
            rig.torsoNode.zRotation = -0.08
            rig.neckPivot.zRotation = -0.08
            rig.torsoNode.position.y += sin(t * 0.18) * 0.9
            rig.neckPivot.position.y += sin(t * 0.18) * 0.6
            rig.setEyesTexture("eyes_closed")
            rig.setMouthTexture("mouth_smile")
        case .peek:
            rig.rootNode.position.x += 32
            rig.neckPivot.zRotation = sin(t * 0.6) * 0.1
            rig.setEyesTexture(frameIndex % 20 > 14 ? "eyes_closed" : "eyes_open")
            rig.setMouthTexture("mouth_smile")
        case .think:
            rig.neckPivot.zRotation = -0.12 + sin(t * 0.25) * 0.03
            rig.leftArmPivot.zRotation = 0.12
            rig.rightArmPivot.zRotation = -0.3
            rig.rightHandNode.zRotation = -0.2
            rig.setSweatVisible(frameIndex % 26 > 18)
            rig.setEyesTexture("eyes_open")
            rig.setMouthTexture("mouth_sad")
        case .greeting:
            // Timeline: bounce (0.15s), one gentle wave, closed-eye smile hold (0.5s), reopen.
            // We model this at 0.05s/frame to match manifest clip timing.
            let seconds = CGFloat(frameIndex) * 0.05
            let bounceDuration: CGFloat = 0.15
            let waveDuration: CGFloat = 5.0
            let closedStart: CGFloat = waveDuration
            let closedEnd: CGFloat = closedStart + 0.25

            // Small body bounce.
            if seconds < bounceDuration {
                let p = max(0, min(1, seconds / bounceDuration))
                let bounce = sin(p * .pi) * 2.0
                rig.torsoNode.position.y += bounce
                rig.neckPivot.position.y += bounce * 0.8
            }

            // Head tilt about 4° toward cursor side (cursor is targeted beside buddy).
            rig.neckPivot.zRotation = 4.0 * (.pi / 180.0)

            // One natural wave: raise and lower once (no repeated oscillation).
            let wp = max(0, min(1, seconds / waveDuration))
            let waveArc = sin(wp * .pi)
            // Keep arm raised, then sweep clearly left-right in a to-fro motion.
            // 4 full cycles across the 5s wave window for visible motion.
            let sweep = sin(wp * (.pi * 2.0) * 4.0)
            rig.rightArmPivot.position.x += sweep * 18
            rig.rightArmPivot.position.y += waveArc * 6
            rig.rightArmPivot.zRotation = -0.5 - waveArc * 0.5 + sweep * 0.35
            rig.rightArmNode.yScale = 1.0 + abs(sweep) * 0.15
            rig.rightArmNode.xScale = 1.0 + abs(sweep) * 0.06
            rig.leftArmPivot.zRotation = waveArc * 0.06
            // Visible hand sweep even in hands-only mode.
            rig.rightHandNode.position = CGPoint(
                x: 2 + sweep * 26,
                y: -41 + waveArc * 15
            )
            rig.rightHandNode.zRotation = sweep * 0.6

            rig.setMouthTexture("mouth_smile")
            if seconds >= closedStart && seconds < closedEnd {
                rig.setEyesTexture("eyes_closed")
            } else {
                rig.setEyesTexture("eyes_open")
            }
        }

        // Only apply plain facing scale when we haven't already applied a profile squash.
        if abs(rig.rootNode.xScale) == 1 {
            rig.rootNode.xScale = facingRight ? 1 : -1
        }
        previousState = state
    }

    private func applySmoothTurnScale(rig: CharacterRig, frameIndex: Int, targetFacingRight: Bool) {
        let totalFrames: CGFloat = 13
        let p = max(0, min(1, CGFloat(frameIndex) / totalFrames))
        // Ease in/out for a softer turn.
        let eased = p * p * (3 - 2 * p)
        // Squash horizontally near the midpoint.
        let squash = max(0.18, pow(abs(cos(eased * .pi)), 0.85))
        let startSign: CGFloat = turnStartFacingRight ? 1 : -1
        let endSign: CGFloat = targetFacingRight ? 1 : -1
        let sign = eased < 0.5 ? startSign : endSign
        rig.rootNode.xScale = sign * squash
    }

    /// Horizontally squashes the entire rig so front-facing sprites read as a side profile.
    private func applyProfileSquash(rig: CharacterRig, facingRight: Bool) {
        // Uniformly scale side mode up so proportions stay natural while appearing larger.
        let profileScale: CGFloat = 1.12
        rig.rootNode.xScale = facingRight ? profileScale : -profileScale
        rig.rootNode.yScale = profileScale
    }

    private func resetPose(_ rig: CharacterRig) {
        rig.rootNode.position = CGPoint(x: rig.rootNode.position.x, y: 0)
        rig.rootNode.zRotation = 0
        rig.rootNode.xScale = 1
        rig.rootNode.yScale = 1

        rig.torsoNode.position = CGPoint(x: 0, y: 62)
        rig.torsoNode.zRotation = 0
        rig.torsoNode.xScale = 1
        rig.torsoNode.yScale = 1

        rig.neckPivot.position = CGPoint(x: 0, y: 112)
        rig.neckPivot.zRotation = 0
        rig.hairBackNode.position = CGPoint(x: 0, y: -3)
        rig.hairFrontNode.position = CGPoint(x: 0, y: 3)
        rig.fringeNode.position = CGPoint(x: 0, y: 16)
        rig.heartClipNode.position = CGPoint(x: 24, y: 24)
        rig.hairBackNode.zRotation = 0
        rig.hairFrontNode.zRotation = 0
        rig.heartClipNode.zRotation = 0
        rig.heartClipNode.xScale = 1
        rig.heartClipNode.yScale = 1

        rig.leftArmPivot.position = CGPoint(x: -28, y: 82)
        rig.rightArmPivot.position = CGPoint(x: 28, y: 82)
        rig.leftArmPivot.zPosition = 19
        rig.rightArmPivot.zPosition = 19
        rig.leftArmPivot.zRotation = 0
        rig.rightArmPivot.zRotation = 0
        rig.leftArmPivot.alpha = 1
        rig.rightArmPivot.alpha = 1
        rig.leftArmNode.xScale = 1
        rig.rightArmNode.xScale = 1
        rig.leftArmNode.yScale = 1
        rig.rightArmNode.yScale = 1
        rig.leftForearmPivot.position = CGPoint(x: -3, y: -24)
        rig.rightForearmPivot.position = CGPoint(x: 3, y: -24)
        rig.leftForearmPivot.zRotation = 0
        rig.rightForearmPivot.zRotation = 0
        rig.leftForearmNode.position = .zero
        rig.rightForearmNode.position = .zero
        rig.leftForearmNode.zRotation = 0
        rig.rightForearmNode.zRotation = 0
        rig.leftForearmNode.xScale = 1
        rig.rightForearmNode.xScale = 1
        rig.leftForearmNode.yScale = 1
        rig.rightForearmNode.yScale = 1
        rig.leftHandNode.position = CGPoint(x: -2, y: -18)
        rig.rightHandNode.position = CGPoint(x: 2, y: -18)
        rig.leftHandNode.zRotation = 0
        rig.rightHandNode.zRotation = 0

        rig.leftLegPivot.position = CGPoint(x: -14, y: 36)
        // Keep right leg slightly more inward in side walk.
        rig.rightLegPivot.position = CGPoint(x: 14, y: 36)
        rig.leftLegPivot.zPosition = 18
        rig.rightLegPivot.zPosition = 18
        rig.leftLegPivot.zRotation = 0
        rig.rightLegPivot.zRotation = 0
        rig.leftLegPivot.alpha = 1
        rig.rightLegPivot.alpha = 1
        rig.leftLegNode.xScale = 1
        rig.rightLegNode.xScale = 1
        rig.leftLegNode.yScale = 1
        rig.rightLegNode.yScale = 1
        rig.leftShoeNode.zRotation = 0
        rig.rightShoeNode.zRotation = 0

        rig.faceNode.position = CGPoint(x: 0, y: -2)
        rig.eyesNode.position = CGPoint(x: 0, y: 5)
        rig.mouthNode.position = CGPoint(x: 0, y: -8)
        rig.headNode.position = CGPoint(x: 0, y: 0)
        rig.headNode.xScale = 1
        rig.headNode.yScale = 1

        rig.bottleNode.position = CGPoint(x: 36, y: 74)
        rig.bottleNode.zRotation = 0
        rig.setBottleVisible(false)
        rig.setHeartVisible(false)
        rig.setSweatVisible(false)
    }

    private func applySideWalkPose(
        rig: CharacterRig,
        frameIndex: Int,
        cadence: CGFloat,
        intensity: CGFloat,
        enableDepthSwap: Bool
    ) {
        let phase = CGFloat(frameIndex) * cadence
        let primarySwing = sin(phase)
        let easedPrimary = primarySwing * abs(primarySwing) // natural ease-in/ease-out stride

        applySideProfileStance(rig)

        let legAngle = easedPrimary * WalkTuning.legSwing * intensity
        let armAngle = -easedPrimary * WalkTuning.armSwing * intensity
        let forearmAngle = -easedPrimary * WalkTuning.forearmSwing * intensity

        // Use a smooth non-negative bob (sin^2) to avoid sharp cusp jitter at step transitions.
        let bodyBob = (0.5 - 0.5 * cos(phase * 2.0)) * WalkTuning.bodyBob * intensity
        let headBob = sin(phase) * WalkTuning.headBob * intensity
        let headTilt = sin(phase) * WalkTuning.headTilt * intensity

        rig.bodyNode.position.y += bodyBob
        rig.leftArmPivot.position.y += bodyBob
        rig.rightArmPivot.position.y += bodyBob
        rig.leftLegPivot.position.y += bodyBob
        rig.rightLegPivot.position.y += bodyBob
        rig.neckPivot.position.y += bodyBob + headBob

        rig.leftLegPivot.zRotation = legAngle
        rig.rightLegPivot.zRotation = -legAngle
        rig.leftShoeNode.zRotation = -legAngle * 0.5
        rig.rightShoeNode.zRotation = legAngle * 0.5

        rig.leftArmPivot.zRotation = armAngle
        rig.rightArmPivot.zRotation = -armAngle
        rig.leftForearmPivot.zRotation = forearmAngle
        rig.rightForearmPivot.zRotation = -forearmAngle
        rig.leftHandNode.zRotation = -forearmAngle * 0.35
        rig.rightHandNode.zRotation = forearmAngle * 0.35

        // Add lateral stride offsets so arm/leg movement is clearly visible.
        let strideX = easedPrimary * 2.2 * intensity
        rig.leftArmPivot.position.x += strideX
        rig.rightArmPivot.position.x -= strideX
        rig.leftLegPivot.position.x += strideX * 0.65
        // Keep right leg from over-shifting inward/outward, which looked detached.
        rig.rightLegPivot.position.x -= strideX * 0.35
        if enableDepthSwap {
            applySideRunDepthOrdering(rig: rig, legAngle: legAngle)
        } else {
            rig.leftLegPivot.zPosition = 20
            rig.rightLegPivot.zPosition = 20
            rig.leftArmPivot.zPosition = 20
            rig.rightArmPivot.zPosition = 20
            rig.torsoNode.zPosition = 21
        }

        rig.neckPivot.zRotation = headTilt

        // Secondary hair motion lags behind head movement.
        let hairLag = sin(phase - WalkTuning.hairLagPhase) * WalkTuning.headTilt * 0.7 * intensity
        rig.hairBackNode.zRotation = hairLag * 1.25
        rig.hairFrontNode.zRotation = hairLag * 0.95
        rig.hairBackNode.position.y += -hairLag * 30.0
        rig.hairFrontNode.position.y += -hairLag * 20.0

        // Heart clip lightly follows the head with a soft bounce.
        let clipBounce = abs(sin(phase * 2.0)) * 1.4 * intensity
        rig.heartClipNode.position.y += clipBounce
        rig.heartClipNode.zRotation = hairLag * 0.7
    }

    private func applyLandingStopPose(rig: CharacterRig, frameIndex: Int) {
        let settleDurationFrames: CGFloat = 10
        let frame = min(CGFloat(frameIndex), settleDurationFrames)
        let progress = frame / settleDurationFrames
        let damp = 1.0 - progress
        let bounce = sin(progress * .pi) * damp

        rig.bodyNode.position.y -= bounce * 2.4
        rig.neckPivot.position.y -= bounce * 1.35
        rig.neckPivot.zRotation = -bounce * (2.0 * (.pi / 180.0))
        rig.hairFrontNode.position.y += bounce * 0.7
        rig.hairBackNode.position.y += bounce * 0.9
        rig.heartClipNode.position.y += bounce * 0.6
    }

    private func applySideProfileStance(_ rig: CharacterRig) {
        // Keep side walk aligned to the same centerline as front idle.
        rig.bodyNode.position.x += 0
        rig.neckPivot.position.x += 0
        rig.headNode.position.x += 0
        rig.faceNode.position = CGPoint(x: 8, y: -2)
        rig.eyesNode.position = CGPoint(x: 2, y: 5)
        rig.mouthNode.position = CGPoint(x: 2, y: -8)
        // Place clip over the side-head hair clip region (top/back of hair mass).
        rig.heartClipNode.position = CGPoint(x: -4, y: 8)
        rig.heartClipNode.xScale = 1
        rig.heartClipNode.yScale = 1

        // Near side slightly larger/clearer, far side slightly reduced to read depth.
        rig.leftArmPivot.position = CGPoint(x: -20, y: 82)
        rig.rightArmPivot.position = CGPoint(x: 18, y: 80)
        rig.leftArmNode.xScale = 0.95
        rig.leftArmNode.yScale = 0.95
        rig.leftForearmNode.xScale = 0.95
        rig.leftForearmNode.yScale = 0.95
        rig.rightArmNode.xScale = 1.03
        rig.rightArmNode.yScale = 1.03
        rig.rightForearmNode.xScale = 1.03
        rig.rightForearmNode.yScale = 1.03
        rig.leftArmPivot.alpha = 0.9
        rig.rightArmPivot.alpha = 1.0

        // Lift side-walk leg roots so they connect cleanly under hoodie hem.
        rig.leftLegPivot.position = CGPoint(x: -8, y: 40)
        rig.rightLegPivot.position = CGPoint(x: 10, y: 40)
        rig.leftLegNode.xScale = 0.95
        rig.leftLegNode.yScale = 0.95
        rig.rightLegNode.xScale = 1.02
        rig.rightLegNode.yScale = 1.02
        rig.leftLegPivot.alpha = 0.92
        rig.rightLegPivot.alpha = 1.0
    }

    private func applyIdleArmMicroMotion(rig: CharacterRig, t: CGFloat) {
        let upper = sin(t * 0.18) * (4.0 * (.pi / 180.0))
        let fore = -sin(t * 0.18) * (2.0 * (.pi / 180.0))
        let handY = sin(t * 0.24)

        rig.leftArmPivot.zRotation = upper
        rig.rightArmPivot.zRotation = -upper
        rig.leftForearmPivot.zRotation = fore
        rig.rightForearmPivot.zRotation = -fore
        rig.leftHandNode.position.y = -18 + handY
        rig.rightHandNode.position.y = -18 - handY
    }

    private func applySideRunDepthOrdering(rig: CharacterRig, legAngle: CGFloat) {
        // Bring the leading leg/arm in front of torso for a readable side-run.
        let leftLeading = legAngle > 0
        rig.leftLegPivot.zPosition = leftLeading ? 22 : 18
        rig.rightLegPivot.zPosition = leftLeading ? 18 : 22
        rig.leftArmPivot.zPosition = leftLeading ? 24 : 19
        rig.rightArmPivot.zPosition = leftLeading ? 19 : 24
        rig.torsoNode.zPosition = 20
    }
}
