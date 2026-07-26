import SpriteKit
import SwiftUI
import Theme

@MainActor
final class CharacterRig {
    let rootNode = SKNode()
    /// Debug aid: reveal rig parts incrementally to validate asset placement.
    /// Set to `nil` to show all parts normally.
    private let partValidationStage: Int? = 10
    /// Temporary mode: hide arm sprites, render hands only.
    private let useHandsOnlyArms = true

    // Core body
    let torsoNode = SKSpriteNode(color: .white, size: CGSize(width: 72, height: 58))
    let neckPivot = SKNode()
    let headNode = SKSpriteNode(color: .white, size: CGSize(width: 62, height: 62))

    // Hair layers
    let hairBackNode = SKSpriteNode(color: .white, size: CGSize(width: 78, height: 68))
    let hairFrontNode = SKSpriteNode(color: .white, size: CGSize(width: 78, height: 66))
    let fringeNode = SKSpriteNode(color: .white, size: CGSize(width: 54, height: 26))
    let heartClipNode = SKSpriteNode(color: .white, size: CGSize(width: 12, height: 12))

    // Face
    let faceNode = SKNode()
    let eyesNode = SKSpriteNode(color: .clear, size: CGSize(width: 30, height: 12))
    let mouthNode = SKSpriteNode(color: .clear, size: CGSize(width: 16, height: 8))

    // Arms
    let leftArmPivot = SKNode()
    let rightArmPivot = SKNode()
    let leftArmNode = SKSpriteNode(color: .white, size: CGSize(width: 22, height: 34))
    let rightArmNode = SKSpriteNode(color: .white, size: CGSize(width: 22, height: 34))
    let leftHandNode = SKSpriteNode(color: .white, size: CGSize(width: 12, height: 12))
    let rightHandNode = SKSpriteNode(color: .white, size: CGSize(width: 12, height: 12))

    // Legs
    let leftLegPivot = SKNode()
    let rightLegPivot = SKNode()
    let leftLegNode = SKSpriteNode(color: .white, size: CGSize(width: 12, height: 24))
    let rightLegNode = SKSpriteNode(color: .white, size: CGSize(width: 12, height: 24))
    let leftShoeNode = SKSpriteNode(color: .white, size: CGSize(width: 14, height: 10))
    let rightShoeNode = SKSpriteNode(color: .white, size: CGSize(width: 14, height: 10))

    // Extras
    let bottleNode = SKSpriteNode(color: .white, size: CGSize(width: 14, height: 20))
    let heartNode = SKSpriteNode(color: .white, size: CGSize(width: 14, height: 14))
    let sweatNode = SKSpriteNode(color: .white, size: CGSize(width: 10, height: 10))

    private let atlasProvider: CompanionAtlasProvider
    private(set) var hasRigTextures = false
    private var isBottleEffectVisible = false
    private var isHeartEffectVisible = false
    private var isSweatEffectVisible = false

    init(atlasProvider: CompanionAtlasProvider) {
        self.atlasProvider = atlasProvider
        buildHierarchy()
        loadTextures()
        applyTheme(ThemeLoader.fallbackTheme)
    }

    func reloadTextures() {
        loadTextures()
    }

    func applyTheme(_ theme: Theme) {
        if torsoNode.texture == nil {
            torsoNode.color = SKColor(Color(hex: theme.primary))
        }
        let skin = SKColor(Color(hex: theme.secondary))
        if headNode.texture == nil {
            headNode.color = skin
        }

        let hair = SKColor(Color(hex: "#4A3040"))
        if hairBackNode.texture == nil { hairBackNode.color = hair }
        if hairFrontNode.texture == nil { hairFrontNode.color = hair }
        if fringeNode.texture == nil { fringeNode.color = hair }

        let sleeve = SKColor(Color(hex: theme.primary)).withAlphaComponent(0.95)
        if leftArmNode.texture == nil { leftArmNode.color = sleeve }
        if rightArmNode.texture == nil { rightArmNode.color = sleeve }

        let hand = SKColor(Color(hex: theme.secondary))
        if leftHandNode.texture == nil { leftHandNode.color = hand }
        if rightHandNode.texture == nil { rightHandNode.color = hand }

        let leg = SKColor(Color(hex: theme.surface))
        if leftLegNode.texture == nil { leftLegNode.color = leg }
        if rightLegNode.texture == nil { rightLegNode.color = leg }
        if leftShoeNode.texture == nil { leftShoeNode.color = SKColor(Color(hex: "#F3BDD0")) }
        if rightShoeNode.texture == nil { rightShoeNode.color = SKColor(Color(hex: "#F3BDD0")) }
        if heartClipNode.texture == nil { heartClipNode.color = SKColor(Color(hex: "#FF8FA8")) }
        if bottleNode.texture == nil { bottleNode.color = SKColor(Color(hex: "#B9E6FF")) }
        if heartNode.texture == nil { heartNode.color = SKColor(Color(hex: "#FF8FA8")) }
        if sweatNode.texture == nil { sweatNode.color = SKColor(Color(hex: "#93D8F5")) }
    }

