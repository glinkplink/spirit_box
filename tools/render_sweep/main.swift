import Foundation
import AVFoundation

// Audit the actual buffer factory over every bundled source, both directions
// and all dwell rates. This is a level measurement, not a listening verdict.
func auditLevels(assets: [SourceAsset], root: URL, output: URL) throws {
    let format = AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1)!
    func rms(_ buffer: AVAudioPCMBuffer, offset: Int = 0, count: Int) -> Double {
        let samples = buffer.floatChannelData![0]
        let start = min(Int(buffer.frameLength), max(0, offset))
        let n = min(count, max(0, Int(buffer.frameLength) - start))
        guard n > 0 else { return 0 }
        return sqrt((start..<(start + n)).reduce(0.0) { $0 + Double(samples[$1]) * Double(samples[$1]) } / Double(n))
    }
    func db(_ value: Double) -> Double { 20 * log10(max(1e-12, value)) }
    func distribution(_ values: [Double]) -> [String: Double] {
        let v = values.sorted()
        return ["min": v.first!, "p05": v[Int(Double(v.count - 1) * 0.05)],
                "median": v[v.count / 2], "p95": v[Int(Double(v.count - 1) * 0.95)], "max": v.last!]
    }
    var reports: [String: Any] = [:]
    var sourceLevels: [(id: String, dbfs: Double)] = []
    for asset in assets {
        let source = try FragmentBufferFactory.loadConvertedSource(fileURL: root.appendingPathComponent(asset.relativePath), outputFormat: format)
        sourceLevels.append((asset.assetID, db(rms(source, count: Int(source.frameLength)))))
    }
    reports["source_rms_dbfs"] = distribution(sourceLevels.map(\.dbfs))
    reports["quietest_sources"] = sourceLevels.sorted { $0.dbfs < $1.dbfs }.prefix(10).map {
        ["asset_id": $0.id, "rms_dbfs": $0.dbfs] as [String: Any]
    }
    let noise = ProceduralNoiseState()
    noise.reset(seed: 12648430)
    let noiseRMS = sqrt((0..<48000).reduce(0.0) { sum, _ in
        let x = Double(noise.nextSample() * SweepTuning.staticGain)
        return sum + x * x
    } / 48000)
    var maximumPeak = 0.0
    for rate in SweepRate.allCases {
        let quietFrames = ProceduralNoiseState.commutationFrames(sampleRate: format.sampleRate).quiet
        var levels: [Double] = [], reverseDifferences: [Double] = [], changes: [Double] = [], balances: [Double] = []
        for asset in assets {
            let source = try FragmentBufferFactory.loadConvertedSource(fileURL: root.appendingPathComponent(asset.relativePath), outputFormat: format)
            // Extremes and midpoint cover the entire bounded runtime gain range.
            for jitter in [0.0, 0.5, 1.0] {
                let crop = FragmentBufferFactory.crop(source, asset: asset, sweepRate: rate, startJitterFraction: jitter)
                let count = Int(crop.frameLength)
                let inputLevel = rms(crop, offset: 0, count: count)
                var pair: [Double] = []
                for direction in SweepDirection.allCases {
                    let buffer = FragmentBufferFactory.makeBuffer(convertedSource: source, asset: asset,
                        sweepRate: rate, direction: direction, startJitterFraction: jitter)
                    let level = rms(buffer, offset: quietFrames, count: count)
                    pair.append(db(level))
                    levels.append(db(level * Double(SweepTuning.vocalGain * SweepTuning.outputGain)))
                    changes.append(db(level / max(inputLevel, 1e-12)))
                    balances.append(db(level * Double(SweepTuning.vocalGain) / noiseRMS))
                    for i in 0..<Int(buffer.frameLength) {
                        let sample = Double(buffer.floatChannelData![0][i])
                        guard sample.isFinite, abs(sample) <= Double(SweepTuning.vocalPeakLimit) + 0.00001 else {
                            throw NSError(domain: "level-audit: invalid vocal peak", code: 1)
                        }
                        maximumPeak = max(maximumPeak, abs(sample))
                    }
                }
                let difference = abs(pair[0] - pair[1])
                // A direction-only change must not double/halve window energy.
                guard difference < 3 else {
                    throw NSError(domain: "level-audit: reverse level changed by >=3 dB for \(asset.assetID)", code: 1)
                }
                reverseDifferences.append(difference)
            }
        }
        let medianBalance = distribution(balances)["median"]!
        guard (4.0...8.0).contains(medianBalance) else {
            throw NSError(domain: "level-audit: median voice/static balance \(medianBalance) dB outside +4...+8 dB at \(rate.milliseconds) ms", code: 1)
        }
        reports[String(rate.milliseconds)] = ["pre_limiter_active_vocal_rms_dbfs": distribution(levels),
            "runtime_level_change_db": distribution(changes),
            "reverse_absolute_rms_difference_db": distribution(reverseDifferences),
            "active_voice_to_static_db": distribution(balances)]
    }
    reports["maximum_vocal_peak"] = maximumPeak
    reports["limited_sample_peak_bound"] = Double(SweepMasterLimiter.sampleCeiling)
    reports["reconstructed_peak_bound"] = Double(SweepMasterLimiter.truePeakCeiling)
    reports["human_listening"] = "NOT_RUN"
    try JSONSerialization.data(withJSONObject: reports, options: [.sortedKeys, .prettyPrinted])
        .write(to: output.appendingPathComponent("level-audit.json"))
}

