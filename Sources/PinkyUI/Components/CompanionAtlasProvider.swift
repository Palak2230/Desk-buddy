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

    init() {
        let atlasNames = [
            "CompanionBase",
            "CompanionExpressions",
            "CompanionOutfits",
        ]
        self.atlases = atlasNames.compactMap { name in
            let atlas = SKTextureAtlas(named: name)
            return atlas.textureNames.isEmpty ? nil : atlas
        }
    }

    func texture(named textureName: String) -> SKTexture? {
        for atlas in atlases where atlas.textureNames.contains(textureName) {
            return atlas.textureNamed(textureName)
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
}
