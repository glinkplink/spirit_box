import AVFoundation
import Foundation

/// Internal renderer tuning. Shared by live playback, the harness, and offline mix.
/// These are listening-test parameters, not customer-facing product constants.
public struct SweepRendererSettings: Equatable, Sendable {
    /// Fraction of sweep slots that expose a vocal fragment. Start ~0.33.
    public var vocalEventProbability: Double
    /// 0 = independent Bernoulli slots; 1 = sticky gaps and short clusters.
    public var clusteriness: Double
    public var staticGain: Float
    public var vocalGain: Float
    public var outputGain: Float
    public var minVocalExposureSeconds: Double
    public var maxVocalExposureSeconds: Double
    public var minExposureFractionOfDwell: Double
    public var maxExposureFractionOfDwell: Double
    public var fadeSeconds: Double
    public var recentExclusionWindow: Int
    public var highPassHz: Double
    public var lowPassHz: Double
    public var gainVariation: Float
    public var vocalPeakLimit: Float
    public var scheduleAheadSeconds: Double

    /// Default preset for the next 200/300 ms listening tests.
    public static let listeningTest = SweepRendererSettings()

    public init(
        vocalEventProbability: Double = 0.08,
        clusteriness: Double = 0.0,
        staticGain: Float = 0.10,
        vocalGain: Float = 0.48,
        outputGain: Float = 3.5,
        minVocalExposureSeconds: Double = 0.080,
        maxVocalExposureSeconds: Double = 0.220,
        minExposureFractionOfDwell: Double = 0.50,
        maxExposureFractionOfDwell: Double = 0.80,
        fadeSeconds: Double = 0.012,
        recentExclusionWindow: Int = 8,
        highPassHz: Double = 500.0,
        lowPassHz: Double = 3_600.0,
        gainVariation: Float = 0.08,
        vocalPeakLimit: Float = 0.65,
        scheduleAheadSeconds: Double = 0.040
    ) {
        self.vocalEventProbability = min(1, max(0, vocalEventProbability))
        self.clusteriness = min(1, max(0, clusteriness))
        self.staticGain = max(0, staticGain)
        self.vocalGain = max(0, vocalGain)
        self.outputGain = min(8, max(0, outputGain))
        self.minVocalExposureSeconds = min(maxVocalExposureSeconds, max(0.015, minVocalExposureSeconds))
        self.maxVocalExposureSeconds = max(self.minVocalExposureSeconds, maxVocalExposureSeconds)
        self.minExposureFractionOfDwell = min(1, max(0.05, minExposureFractionOfDwell))
        self.maxExposureFractionOfDwell = min(1, max(self.minExposureFractionOfDwell, maxExposureFractionOfDwell))
        self.fadeSeconds = min(0.025, max(0.003, fadeSeconds))
        self.recentExclusionWindow = max(0, recentExclusionWindow)
        self.highPassHz = highPassHz
        self.lowPassHz = lowPassHz
        self.gainVariation = min(0.2, max(0, gainVariation))
        self.vocalPeakLimit = min(0.95, max(0.1, vocalPeakLimit))
        self.scheduleAheadSeconds = min(0.12, max(0.02, scheduleAheadSeconds))
    }

    public var schedulerConfiguration: SchedulerConfiguration {
        SchedulerConfiguration(recentExclusionWindow: recentExclusionWindow)
    }

    public func clamped() -> SweepRendererSettings {
        SweepRendererSettings(
            vocalEventProbability: vocalEventProbability,
            clusteriness: clusteriness,
            staticGain: staticGain,
            vocalGain: vocalGain,
            outputGain: outputGain,
            minVocalExposureSeconds: minVocalExposureSeconds,
            maxVocalExposureSeconds: maxVocalExposureSeconds,
            minExposureFractionOfDwell: minExposureFractionOfDwell,
            maxExposureFractionOfDwell: maxExposureFractionOfDwell,
            fadeSeconds: fadeSeconds,
            recentExclusionWindow: recentExclusionWindow,
            highPassHz: highPassHz,
            lowPassHz: lowPassHz,
            gainVariation: gainVariation,
            vocalPeakLimit: vocalPeakLimit,
            scheduleAheadSeconds: scheduleAheadSeconds
        )
    }
}

/// Back-compat aliases for the listening-test defaults.
enum SweepTuning {
    static let listeningTest = SweepRendererSettings.listeningTest
    static var staticGain: Float { listeningTest.staticGain }
    static var vocalGain: Float { listeningTest.vocalGain }
    static var outputGain: Float { listeningTest.outputGain }
    static var highPassHz: Double { listeningTest.highPassHz }
    static var lowPassHz: Double { listeningTest.lowPassHz }
    static var fadeSeconds: Double { listeningTest.fadeSeconds }
    static var gainVariation: Float { listeningTest.gainVariation }
    static var vocalPeakLimit: Float { listeningTest.vocalPeakLimit }
    static var scheduleAheadSeconds: Double { listeningTest.scheduleAheadSeconds }
}

