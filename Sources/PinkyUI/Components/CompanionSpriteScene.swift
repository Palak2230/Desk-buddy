import SwiftUI
import SpriteKit
import Core
import Domain
import Theme

/// SpriteKit scene for rendering the companion with atlas-backed parts and themed tinting.
@MainActor
final class CompanionSpriteScene: SKScene {
    // MARK: - Scene graph

    private let rootNode = SKNode()
    private let shadowNode = SKShapeNode(ellipseOf: CGSize(width: 72, height: 14))
    private let frameSpriteNode = SKSpriteNode(color: .clear, size: CGSize(width: 128, height: 128))

    private let torsoNode = SKSpriteNode(color: .white, size: CGSize(width: 74, height: 88))
    private let hoodNode = SKSpriteNode(color: .white, size: CGSize(width: 72, height: 52))
    private let pocketNode = SKShapeNode(rectOf: CGSize(width: 34, height: 14), cornerRadius: 6)
    private let hoodieStringLeftNode = SKShapeNode(rectOf: CGSize(width: 2.4, height: 20), cornerRadius: 1.2)
    private let hoodieStringRightNode = SKShapeNode(rectOf: CGSize(width: 2.4, height: 20), cornerRadius: 1.2)
    private let headNode = SKSpriteNode(color: .white, size: CGSize(width: 62, height: 58))
    private let hairNode = SKSpriteNode(color: .white, size: CGSize(width: 66, height: 40))
    private let bangLeftNode = SKShapeNode(circleOfRadius: 8)
    private let bangRightNode = SKShapeNode(circleOfRadius: 8)
    private let blushLeftNode = SKShapeNode(circleOfRadius: 6.2)
    private let blushRightNode = SKShapeNode(circleOfRadius: 6.2)
    private let expressionNode = SKSpriteNode(color: .clear, size: CGSize(width: 44, height: 22))
    private let leftEyeNode = SKShapeNode(ellipseOf: CGSize(width: 7, height: 7))
    private let rightEyeNode = SKShapeNode(ellipseOf: CGSize(width: 7, height: 7))
    private let mouthNode = SKShapeNode(path: CGPath(ellipseIn: CGRect(x: -5, y: -2, width: 10, height: 5), transform: nil))
    private let leftFootNode = SKSpriteNode(color: .white, size: CGSize(width: 18, height: 9))
    private let rightFootNode = SKSpriteNode(color: .white, size: CGSize(width: 18, height: 9))
    private let accessoryNode = SKLabelNode(text: "♥")
    private let statusNode = SKLabelNode(text: "")

    // Atlas overlays (if present they replace plain-tint appearance)
    private let atlasProvider = CompanionAtlasProvider()
    private var outfit: CompanionAtlasProvider.Outfit = .classic
    private var hasTorsoTexture = false
    private var hasHoodTexture = false
    private var hasHeadTexture = false
    private var hasHairTexture = false
    private var hasFeetTexture = false

    private var baseBodyY: CGFloat = 58
    private var baseHeadY: CGFloat = 114
    private var facingRight = true

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .clear
        print("Companion resource source:", CompanionAtlasProvider.debugResourceBundleHint())
        setupNodes()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOutfit(_ newOutfit: CompanionAtlasProvider.Outfit) {
        outfit = newOutfit
        applyAtlasTexturesIfAvailable()
    }

