import AVFoundation
import Foundation

/// Offline non-semantic sweep renderer used by the private developer harness.
///
/// Reusable by a later product UI. Does not implement MARK, session recording,
/// commerce, radio, speech recognition, or semantic response logic.
public final class SweepAudioEngine: @unchecked Sendable {
    public var onEvent: ((SweepEvent) -> Void)?
    public var onCaptureStateChange: ((EngineOutputCaptureState) -> Void)?
    public var onRuntimeMessage: ((String) -> Void)?

    private let queue = DispatchQueue(label: "com.glinkplink.spiritbox.sweep-engine")
    private let captureWriteQueue = DispatchQueue(label: "com.glinkplink.spiritbox.sweep-engine.capture-write")
    private let captureBackpressure = DispatchSemaphore(value: 8)
    private let engine = AVAudioEngine()
    private var fragmentPlayer = AVAudioPlayerNode()
    private let noiseState = ProceduralNoiseState()
    private let captureWriter = EngineOutputCaptureWriter()
    private let eventLog: SweepEventLog

    private var noiseNode: AVAudioSourceNode?
    private var timer: DispatchSourceTimer?
    private var scheduler = SweepScheduler(assets: [])
    private var corpus = LoadedCorpus.empty
    private var graphFormat: AVAudioFormat?
    private var convertedBufferCache: [String: AVAudioPCMBuffer] = [:]
    private var captureEventFileHandle: FileHandle?
    private var jitterSeed: UInt64 = 0xC0FFEE

    private var running = false
    private var sweepRate: SweepRate = .default
    private var direction: SweepDirection = .forward
    private var captureTickCounter = 0
    private var captureTapInstalled = false
    private var captureActive = false

    public init(eventLog: SweepEventLog = SweepEventLog()) {
        self.eventLog = eventLog
    }

    public var isRunning: Bool {
        queue.sync { running }
    }

    public var currentRate: SweepRate {
        queue.sync { sweepRate }
    }

    public var currentDirection: SweepDirection {
        queue.sync { direction }
    }

    public var loadedCorpus: LoadedCorpus {
        queue.sync { corpus }
    }

    public var recentEvents: [SweepEvent] {
        eventLog.recent()
    }

    public func load(_ loaded: LoadedCorpus) {
        queue.sync {
            corpus = loaded
            scheduler = SweepScheduler(assets: loaded.assets)
            convertedBufferCache.removeAll(keepingCapacity: false)
        }
    }

    public func setSweepRate(_ rate: SweepRate) {
        queue.sync {
            sweepRate = rate
            if running {
                installTimerLocked()
            }
        }
    }

    public func setDirection(_ direction: SweepDirection) {
        queue.sync {
            self.direction = direction
            scheduler.resetTraversal()
        }
    }

    public func start() throws {
        try queue.sync {
            if running {
                stopLocked(deactivateSession: false)
            }
            try startLocked()
        }
    }

    public func stop() {
        queue.sync {
            stopLocked(deactivateSession: true)
        }
    }

    public func startEngineOutputCapture(durationSeconds: Int = EngineOutputCaptureLocator.defaultDurationSeconds) throws {
        try queue.sync {
            guard running else {
                throw CaptureError.sweepNotRunning
            }
            try startCaptureLocked(durationSeconds: durationSeconds)
        }
    }

    public func stopEngineOutputCapture() {
        queue.sync {
            finishCaptureLocked(failed: nil)
        }
    }

    private func startLocked() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setActive(true)

        attachGraphLocked()

        try engine.start()
        fragmentPlayer.play()
        running = true
        installTimerLocked()