    func setEyesTexture(_ name: String) {
        eyesNode.texture = atlasProvider.characterPartTexture(group: "Face", name: name)
        if eyesNode.texture == nil {
            eyesNode.color = .black
            eyesNode.alpha = 0.85
        } else {
            eyesNode.color = .white
            eyesNode.alpha = 1
        }
    }

    func setMouthTexture(_ name: String) {
        mouthNode.texture = atlasProvider.characterPartTexture(group: "Face", name: name)
        if mouthNode.texture == nil {
            mouthNode.color = .black
            mouthNode.alpha = 0.7
        } else {
            mouthNode.color = .white
            mouthNode.alpha = 1
        }
    }

    func setBottleVisible(_ visible: Bool) {
        isBottleEffectVisible = visible
        bottleNode.alpha = visible ? 1 : 0
    }

    func setHeartVisible(_ visible: Bool) {
        isHeartEffectVisible = visible
        heartNode.alpha = visible ? 1 : 0
    }

    func setSweatVisible(_ visible: Bool) {
        isSweatEffectVisible = visible
        sweatNode.alpha = visible ? 1 : 0
    }

    private func buildHierarchy() {
        rootNode.zPosition = 60

        torsoNode.position = CGPoint(x: 0, y: 62)
        torsoNode.zPosition = 20

        leftArmPivot.position = CGPoint(x: -28, y: 82)
        rightArmPivot.position = CGPoint(x: 28, y: 82)
        leftArmPivot.zPosition = 19
        rightArmPivot.zPosition = 19

        leftArmNode.anchorPoint = CGPoint(x: 0.5, y: 1)
        rightArmNode.anchorPoint = CGPoint(x: 0.5, y: 1)
        leftArmNode.position = .zero
        rightArmNode.position = .zero

        leftHandNode.position = useHandsOnlyArms ? CGPoint(x: -3, y: -41) : CGPoint(x: 0, y: -30)
        rightHandNode.position = useHandsOnlyArms ? CGPoint(x: 2, y: -41) : CGPoint(x: 0, y: -30)
        leftHandNode.zPosition = 1
        rightHandNode.zPosition = 1

        neckPivot.position = CGPoint(x: 0, y: 112)
        neckPivot.zPosition = 25
        // Keep head centered inside the hair shell in normal render mode.
        headNode.position = CGPoint(x: 0, y: 0)
        headNode.zPosition = 2
        hairBackNode.position = CGPoint(x: 0, y: -3)
        hairBackNode.zPosition = 1
        hairFrontNode.position = CGPoint(x: 0, y: 3)
        hairFrontNode.zPosition = 3
        fringeNode.position = CGPoint(x: 0, y: 16)
        fringeNode.zPosition = 4
        heartClipNode.position = CGPoint(x: 24, y: 24)
        heartClipNode.zPosition = 9

        faceNode.position = CGPoint(x: 0, y: -2)
        faceNode.zPosition = 6
        eyesNode.position = CGPoint(x: 0, y: 5)
        mouthNode.position = CGPoint(x: 0, y: -8)
        eyesNode.zPosition = 1
        mouthNode.zPosition = 1

        leftLegPivot.position = CGPoint(x: -14, y: 30)
        rightLegPivot.position = CGPoint(x: 14, y: 30)
        leftLegPivot.zPosition = 18
        rightLegPivot.zPosition = 18
        leftLegNode.anchorPoint = CGPoint(x: 0.5, y: 1)
        rightLegNode.anchorPoint = CGPoint(x: 0.5, y: 1)
        leftLegNode.position = .zero
        rightLegNode.position = .zero
        leftShoeNode.position = CGPoint(x: 0, y: -22)
        rightShoeNode.position = CGPoint(x: 0, y: -22)

        bottleNode.position = CGPoint(x: 36, y: 74)
        bottleNode.zPosition = 30
        bottleNode.alpha = 0
        heartNode.position = CGPoint(x: 26, y: 145)
        heartNode.zPosition = 31
        heartNode.alpha = 0
        sweatNode.position = CGPoint(x: 24, y: 132)
        sweatNode.zPosition = 31
        sweatNode.alpha = 0

        rootNode.addChild(torsoNode)
        rootNode.addChild(leftArmPivot)
        rootNode.addChild(rightArmPivot)
        rootNode.addChild(leftLegPivot)
        rootNode.addChild(rightLegPivot)
        rootNode.addChild(neckPivot)
        rootNode.addChild(bottleNode)
        rootNode.addChild(heartNode)
        rootNode.addChild(sweatNode)

        leftArmPivot.addChild(leftArmNode)
        rightArmPivot.addChild(rightArmNode)
        if useHandsOnlyArms {
            leftArmPivot.addChild(leftHandNode)
            rightArmPivot.addChild(rightHandNode)
        } else {
            leftArmNode.addChild(leftHandNode)
            rightArmNode.addChild(rightHandNode)
        }

        leftLegPivot.addChild(leftLegNode)
        leftLegNode.addChild(leftShoeNode)
        rightLegPivot.addChild(rightLegNode)
        rightLegNode.addChild(rightShoeNode)

        neckPivot.addChild(hairBackNode)
        neckPivot.addChild(headNode)
        neckPivot.addChild(hairFrontNode)
        neckPivot.addChild(fringeNode)
        neckPivot.addChild(heartClipNode)
        neckPivot.addChild(faceNode)
        faceNode.addChild(eyesNode)
        faceNode.addChild(mouthNode)
    }

