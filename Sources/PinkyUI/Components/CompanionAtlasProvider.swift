import Foundation
import SpriteKit
import AppKit

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
        // SwiftPM often stores target resources in generated side bundles.
        // Resolve the PNG from any loaded bundle and build texture from file bytes.
        if let url = Self.resourceURL(for: textureName, ext: "png"),
           let image = NSImage(contentsOf: url) {
            return SKTexture(image: image)
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
        resourceURL(for: name, ext: "atlasc") != nil || resourceURL(for: name, ext: "atlas") != nil
    }

    private static func resourceURL(for name: String, ext: String) -> URL? {
        for bundle in resourceBundles {
            if let url = bundle.url(forResource: name, withExtension: ext) {
                return url
            }
        }

        let filename = "\(name).\(ext)"
        for directory in sideResourceDirectories {
            let candidate = directory.appendingPathComponent(filename, isDirectory: false)
            if FileManager.default.fileExists(atPath: candidate.path) {
                return candidate
            }
        }
        return nil
    }

    private static let resourceBundles: [Bundle] = {
        var unique: [URL: Bundle] = [:]
        let bundles = [Bundle.main] + Bundle.allBundles + Bundle.allFrameworks
        for bundle in bundles {
            unique[bundle.bundleURL] = bundle
        }
        return Array(unique.values)
    }()

    /// SwiftPM executable resources are frequently emitted in sibling *.bundle folders.
    private static let sideResourceDirectories: [URL] = {
        guard let executableDir = Bundle.main.executableURL?.deletingLastPathComponent() else {
            return []
        }

        var directories: [URL] = [executableDir]
        if let children = try? FileManager.default.contentsOfDirectory(
            at: executableDir,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) {
            for child in children where child.pathExtension == "bundle" {
                directories.append(child)
            }
        }
        return directories
    }()
    
    /// Debug helper to surface where companion textures are being loaded from.
    static func debugResourceBundleHint() -> String {
        if let url = resourceURL(for: "reference_fullbody", ext: "png") {
            return url.deletingLastPathComponent().lastPathComponent
        }
        return "missing-reference_fullbody"
    }
}
