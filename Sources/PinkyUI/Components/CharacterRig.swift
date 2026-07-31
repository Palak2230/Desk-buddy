import SpriteKit
import SwiftUI
import Theme

@MainActor
final class CharacterRig {
    let rootNode = SKNode()
    /// Debug aid: reveal rig parts incrementally to validate asset placement.
    /// Set to `nil` to show all parts normally.
    private let partValidationStage: Int? = nil
    /// Keep the full arm chain visible for procedural side-walk.
    private let useHandsOnlyArms = false
    /// Current head art already includes eyes/mouth; disable overlay face sprites.
    private let useFaceFeatureOverlays = false
    /// Use separate hand sprites in front-facing states.
    private let useSeparateHandSprites = true

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
    let leftForearmPivot = SKNode()
    let rightForearmPivot = SKNode()
    let leftForearmNode = SKSpriteNode(color: .white, size: CGSize(width: 16, height: 18))
    let rightForearmNode = SKSpriteNode(color: .white, size: CGSize(width: 16, height: 18))
    let leftHandNode = SKSpriteNode(color: .white, size: CGSize(width: 12, height: 12))
    let rightHandNode = SKSpriteNode(color: .white, size: CGSize(width: 12, height: 12))

    // Hierarchy aliases used by the procedural side-walk rig naming.
    var characterRootNode: SKNode { rootNode }
    var bodyNode: SKSpriteNode { torsoNode }
    var leftUpperArmNode: SKSpriteNode { leftArmNode }
    var rightUpperArmNode: SKSpriteNode { rightArmNode }

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
    private var isGreetingWaveActive = false
    private var isSideHeadActive = false
    private var isSideBodyActive = false
    private var sideVisibleHandFacingRight: Bool?
    private var hideFrontShoulderSleeves = false
    private var forearmsAttachedToUpperArms = true
    private var handsAttachedToSleeves = false
    private var handsAttachedToFrontPivots = false
    private let sideLeftHandCuffPosition = CGPoint(x: -10, y: -25)
    private let sideRightHandCuffPosition = CGPoint(x: -4, y: -25)
    private let frontLeftHandPivotPosition = CGPoint(x: -8, y: -42)
    private let frontRightHandPivotPosition = CGPoint(x: 8, y: -42)
    private var frontHeadTexture: SKTexture?
    private var sideHeadTexture: SKTexture?
    private var frontBodyTexture: SKTexture?
    private var sideBodyTexture: SKTexture?
    private var frontLeftUpperArmTexture: SKTexture?
    private var frontRightUpperArmTexture: SKTexture?
    private var frontLeftForearmTexture: SKTexture?
    private var frontRightForearmTexture: SKTexture?
    private var frontLeftHandTexture: SKTexture?
    private var frontRightHandTexture: SKTexture?
    private var sideLeftUpperArmTexture: SKTexture?
    private var sideRightUpperArmTexture: SKTexture?
    private var sideLeftForearmTexture: SKTexture?
    private var sideRightForearmTexture: SKTexture?
    private var sideLeftHandTexture: SKTexture?
    private var sideRightHandTexture: SKTexture?
    /// Temporary guard: only enable after providing a transparent, tightly-cropped side head asset.
    private let useSideHeadTexture = true
    /// Side body toggle for walk/run profile testing.
    private let useSideBodyTexture = true
    /// Keep false until clean dedicated side arm sprites are ready.
    private let useSideArmTextures = false
    private let frontForearmInsetX: CGFloat = 3

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
        if leftForearmNode.texture == nil { leftForearmNode.color = sleeve }
        if rightForearmNode.texture == nil { rightForearmNode.color = sleeve }