    private func loadTextures() {
        torsoNode.texture = atlasProvider.characterPartTexture(group: "Body", name: "hoodie")
        leftArmNode.texture = atlasProvider.characterPartTexture(group: "Body", name: "left_arm")
        rightArmNode.texture = atlasProvider.characterPartTexture(group: "Body", name: "right_arm")
        leftHandNode.texture = atlasProvider.characterPartTexture(group: "Body", name: "left_hand")
        rightHandNode.texture = atlasProvider.characterPartTexture(group: "Body", name: "right_hand")

        headNode.texture = atlasProvider.characterPartTexture(group: "Head", name: "head")
        hairBackNode.texture = atlasProvider.characterPartTexture(group: "Head", name: "hair_back")
        hairFrontNode.texture = atlasProvider.characterPartTexture(group: "Head", name: "hair_front")
        fringeNode.texture = atlasProvider.characterPartTexture(group: "Head", name: "fringe")
        heartClipNode.texture = atlasProvider.characterPartTexture(group: "Head", name: "heart_clip")

        leftLegNode.texture = atlasProvider.characterPartTexture(group: "Legs", name: "left_leg")
        rightLegNode.texture = atlasProvider.characterPartTexture(group: "Legs", name: "right_leg")
        leftShoeNode.texture = atlasProvider.characterPartTexture(group: "Legs", name: "left_shoe")
        rightShoeNode.texture = atlasProvider.characterPartTexture(group: "Legs", name: "right_shoe")

        bottleNode.texture = atlasProvider.characterPartTexture(group: "Extras", name: "water_bottle")
        heartNode.texture = atlasProvider.characterPartTexture(group: "Extras", name: "heart")
        sweatNode.texture = atlasProvider.characterPartTexture(group: "Extras", name: "sweat_drop")

        hasRigTextures = [torsoNode.texture, headNode.texture, eyesNode.texture].contains { $0 != nil }
        setEyesTexture("eyes_open")
        setMouthTexture("mouth_smile")
        if useHandsOnlyArms {
            leftArmNode.alpha = 0
            rightArmNode.alpha = 0
        }

        applyTextureSizing()
        applyPartValidationVisibility()
    }

    func enforcePartValidationVisibility() {
        applyPartValidationVisibility()
    }

