import Foundation
import Core

/// Loads sprite-sheet clip manifests and materializes `AnimationClip` values.
public final class SpriteSheetCatalog: Sendable {
    private let bundle: Bundle

    public init(bundle: Bundle? = nil) {
        self.bundle = bundle ?? Bundle.module
    }

    public func loadClips(manifestID: String) -> [AnimationClip] {
        guard let url = bundle.url(forResource: manifestID, withExtension: "json", subdirectory: "Animations") else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let manifest = try JSONDecoder().decode(SpriteSheetManifest.self, from: data)

            return manifest.clips.map { clip in
                let frames = (0 ..< clip.frameCount).map { index in
                    AnimationFrame(
                        textureName: "\(clip.id)_\(index)",
                        duration: clip.frameDuration
                    )
                }

                return AnimationClip(
                    id: clip.id,
                    frames: frames,
                    playbackMode: clip.resolvedPlaybackMode,
                    priority: clip.priority
                )
            }
        } catch {
            AppLogger.log("Animations", "Failed to load sprite manifest \(manifestID): \(error)")
            return []
        }
    }
}