        let hand = SKColor(Color(hex: theme.secondary))
        if useSeparateHandSprites {
            if leftHandNode.texture == nil { leftHandNode.color = hand }
            if rightHandNode.texture == nil { rightHandNode.color = hand }
        }

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
        guard useFaceFeatureOverlays else {
            eyesNode.texture = nil
            eyesNode.color = .clear
            eyesNode.alpha = 0
            return
        }
        eyesNode.texture = atlasProvider.characterPartTexture(group: "Face", name: name)
        if eyesNode.texture == nil {
            // Avoid black rectangular artifacts when a face texture is missing.
            eyesNode.color = .clear
            eyesNode.alpha = 0
        } else {
            eyesNode.color = .white
            eyesNode.alpha = 1
        }
    }

    func setMouthTexture(_ name: String) {
        guard useFaceFeatureOverlays else {
            mouthNode.texture = nil
            mouthNode.color = .clear
            mouthNode.alpha = 0
            return
        }
        mouthNode.texture = atlasProvider.characterPartTexture(group: "Face", name: name)
        if mouthNode.texture == nil {
            // Avoid black rectangular artifacts when a face texture is missing.
            mouthNode.color = .clear
            mouthNode.alpha = 0
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

    func setGreetingWaveActive(_ active: Bool) {
        isGreetingWaveActive = active
    }

    func setFrontShoulderSleevesHidden(_ hidden: Bool) {
        guard hideFrontShoulderSleeves != hidden else { return }
        hideFrontShoulderSleeves = hidden
        setForearmsAttachedToUpperArms(!hidden)
        if !isSideBodyActive {
            setHandsAttachedToFrontPivots(hidden)
        }
    }

    func setSideVisibleHandFacingRight(_ facingRight: Bool?) {
        sideVisibleHandFacingRight = facingRight
    }

    private func setForearmsAttachedToUpperArms(_ attached: Bool) {
        guard forearmsAttachedToUpperArms != attached else { return }
        forearmsAttachedToUpperArms = attached

        leftForearmPivot.removeFromParent()
        rightForearmPivot.removeFromParent()

        if attached {
            leftArmNode.addChild(leftForearmPivot)
            rightArmNode.addChild(rightForearmPivot)
        } else {
            leftArmPivot.addChild(leftForearmPivot)
            rightArmPivot.addChild(rightForearmPivot)
        }

        leftForearmPivot.position = CGPoint(x: -frontForearmInsetX, y: -24)
        rightForearmPivot.position = CGPoint(x: frontForearmInsetX, y: -24)
    }

    private func setHandsAttachedToSleeves(_ attached: Bool) {
        guard handsAttachedToSleeves != attached else { return }
        handsAttachedToSleeves = attached

        leftHandNode.removeFromParent()
        rightHandNode.removeFromParent()

        if attached {
            // In side fallback, sleeve shape is baked in torso art, so anchor hands to cuff points on torso.
            torsoNode.addChild(leftHandNode)
            torsoNode.addChild(rightHandNode)
            leftHandNode.position = sideLeftHandCuffPosition
            rightHandNode.position = sideRightHandCuffPosition
        } else {
            leftForearmNode.addChild(leftHandNode)
            rightForearmNode.addChild(rightHandNode)
            leftHandNode.position = CGPoint(x: -2, y: -18)
            rightHandNode.position = CGPoint(x: 2, y: -18)
        }
    }

    private func setHandsAttachedToFrontPivots(_ attached: Bool) {
        guard handsAttachedToFrontPivots != attached else { return }
        handsAttachedToFrontPivots = attached

        leftHandNode.removeFromParent()
        rightHandNode.removeFromParent()

        if attached {
            leftArmPivot.addChild(leftHandNode)
            rightArmPivot.addChild(rightHandNode)
            leftHandNode.position = frontLeftHandPivotPosition
            rightHandNode.position = frontRightHandPivotPosition
        } else {
            leftForearmNode.addChild(leftHandNode)
            rightForearmNode.addChild(rightHandNode)
            leftHandNode.position = CGPoint(x: -2, y: -18)
            rightHandNode.position = CGPoint(x: 2, y: -18)
        }
    }

    func setSideHeadActive(_ active: Bool) {
        if active != isSideHeadActive {
            isSideHeadActive = active
            let targetTexture = active ? (sideHeadTexture ?? frontHeadTexture) : frontHeadTexture
            headNode.texture = targetTexture
        }
        applyNaturalSize(headNode, fallback: CGSize(width: 62, height: 62), max: CGSize(width: 72, height: 72))
        headNode.xScale = 1
        headNode.yScale = 1
    }

    func setSideBodyActive(_ active: Bool) {
        if active != isSideBodyActive {
            isSideBodyActive = active
            if active && !useSideArmTextures {
                // Keep hand chain physically connected to hoodie sleeves in side fallback mode.
                setForearmsAttachedToUpperArms(true)
                setHandsAttachedToFrontPivots(false)
                setHandsAttachedToSleeves(true)
            } else {
                setForearmsAttachedToUpperArms(!hideFrontShoulderSleeves)
                setHandsAttachedToSleeves(false)
                setHandsAttachedToFrontPivots(hideFrontShoulderSleeves)
            }
            let targetTexture = active ? (sideBodyTexture ?? frontBodyTexture) : frontBodyTexture
            torsoNode.texture = targetTexture
            // Keep arm chain on clean front assets until dedicated side arm sprites are exported without labels.
            leftArmNode.texture = frontLeftUpperArmTexture
            rightArmNode.texture = frontRightUpperArmTexture
            leftForearmNode.texture = frontLeftForearmTexture
            rightForearmNode.texture = frontRightForearmTexture
            leftHandNode.texture = frontLeftHandTexture
            rightHandNode.texture = frontRightHandTexture
            if active && !useSideArmTextures {
                // Compact side fallback chain so sleeve motion still feels natural.
                leftForearmPivot.position = CGPoint(x: 0, y: -16)
                rightForearmPivot.position = CGPoint(x: 0, y: -16)
                leftHandNode.position = sideLeftHandCuffPosition
                rightHandNode.position = sideRightHandCuffPosition
            } else {
                leftForearmPivot.position = CGPoint(x: -frontForearmInsetX, y: -24)
                rightForearmPivot.position = CGPoint(x: frontForearmInsetX, y: -24)
                leftHandNode.position = CGPoint(x: -2, y: -18)
                rightHandNode.position = CGPoint(x: 2, y: -18)
            }
        }
        applyNaturalSize(torsoNode, fallback: CGSize(width: 72, height: 58), max: CGSize(width: 86, height: 68))
        applyNaturalSize(leftArmNode, fallback: CGSize(width: 22, height: 34), max: CGSize(width: 26, height: 38))
        applyNaturalSize(rightArmNode, fallback: CGSize(width: 22, height: 34), max: CGSize(width: 26, height: 38))
        applyNaturalSize(leftForearmNode, fallback: CGSize(width: 16, height: 18), max: CGSize(width: 22, height: 32))
        applyNaturalSize(rightForearmNode, fallback: CGSize(width: 16, height: 18), max: CGSize(width: 22, height: 32))
        applyNaturalSize(leftHandNode, fallback: CGSize(width: 12, height: 12), max: CGSize(width: 20, height: 18))
        applyNaturalSize(rightHandNode, fallback: CGSize(width: 12, height: 12), max: CGSize(width: 20, height: 18))
        torsoNode.xScale = 1
        torsoNode.yScale = 1
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
        leftForearmPivot.position = CGPoint(x: -frontForearmInsetX, y: -24)
        rightForearmPivot.position = CGPoint(x: frontForearmInsetX, y: -24)
        leftForearmNode.anchorPoint = CGPoint(x: 0.5, y: 1)
        rightForearmNode.anchorPoint = CGPoint(x: 0.5, y: 1)
        leftForearmNode.position = .zero
        rightForearmNode.position = .zero
        leftHandNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rightHandNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        leftHandNode.position = CGPoint(x: -2, y: -18)
        rightHandNode.position = CGPoint(x: 2, y: -18)
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

        leftLegPivot.position = CGPoint(x: -14, y: 36)
        rightLegPivot.position = CGPoint(x: 14, y: 36)
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
        // Keep floating reminder hearts behind mascot body.
        heartNode.position = CGPoint(x: 24, y: 120)
        heartNode.zPosition = 17
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
        leftArmNode.addChild(leftForearmPivot)
        rightArmNode.addChild(rightForearmPivot)
        leftForearmPivot.addChild(leftForearmNode)
        rightForearmPivot.addChild(rightForearmNode)
        leftForearmNode.addChild(leftHandNode)
        rightForearmNode.addChild(rightHandNode)
        leftHandNode.alpha = useSeparateHandSprites ? 1 : 0
        rightHandNode.alpha = useSeparateHandSprites ? 1 : 0

        leftLegPivot.addChild(leftLegNode)
        leftLegNode.addChild(leftShoeNode)
        rightLegPivot.addChild(rightLegNode)
        rightLegNode.addChild(rightShoeNode)

        neckPivot.addChild(hairBackNode)
        neckPivot.addChild(headNode)
        neckPivot.addChild(hairFrontNode)
        // Temporarily disabled to isolate face-layer artifacts.
        // neckPivot.addChild(fringeNode)
        neckPivot.addChild(heartClipNode)
        neckPivot.addChild(faceNode)
        faceNode.addChild(eyesNode)
        // Temporarily disabled to hide fallback mouth artifact.
        // faceNode.addChild(mouthNode)
    }

    private func loadTextures() {
        frontBodyTexture = atlasProvider.characterPartTexture(group: "Body", name: "hoodie")
        sideBodyTexture = useSideBodyTexture
            ? atlasProvider.characterPartTexture(group: "Body", name: "hoodie_side")
            : nil
        torsoNode.texture = frontBodyTexture
        isSideBodyActive = false
        frontLeftUpperArmTexture = atlasProvider.characterPartTexture(group: "Body", name: "left_upper_arm")
            ?? atlasProvider.characterPartTexture(group: "Body", name: "left_arm")
        frontRightUpperArmTexture = atlasProvider.characterPartTexture(group: "Body", name: "right_upper_arm")
            ?? atlasProvider.characterPartTexture(group: "Body", name: "right_arm")
        let leftForearmBase = atlasProvider.characterPartTexture(group: "Body", name: "left_forearm")
            ?? frontLeftUpperArmTexture
        let rightForearmBase = atlasProvider.characterPartTexture(group: "Body", name: "right_forearm")
            ?? frontRightUpperArmTexture
        // Avoid duplicated hands when forearm assets are missing but separate hand nodes are enabled.
        frontLeftForearmTexture = leftForearmBase
            ?? (useSeparateHandSprites ? nil : atlasProvider.characterPartTexture(group: "Body", name: "left_hand"))
        frontRightForearmTexture = rightForearmBase
            ?? (useSeparateHandSprites ? nil : atlasProvider.characterPartTexture(group: "Body", name: "right_hand"))
        frontLeftHandTexture = useSeparateHandSprites
            ? atlasProvider.characterPartTexture(group: "Body", name: "left_hand")
            : nil
        frontRightHandTexture = useSeparateHandSprites
            ? atlasProvider.characterPartTexture(group: "Body", name: "right_hand")
            : nil

        sideLeftUpperArmTexture = atlasProvider.characterPartTexture(group: "Body", name: "left_upper_arm_side")
        sideRightUpperArmTexture = atlasProvider.characterPartTexture(group: "Body", name: "right_upper_arm_side")
        sideLeftForearmTexture = atlasProvider.characterPartTexture(group: "Body", name: "left_forearm_side")
        sideRightForearmTexture = atlasProvider.characterPartTexture(group: "Body", name: "right_forearm_side")
        sideLeftHandTexture = useSeparateHandSprites
            ? atlasProvider.characterPartTexture(group: "Body", name: "left_hand_side")
            : nil
        sideRightHandTexture = useSeparateHandSprites
            ? atlasProvider.characterPartTexture(group: "Body", name: "right_hand_side")
            : nil

        leftArmNode.texture = frontLeftUpperArmTexture
        rightArmNode.texture = frontRightUpperArmTexture
        leftForearmNode.texture = frontLeftForearmTexture
        rightForearmNode.texture = frontRightForearmTexture
        leftHandNode.texture = frontLeftHandTexture
        rightHandNode.texture = frontRightHandTexture
        leftHandNode.alpha = useSeparateHandSprites ? 1 : 0
        rightHandNode.alpha = useSeparateHandSprites ? 1 : 0

        frontHeadTexture = atlasProvider.characterPartTexture(group: "Head", name: "head")
        sideHeadTexture = useSideHeadTexture
            ? atlasProvider.characterPartTexture(group: "Head", name: "head_side")
            : nil
        headNode.texture = frontHeadTexture
        isSideHeadActive = false
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
        applyNaturalSize(leftForearmNode, fallback: CGSize(width: 16, height: 18), max: CGSize(width: 22, height: 32))
        applyNaturalSize(rightForearmNode, fallback: CGSize(width: 16, height: 18), max: CGSize(width: 22, height: 32))
        if useSeparateHandSprites {
            applyNaturalSize(leftHandNode, fallback: CGSize(width: 12, height: 12), max: CGSize(width: 20, height: 18))
            applyNaturalSize(rightHandNode, fallback: CGSize(width: 12, height: 12), max: CGSize(width: 20, height: 18))
        } else {
            leftHandNode.size = CGSize(width: 12, height: 12)
            rightHandNode.size = CGSize(width: 12, height: 12)
        }
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
            var normalParts: [SKNode] = [
                headNode,
                hairFrontNode,
                hairBackNode,
                torsoNode,
                leftArmNode,
                rightArmNode,
                leftForearmNode,
                rightForearmNode,
                leftHandNode,
                rightHandNode,
                leftLegNode,
                rightLegNode,
                leftShoeNode,
                rightShoeNode,
                fringeNode,
                heartClipNode,
            ]
            if useFaceFeatureOverlays {
                normalParts.append(eyesNode)
                normalParts.append(mouthNode)
            }
            for node in normalParts {
                node.alpha = 1
            }
            if isSideHeadActive {
                // Side-head texture already includes hair/face details.
                hairBackNode.alpha = 0
                hairFrontNode.alpha = 0
                fringeNode.alpha = 0
                // Keep heart clip visible as explicit overlay in side mode.
                heartClipNode.alpha = 1
            }
            if isSideBodyActive && !useSideArmTextures {
                // Side hoodie already contains sleeve art; render only near-side hand at cuff.
                leftHandNode.position = sideLeftHandCuffPosition
                rightHandNode.position = sideRightHandCuffPosition
                if let facingRight = sideVisibleHandFacingRight {
                    leftArmNode.alpha = 0
                    rightArmNode.alpha = 0
                    leftForearmNode.alpha = 0
                    rightForearmNode.alpha = 0
                    leftHandNode.alpha = facingRight ? 0 : 1
                    rightHandNode.alpha = facingRight ? 1 : 0
                } else {
                    leftArmNode.alpha = 0
                    rightArmNode.alpha = 0
                    leftForearmNode.alpha = 0
                    rightForearmNode.alpha = 0
                    leftHandNode.alpha = 1
                    rightHandNode.alpha = 1
                }
            }
            if hideFrontShoulderSleeves {
                leftArmNode.alpha = 0
                rightArmNode.alpha = 0
                // In calm front states, hide sleeve forearm blobs while keeping hands visible.
                if !isSideBodyActive {
                    leftForearmNode.alpha = 0
                    rightForearmNode.alpha = 0
                    leftHandNode.position = frontLeftHandPivotPosition
                    rightHandNode.position = frontRightHandPivotPosition
                    leftHandNode.alpha = 1
                    rightHandNode.alpha = 1
                }
            }
            if useHandsOnlyArms {
                leftArmNode.alpha = 0
                rightArmNode.alpha = isGreetingWaveActive ? 1 : 0
                leftForearmNode.alpha = 0
                rightForearmNode.alpha = 0
                leftHandNode.alpha = 1
                rightHandNode.alpha = 1
            }
            if !useSeparateHandSprites {
                leftHandNode.alpha = 0
                rightHandNode.alpha = 0
            }
            // Effect nodes stay off unless explicitly enabled by state logic.
            bottleNode.alpha = isBottleEffectVisible ? 1 : 0
            heartNode.alpha = isHeartEffectVisible ? 1 : 0
            sweatNode.alpha = isSweatEffectVisible ? 1 : 0
            return
        }
        var orderedParts: [SKNode] = [
            headNode,
            hairFrontNode,
            hairBackNode,
            torsoNode,
            leftArmNode,
            rightArmNode,
            leftForearmNode,
            rightForearmNode,
            leftHandNode,
            rightHandNode,
            leftLegNode,
            rightLegNode,
            leftShoeNode,
            rightShoeNode,
            fringeNode,
            heartClipNode,
            bottleNode,
            heartNode,
            sweatNode,
        ]
        if useFaceFeatureOverlays {
            orderedParts.insert(eyesNode, at: 12)
            orderedParts.insert(mouthNode, at: 13)
        }
        let clampedStage = max(0, min(stage, orderedParts.count))
        for (index, node) in orderedParts.enumerated() {
            node.alpha = index < clampedStage ? 1 : 0
        }
        if isSideHeadActive {
            // Keep only the composed side-head while moving.
            hairBackNode.alpha = 0
            hairFrontNode.alpha = 0
            fringeNode.alpha = 0
            // Keep heart clip visible as explicit overlay in side mode.
            heartClipNode.alpha = 1
        }
        if isSideBodyActive && !useSideArmTextures {
            // Side hoodie already contains sleeve art; render only near-side hand at cuff.
            leftHandNode.position = sideLeftHandCuffPosition
            rightHandNode.position = sideRightHandCuffPosition
            if let facingRight = sideVisibleHandFacingRight {
                leftArmNode.alpha = 0
                rightArmNode.alpha = 0
                leftForearmNode.alpha = 0
                rightForearmNode.alpha = 0
                leftHandNode.alpha = facingRight ? 0 : 1
                rightHandNode.alpha = facingRight ? 1 : 0
            } else {
                leftArmNode.alpha = 0
                rightArmNode.alpha = 0
                leftForearmNode.alpha = 0
                rightForearmNode.alpha = 0
                leftHandNode.alpha = 1
                rightHandNode.alpha = 1
            }
        }
        if hideFrontShoulderSleeves {
            leftArmNode.alpha = 0
            rightArmNode.alpha = 0
            // In calm front states, hide sleeve forearm blobs while keeping hands visible.
            if !isSideBodyActive {
                leftForearmNode.alpha = 0
                rightForearmNode.alpha = 0
                leftHandNode.position = frontLeftHandPivotPosition
                rightHandNode.position = frontRightHandPivotPosition
                leftHandNode.alpha = 1
                rightHandNode.alpha = 1
            }
        }
        if useHandsOnlyArms {
            leftArmNode.alpha = 0
            rightArmNode.alpha = isGreetingWaveActive ? 1 : 0
            leftForearmNode.alpha = 0
            rightForearmNode.alpha = 0
        }
        if !useSeparateHandSprites {
            leftHandNode.alpha = 0
            rightHandNode.alpha = 0
        }
        // Keep heart clip visible during validation so placement is easy to verify.
        heartClipNode.alpha = 1
        // Preserve transient effect visibility driven by state machine.
        bottleNode.alpha = isBottleEffectVisible ? 1 : 0
        heartNode.alpha = isHeartEffectVisible ? 1 : 0
        sweatNode.alpha = isSweatEffectVisible ? 1 : 0
    }
}
