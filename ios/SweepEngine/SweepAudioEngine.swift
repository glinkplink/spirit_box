import AVFoundation
import Foundation

/// Offline non-semantic sweep renderer used by the private developer harness.
///
/// Reusable by a later product UI. Does not implement MARK, session recording,
/// commerce, radio, speech recognition, or semantic response logic.
public final class SweepAudioEngine: @unchecked Sendable {
    public var onEvent: ((SweepEvent) -> Void)?
    public var onCaptureStateChange: ((EngineOutputCaptureState) -> Void)?
    public var onAudioGateRunStateChange: ((AudioGateRunState) -> Void)?
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
    private var audioGateRun: ActiveAudioGateRun?

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
            if audioGateRun != nil {
                throw CaptureError.runInProgress
            }
            let documents = try EngineOutputCaptureLocator.documentsDirectory()
            try EngineOutputCaptureLocator.ensureCaptureDirectory(in: documents)
            let url = EngineOutputCaptureLocator.makeFileURL(in: documents)
            try startCaptureLocked(
                durationSeconds: durationSeconds,
                wavURL: url,
                eventsURL: EngineOutputCaptureLocator.makeEventLogURL(forCaptureURL: url)
            )
        }
    }

    public func startAudioGateRun(
        durationSeconds: Int = EngineOutputCaptureLocator.defaultDurationSeconds
    ) throws {
        try queue.sync {
            guard running else {
                throw CaptureError.sweepNotRunning
            }
            if audioGateRun != nil {
                throw CaptureError.runInProgress
            }
            if captureActive {
                finishCaptureLocked(reason: .userStopped)
            }
            try startAudioGateRunLocked(durationSeconds: durationSeconds)
        }
    }

    public func stopEngineOutputCapture() {
        queue.sync {
            finishCaptureLocked(reason: .userStopped)
        }
    }

    public func stopAudioGateRun() {
        stopEngineOutputCapture()
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
        finishCaptureLocked(reason: .userStopped)

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
        fragmentPlayer.volume = 0.88
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

    private func startAudioGateRunLocked(durationSeconds: Int) throws {
        let location: AudioGateRunLocation
        do {
            location = try AudioGateRunLocator.createUniqueRunDirectory(
                in: try AudioGateRunLocator.documentsDirectory()
            )
        } catch {
            let message = error.localizedDescription
            publishAudioGateRun(
                .finalized(
                    runID: "uncreated",
                    completion: .failed,
                    capturedSeconds: 0,
                    durationSeconds: durationSeconds,
                    directoryName: AudioGateRunLocator.directoryName,
                    corpusSource: describeCorpusSource(corpus.source),
                    isDevFixture: corpus.isDevFixture,
                    failureMessage: message
                )
            )
            notifyRuntime("Audio-gate run directory failed: \(message)")
            throw CaptureError.runDirectoryUnavailable(message)
        }

        var listeningNotesError: String?
        do {
            try AudioGateRunBundleWriter.writeListeningNotes(
                to: location.listeningNotesURL,
                runID: location.runID
            )
        } catch {
            listeningNotesError = error.localizedDescription
            notifyRuntime("LISTENING_NOTES.md was not written: \(error.localizedDescription)")
        }

        audioGateRun = ActiveAudioGateRun(
            location: location,
            startedAt: Date(),
            requestedDurationSeconds: durationSeconds,
            startingRate: sweepRate,
            startingDirection: direction,
            corpus: corpus,
            events: [],
            eventLogOpenFailed: false,
            listeningNotesError: listeningNotesError
        )

        do {
            try startCaptureLocked(
                durationSeconds: durationSeconds,
                wavURL: location.wavURL,
                eventsURL: location.eventsURL
            )
        } catch {
            finishCaptureLocked(reason: .failed(error.localizedDescription))
            throw error
        }

        publishAudioGateRun(
            .running(
                runID: location.runID,
                elapsedSeconds: 0,
                durationSeconds: durationSeconds,
                directoryName: location.directoryURL.lastPathComponent,
                corpusSource: describeCorpusSource(corpus.source),
                isDevFixture: corpus.isDevFixture
            )
        )
    }

    /// Reuses `EngineOutputCaptureWriter` with a caller-supplied WAV destination.
    private func startCaptureLocked(durationSeconds: Int, wavURL: URL, eventsURL: URL) throws {
        let mixFormat = engine.mainMixerNode.outputFormat(forBus: 0)
        guard mixFormat.sampleRate > 0, mixFormat.channelCount > 0 else {
            throw CaptureError.engineFormatUnavailable
        }
        if captureTapInstalled {
            engine.mainMixerNode.removeTap(onBus: 0)
            captureTapInstalled = false
        }
        closeCaptureEventFileLocked()

        try captureWriteQueue.sync {
            try captureWriter.start(url: wavURL, format: mixFormat, durationSeconds: durationSeconds)
        }
        captureTickCounter = 0
        captureActive = true

        do {
            try openCaptureEventFileLocked(at: eventsURL)
        } catch {
            if audioGateRun != nil {
                audioGateRun?.eventLogOpenFailed = true
                notifyRuntime("events.jsonl was not opened: \(error.localizedDescription)")
            } else {
                throw error
            }
        }

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

        publishCapture(.capturing(elapsedSeconds: 0, durationSeconds: durationSeconds, url: wavURL))
    }

    private func handleCaptureBufferOnWriteQueue(_ buffer: AVAudioPCMBuffer) {
        do {
            let finished = try captureWriter.write(buffer)
            if finished {
                queue.async { [weak self] in
                    self?.finishCaptureLocked(reason: .durationReached)
                }
            }
        } catch {
            let message = error.localizedDescription
            queue.async { [weak self] in
                self?.finishCaptureLocked(reason: .failed(message))
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
            if let run = audioGateRun {
                publishAudioGateRun(
                    .running(
                        runID: run.location.runID,
                        elapsedSeconds: snapshot.elapsed,
                        durationSeconds: snapshot.duration,
                        directoryName: run.location.directoryURL.lastPathComponent,
                        corpusSource: describeCorpusSource(run.corpus.source),
                        isDevFixture: run.corpus.isDevFixture
                    )
                )
            }
        }
    }

    private func finishCaptureLocked(reason: AudioGateRunFinishReason) {
        guard captureActive || captureTapInstalled || audioGateRun != nil else { return }
        captureActive = false
        let stopped = captureWriteQueue.sync {
            captureWriter.stop()
        }
        closeCaptureEventFileLocked()
        let run = audioGateRun
        audioGateRun = nil
        if run == nil, let url = stopped.url {
            writeFullEventLogSnapshotLocked(nextTo: url)
        }
        if captureTapInstalled {
            engine.mainMixerNode.removeTap(onBus: 0)
            captureTapInstalled = false
        }
        if let run {
            finalizeAudioGateRunLocked(run: run, capturedSeconds: stopped.seconds, reason: reason)
        }
        switch reason {
        case .failed(let message):
            publishCapture(.failed(message))
        case .durationReached, .userStopped:
            if let url = stopped.url {
                if run == nil, let verificationError = CapturePersistenceVerifier.verify(wavURL: url) {
                    publishCapture(.failed(verificationError))
                } else {
                    publishCapture(.finished(url: url, seconds: stopped.seconds))
                }
            } else {
                publishCapture(.idle)
            }
        }
    }

    private func finalizeAudioGateRunLocked(
        run: ActiveAudioGateRun,
        capturedSeconds: Int,
        reason: AudioGateRunFinishReason
    ) {
        var reportingParts: [String] = []
        if run.eventLogOpenFailed {
            reportingParts.append("events.jsonl could not be opened")
        }
        if let listeningNotesError = run.listeningNotesError {
            reportingParts.append("LISTENING_NOTES.md: \(listeningNotesError)")
        }

        let endedAt = Date()
        var completion = AudioGateRunCompletionResolver.resolve(
            reason: reason,
            reportingError: reportingParts.isEmpty ? nil : reportingParts.joined(separator: "; ")
        )
        let failureMessage = AudioGateRunCompletionResolver.failureMessage(
            reason: reason,
            reportingError: reportingParts.isEmpty ? nil : reportingParts.joined(separator: "; ")
        )

        let summary = AudioGateRunSummary.make(
            runID: run.location.runID,
            startedAt: run.startedAt,
            endedAt: endedAt,
            requestedDurationSeconds: run.requestedDurationSeconds,
            capturedDurationSeconds: capturedSeconds,
            completion: completion,
            failureMessage: failureMessage,
            corpus: run.corpus,
            startingSweepRate: run.startingRate,
            startingDirection: run.startingDirection,
            events: run.events
        )

        do {
            try AudioGateRunBundleWriter.writeSummaries(summary, location: run.location)
        } catch {
            reportingParts.append("summary write: \(error.localizedDescription)")
            completion = AudioGateRunCompletionResolver.resolve(
                reason: reason,
                reportingError: reportingParts.joined(separator: "; ")
            )
            notifyRuntime("Audio-gate summary write issue: \(error.localizedDescription)")
        }

        let publishedFailure = AudioGateRunCompletionResolver.failureMessage(
            reason: reason,
            reportingError: reportingParts.isEmpty ? nil : reportingParts.joined(separator: "; ")
        )
        if completion == .failed {
            notifyRuntime(publishedFailure.map { "Audio-gate run failed: \($0)" } ?? "Audio-gate run failed.")
        }

        publishAudioGateRun(
            .finalized(
                runID: run.location.runID,
                completion: completion,
                capturedSeconds: capturedSeconds,
                durationSeconds: run.requestedDurationSeconds,
                directoryName: run.location.directoryURL.lastPathComponent,
                corpusSource: describeCorpusSource(run.corpus.source),
                isDevFixture: run.corpus.isDevFixture,
                failureMessage: publishedFailure
            )
        )
    }

    private func publishCapture(_ state: EngineOutputCaptureState) {
        let callback = onCaptureStateChange
        DispatchQueue.main.async {
            callback?(state)
        }
    }

    private func publishAudioGateRun(_ state: AudioGateRunState) {
        let callback = onAudioGateRunStateChange
        DispatchQueue.main.async {
            callback?(state)
        }
    }

    private func describeCorpusSource(_ source: CorpusSource) -> String {
        switch source {
        case .documentsPhase1:
            return "Documents/SpiritBoxPhase1Corpus"
        case .bundlePhase1:
            return "Bundle/Phase1"
        case .bundleDevFixtures:
            return "Bundle/DevFixtures"
        case .empty:
            return "none"
        }
    }

    private func openCaptureEventFileLocked(at eventsURL: URL) throws {
        FileManager.default.createFile(atPath: eventsURL.path, contents: nil)
        captureEventFileHandle = try FileHandle(forWritingTo: eventsURL)
    }

    private func appendCaptureEventLocked(_ event: SweepEvent) {
        if audioGateRun != nil {
            audioGateRun?.events.append(event)
        }
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
        case runInProgress
        case runDirectoryUnavailable(String)

        var errorDescription: String? {
            switch self {
            case .sweepNotRunning:
                return "START the sweep before capturing engine output."
            case .engineFormatUnavailable:
                return "Engine mix format is not available."
            case .runInProgress:
                return "An audio-gate run is already in progress. Stop the run before starting another capture."
            case .runDirectoryUnavailable(let message):
                return message
            }
        }
    }

    private struct ActiveAudioGateRun {
        var location: AudioGateRunLocation
        var startedAt: Date
        var requestedDurationSeconds: Int
        var startingRate: SweepRate
        var startingDirection: SweepDirection
        var corpus: LoadedCorpus
        var events: [SweepEvent]
        var eventLogOpenFailed: Bool
        var listeningNotesError: String?
    }
}