    func apply(state: CharacterState, frameIndex: Int, theme: Theme) {
        // Keep atlas-frame rendering anchored even after scene resize.
        frameSpriteNode.position = CGPoint(x: size.width / 2, y: 92)

        if let referenceTexture = atlasProvider.texture(named: "reference_fullbody") {
            frameSpriteNode.texture = referenceTexture
            frameSpriteNode.size = CGSize(width: 160, height: 160)
            frameSpriteNode.alpha = 1
            rootNode.alpha = 0
            shadowNode.alpha = 0.2
            applyReferencePose(state: state, frameIndex: frameIndex)
            return
        }

        if let frameTexture = atlasProvider.texture(named: frameTextureName(state: state, frameIndex: frameIndex)) {
            frameSpriteNode.texture = frameTexture
            frameSpriteNode.size = CGSize(width: 128, height: 128)
            frameSpriteNode.alpha = 1
            frameSpriteNode.xScale = facingRight ? 1 : -1
            rootNode.alpha = 0
            shadowNode.alpha = 0.2

            if state == .turn, frameIndex % 5 == 0 {
                facingRight.toggle()
            } else if state == .walk || state == .run {
                frameSpriteNode.xScale = facingRight ? 1 : -1
            }
            return
        } else {
            frameSpriteNode.texture = nil
            frameSpriteNode.alpha = 0
            rootNode.alpha = 1
            shadowNode.alpha = 1
        }

        applyTheme(theme)

        let progress = CGFloat(frameIndex)
        let wave = sin(progress * 0.42)
        let step = sin(progress * 0.8)
        let bob = abs(sin(progress * 0.5))

        // Default posture / reset.
        rootNode.position = CGPoint(x: size.width / 2, y: 0)
        rootNode.zRotation = 0
        torsoNode.position = CGPoint(x: 0, y: baseBodyY)
        hoodNode.position = CGPoint(x: 0, y: baseBodyY + 20)
        pocketNode.position = CGPoint(x: 0, y: baseBodyY - 4)
        hoodieStringLeftNode.position = CGPoint(x: -10, y: baseBodyY + 20)
        hoodieStringRightNode.position = CGPoint(x: 10, y: baseBodyY + 20)
        headNode.position = CGPoint(x: 0, y: baseHeadY)
        hairNode.position = CGPoint(x: 0, y: baseHeadY + 14)
        bangLeftNode.position = CGPoint(x: -14, y: baseHeadY + 6)
        bangRightNode.position = CGPoint(x: 14, y: baseHeadY + 6)
        headNode.zRotation = 0
        torsoNode.zRotation = 0
        leftFootNode.position = CGPoint(x: -16, y: baseBodyY - 48)
        rightFootNode.position = CGPoint(x: 16, y: baseBodyY - 48)
        leftFootNode.zRotation = 0
        rightFootNode.zRotation = 0
        accessoryNode.alpha = 0.15
        accessoryNode.fontSize = 14
        statusNode.text = ""
        statusNode.alpha = 0
        statusNode.position = CGPoint(x: 0, y: baseHeadY + 26)
        expressionNode.position = CGPoint(x: 0, y: baseHeadY + 2)
        expressionNode.alpha = 0
        setExpression(.neutral)

        switch state {
        case .idle:
            torsoNode.position.y += wave * 1.4
            headNode.position.y += wave * 1.8
            hairNode.position.y += wave * 1.5
            setExpression(.smile)
        case .turn:
            torsoNode.zRotation = wave * 0.25
            headNode.zRotation = -wave * 0.18
            facingRight.toggle()
            rootNode.xScale = facingRight ? 1 : -1
            statusNode.text = "↺"
            statusNode.alpha = 0.8
            setExpression(.blink)
        case .stop:
            torsoNode.position.y -= bob * 2.0
            headNode.position.y -= bob * 1.6
            setExpression(.neutral)
        case .breathing:
            torsoNode.yScale = 1 + wave * 0.03
            headNode.position.y += wave * 1.0
            setExpression(.neutral)
        case .walk:
            torsoNode.position.y += wave * 1.1
            headNode.position.y += wave * 1.1
            leftFootNode.position.y += step * 2.2
            rightFootNode.position.y -= step * 2.2
            leftFootNode.zRotation = step * 0.2
            rightFootNode.zRotation = -step * 0.2
            setExpression(.focused)
        case .run:
            torsoNode.position.y += wave * 1.8
            headNode.position.y += wave * 1.8
            leftFootNode.position.y += step * 3.5
            rightFootNode.position.y -= step * 3.5
            leftFootNode.zRotation = step * 0.28
            rightFootNode.zRotation = -step * 0.28
            torsoNode.zRotation = wave * 0.13
            headNode.zRotation = wave * 0.05
            setExpression(.focused)
        case .blink:
            setExpression(frameIndex % 6 > 1 ? .blink : .smile)
        case .wave:
            headNode.zRotation = wave * 0.15
            accessoryNode.alpha = 0.6
            setExpression(.happy)
        case .drink:
            headNode.zRotation = -0.35
            headNode.position.y -= 3
            statusNode.text = "💧"
            statusNode.alpha = 0.8
            setExpression(.sip)
        case .sleep:
            setExpression(.sleep)
            torsoNode.zRotation = -0.08
            accessoryNode.alpha = 0.05
            statusNode.text = "Zzz"
            statusNode.alpha = 0.85
        case .happy:
            headNode.position.y += 3 + abs(wave) * 2
            accessoryNode.alpha = 1
            accessoryNode.fontSize = 15 + abs(wave) * 5
            setExpression(.happy)
        case .sad:
            headNode.position.y -= 2
            headNode.zRotation = -0.08
            statusNode.text = "..."
            statusNode.alpha = 0.7
            setExpression(.sad)
        case .think:
            statusNode.text = "?"
            statusNode.alpha = 0.9
            statusNode.position.x = 34
            statusNode.position.y = baseHeadY + 18
            setExpression(.neutral)
        case .peek:
            rootNode.position.x += 24
            statusNode.text = "👀"
            statusNode.alpha = 0.9
            setExpression(.blink)
        case .celebrate:
            headNode.position.y += abs(wave) * 8
            accessoryNode.alpha = 1
            accessoryNode.fontSize = 18 + abs(wave) * 8
            statusNode.text = "✨"
            statusNode.alpha = 0.9
            setExpression(.happy)
        }
    }

