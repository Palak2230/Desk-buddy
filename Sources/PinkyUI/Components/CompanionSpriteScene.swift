import SwiftUI
import SpriteKit
import Core
import Domain
import Theme

/// SpriteKit scene for rendering the companion with lightweight procedural animations.
@MainActor
final class CompanionSpriteScene: SKScene {
    private let shadowNode = SKShapeNode(ellipseOf: CGSize(width: 68, height: 14))
    private let bodyNode = SKShapeNode(rectOf: CGSize(width: 76, height: 96), cornerRadius: 18)
    private let headNode = SKShapeNode(circleOfRadius: 26)
    private let leftEyeNode = SKShapeNode(circleOfRadius: 3.5)
    private let rightEyeNode = SKShapeNode(circleOfRadius: 3.5)
    private let heartNode = SKLabelNode(text: "♥")
    private let statusNode = SKLabelNode(text: "")

    private var baseBodyY: CGFloat = 62
    private var baseHeadY: CGFloat = 122

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .clear
        setupNodes()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(state: CharacterState, frameIndex: Int, theme: Theme) {
        applyTheme(theme)

        let progress = CGFloat(frameIndex)
        let wave = sin(progress * 0.4)
        let bounce = sin(progress * 0.7)

        // Default posture.
        bodyNode.position = CGPoint(x: size.width / 2, y: baseBodyY)
        bodyNode.zRotation = 0
        headNode.position = CGPoint(x: size.width / 2, y: baseHeadY)
        headNode.zRotation = 0
        headNode.xScale = 1
        heartNode.alpha = 0.25
        statusNode.text = ""
        statusNode.alpha = 0
        setEyes(closed: false)

        switch state {
        case .idle:
            bodyNode.position.y += wave * 1.5
            headNode.position.y += wave * 1.5
        case .turn:
            bodyNode.zRotation = wave * 0.22
            headNode.zRotation = -wave * 0.18
            statusNode.text = "↺"
            statusNode.alpha = 0.8
        case .stop:
            bodyNode.position.y -= abs(wave) * 1.2
            headNode.position.y -= abs(wave) * 1.0
        case .breathing:
            bodyNode.yScale = 1 + wave * 0.03
            headNode.position.y += wave * 1.0
        case .walk:
            bodyNode.position.x += bounce * 8
            headNode.position.x += bounce * 8
            bodyNode.zRotation = wave * 0.08
        case .run:
            bodyNode.position.x += bounce * 14
            headNode.position.x += bounce * 14
            bodyNode.zRotation = wave * 0.16
            headNode.zRotation = wave * 0.05
        case .blink:
            setEyes(closed: frameIndex % 6 > 1)
        case .wave:
            headNode.zRotation = wave * 0.15
            heartNode.alpha = 0.5
        case .drink:
            headNode.zRotation = -0.35
            headNode.position.y -= 3
            statusNode.text = "💧"
            statusNode.alpha = 0.8
        case .sleep:
            setEyes(closed: true)
            bodyNode.zRotation = -0.08
            heartNode.alpha = 0.1
            statusNode.text = "Zzz"
            statusNode.alpha = 0.85
        case .happy:
            headNode.position.y += 3 + abs(wave) * 2
            heartNode.alpha = 0.95
            heartNode.fontSize = 14 + abs(wave) * 5
        case .sad:
            headNode.position.y -= 2
            headNode.zRotation = -0.08
            statusNode.text = "..."
            statusNode.alpha = 0.7
        case .think:
            statusNode.text = "?"
            statusNode.alpha = 0.9
            statusNode.position.x = headNode.position.x + 34
            statusNode.position.y = headNode.position.y + 18
        case .peek:
            bodyNode.position.x = size.width / 2 + 24
            headNode.position.x = size.width / 2 + 24
            statusNode.text = "👀"
            statusNode.alpha = 0.9
        case .celebrate:
            headNode.position.y += abs(wave) * 8
            heartNode.alpha = 1
            heartNode.fontSize = 18 + abs(wave) * 8
            statusNode.text = "✨"
            statusNode.alpha = 0.9
        }
    }

    private func setupNodes() {
        shadowNode.fillColor = .black.withAlphaComponent(0.14)
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: size.width / 2, y: 24)

        bodyNode.strokeColor = .clear
        bodyNode.position = CGPoint(x: size.width / 2, y: baseBodyY)

        headNode.strokeColor = .clear
        headNode.position = CGPoint(x: size.width / 2, y: baseHeadY)

        leftEyeNode.fillColor = .black
        leftEyeNode.strokeColor = .clear
        leftEyeNode.position = CGPoint(x: -10, y: 4)

        rightEyeNode.fillColor = .black
        rightEyeNode.strokeColor = .clear
        rightEyeNode.position = CGPoint(x: 10, y: 4)

        heartNode.fontName = "HelveticaNeue-Bold"
        heartNode.fontSize = 14
        heartNode.position = CGPoint(x: size.width / 2 + 24, y: baseHeadY + 24)
        heartNode.alpha = 0.25

        statusNode.fontName = "HelveticaNeue-Medium"
        statusNode.fontSize = 12
        statusNode.position = CGPoint(x: size.width / 2 - 2, y: baseHeadY + 28)
        statusNode.alpha = 0

        addChild(shadowNode)
        addChild(bodyNode)
        addChild(headNode)
        addChild(heartNode)
        addChild(statusNode)
        headNode.addChild(leftEyeNode)
        headNode.addChild(rightEyeNode)
    }

    private func applyTheme(_ theme: Theme) {
        bodyNode.fillColor = SKColor(Color(hex: theme.primary))
        headNode.fillColor = SKColor(Color(hex: theme.secondary))
        heartNode.fontColor = SKColor(Color(hex: theme.accent))
        statusNode.fontColor = SKColor(Color(hex: theme.text))
    }

    private func setEyes(closed: Bool) {
        let width: CGFloat = closed ? 4 : 7
        let height: CGFloat = closed ? 1.2 : 7

        leftEyeNode.path = CGPath(ellipseIn: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), transform: nil)
        rightEyeNode.path = CGPath(ellipseIn: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), transform: nil)
    }
}
