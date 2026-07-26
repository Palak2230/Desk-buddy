import Foundation
import AVFoundation
import Core

/// Lightweight synthesized sound feedback service (no bundled audio assets required).
@MainActor
public final class CompanionSoundService {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    private var isConfigured = false

    public init() {}

    public func playReminder(volume: Double) {
        playTone(frequency: 622.0, duration: 0.12, volume: volume)
    }

    public func playSuccess(volume: Double) {
        playTone(frequency: 784.0, duration: 0.10, volume: volume)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) { [weak self] in
            self?.playTone(frequency: 988.0, duration: 0.12, volume: volume)
        }
    }

    public func playSnooze(volume: Double) {
        playTone(frequency: 494.0, duration: 0.16, volume: volume * 0.8)
    }

    private func configureEngineIfNeeded() {
        guard !isConfigured else { return }

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: audioFormat)
        isConfigured = true
    }

    private var audioFormat: AVAudioFormat {
        AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
    }

    private func playTone(frequency: Double, duration: Double, volume: Double) {
        guard volume > 0.01 else { return }
        configureEngineIfNeeded()

        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount),
            let channelData = buffer.floatChannelData?[0]
        else { return }

        buffer.frameLength = frameCount
        let amplitude = Float(min(max(volume, 0), 1)) * 0.25

        for frame in 0 ..< Int(frameCount) {
            let time = Double(frame) / sampleRate
            let envelope = max(0.0, 1.0 - (time / duration))
            let sample = sin(2.0 * .pi * frequency * time) * envelope
            channelData[frame] = Float(sample) * amplitude
        }

        do {
            if !engine.isRunning {
                try engine.start()
            }
            player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
            player.play()
        } catch {
            AppLogger.log("Sound", "Failed to play tone: \(error)")
        }
    }
}