    private func setupNodes() {
        shadowNode.fillColor = .black.withAlphaComponent(0.14)
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: size.width / 2, y: 24)
        shadowNode.zPosition = 0

        frameSpriteNode.position = CGPoint(x: size.width / 2, y: 92)
        frameSpriteNode.zPosition = 50
        frameSpriteNode.alpha = 0

        torsoNode.position = CGPoint(x: 0, y: baseBodyY)
        torsoNode.zPosition = 10
        torsoNode.colorBlendFactor = 1

        hoodNode.position = CGPoint(x: 0, y: baseBodyY + 20)
        hoodNode.zPosition = 11
        hoodNode.colorBlendFactor = 1

        pocketNode.position = CGPoint(x: 0, y: baseBodyY - 4)
        pocketNode.zPosition = 12
        pocketNode.strokeColor = .clear

        hoodieStringLeftNode.position = CGPoint(x: -10, y: baseBodyY + 20)
        hoodieStringLeftNode.zPosition = 13
        hoodieStringLeftNode.strokeColor = .clear

        hoodieStringRightNode.position = CGPoint(x: 10, y: baseBodyY + 20)
        hoodieStringRightNode.zPosition = 13
        hoodieStringRightNode.strokeColor = .clear

        headNode.position = CGPoint(x: 0, y: baseHeadY)
        headNode.zPosition = 20
        headNode.colorBlendFactor = 1

        hairNode.position = CGPoint(x: 0, y: baseHeadY + 14)
        hairNode.zPosition = 22
        hairNode.colorBlendFactor = 1

        bangLeftNode.position = CGPoint(x: -14, y: baseHeadY + 6)
        bangLeftNode.zPosition = 23
        bangLeftNode.strokeColor = .clear

        bangRightNode.position = CGPoint(x: 14, y: baseHeadY + 6)
        bangRightNode.zPosition = 23
        bangRightNode.strokeColor = .clear

