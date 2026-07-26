import SpriteKit
import Domain

@MainActor
final class CharacterRigAnimator {
    func apply(state: CharacterState, frameIndex: Int, rig: CharacterRig, facingRight: inout Bool) {
        let t = CGFloat(frameIndex)
        let wave = sin(t * 0.34)
        let quick = sin(t * 0.75)

        resetPose(rig)

        switch state {
        case .idle:
            rig.torsoNode.position.y += wave * 1.4
            rig.neckPivot.position.y += wave * 1.3
            rig.hairFrontNode.position.y -= wave * 0.8
            rig.hairBackNode.position.y -= wave * 1.1
            rig.neckPivot.zRotation = wave * 0.03
            rig.torsoNode.yScale = 1 + wave * 0.01
            rig.setEyesTexture(frameIndex % 90 > 82 ? "eyes_closed" : "eyes_open")
            rig.setMouthTexture(frameIndex % 140 > 118 ? "mouth_open" : "mouth_smile")
        case .breathing:
            rig.torsoNode.yScale = 1 + wave * 0.02
            rig.neckPivot.position.y += wave * 1.2
            rig.hairBackNode.position.y -= wave * 0.6
            rig.setEyesTexture("eyes_open")
            rig.setMouthTexture("mouth_smile")
        case .blink:
            rig.setEyesTexture(frameIndex % 6 > 1 ? "eyes_closed" : "eyes_open")
            rig.setMouthTexture("mouth_smile")
        case .walk:
            facingRight = true
            applyWalkPose(rig: rig, wave: quick, intensity: 0.45)
            rig.setEyesTexture("eyes_open")
            rig.setMouthTexture("mouth_smile")
        case .run:
            facingRight = true
            applyWalkPose(rig: rig, wave: quick, intensity: 0.72)
            rig.torsoNode.position.y += abs(quick) * 1.8
            rig.setEyesTexture("eyes_open")
            rig.setMouthTexture("mouth_open")
        case .turn:
            if frameIndex % 5 == 0 { facingRight.toggle() }
            rig.neckPivot.zRotation = wave * 0.14
            rig.torsoNode.zRotation = -wave * 0.08
            rig.setEyesTexture("eyes_open")
            rig.setMouthTexture("mouth_smile")
        case .stop:
            rig.torsoNode.position.y -= abs(wave) * 1.6
            rig.neckPivot.position.y -= abs(wave) * 0.8
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
            rig.setHeartVisible(true)
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
        }

        rig.rootNode.xScale = facingRight ? 1 : -1
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

        rig.leftArmPivot.position = CGPoint(x: -28, y: 82)
        rig.rightArmPivot.position = CGPoint(x: 28, y: 82)
        rig.leftArmPivot.zRotation = 0
        rig.rightArmPivot.zRotation = 0
        rig.leftHandNode.zRotation = 0
        rig.rightHandNode.zRotation = 0

        rig.leftLegPivot.position = CGPoint(x: -14, y: 30)
        rig.rightLegPivot.position = CGPoint(x: 14, y: 30)
        rig.leftLegPivot.zRotation = 0
        rig.rightLegPivot.zRotation = 0
        rig.leftShoeNode.zRotation = 0
        rig.rightShoeNode.zRotation = 0

        rig.bottleNode.position = CGPoint(x: 36, y: 74)
        rig.bottleNode.zRotation = 0
        rig.setBottleVisible(false)
        rig.setHeartVisible(false)
        rig.setSweatVisible(false)
    }

    private func applyWalkPose(rig: CharacterRig, wave: CGFloat, intensity: CGFloat) {
        rig.torsoNode.position.y += abs(wave) * (2.2 * intensity)
        rig.neckPivot.position.y += abs(wave) * (1.1 * intensity)

        rig.leftLegPivot.zRotation = wave * 0.35 * intensity
        rig.rightLegPivot.zRotation = -wave * 0.35 * intensity
        rig.leftShoeNode.zRotation = -wave * 0.12 * intensity
        rig.rightShoeNode.zRotation = wave * 0.12 * intensity

        rig.leftArmPivot.zRotation = -wave * 0.33 * intensity
        rig.rightArmPivot.zRotation = wave * 0.33 * intensity
        rig.neckPivot.zRotation = wave * 0.02
        rig.hairBackNode.position.y -= wave * 1.5 * intensity
        rig.hairFrontNode.position.y -= wave * 1.1 * intensity
    }
}
