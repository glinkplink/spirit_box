import AVFoundation
import Foundation

/// Direct-form II biquad. State belongs to one stream, never to the audio graph.
private struct SweepBiquad {
    var b0: Double, b1: Double, b2: Double, a1: Double, a2: Double
    private var z1 = 0.0, z2 = 0.0

    init(hz: Double, sampleRate: Double, highPass: Bool) {
        let w = 2 * Double.pi * min(sampleRate * 0.45, max(20, hz)) / sampleRate
        let c = cos(w), alpha = sin(w) / sqrt(2.0), a0 = 1 + alpha
        b0 = (highPass ? 1 + c : 1 - c) / (2 * a0)
        b1 = (highPass ? -(1 + c) : 1 - c) / a0
        b2 = b0
        a1 = -2 * c / a0
        a2 = (1 - alpha) / a0
    }

    init(presenceHz: Double, sampleRate: Double) {
        let w = 2 * Double.pi * min(sampleRate * 0.45, presenceHz) / sampleRate
        let a = pow(10.0, 3.5 / 40), alpha = sin(w) / (2 * 1.75)
        let a0 = 1 + alpha / a
        b0 = (1 + alpha * a) / a0
        b1 = -2 * cos(w) / a0
        b2 = (1 - alpha * a) / a0
        a1 = b1
        a2 = (1 - alpha / a) / a0
    }

    mutating func process(_ input: Double) -> Double {
        let output = b0 * input + z1
        z1 = b1 * input - a1 * output + z2
        z2 = b2 * input - a2 * output
        return output
    }
}

/// Identical 12 dB/octave edges and +3.5 dB / Q 1.75 presence for both layers.
struct RadioSpeakerShape {
    private var high: SweepBiquad
    private var low: SweepBiquad
    private var presence: SweepBiquad

    init(sampleRate: Double, settings: SweepRendererSettings = .listeningTest) {
        high = SweepBiquad(hz: settings.highPassHz, sampleRate: sampleRate, highPass: true)
        low = SweepBiquad(hz: settings.lowPassHz, sampleRate: sampleRate, highPass: false)
        presence = SweepBiquad(presenceHz: 2350, sampleRate: sampleRate)
    }

    mutating func process(_ input: Float) -> Float {
        Float(presence.process(low.process(high.process(Double(input.isFinite ? input : 0)))))
    }
}

/// Generated on the serial scheduling queue, not a second, free-running clock.
final class ProceduralNoiseState {
    private var seed: UInt32 = 0
    private var shape = RadioSpeakerShape(sampleRate: 48_000)

    func reset(seed: UInt32, sampleRate: Double = 48_000,
               settings: SweepRendererSettings = .listeningTest) {
        self.seed = seed
        shape = RadioSpeakerShape(sampleRate: sampleRate, settings: settings)
    }

    func configure(sampleRate: Double, settings: SweepRendererSettings) {
        shape = RadioSpeakerShape(sampleRate: sampleRate, settings: settings)
    }

    static func commutationFrames(sampleRate: Double) -> (quiet: Int, edge: Int) {
        (0, 0)
    }

    /// The static bed remains continuous; slot envelope does not apply unnatural gating tremolo.
    static func slotEnvelope(frame: Int, count: Int, sampleRate: Double) -> Float {
        1.0
    }

    func nextSample() -> Float {
        seed = seed &* 1_664_525 &+ 1_013_904_223
        let white = Float(seed >> 8) / Float(0x00FF_FFFF) * 2 - 1
        return shape.process(white)
    }
}

/// Master peak limiter with anticipatory lookahead and smooth release.
/// Uses a practical -2.5 dBFS sample ceiling (0.7498942) retaining ~1.5 dB
/// true-peak reconstruction margin below the -1.0 dBFS (0.8912509) true peak ceiling.
/// The 2 ms forward preview anticipates attacks; 40 ms release prevents pumping.
enum SweepMasterLimiter {
    static let truePeakCeiling: Float = 0.8912509 // -1.0 dBFS
    static let sampleCeiling: Float = 0.7498942 // -2.5 dBFS (retains ~1.5 dB true-peak reconstruction margin)

    static func process(_ samples: UnsafeMutablePointer<Float>, count: Int, sampleRate: Double) {
        let ceiling = sampleCeiling
        let release = Float(exp(-1 / (sampleRate * 0.040)))
        let preview = max(1, Int(sampleRate * 0.002))
        // Backward peak envelope anticipates attacks; final sample bound remains
        // valid even for full-scale adversarial input or an end-of-slot transient.
        var future = [Float](repeating: 0, count: count)
        var peak: Float = 0
        let decay = Float(exp(-1 / Double(preview)))
        for i in stride(from: count - 1, through: 0, by: -1) {
            if !samples[i].isFinite { samples[i] = 0 }
            peak = max(abs(samples[i]), peak * decay)
            future[i] = peak
        }
        var gain: Float = 1
        for i in 0..<count {
            let target = min(1, ceiling / max(ceiling, future[i]))
            gain = min(target, release * gain + (1 - release))
            samples[i] = max(-ceiling, min(ceiling, samples[i] * gain))
        }
    }
}

/// One shared pre-device PCM path. Vocals, static, cadence and master limiting
/// are baked together before either live or offline AVAudioPlayerNode playback.
enum SweepSlotMixer {
    static func mix(_ buffer: AVAudioPCMBuffer, noise: ProceduralNoiseState,
                    settings: SweepRendererSettings) {
        guard let channels = buffer.floatChannelData else { return }
        let count = Int(buffer.frameLength)
        guard count > 0 else { return }
        for i in 0..<count {
            let bed = noise.nextSample() * settings.staticGain
            for c in 0..<Int(buffer.format.channelCount) {
                channels[c][i] = (channels[c][i] * settings.vocalGain + bed) * settings.outputGain
            }
        }
        for c in 0..<Int(buffer.format.channelCount) {
            SweepMasterLimiter.process(channels[c], count: count, sampleRate: buffer.format.sampleRate)
        }
    }
}
