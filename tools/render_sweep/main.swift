import Foundation

// Compile with the app's SweepEngine sources. No parallel DSP implementation.
let args = CommandLine.arguments
if args.count < 4 || args.count > 7 {
    fputs("Usage: render-sweep CORPUS OUTPUT_DIRECTORY SECONDS [75|125|200|300] [forward|reverse] [SEED]\n", stderr)
    exit(2)
}
do {
    let root = URL(fileURLWithPath: args[1], isDirectory: true)
    let manifest = try JSONDecoder().decode(CorpusManifest.self, from: Data(contentsOf: root.appendingPathComponent("manifest.json")))
    guard let seconds = Int(args[3]), (1...1200).contains(seconds),
          let rate = SweepRate(rawValue: args.count > 4 ? Int(args[4]) ?? 0 : 200),
          let direction = SweepDirection(rawValue: args.count > 5 ? args[5] : "forward"),
          let seed = UInt64(args.count > 6 ? args[6] : "12648430") else {
        throw NSError(domain: "render-sweep: invalid arguments", code: 2)
    }
    let engine = SweepAudioEngine()
    engine.load(LoadedCorpus(assets: manifest.assets, skippedMalformedCount: 0,
                             source: .bundlePhase1, label: manifest.label ?? "QA corpus",
                             isDevFixture: false, rootURL: root))
    engine.setSweepRate(rate)
    engine.setDirection(direction)
    let start = Date()
    try engine.renderFinalMix(to: URL(fileURLWithPath: args[2], isDirectory: true), seconds: seconds, seed: seed)
    print("Rendered \(seconds)s of actual engine mix in \(Date().timeIntervalSince(start))s → \(args[2])/sweep.wav")
} catch {
    fputs("Render failed: \(error)\n", stderr)
    exit(1)
}
