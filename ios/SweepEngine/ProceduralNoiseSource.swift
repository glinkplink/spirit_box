import AVFoundation
import Foundation

/// Continuous procedural hiss / static bed. No stored radio or broadcast recordings.
final class ProceduralNoiseState: @unchecked Sendable {
    var amplitude: Float
    private var brown: Float = 0
    private var crackleCountdown: Int
    private var seed: UInt32

    init(seed: UInt32 = 0x5EED_F15E, amplitude: Float = SweepRendererSettings.listeningTest.staticGain) {
        self.seed = seed
        self.amplitude = amplitude
        self.crackleCountdown = 24_000
    }

    func reset(seed: UInt32 = 0x5EED_F15E) {
        self.seed = seed
        brown = 0
        crackleCountdown = 24_000
    }

    func nextSample() -> Float {
        let white = nextUnit()
        brown = max(-1, min(1, brown * 0.88 + white * 0.12))
        var sample = brown * 0.65 + white * 0.18
        crackleCountdown -= 1
        if crackleCountdown <= 0 {
            sample += nextUnit() * 0.35
            crackleCountdown = 6_000 + Int(nextUInt32() % 36_000)
        }
        return max(-1, min(1, sample)) * amplitude
    }

    private func nextUnit() -> Float {
        Float(nextUInt32() % 2001) / 1000.0 - 1.0
    }

    private func nextUInt32() -> UInt32 {
        seed = seed &* 1_664_525 &+ 1_013_904_223
        return seed
    }
}

enum ProceduralNoiseSource {
    static func makeNode(format: AVAudioFormat, state: ProceduralNoiseState) -> AVAudioSourceNode {
        AVAudioSourceNode(format: format) { isSilence, _, frameCount, audioBufferList -> OSStatus in
            isSilence.pointee = false
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for buffer in abl {
                guard let raw = buffer.mData else { continue }
                let samples = raw.assumingMemoryBound(to: Float.self)
                let count = Int(frameCount)
                for index in 0..<count {
                    samples[index] = state.nextSample()
                }
            }
            return noErr
        }
    }
}
