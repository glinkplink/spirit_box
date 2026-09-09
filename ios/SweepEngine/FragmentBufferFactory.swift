import AVFoundation
import Foundation

/// Internal tuning only; shared by live playback and offline final-mix rendering.
enum SweepTuning {
    static let staticGain: Float = 0.09
    static let vocalGain: Float = 0.88
    static let outputGain: Float = 0.82
    static let highPassHz = 280.0
    static let lowPassHz = 4_200.0
    static let fadeSeconds = 0.006
    static let gainVariation: Float = 0.08
    static let vocalPeakLimit: Float = 0.65
    static let scheduleAheadSeconds = 0.040
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
        startJitterFraction: Double
    ) -> AVAudioPCMBuffer {
        let cropped = crop(
            convertedSource,
            asset: asset,
            sweepRate: sweepRate,
            startJitterFraction: min(1, max(0, startJitterFraction))
        )
        let oriented = direction == .reverse ? reverse(cropped) : cropped
        applyRadioShape(oriented, variation: startJitterFraction)
        applyFades(oriented, fadeSeconds: SweepTuning.fadeSeconds)
        // The slot always lasts one dwell. A short source leaves static, never a
        // looped/stretched syllable or a late wall-clock gap before the next slot.
        return padded(oriented, frames: Int(convertedSource.format.sampleRate * sweepRate.timeInterval))
    }

    static func makeBuffer(
        fileURL: URL,
        asset: SourceAsset,
        sweepRate: SweepRate,
        direction: SweepDirection,
        outputFormat: AVAudioFormat,
        startJitterFraction: Double
    ) throws -> AVAudioPCMBuffer {
        let converted = try loadConvertedSource(fileURL: fileURL, outputFormat: outputFormat)
        return makeBuffer(
            convertedSource: converted,
            asset: asset,
            sweepRate: sweepRate,
            direction: direction,
            startJitterFraction: startJitterFraction
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
        startJitterFraction: Double
    ) -> AVAudioPCMBuffer {
        let bounds = cropBounds(buffer, asset: asset, sweepRate: sweepRate, startJitterFraction: startJitterFraction)
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

    static func cropBounds(
        _ buffer: AVAudioPCMBuffer, asset: SourceAsset,
        sweepRate: SweepRate, startJitterFraction: Double
    ) -> (start: Int, count: Int) {
        let sampleRate = buffer.format.sampleRate
        let total = Int(buffer.frameLength)
        guard total > 0 else { return (0, 0) }

        let desired = max(1, Int((sampleRate * sweepRate.timeInterval).rounded()))

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
        let playFrames = min(total, desired, available)
        let maxStart = max(safeStart, safeEnd - playFrames)
        let span = max(0, maxStart - safeStart)
        let start = min(safeEnd - 1, safeStart + Int(Double(span) * min(1, max(0, startJitterFraction))))
        let end = min(safeEnd, start + playFrames)
        let length = max(1, end - start)

        return (start, length)
    }

    static func padded(_ source: AVAudioPCMBuffer, frames: Int) -> AVAudioPCMBuffer {
        guard frames > Int(source.frameLength),
              let output = AVAudioPCMBuffer(pcmFormat: source.format, frameCapacity: AVAudioFrameCount(frames)),
              let channels = output.floatChannelData else { return source }
        output.frameLength = AVAudioFrameCount(frames)
        for channel in 0..<Int(source.format.channelCount) {
            channels[channel].initialize(repeating: 0, count: frames)
        }
        copyFrames(from: source, to: output, sourceStart: 0, count: Int(source.frameLength))
        return output
    }

    static func applyRadioShape(_ buffer: AVAudioPCMBuffer, variation: Double) {
        guard let channels = buffer.floatChannelData else { return }
        let dt = 1 / buffer.format.sampleRate
        let hpRC = 1 / (2 * Double.pi * SweepTuning.highPassHz)
        let lpRC = 1 / (2 * Double.pi * SweepTuning.lowPassHz)
        let hp = Float(hpRC / (hpRC + dt))
        let lp = Float(dt / (lpRC + dt))
        let gain = 1 + (Float(min(1, max(0, variation))) * 2 - 1) * SweepTuning.gainVariation
        for channel in 0..<Int(buffer.format.channelCount) {
            var previous: Float = 0, high: Float = 0, low: Float = 0
            var peak: Float = 0
            let samples = channels[channel]
            for index in 0..<Int(buffer.frameLength) {
                let input = samples[index].isFinite ? samples[index] : 0
                high = hp * (high + input - previous)
                previous = input
                low += lp * (high - low)
                samples[index] = low * gain
                peak = max(peak, abs(samples[index]))
            }
            // Whole-window attenuation prevents clipping without nonlinear distortion.
            if peak > SweepTuning.vocalPeakLimit {
                let attenuation = SweepTuning.vocalPeakLimit / peak
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
                let gain = Float(index) / Float(fadeFrames)
                samples[index] *= gain
                samples[count - 1 - index] *= gain
            }
        }
    }

    private static func copyFrames(
        from source: AVAudioPCMBuffer,
        to dest: AVAudioPCMBuffer,
        sourceStart: Int,
        count: Int
    ) {
        if let inData = source.floatChannelData, let outData = dest.floatChannelData {
            for channel in 0..<Int(source.format.channelCount) {
                outData[channel].update(from: inData[channel].advanced(by: sourceStart), count: count)
            }
        } else if let inData = source.int16ChannelData, let outData = dest.int16ChannelData {
            for channel in 0..<Int(source.format.channelCount) {
                outData[channel].update(from: inData[channel].advanced(by: sourceStart), count: count)
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
