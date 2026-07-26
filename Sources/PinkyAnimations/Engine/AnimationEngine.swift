import Foundation
import Combine

/// Drives frame-based sprite animations with queueing and priority interruption.
@MainActor
public final class AnimationEngine: ObservableObject {
    @Published public private(set) var currentClipID: String?
    @Published public private(set) var currentFrameIndex: Int = 0

    private var clips: [String: AnimationClip] = [:]
    private var queue: [AnimationClip] = []
    private var timer: Timer?
    private var onComplete: (() -> Void)?
    private var playbackDirection: Int = 1

    public init() {}

    // MARK: - Registration

    public func register(_ clip: AnimationClip) {
        clips[clip.id] = clip
    }

    public func register(_ clips: [AnimationClip]) {
        clips.forEach { register($0) }
    }

    // MARK: - Playback

    public func play(_ clipID: String, onComplete: (() -> Void)? = nil) {
        guard let clip = clips[clipID] else { return }

        if let currentID = currentClipID,
           let current = clips[currentID],
           clip.priority < current.priority {
            queue.append(clip)
            return
        }

        stopTimer()
        currentClipID = clip.id
        currentFrameIndex = 0
        playbackDirection = 1
        self.onComplete = onComplete
        scheduleNextFrame(for: clip)
    }

    public func stop() {
        stopTimer()
        currentClipID = nil
        currentFrameIndex = 0
        playbackDirection = 1
        onComplete = nil
        queue.removeAll()
    }

    // MARK: - Private

    private func scheduleNextFrame(for clip: AnimationClip) {
        guard currentFrameIndex < clip.frames.count else {
            finishClip(clip)
            return
        }

        let frame = clip.frames[currentFrameIndex]
        let clipID = clip.id
        timer = Timer.scheduledTimer(withTimeInterval: frame.duration, repeats: false) { _ in
            Task { @MainActor [weak self] in
                guard let self, let clip = self.clips[clipID] else { return }
                self.advanceFrame(in: clip)
            }
        }
    }

    private func advanceFrame(in clip: AnimationClip) {
        if clip.playbackMode == .pingPong {
            advancePingPongFrame(in: clip)
            return
        }

        currentFrameIndex += 1

        if currentFrameIndex < clip.frames.count {
            scheduleNextFrame(for: clip)
            return
        }

        finishClip(clip)
    }

    private func advancePingPongFrame(in clip: AnimationClip) {
        guard clip.frames.count > 1 else {
            scheduleNextFrame(for: clip)
            return
        }

        let candidate = currentFrameIndex + playbackDirection
        if candidate >= clip.frames.count {
            playbackDirection = -1
            currentFrameIndex = clip.frames.count - 2
            scheduleNextFrame(for: clip)
            return
        }
        if candidate < 0 {
            playbackDirection = 1
            currentFrameIndex = 1
            scheduleNextFrame(for: clip)
            return
        }

        currentFrameIndex = candidate
        scheduleNextFrame(for: clip)
    }

    private func finishClip(_ clip: AnimationClip) {
        if clip.playbackMode == .loop {
            currentFrameIndex = 0
            playbackDirection = 1
            scheduleNextFrame(for: clip)
        } else if clip.playbackMode == .pingPong {
            playbackDirection = 1
            currentFrameIndex = 0
            scheduleNextFrame(for: clip)
        } else {
            let completion = onComplete
            onComplete = nil
            currentClipID = nil
            currentFrameIndex = 0

            if let next = queue.first {
                queue.removeFirst()
                play(next.id)
            } else {
                completion?()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