enum FragmentBufferFactory {
    static func loadConvertedSource(fileURL: URL, outputFormat: AVAudioFormat) throws -> AVAudioPCMBuffer {
        let file = try AVAudioFile(forReading: fileURL)
        let sourceFormat = file.processingFormat
        let totalFrames = AVAudioFrameCount(file.length)
        guard totalFrames > 0,
              let source = AVAudioPCMBuffer(pcmFormat: sourceFormat, frameCapacity: totalFrames)
        else {
            throw FragmentError.emptyFile(fileURL.lastPathComponent)
        }
        try file.read(into: source)
        return try convert(source, to: outputFormat)
    }

    static func makeBuffer(
        convertedSource: AVAudioPCMBuffer,
        asset: SourceAsset,
        sweepRate: SweepRate,
        direction: SweepDirection,
        startJitterFraction: Double,
        durationJitterFraction: Double = 0,
        placementJitterFraction: Double = 0,
        settings: SweepRendererSettings = .listeningTest
    ) -> AVAudioPCMBuffer {
        let cropped = crop(
            convertedSource,
            asset: asset,
            sweepRate: sweepRate,
            startJitterFraction: min(1, max(0, startJitterFraction)),
            durationJitterFraction: min(1, max(0, durationJitterFraction)),
            settings: settings
        )
        // Shape once in source orientation so causal filter startup/tail loss
        // cannot change fragment energy when the direction control is flipped.
        applyRadioShape(cropped, variation: startJitterFraction, settings: settings)
        // Reverse direction reverses corpus traversal order; keep speech natural
        // without unnatural PCM waveform reversal.
        let oriented = cropped
        applyFades(oriented, fadeSeconds: settings.fadeSeconds)
        balanceVocalLevel(oriented, settings: settings)
        // One dwell-sized vocal slot: glimpse plus zeros. The independent noise
        // bed continues; never stretch, loop, or overlap a second speaker.
        // Coordinate placement with the commutation envelope so the glimpse
        // never starts inside the initial quiet shelf.
        let dwellFrames = Int(convertedSource.format.sampleRate * sweepRate.timeInterval)
        let quietFrames = ProceduralNoiseState.commutationFrames(sampleRate: convertedSource.format.sampleRate).quiet
        let effectiveSlack = max(0, dwellFrames - Int(oriented.frameLength) - quietFrames)
        let lead = quietFrames + min(effectiveSlack, Int(Double(effectiveSlack) * min(1, max(0, placementJitterFraction))))
        return padded(oriented, frames: dwellFrames, leadFrames: lead)
    }

    static func makeBuffer(
        fileURL: URL,
        asset: SourceAsset,
        sweepRate: SweepRate,
        direction: SweepDirection,
        outputFormat: AVAudioFormat,
        startJitterFraction: Double,
        durationJitterFraction: Double = 0,
        placementJitterFraction: Double = 0,
        settings: SweepRendererSettings = .listeningTest
    ) throws -> AVAudioPCMBuffer {
        let converted = try loadConvertedSource(fileURL: fileURL, outputFormat: outputFormat)
        return makeBuffer(
            convertedSource: converted,
            asset: asset,
            sweepRate: sweepRate,
            direction: direction,
            startJitterFraction: startJitterFraction,
            durationJitterFraction: durationJitterFraction,
            placementJitterFraction: placementJitterFraction,
            settings: settings
        )
    }

    static func convert(_ buffer: AVAudioPCMBuffer, to format: AVAudioFormat) throws -> AVAudioPCMBuffer {
        if buffer.format.sampleRate == format.sampleRate,
           buffer.format.channelCount == format.channelCount,
           buffer.format.commonFormat == format.commonFormat {
            return buffer
        }
        guard let converter = AVAudioConverter(from: buffer.format, to: format) else {
            throw FragmentError.conversionFailed
        }
        let ratio = format.sampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount((Double(buffer.frameLength) * ratio).rounded(.up) + 32)
        guard let output = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity) else {
            throw FragmentError.conversionFailed
        }