// Compile with the app's SweepEngine sources. No parallel DSP implementation.
let args = CommandLine.arguments
if args.count < 4 || args.count > 8 {
    fputs("Usage: render-sweep CORPUS OUTPUT_DIRECTORY SECONDS [75|125|200|300] [forward|reverse] [SEED] [PRESET]\n", stderr)
    fputs("PRESET: listening-test (default) | listening-test-pre-rebalance | archived-continuous-static\n", stderr)
    exit(2)
}
do {
    let root = URL(fileURLWithPath: args[1], isDirectory: true)
    let manifest = try JSONDecoder().decode(CorpusManifest.self, from: Data(contentsOf: root.appendingPathComponent("manifest.json")))
    guard let seconds = Int(args[3]), (1...1200).contains(seconds),
          let rate = SweepRate(rawValue: args.count > 4 ? Int(args[4]) ?? 0 : 300),
          let direction = SweepDirection(rawValue: args.count > 5 ? args[5] : "forward"),
          let seed = UInt64(args.count > 6 ? args[6] : "12648430") else {
        throw NSError(domain: "render-sweep: invalid arguments", code: 2)
    }
    let presetName = args.count > 7 ? args[7] : SweepRendererSettings.listeningTestIdentity.identifier
    guard let settings = SweepRendererSettings.preset(identifier: presetName) else {
        throw NSError(domain: "render-sweep: unknown preset \(presetName)", code: 2)
    }
    let engine = SweepAudioEngine()
    engine.load(LoadedCorpus(assets: manifest.assets, skippedMalformedCount: 0,
                             source: .bundlePhase1, label: manifest.label ?? "QA corpus",
                             isDevFixture: false, rootURL: root))
    engine.setRendererSettings(settings)
    engine.setSweepRate(rate)
    engine.setDirection(direction)
    let start = Date()
    try engine.renderFinalMix(to: URL(fileURLWithPath: args[2], isDirectory: true), seconds: seconds, seed: seed)
    if ProcessInfo.processInfo.environment["SPIRIT_BOX_LEVEL_AUDIT"] == "1" {
        try auditLevels(assets: manifest.assets, root: root, output: URL(fileURLWithPath: args[2]))
    }
    let preset = engine.currentRendererSettings.namedPreset
    print("Rendered \(seconds)s of actual engine mix in \(Date().timeIntervalSince(start))s → \(args[2])/sweep.wav")
    print("Preset \(preset.identifier) \(preset.version) seed \(seed) \(rate.milliseconds)ms \(direction.rawValue)")
} catch {
    fputs("Render failed: \(error)\n", stderr)
    exit(1)
}
