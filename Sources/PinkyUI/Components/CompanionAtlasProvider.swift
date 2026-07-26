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
    private let stateFrameURLs: [String: [URL]]
    private var textureURLCache: [URL: SKTexture] = [:]
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
        self.stateFrameURLs = Self.discoveredStateFrameURLs
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

    /// Resolves frame texture dynamically from discovered state directories/files.
    /// Expected primary layout:
    /// Resources/Character/<State>/<state>_NN.png
    func stateTexture(for stateName: String, frameIndex: Int) -> SKTexture? {
        let key = stateName.lowercased()
        guard let urls = stateFrameURLs[key], !urls.isEmpty else {
            return nil
        }

        let index = frameIndex % urls.count
        let url = urls[index]
        if let cached = textureURLCache[url] {
            return cached
        }
        guard let image = NSImage(contentsOf: url) else {
            return nil
        }
        let texture = SKTexture(image: image)
        textureURLCache[url] = texture
        return texture
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
    
    private static let discoveredStateFrameURLs: [String: [URL]] = {
        var grouped: [String: [(index: Int, name: String, url: URL)]] = [:]
        let validStates = Set([
            "idle", "turn", "stop", "blink", "breathing", "walk", "run",
            "wave", "drink", "sleep", "happy", "sad", "think", "peek", "celebrate",
        ])

        for baseDirectory in resourceSearchDirectories {
            guard let enumerator = FileManager.default.enumerator(
                at: baseDirectory,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { continue }

            for case let fileURL as URL in enumerator where fileURL.pathExtension.lowercased() == "png" {
                let stem = fileURL.deletingPathExtension().lastPathComponent
                let relativePath = fileURL.path.replacingOccurrences(of: baseDirectory.path, with: "")
                let lowerRelativePath = relativePath.lowercased()

                let key: String
                if let markerRange = lowerRelativePath.range(of: "/character/") {
                    let suffix = lowerRelativePath[markerRange.upperBound...]
                    guard let stateFolder = suffix.split(separator: "/").first.map(String.init) else { continue }
                    key = stateFolder.lowercased()
                    guard validStates.contains(key) else { continue }
                    guard isValidCharacterFrameName(stem: stem.lowercased(), state: key) else { continue }
                } else {
                    // SwiftPM can flatten processed resources and drop parent folders.
                    guard let parsed = parsedStateFromCharacterFrameStem(stem.lowercased()) else { continue }
                    key = parsed
                    guard validStates.contains(key) else { continue }
                }
                let frameNumber = parsedFrameIndex(fromStem: stem)
                grouped[key, default: []].append((frameNumber, stem, fileURL))
            }
        }

        var sorted: [String: [URL]] = [:]
        for (state, frames) in grouped {
            sorted[state] = frames
                .sorted { lhs, rhs in
                    if lhs.index == rhs.index { return lhs.name < rhs.name }
                    return lhs.index < rhs.index
                }
                .map(\.url)
        }
        return sorted
    }()

    private static let resourceSearchDirectories: [URL] = {
        var unique: [URL: URL] = [:]
        for bundle in resourceBundles {
            if let resourceURL = bundle.resourceURL {
                unique[resourceURL] = resourceURL
            }
        }
        for directory in sideResourceDirectories {
            unique[directory] = directory
        }
        return Array(unique.values)
    }()

    private static func parsedFrameIndex(fromStem stem: String) -> Int {
        let digits = stem.reversed().prefix { $0.isNumber }.reversed()
        if let index = Int(String(digits)) {
            return index
        }
        return Int.max / 4
    }

    /// Accept only artist-frame names like `idle_01.png` in `Character/Idle/`.
    private static func isValidCharacterFrameName(stem: String, state: String) -> Bool {
        let prefix = "\(state)_"
        guard stem.hasPrefix(prefix) else { return false }
        let suffix = String(stem.dropFirst(prefix.count))
        guard !suffix.isEmpty else { return false }
        return suffix.allSatisfy { $0.isNumber }
    }

    private static func parsedStateFromCharacterFrameStem(_ stem: String) -> String? {
        guard let underscore = stem.firstIndex(of: "_") else { return nil }
        let state = String(stem[..<underscore])
        let suffix = String(stem[stem.index(after: underscore)...])
        guard !state.isEmpty, !suffix.isEmpty, suffix.allSatisfy(\.isNumber) else { return nil }
        return state
    }
}