        blushLeftNode.position = CGPoint(x: -14, y: baseHeadY - 3)
        blushLeftNode.zPosition = 23
        blushLeftNode.strokeColor = .clear

        blushRightNode.position = CGPoint(x: 14, y: baseHeadY - 3)
        blushRightNode.zPosition = 23
        blushRightNode.strokeColor = .clear

        leftEyeNode.fillColor = .black
        leftEyeNode.strokeColor = .clear
        leftEyeNode.position = CGPoint(x: -10, y: baseHeadY + 4)
        leftEyeNode.zPosition = 24

        rightEyeNode.fillColor = .black
        rightEyeNode.strokeColor = .clear
        rightEyeNode.position = CGPoint(x: 10, y: baseHeadY + 4)
        rightEyeNode.zPosition = 24

        mouthNode.fillColor = .black
        mouthNode.strokeColor = .clear
        mouthNode.position = CGPoint(x: 0, y: baseHeadY - 8)
        mouthNode.zPosition = 24

        expressionNode.position = CGPoint(x: 0, y: baseHeadY + 2)
        expressionNode.zPosition = 25
        expressionNode.alpha = 0

        leftFootNode.position = CGPoint(x: -16, y: baseBodyY - 48)
        leftFootNode.zPosition = 9
        leftFootNode.colorBlendFactor = 1
        leftFootNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        rightFootNode.position = CGPoint(x: 16, y: baseBodyY - 48)
        rightFootNode.zPosition = 9
        rightFootNode.colorBlendFactor = 1
        rightFootNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        accessoryNode.fontName = "HelveticaNeue-Bold"
        accessoryNode.fontSize = 14
        accessoryNode.position = CGPoint(x: 24, y: baseHeadY + 24)
        accessoryNode.alpha = 0.25
        accessoryNode.zPosition = 30

        statusNode.fontName = "HelveticaNeue-Medium"
        statusNode.fontSize = 12
        statusNode.position = CGPoint(x: -2, y: baseHeadY + 28)
        statusNode.alpha = 0
        statusNode.zPosition = 31

        addChild(shadowNode)
        addChild(frameSpriteNode)
        addChild(rootNode)

        rootNode.addChild(leftFootNode)
        rootNode.addChild(rightFootNode)
        rootNode.addChild(torsoNode)
        rootNode.addChild(hoodNode)
        rootNode.addChild(pocketNode)
        rootNode.addChild(hoodieStringLeftNode)
        rootNode.addChild(hoodieStringRightNode)
        rootNode.addChild(headNode)
        rootNode.addChild(hairNode)
        rootNode.addChild(bangLeftNode)
        rootNode.addChild(bangRightNode)
        rootNode.addChild(blushLeftNode)
        rootNode.addChild(blushRightNode)
        rootNode.addChild(leftEyeNode)
        rootNode.addChild(rightEyeNode)
        rootNode.addChild(mouthNode)
        rootNode.addChild(expressionNode)
        rootNode.addChild(accessoryNode)
        rootNode.addChild(statusNode)

