import Foundation
import SpriteKit

/// Sprite atlas helper for companion rendering parts.
/// Falls back gracefully when atlases or textures are missing.
@MainActor
final class CompanionAtlasProvider {
    enum Outfit: String {
        case classic
        case sporty
        case cozy
    }

    private let atlases: [SKTextureAtlas]
    private static let atlasNames = [
        "CompanionFrames",
        "CompanionBase",
        "CompanionExpressions",
        "CompanionOutfits",
    ]

    private static let cachedAtlases: [SKTextureAtlas] = {
        atlasNames.compactMap { name in
            guard atlasExists(named: name) else { return nil }
            let atlas = SKTextureAtlas(named: name)
            return atlas.textureNames.isEmpty ? nil : atlas
        }
    }()

    init() {
        // Cache atlas resolution once to avoid repeated lookup warnings/noise.
        self.atlases = Self.cachedAtlases
    }

    func texture(named textureName: String) -> SKTexture? {
        for atlas in atlases where atlas.textureNames.contains(textureName) {
            return atlas.textureNamed(textureName)
        }
        // SwiftPM may flatten `.atlas` resources into plain PNG files in the app bundle.
        // Fall back to direct image-name lookup so frame textures still resolve.
        let bundle = Bundle.main
        if bundle.url(forResource: textureName, withExtension: "png") != nil {
            return SKTexture(imageNamed: textureName)
        }
        return nil
    }

    func partTexture(part: String, outfit: Outfit) -> SKTexture? {
        let outfitSpecific = "\(part)_\(outfit.rawValue)"
        return texture(named: outfitSpecific) ?? texture(named: part)
    }

    func expressionTexture(_ expression: String) -> SKTexture? {
        texture(named: "expression_\(expression)")
    }

    private static func atlasExists(named name: String) -> Bool {
        let bundle = Bundle.main
        return bundle.url(forResource: name, withExtension: "atlasc") != nil ||
            bundle.url(forResource: name, withExtension: "atlas") != nil
    }
}
