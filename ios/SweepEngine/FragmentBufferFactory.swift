import AVFoundation
import Foundation

enum FragmentBufferFactory {
    static func makeBuffer(
        fileURL: URL,
        asset: SourceAsset,
        sweepRate: SweepRate,
        direction: SweepDirection,
        outputFormat: AVAudioFormat,
        startJitterFraction: Double
    ) throws -> AVAudioPCMBuffer {
        let file = try AVAudioFile(forReading: fileURL)
        let sourceFormat = file.processingFormat
        let totalFrames = AVAudioFrameCount(file.length)
        guard totalFrames > 0,
              let source = AVAudioPCMBuffer(pcmFormat: sourceFormat, frameCapacity: totalFrames)
        else {
            throw FragmentError.emptyFile(asset.assetID)
        }
        try file.read(into: source)

        let converted = try convert(source, to: outputFormat)
        let cropped = crop(
            converted,
            asset: asset,
            sweepRate: sweepRate,
            startJitterFraction: min(1, max(0, startJitterFraction))
        )
        let oriented = direction == .reverse ? reverse(cropped) : cropped
        applyFades(oriented, fadeSeconds: 0.006)
        return oriented
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
        let sampleRate = buffer.format.sampleRate
        let total = Int(buffer.frameLength)
        guard total > 0 else { return buffer }

        let desired = max(1, Int((sampleRate * sweepRate.timeInterval).rounded()))
        let playFrames = min(total, desired)

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
        let maxStart = max(safeStart, min(safeEnd, total) - playFrames)
        let span = max(0, maxStart - safeStart)
        let start = safeStart + Int(Double(span) * startJitterFraction)
        let end = min(total, start + playFrames)
        let length = max(1, end - start)

        guard let sliced = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: AVAudioFrameCount(length)) else {
            return buffer
        }
        sliced.frameLength = AVAudioFrameCount(length)
        copyFrames(from: buffer, to: sliced, sourceStart: start, count: length)
        return sliced
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