    private func applyTextureSizing() {
        applyNaturalSize(torsoNode, fallback: CGSize(width: 72, height: 58), max: CGSize(width: 86, height: 68))
        applyNaturalSize(headNode, fallback: CGSize(width: 62, height: 62), max: CGSize(width: 72, height: 72))
        applyNaturalSize(hairBackNode, fallback: CGSize(width: 78, height: 68), max: CGSize(width: 84, height: 74))
        applyNaturalSize(hairFrontNode, fallback: CGSize(width: 78, height: 66), max: CGSize(width: 84, height: 72))
        applyNaturalSize(fringeNode, fallback: CGSize(width: 54, height: 26), max: CGSize(width: 60, height: 32))
        applyNaturalSize(heartClipNode, fallback: CGSize(width: 12, height: 12), max: CGSize(width: 20, height: 20))
        applyNaturalSize(leftArmNode, fallback: CGSize(width: 22, height: 34), max: CGSize(width: 26, height: 38))
        applyNaturalSize(rightArmNode, fallback: CGSize(width: 22, height: 34), max: CGSize(width: 26, height: 38))
        applyNaturalSize(leftHandNode, fallback: CGSize(width: 12, height: 12), max: CGSize(width: 14, height: 14))
        applyNaturalSize(rightHandNode, fallback: CGSize(width: 12, height: 12), max: CGSize(width: 14, height: 14))
        applyNaturalSize(leftLegNode, fallback: CGSize(width: 12, height: 24), max: CGSize(width: 14, height: 28))
        applyNaturalSize(rightLegNode, fallback: CGSize(width: 12, height: 24), max: CGSize(width: 14, height: 28))
        applyNaturalSize(leftShoeNode, fallback: CGSize(width: 14, height: 10), max: CGSize(width: 18, height: 14))
        applyNaturalSize(rightShoeNode, fallback: CGSize(width: 14, height: 10), max: CGSize(width: 18, height: 14))
        applyNaturalSize(eyesNode, fallback: CGSize(width: 30, height: 12), max: CGSize(width: 34, height: 16))
        applyNaturalSize(mouthNode, fallback: CGSize(width: 16, height: 8), max: CGSize(width: 20, height: 12))
        applyNaturalSize(bottleNode, fallback: CGSize(width: 14, height: 20), max: CGSize(width: 18, height: 24))
        applyNaturalSize(heartNode, fallback: CGSize(width: 14, height: 14), max: CGSize(width: 16, height: 16))
        applyNaturalSize(sweatNode, fallback: CGSize(width: 10, height: 10), max: CGSize(width: 12, height: 12))
    }

    private func applyNaturalSize(_ node: SKSpriteNode, fallback: CGSize, max: CGSize) {
        guard let texture = node.texture else {
            node.size = fallback
            return
        }
        let texSize = texture.size()
        guard texSize.width > 0, texSize.height > 0 else {
            node.size = fallback
            return
        }
        let scale = min(max.width / texSize.width, max.height / texSize.height)
        node.size = CGSize(width: texSize.width * scale, height: texSize.height * scale)
    }

    private func applyPartValidationVisibility() {
        guard let stage = partValidationStage else {
            // Restore normal visibility when staged validation is disabled.
            let normalParts: [SKNode] = [
                headNode,
                hairFrontNode,
                hairBackNode,
                torsoNode,
                leftArmNode,
                rightArmNode,
                leftHandNode,
                rightHandNode,
                leftLegNode,
                rightLegNode,
                leftShoeNode,
                rightShoeNode,
                eyesNode,
                mouthNode,
                fringeNode,
                heartClipNode,
            ]
            for node in normalParts {
                node.alpha = 1
            }
            if useHandsOnlyArms {
                leftArmNode.alpha = 0
                rightArmNode.alpha = 0
                leftHandNode.alpha = 1
                rightHandNode.alpha = 1
            }
            // Effect nodes stay off unless explicitly enabled by state logic.
            bottleNode.alpha = isBottleEffectVisible ? 1 : 0
            heartNode.alpha = isHeartEffectVisible ? 1 : 0
            sweatNode.alpha = isSweatEffectVisible ? 1 : 0
            return
        }
        let orderedParts: [SKNode] = [
            headNode,
            hairFrontNode,
            hairBackNode,
            torsoNode,
            leftArmNode,
            rightArmNode,
            leftHandNode,
            rightHandNode,
            leftLegNode,
            rightLegNode,
            leftShoeNode,
            rightShoeNode,
            eyesNode,
            mouthNode,
            fringeNode,
            heartClipNode,
            bottleNode,
            heartNode,
            sweatNode,
        ]
        let clampedStage = max(0, min(stage, orderedParts.count))
        for (index, node) in orderedParts.enumerated() {
            node.alpha = index < clampedStage ? 1 : 0
        }
        if useHandsOnlyArms {
            leftArmNode.alpha = 0
            rightArmNode.alpha = 0
        }
        // Keep heart clip visible during validation so placement is easy to verify.
        heartClipNode.alpha = 1
        // Preserve transient effect visibility driven by state machine.
        bottleNode.alpha = isBottleEffectVisible ? 1 : 0
        heartNode.alpha = isHeartEffectVisible ? 1 : 0
        sweatNode.alpha = isSweatEffectVisible ? 1 : 0
    }
}