        if corpus.assets.isEmpty {
            notifyRuntime("Zero-asset corpus: noise bed only. No fragments will be scheduled.")
        } else if corpus.isDevFixture {
            notifyRuntime("Loaded DEV fixtures. These cannot pass the canonical audio gate.")
        }
    }

    private func stopLocked(deactivateSession: Bool) {
        timer?.cancel()
        timer = nil
        finishCaptureLocked(failed: nil)

        if fragmentPlayer.isPlaying {
            fragmentPlayer.stop()
        }
        if engine.isRunning {
            engine.stop()
        }
        detachGraphLocked()
        engine.reset()
        running = false

        if deactivateSession {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    private func attachGraphLocked() {
        detachGraphLocked()

        let format = AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1)
            ?? engine.mainMixerNode.outputFormat(forBus: 0)
        graphFormat = format
        noiseState.reset()

        let noise = ProceduralNoiseSource.makeNode(format: format, state: noiseState, amplitude: 0.045)
        noiseNode = noise
        fragmentPlayer = AVAudioPlayerNode()

        engine.attach(noise)
        engine.attach(fragmentPlayer)
        engine.connect(noise, to: engine.mainMixerNode, format: format)
        engine.connect(fragmentPlayer, to: engine.mainMixerNode, format: format)
        fragmentPlayer.volume = 0.62
        engine.mainMixerNode.outputVolume = 0.82
    }

    private func detachGraphLocked() {
        if let noiseNode {
            engine.disconnectNodeOutput(noiseNode)
            engine.detach(noiseNode)
            self.noiseNode = nil
        }
        if fragmentPlayer.engine != nil {
            engine.disconnectNodeOutput(fragmentPlayer)
            engine.detach(fragmentPlayer)
        }
    }

    private func installTimerLocked() {
        timer?.cancel()
        let source = DispatchSource.makeTimerSource(queue: queue)
        let interval = sweepRate.timeInterval
        source.schedule(deadline: .now(), repeating: interval, leeway: .milliseconds(2))
        source.setEventHandler { [weak self] in
            self?.tickLocked()
        }
        source.resume()
        timer = source
    }

    private func tickLocked() {
        guard running else { return }
        updateCaptureElapsedLocked()

        switch scheduler.next(direction: direction) {
        case .emptyCorpus:
            return
        case .picked(let pick):
            playLocked(pick)
            let event = SweepEvent(pick: pick, rate: sweepRate, direction: direction, timestamp: Date())
            eventLog.append(event)
            appendCaptureEventLocked(event)
            let callback = onEvent
            DispatchQueue.main.async {
                callback?(event)
            }
        }
    }

    private func playLocked(_ pick: SchedulePick) {
        guard let format = graphFormat else { return }
        guard let url = CorpusLoader.fileURL(for: pick.asset, root: corpus.rootURL) else {
            notifyRuntime("Missing file locator for \(pick.asset.assetID)")
            return
        }
        guard FileManager.default.fileExists(atPath: url.path) else {
            notifyRuntime("Missing audio file for \(pick.asset.assetID)")
            return
        }

        do {
            let converted = try cachedConvertedBufferLocked(assetID: pick.asset.assetID, url: url, format: format)
            let jitter = nextJitterLocked()
            let buffer = FragmentBufferFactory.makeBuffer(
                convertedSource: converted,
                asset: pick.asset,
                sweepRate: sweepRate,
                direction: direction,
                startJitterFraction: jitter
            )
            if fragmentPlayer.engine == nil {
                return
            }
            if !fragmentPlayer.isPlaying {
                fragmentPlayer.play()
            }
            fragmentPlayer.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        } catch {
            notifyRuntime("Fragment play failed for \(pick.asset.assetID): \(error.localizedDescription)")
        }
    }

    private func nextJitterLocked() -> Double {
        jitterSeed = jitterSeed &* 6_364_136_223_846_793_005 &+ 1
        return Double(jitterSeed % 1_000) / 1_000.0
    }

    private func cachedConvertedBufferLocked(assetID: String, url: URL, format: AVAudioFormat) throws -> AVAudioPCMBuffer {
        if let cached = convertedBufferCache[assetID] {
            return cached
        }
        let converted = try FragmentBufferFactory.loadConvertedSource(fileURL: url, outputFormat: format)
        convertedBufferCache[assetID] = converted
        return converted
    }

    private func startCaptureLocked(durationSeconds: Int) throws {
        let mixFormat = engine.mainMixerNode.outputFormat(forBus: 0)
        guard mixFormat.sampleRate > 0, mixFormat.channelCount > 0 else {
            throw CaptureError.engineFormatUnavailable
        }
        if captureTapInstalled {
            engine.mainMixerNode.removeTap(onBus: 0)
            captureTapInstalled = false
        }
        closeCaptureEventFileLocked()

        let url = EngineOutputCaptureLocator.makeFileURL(
            in: EngineOutputCaptureLocator.documentsDirectory()
        )
        try captureWriteQueue.sync {
            try captureWriter.start(url: url, format: mixFormat, durationSeconds: durationSeconds)
        }
        captureTickCounter = 0
        captureActive = true
        try openCaptureEventFileLocked(for: url)

        let writeQueue = captureWriteQueue
        let backpressure = captureBackpressure
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 4096, format: mixFormat) { buffer, _ in
            // Copy samples before returning from the tap. The engine may reuse the
            // original AVAudioPCMBuffer after this callback returns.
            if backpressure.wait(timeout: .now()) != .success {
                return
            }
            guard let copy = PCMBufferIndependentCopy.make(from: buffer) else {
                backpressure.signal()
                return
            }
            writeQueue.async { [weak self] in
                defer { backpressure.signal() }
                self?.handleCaptureBufferOnWriteQueue(copy)
            }
        }
        captureTapInstalled = true

        publishCapture(.capturing(elapsedSeconds: 0, durationSeconds: durationSeconds, url: url))
    }

    private func handleCaptureBufferOnWriteQueue(_ buffer: AVAudioPCMBuffer) {
        do {
            let finished = try captureWriter.write(buffer)
            if finished {
                queue.async { [weak self] in
                    self?.finishCaptureLocked(failed: nil)
                }
            }
        } catch {
            let message = error.localizedDescription
            queue.async { [weak self] in
                self?.finishCaptureLocked(failed: message)
            }
        }
    }

    private func updateCaptureElapsedLocked() {
        guard captureActive else { return }
        let snapshot: (writing: Bool, url: URL?, elapsed: Int, duration: Int) = captureWriteQueue.sync {
            (captureWriter.isWriting, captureWriter.url, captureWriter.elapsedSeconds, captureWriter.durationSeconds)
        }
        guard snapshot.writing, let url = snapshot.url else { return }
        captureTickCounter += 1
        if captureTickCounter % 4 == 0 {
            publishCapture(
                .capturing(
                    elapsedSeconds: snapshot.elapsed,
                    durationSeconds: snapshot.duration,
                    url: url
                )
            )
        }
    }

    private func finishCaptureLocked(failed: String?) {
        guard captureActive || captureTapInstalled else { return }
        captureActive = false
        let stopped = captureWriteQueue.sync {
            captureWriter.stop()
        }
        closeCaptureEventFileLocked()
        if let url = stopped.url {
            writeFullEventLogSnapshotLocked(nextTo: url)
        }
        if captureTapInstalled {
            engine.mainMixerNode.removeTap(onBus: 0)
            captureTapInstalled = false
        }
        if let failed {
            publishCapture(.failed(failed))
        } else if let url = stopped.url {
            publishCapture(.finished(url: url, seconds: stopped.seconds))
        } else {
            publishCapture(.idle)
        }
    }

    private func publishCapture(_ state: EngineOutputCaptureState) {
        let callback = onCaptureStateChange
        DispatchQueue.main.async {
            callback?(state)
        }
    }

    private func openCaptureEventFileLocked(for captureURL: URL) throws {
        let eventsURL = EngineOutputCaptureLocator.makeEventLogURL(forCaptureURL: captureURL)
        FileManager.default.createFile(atPath: eventsURL.path, contents: nil)
        captureEventFileHandle = try FileHandle(forWritingTo: eventsURL)
    }

    private func appendCaptureEventLocked(_ event: SweepEvent) {
        guard let handle = captureEventFileHandle,
              let data = (event.diagnosticJSONLine() + "\n").data(using: .utf8)
        else { return }
        handle.write(data)
    }

    private func writeFullEventLogSnapshotLocked(nextTo captureURL: URL) {
        let snapshotURL = captureURL.deletingPathExtension().appendingPathExtension("eventlog.jsonl")
        let lines = eventLog.allChronological().map { $0.diagnosticJSONLine() }.joined(separator: "\n")
        try? (lines + (lines.isEmpty ? "" : "\n")).write(to: snapshotURL, atomically: true, encoding: .utf8)
    }

    private func closeCaptureEventFileLocked() {
        try? captureEventFileHandle?.close()
        captureEventFileHandle = nil
    }

    private func notifyRuntime(_ message: String) {
        let callback = onRuntimeMessage
        DispatchQueue.main.async {
            callback?(message)
        }
    }

    enum CaptureError: Error, LocalizedError, Equatable {
        case sweepNotRunning
        case engineFormatUnavailable

        var errorDescription: String? {
            switch self {
            case .sweepNotRunning:
                return "START the sweep before capturing engine output."
            case .engineFormatUnavailable:
                return "Engine mix format is not available."
            }
        }
    }
}
