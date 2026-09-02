import Combine
import Foundation

@MainActor
final class HarnessViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var sweepRate: SweepRate = .default
    @Published var direction: SweepDirection = .forward
    @Published var corpusCount = 0
    @Published var skippedMalformedCount = 0
    @Published var corpusLabel = "No corpus loaded"
    @Published var corpusSourceDescription = ""
    @Published var isDevFixtureCorpus = true
    @Published var currentAssetID: String?
    @Published var currentVoiceFamily: String?
    @Published var events: [SweepEvent] = []
    @Published var captureStatusText = "Idle — engine mix only, not microphone / session recording"
    @Published var lastMessage: String?
    @Published var documentsCorpusPath = ""
    @Published var documentsDirectoryExists = false
    @Published var documentsManifestExists = false
    @Published var expectedDocumentsFolderName = CorpusLoader.documentsDirectoryName
    @Published var filesAppInstruction = ""
    @Published var captureDirectoryPath = ""
    @Published var audioGateRunState: AudioGateRunState = .idle
    @Published var audioGateRunsDirectoryPath = ""
    @Published var audioGateFilesInstruction = ""

    @Published var documentsAvailable = false
    @Published var filesSharingExpected = false
    @Published var engineOutputCapturesExists = false
    @Published var harnessFilesTxtExists = false
    @Published var lastCaptureFilename = "none"
    @Published var lastCaptureExists = false
    @Published var lastCaptureSize = "—"
    @Published var filesLocationInstruction = ""
    @Published var documentsDebugPath = ""

    let audioGateStatus = AudioGateStatus.notYetRunWaitingForPhase1Corpus

    private let engine = SweepAudioEngine()
    private let appDisplayName: String

    init() {
        appDisplayName = Self.resolvedAppDisplayName()
        filesSharingExpected = HarnessDocuments.filesSharingConfigured()

        engine.onEvent = { [weak self] event in
            Task { @MainActor in
                self?.handle(event)
            }
        }
        engine.onCaptureStateChange = { [weak self] state in
            Task { @MainActor in
                self?.handleCapture(state)
            }
        }
        engine.onAudioGateRunStateChange = { [weak self] state in
            Task { @MainActor in
                self?.audioGateRunState = state
            }
        }
        engine.onRuntimeMessage = { [weak self] message in
            Task { @MainActor in
                self?.lastMessage = message
            }
        }

        filesAppInstruction = CorpusLoader.filesAppCorpusInstruction(appDisplayName: appDisplayName)
        audioGateFilesInstruction = AudioGateRunLocator.filesAppInstruction(appDisplayName: appDisplayName)
        filesLocationInstruction = HarnessDocuments.filesAppCaptureInstruction(appDisplayName: appDisplayName)

        bootstrapStorage()
        reloadCorpus()
    }

    func reloadCorpus() {
        do {
            let folder = try CorpusLoader.ensureDocumentsCorpusDirectory()
            documentsCorpusPath = folder.url.path
            documentsDirectoryExists = folder.directoryExists
            documentsManifestExists = folder.manifestExists
            expectedDocumentsFolderName = CorpusLoader.documentsDirectoryName

            let loaded = try CorpusLoader.load()
            engine.load(loaded)
            corpusCount = loaded.assetCount
            skippedMalformedCount = loaded.skippedMalformedCount
            corpusLabel = loaded.label
            isDevFixtureCorpus = loaded.isDevFixture
            corpusSourceDescription = Self.describe(loaded.source)
            if let diagnostic = folder.diagnostic {
                lastMessage = diagnostic
            } else if loaded.assetCount == 0 {
                lastMessage = "Zero assets. START will run the noise bed only."
            } else {
                lastMessage = nil
            }
            refreshStorageDiagnostics()
        } catch {
            lastMessage = "Corpus reload failed: \(error.localizedDescription)"
            refreshStorageDiagnostics()
        }
    }

    func prepareCorpusUpload() -> Bool {
        if isRunning {
            lastMessage = "Stop the sweep before uploading a corpus."
            return false
        }
        return true
    }

    func importCorpus(from urls: [URL]) {
        var scoped: [URL] = []
        for url in urls where url.startAccessingSecurityScopedResource() {
            scoped.append(url)
        }
        defer {
            scoped.forEach { $0.stopAccessingSecurityScopedResource() }
        }

        do {
            let destination = try CorpusLoader.documentsCorpusURL()
            _ = try CorpusLoader.ensureDocumentsCorpusDirectory(at: destination)
            let result = try CorpusImporter.importItems(urls: urls, into: destination)
            reloadCorpus()
            if engine.loadedCorpus.source == .documentsPhase1 {
                lastMessage = "Loaded \(corpusCount) assets from \(result.wavCount) WAV files. Tap Start 20-minute test when ready."
            } else {
                lastMessage = "Corpus files were copied, but the Documents corpus did not activate. Check manifest.json and reload."
            }
        } catch {
            lastMessage = "Corpus upload failed: \(error.localizedDescription)"
        }
    }

    func start() {
        do {
            try engine.start()
            isRunning = true
            lastMessage = corpusCount == 0
                ? "Sweep running with an empty corpus (noise only)."
                : nil
        } catch {
            isRunning = false
            lastMessage = "START failed: \(error.localizedDescription)"
        }
    }

    func stop() {
        engine.stop()
        isRunning = false
    }

    func applySweepRate(_ rate: SweepRate) {
        sweepRate = rate
        engine.setSweepRate(rate)
    }

    func applyDirection(_ direction: SweepDirection) {
        self.direction = direction
        engine.setDirection(direction)
    }

    func startTwoMinuteCapture() {
        startCapture(seconds: EngineOutputCaptureLocator.defaultDurationSeconds)
    }

    func startTwentyMinuteCapture() {
        startCapture(seconds: EngineOutputCaptureLocator.manualEvaluationDurationSeconds)
    }

    func startTwoMinuteSmokeRun() {
        startAudioGateRun(seconds: EngineOutputCaptureLocator.defaultDurationSeconds)
    }

    func startTwentyMinuteEvaluationRun() {
        startAudioGateRun(seconds: EngineOutputCaptureLocator.manualEvaluationDurationSeconds)
    }

    func stopAudioGateRun() {
        engine.stopAudioGateRun()
    }

    func stopCapture() {
        engine.stopEngineOutputCapture()
    }

    private func bootstrapStorage() {
        do {
            _ = try HarnessDocuments.bootstrap()
            refreshStorageDiagnostics()
        } catch {
            documentsAvailable = false
            lastMessage = error.localizedDescription
        }
    }

    private func refreshStorageDiagnostics() {
        let fileManager = FileManager.default
        filesSharingExpected = HarnessDocuments.filesSharingConfigured()

        do {
            let documents = try HarnessDocuments.resolve(fileManager: fileManager)
            documentsAvailable = true
            documentsDebugPath = documents.path
            captureDirectoryPath = EngineOutputCaptureLocator.directory(in: documents).path
            audioGateRunsDirectoryPath = AudioGateRunLocator.directory(in: documents).path

            let captureDirectory = EngineOutputCaptureLocator.directory(in: documents)
            var isDirectory: ObjCBool = false
            engineOutputCapturesExists = fileManager.fileExists(atPath: captureDirectory.path, isDirectory: &isDirectory)
                && isDirectory.boolValue

            let sentinelURL = try HarnessDocuments.harnessFilesTxtURL(fileManager: fileManager)
            harnessFilesTxtExists = fileManager.fileExists(atPath: sentinelURL.path)
        } catch {
            documentsAvailable = false
            documentsDebugPath = ""
            engineOutputCapturesExists = false
            harnessFilesTxtExists = false
        }
    }

    private func startCapture(seconds: Int) {
        do {
            try engine.startEngineOutputCapture(durationSeconds: seconds)
        } catch {
            captureStatusText = error.localizedDescription
        }
    }

    private func startAudioGateRun(seconds: Int) {
        if !isRunning {
            start()
            guard isRunning else { return }
        }
        do {
            try engine.startAudioGateRun(durationSeconds: seconds)
        } catch {
            lastMessage = "Audio-gate run failed to start: \(error.localizedDescription)"
        }
    }

    private func handle(_ event: SweepEvent) {
        currentAssetID = event.assetID
        currentVoiceFamily = event.voiceFamily ?? event.performerID
        events.insert(event, at: 0)
        if events.count > 200 {
            events.removeLast(events.count - 200)
        }
    }

    private func handleCapture(_ state: EngineOutputCaptureState) {
        switch state {
        case .idle:
            captureStatusText = "Idle — engine mix only, not microphone / session recording"
        case .capturing(let elapsed, let duration, let url):
            captureStatusText = "Capturing engine mix \(elapsed)s / \(duration)s → \(url.lastPathComponent)"
        case .finished(let url, let seconds):
            lastCaptureFilename = url.lastPathComponent
            if let verificationError = CapturePersistenceVerifier.verify(wavURL: url) {
                lastCaptureExists = false
                lastCaptureSize = "—"
                captureStatusText = "Capture failed: \(verificationError)"
            } else {
                lastCaptureExists = true
                lastCaptureSize = Self.formatByteCount(at: url)
                captureStatusText = "Saved engine mix (\(seconds)s): \(url.lastPathComponent)"
            }
            refreshStorageDiagnostics()
        case .failed(let message):
            captureStatusText = "Capture failed: \(message)"
            refreshStorageDiagnostics()
        }
    }

    private static func formatByteCount(at url: URL) -> String {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attributes[.size] as? NSNumber else {
            return "—"
        }
        return ByteCountFormatter.string(fromByteCount: size.int64Value, countStyle: .file)
    }

    private static func describe(_ source: CorpusSource) -> String {
        switch source {
        case .documentsPhase1:
            return "Documents/SpiritBoxPhase1Corpus"
        case .bundlePhase1:
            return "Bundle/Phase1"
        case .bundleDevFixtures:
            return "Bundle/DevFixtures (DEV / TEST ONLY)"
        case .empty:
            return "none"
        }
    }

    private static func resolvedAppDisplayName() -> String {
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        return "Audio Harness"
    }
}