        applyAtlasTexturesIfAvailable()
    }

    private func applyTheme(_ theme: Theme) {
        // Theme tinting keeps a pastel look while allowing distinct palettes.
        if !hasTorsoTexture {
            torsoNode.color = SKColor(Color(hex: theme.primary))
        }
        if !hasHoodTexture {
            hoodNode.color = SKColor(Color(hex: theme.primary)).withAlphaComponent(0.9)
        }
        if !hasHeadTexture {
            headNode.color = SKColor(Color(hex: theme.secondary))
        }
        let baseHair = SKColor(Color(hex: "#4A3040"))
        if !hasHairTexture {
            hairNode.color = baseHair
        }
        if !hasFeetTexture {
            leftFootNode.color = SKColor(Color(hex: theme.surface))
            rightFootNode.color = SKColor(Color(hex: theme.surface))
        }

        pocketNode.fillColor = SKColor(white: 0.18, alpha: 1)
        pocketNode.strokeColor = SKColor(Color(hex: theme.text)).withAlphaComponent(0.2)
        pocketNode.lineWidth = 1
        hoodieStringLeftNode.fillColor = SKColor(Color(hex: "#F5E6F0"))
        hoodieStringRightNode.fillColor = SKColor(Color(hex: "#F5E6F0"))
        bangLeftNode.fillColor = baseHair
        bangRightNode.fillColor = baseHair
        blushLeftNode.fillColor = SKColor(Color(hex: "#FF8FA8")).withAlphaComponent(0.45)
        blushRightNode.fillColor = SKColor(Color(hex: "#FF8FA8")).withAlphaComponent(0.45)
        accessoryNode.fontColor = SKColor(Color(hex: theme.accent))
        statusNode.fontColor = SKColor(Color(hex: theme.text))

        // Normal mode: preserve authored atlas textures with light theme tint.
        if hasTorsoTexture {
            torsoNode.colorBlendFactor = 0.02
        }
        if hasHoodTexture {
            hoodNode.colorBlendFactor = 0.02
        }
    }

    private enum Expression {
        case neutral
        case smile
        case happy
        case blink
        case focused
        case sad
        case sleep
        case sip
    }

    private func setExpression(_ expression: Expression) {
        let expressionName: String
        switch expression {
        case .neutral:
            expressionName = "neutral"
            setEyeShape(width: 7, height: 7)
            mouthNode.path = CGPath(ellipseIn: CGRect(x: -4, y: -1.5, width: 8, height: 3), transform: nil)
        case .smile:
            expressionName = "smile"
            setEyeShape(width: 7, height: 7)
            mouthNode.path = CGPath(ellipseIn: CGRect(x: -5, y: -2, width: 10, height: 5), transform: nil)
        case .happy:
            expressionName = "happy"
            setEyeShape(width: 6.5, height: 6.5)
            mouthNode.path = CGPath(ellipseIn: CGRect(x: -5.5, y: -3, width: 11, height: 6), transform: nil)
        case .blink:
            expressionName = "blink"
            setEyeShape(width: 4, height: 1.2)
            mouthNode.path = CGPath(ellipseIn: CGRect(x: -4, y: -1.2, width: 8, height: 2.4), transform: nil)
        case .focused:
            expressionName = "focused"
            setEyeShape(width: 6.5, height: 6.5)
            mouthNode.path = CGPath(ellipseIn: CGRect(x: -3.4, y: -1, width: 6.8, height: 2), transform: nil)
        case .sad:
            expressionName = "sad"
            setEyeShape(width: 6.2, height: 6.2)
            mouthNode.path = CGPath(ellipseIn: CGRect(x: -3.5, y: -0.8, width: 7, height: 1.5), transform: nil)
        case .sleep:
            expressionName = "sleep"
            setEyeShape(width: 4, height: 1.1)
            mouthNode.path = CGPath(ellipseIn: CGRect(x: -2.2, y: -0.8, width: 4.4, height: 1.6), transform: nil)
        case .sip:
            expressionName = "sip"
            setEyeShape(width: 6, height: 6)
            mouthNode.path = CGPath(ellipseIn: CGRect(x: -1.8, y: -1.8, width: 3.6, height: 3.6), transform: nil)
        }

        if let expressionTexture = atlasProvider.expressionTexture(expressionName) {
            expressionNode.texture = expressionTexture
            expressionNode.alpha = 1
            leftEyeNode.alpha = 0
            rightEyeNode.alpha = 0
            mouthNode.alpha = 0
        } else {
            expressionNode.texture = nil
            expressionNode.alpha = 0
            leftEyeNode.alpha = 1
            rightEyeNode.alpha = 1
            mouthNode.alpha = 1
        }
    }

    private func setEyeShape(width: CGFloat, height: CGFloat) {
        leftEyeNode.path = CGPath(ellipseIn: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), transform: nil)
        rightEyeNode.path = CGPath(ellipseIn: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), transform: nil)
    }

    private func applyAtlasTexturesIfAvailable() {
        hasTorsoTexture = false
        hasHoodTexture = false
        hasHeadTexture = false
        hasHairTexture = false
        hasFeetTexture = false

        if let torso = atlasProvider.partTexture(part: "companion_torso", outfit: outfit) {
            torsoNode.texture = torso
            torsoNode.colorBlendFactor = 0.02
            hasTorsoTexture = true
        }
        if let hood = atlasProvider.partTexture(part: "companion_hood", outfit: outfit) {
            hoodNode.texture = hood
            hoodNode.colorBlendFactor = 0.02
            hasHoodTexture = true
        }
        if let head = atlasProvider.partTexture(part: "companion_head", outfit: outfit) {
            headNode.texture = head
            headNode.colorBlendFactor = 0.01
            hasHeadTexture = true
        }
        if let hair = atlasProvider.partTexture(part: "companion_hair", outfit: outfit) {
            hairNode.texture = hair
            hairNode.color = SKColor(Color(hex: "#4A3040"))
            hairNode.colorBlendFactor = 0.0
            hasHairTexture = true
        }
        if let feet = atlasProvider.partTexture(part: "companion_feet", outfit: outfit) {
            leftFootNode.texture = feet
            rightFootNode.texture = feet
            leftFootNode.colorBlendFactor = 0.0
            rightFootNode.colorBlendFactor = 0.0
            hasFeetTexture = true
        }
    }

    private func applyReferencePose(state: CharacterState, frameIndex: Int) {
        let t = CGFloat(frameIndex)
        let wave = sin(t * 0.42)
        let step = sin(t * 0.85)

        frameSpriteNode.zRotation = 0
        frameSpriteNode.yScale = 1
        frameSpriteNode.xScale = facingRight ? 1 : -1
        frameSpriteNode.position.y = 92

        switch state {
        case .idle, .breathing, .stop:
            frameSpriteNode.position.y += wave * 2
        case .walk:
            frameSpriteNode.position.y += abs(step) * 3
            frameSpriteNode.xScale = facingRight ? 1 : -1
        case .run:
            frameSpriteNode.position.y += abs(step) * 5
            frameSpriteNode.zRotation = wave * 0.05
            frameSpriteNode.xScale = facingRight ? 1 : -1
        case .turn:
            if frameIndex % 5 == 0 { facingRight.toggle() }
            frameSpriteNode.xScale = facingRight ? 1 : -1
        case .sleep:
            frameSpriteNode.zRotation = -0.1
            frameSpriteNode.position.y -= 8
        case .happy, .celebrate:
            frameSpriteNode.position.y += abs(wave) * 6
        case .sad:
            frameSpriteNode.position.y -= 2
        case .wave, .drink, .think, .peek, .blink:
            frameSpriteNode.position.y += wave
        }
    }

    private func frameTextureName(state: CharacterState, frameIndex: Int) -> String {
        let maxIndex: Int
        switch state {
        case .idle: maxIndex = 24
        case .turn: maxIndex = 10
        case .stop: maxIndex = 8
        case .blink: maxIndex = 6
        case .breathing: maxIndex = 20
        case .walk: maxIndex = 16
        case .run: maxIndex = 14
        case .wave: maxIndex = 12
        case .drink: maxIndex = 12
        case .sleep: maxIndex = 20
        case .happy: maxIndex = 12
        case .sad: maxIndex = 12
        case .think: maxIndex = 12
        case .peek: maxIndex = 10
        case .celebrate: maxIndex = 14
        }
        return "\(state.rawValue)_\(frameIndex % max(1, maxIndex))"
    }
}
