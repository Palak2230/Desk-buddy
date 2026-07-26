import Foundation
import Core

/// Loads and caches JSON theme definitions from bundled resources.
public final class ThemeLoader: Sendable {
    public static let shared = ThemeLoader()

    private let bundle: Bundle

    public init(bundle: Bundle? = nil) {
        self.bundle = bundle ?? Bundle.module
    }

    public func loadTheme(id: String) -> Theme? {
        guard let url = bundle.url(forResource: id, withExtension: "json", subdirectory: "Themes") else {
            return Self.fallbackTheme
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Theme.self, from: data)
        } catch {
            AppLogger.log("ThemeLoader", "Failed to load theme \(id): \(error)")
            return Self.fallbackTheme
        }
    }

    public func allThemes() -> [Theme] {
        guard let themesURL = bundle.url(forResource: "Themes", withExtension: nil) else {
            return [Self.fallbackTheme]
        }

        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(at: themesURL, includingPropertiesForKeys: nil) else {
            return [Self.fallbackTheme]
        }

        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url -> Theme? in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? JSONDecoder().decode(Theme.self, from: data)
            }
    }

    public static let fallbackTheme = Theme(
        id: "strawberry-milk",
        name: "Strawberry Milk",
        primary: "#FFB6C1",
        secondary: "#FFF0F5",
        accent: "#FF69B4",
        background: "#FFF5F7",
        surface: "#FFFFFF",
        text: "#4A3040",
        speechBubble: "#FFFFFF"
    )
}