        var consumed = false
        var converterError: NSError?
        let status = converter.convert(to: output, error: &converterError) { _, outStatus in
            if consumed {
                outStatus.pointee = .noDataNow
                return nil
            }
            consumed = true
            outStatus.pointee = .haveData
            return buffer
        }
        if status == .error {
            throw converterError ?? FragmentError.conversionFailed
        }
        return output
    }

    static func crop(
        _ buffer: AVAudioPCMBuffer,
        asset: SourceAsset,
        sweepRate: SweepRate,
        startJitterFraction: Double,
        durationJitterFraction: Double = 0,
        settings: SweepRendererSettings = .listeningTest
    ) -> AVAudioPCMBuffer {
        let bounds = cropBounds(
            buffer, asset: asset, sweepRate: sweepRate,
            startJitterFraction: startJitterFraction,
            durationJitterFraction: durationJitterFraction,
            settings: settings
        )
        let start = bounds.start
        let length = bounds.count
        guard length > 0 else { return buffer }

        guard let sliced = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: AVAudioFrameCount(length)) else {
            return buffer
        }
        sliced.frameLength = AVAudioFrameCount(length)
        copyFrames(from: buffer, to: sliced, sourceStart: start, count: length)
        return sliced
    }

    /// Exposed source frames for one vocal glimpse. Never time-stretches; never
    /// longer than the dwell. Sweep rate sizes the window; it does not speed speech.
    static func exposureFrameCount(
        sampleRate: Double,
        sweepRate: SweepRate,
        availableFrames: Int,
        durationJitterFraction: Double,
        settings: SweepRendererSettings = .listeningTest
    ) -> Int {
        let dwellFrames = max(1, Int((sampleRate * sweepRate.timeInterval).rounded()))
        let minFrames = max(1, Int((sampleRate * settings.minVocalExposureSeconds).rounded()))
        let maxFrames = max(minFrames, Int((sampleRate * settings.maxVocalExposureSeconds).rounded()))
        // Hard safety bounds: preserve natural speech syllables while preventing long sentence leakage.
        let hardSeconds = min(0.240, sweepRate.timeInterval * 0.85)
        let hardFrames = max(1, Int((sampleRate * hardSeconds).rounded(.down)))
        let ceiling = max(1, min(availableFrames, dwellFrames, maxFrames, hardFrames))
        let rateMin = Int((Double(dwellFrames) * settings.minExposureFractionOfDwell).rounded())
        let rateMax = Int((Double(dwellFrames) * settings.maxExposureFractionOfDwell).rounded())
        let floor = min(ceiling, max(1, minFrames, rateMin))
        let high = min(ceiling, max(floor, rateMax))
        let jitter = min(1, max(0, durationJitterFraction))
        return min(ceiling, floor + Int(Double(max(0, high - floor)) * jitter))
    }

    static func cropBounds(
        _ buffer: AVAudioPCMBuffer, asset: SourceAsset,
        sweepRate: SweepRate, startJitterFraction: Double,
        durationJitterFraction: Double = 0,
        settings: SweepRendererSettings = .listeningTest
    ) -> (start: Int, count: Int) {
        let sampleRate = buffer.format.sampleRate
        let total = Int(buffer.frameLength)
        guard total > 0 else { return (0, 0) }

        let safeStartMs = max(0, asset.cropSafeStartMs ?? 0)
        let safeEndMs: Int
        if let end = asset.cropSafeEndMs, end > safeStartMs {
            safeEndMs = end
        } else if let duration = asset.durationMs, duration > safeStartMs {
            safeEndMs = duration
        } else {
            safeEndMs = Int((Double(total) / sampleRate) * 1000.0)
        }

        let safeStart = min(total - 1, Int((Double(safeStartMs) / 1000.0) * sampleRate))
        let safeEnd = min(total, max(safeStart + 1, Int((Double(safeEndMs) / 1000.0) * sampleRate)))
        let available = max(1, safeEnd - safeStart)
        let playFrames = exposureFrameCount(
            sampleRate: sampleRate, sweepRate: sweepRate, availableFrames: available,
            durationJitterFraction: durationJitterFraction, settings: settings
        )
        let maxStart = max(safeStart, safeEnd - playFrames)
        let span = max(0, maxStart - safeStart)
        let start = min(safeEnd - 1, safeStart + Int(Double(span) * min(1, max(0, startJitterFraction))))
        let end = min(safeEnd, start + playFrames)
        let length = max(1, end - start)

        return (start, length)
    }

    static func padded(_ source: AVAudioPCMBuffer, frames: Int, leadFrames: Int = 0) -> AVAudioPCMBuffer {
        let lead = min(max(0, leadFrames), max(0, frames - Int(source.frameLength)))
        guard frames > Int(source.frameLength) || lead > 0,
              let output = AVAudioPCMBuffer(pcmFormat: source.format, frameCapacity: AVAudioFrameCount(max(frames, Int(source.frameLength)))),
              let channels = output.floatChannelData else { return source }
        output.frameLength = AVAudioFrameCount(frames)
        for channel in 0..<Int(source.format.channelCount) {
            channels[channel].initialize(repeating: 0, count: frames)
        }
        copyFrames(from: source, to: output, sourceStart: 0, count: Int(source.frameLength), destStart: lead)
        return output
    }

    static func applyRadioShape(
        _ buffer: AVAudioPCMBuffer,
        variation: Double,
        settings: SweepRendererSettings = .listeningTest
    ) {
        guard let channels = buffer.floatChannelData else { return }
        let mix = min(1, max(0, variation))
        let gain = 1 + (Float(mix) * 2 - 1) * settings.gainVariation
        for channel in 0..<Int(buffer.format.channelCount) {
            var shape = RadioSpeakerShape(sampleRate: buffer.format.sampleRate, settings: settings)
            var peak: Float = 0
            let samples = channels[channel]
            for index in 0..<Int(buffer.frameLength) {
                samples[index] = shape.process(samples[index]) * gain
                peak = max(peak, abs(samples[index]))
            }
            // Whole-window attenuation prevents clipping without nonlinear distortion.
            if peak > settings.vocalPeakLimit {
                let attenuation = settings.vocalPeakLimit / peak
                for index in 0..<Int(buffer.frameLength) { samples[index] *= attenuation }
            }
        }
    }

    static func reverse(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer {
        let count = Int(buffer.frameLength)
        guard count > 1,
              let output = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: buffer.frameCapacity)
        else {
            return buffer
        }
        output.frameLength = buffer.frameLength

        if let source = buffer.floatChannelData, let dest = output.floatChannelData {
            for channel in 0..<Int(buffer.format.channelCount) {
                let inSamples = source[channel]
                let outSamples = dest[channel]
                for index in 0..<count {
                    outSamples[index] = inSamples[count - 1 - index]
                }
            }
            return output
        }

        if let source = buffer.int16ChannelData, let dest = output.int16ChannelData {
            for channel in 0..<Int(buffer.format.channelCount) {
                let inSamples = source[channel]
                let outSamples = dest[channel]
                for index in 0..<count {
                    outSamples[index] = inSamples[count - 1 - index]
                }
            }
            return output
        }

        return buffer
    }

    static func applyFades(_ buffer: AVAudioPCMBuffer, fadeSeconds: Double) {
        let count = Int(buffer.frameLength)
        guard count > 4 else { return }
        let fadeFrames = min(count / 4, max(1, Int(buffer.format.sampleRate * fadeSeconds)))
        guard let channels = buffer.floatChannelData else { return }
        for channel in 0..<Int(buffer.format.channelCount) {
            let samples = channels[channel]
            for index in 0..<fadeFrames {
                let gain = Float(0.5 * (1.0 - cos(Double.pi * Double(index) / Double(fadeFrames))))
                samples[index] *= gain
                samples[count - 1 - index] *= gain
            }
        }
    }

    /// The actual full-corpus audit measured the shaped bed at ~0.025 RMS
    /// with staticGain 0.10. A 0.105 RMS glimpse at vocalGain 0.48 is ~6 dB
    /// above that bed. Bound lift to 12 dB: near-silent source windows remain
    /// quiet rather than having their recording floor aggressively amplified.
    /// Work on the faded glimpse, never on its dwell-sized zero padding.
    static func balanceVocalLevel(
        _ buffer: AVAudioPCMBuffer,
        settings: SweepRendererSettings = .listeningTest
    ) {
        guard let channels = buffer.floatChannelData, buffer.frameLength > 0 else { return }
        let count = Int(buffer.frameLength)
        for channel in 0..<Int(buffer.format.channelCount) {
            let samples = channels[channel]
            var sum = 0.0
            var peak: Float = 0
            for i in 0..<count {
                let sample = samples[i].isFinite ? samples[i] : 0
                samples[i] = sample
                sum += Double(sample) * Double(sample)
                peak = max(peak, abs(sample))
            }
            let rms = sqrt(sum / Double(count))
            guard rms > 0, peak > 0 else { continue }
            let gain = min(Float(0.105 / rms), 4, settings.vocalPeakLimit / peak)
            for i in 0..<count { samples[i] *= gain }
        }
    }

    private static func copyFrames(
        from source: AVAudioPCMBuffer,
        to dest: AVAudioPCMBuffer,
        sourceStart: Int,
        count: Int,
        destStart: Int = 0
    ) {
        if let inData = source.floatChannelData, let outData = dest.floatChannelData {
            for channel in 0..<Int(source.format.channelCount) {
                outData[channel].advanced(by: destStart)
                    .update(from: inData[channel].advanced(by: sourceStart), count: count)
            }
        } else if let inData = source.int16ChannelData, let outData = dest.int16ChannelData {
            for channel in 0..<Int(source.format.channelCount) {
                outData[channel].advanced(by: destStart)
                    .update(from: inData[channel].advanced(by: sourceStart), count: count)
            }
        }
    }

    enum FragmentError: Error, LocalizedError {
        case emptyFile(String)
        case conversionFailed

        var errorDescription: String? {
            switch self {
            case .emptyFile(let id): return "Empty audio file for \(id)"
            case .conversionFailed: return "Could not convert fragment to engine format"
            }
        }
    }
}
