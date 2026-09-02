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

    let audioGateStatus = AudioGateStatus.notYetRunWaitingForPhase1Corpus

    private let engine = SweepAudioEngine()

    init() {
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
        engine.onRuntimeMessage = { [weak self] message in
            Task { @MainActor in
                self?.lastMessage = message
            }
        }

        documentsCorpusPath = CorpusLoader.documentsCorpusURL().path
        captureDirectoryPath = EngineOutputCaptureLocator.directory(
            in: EngineOutputCaptureLocator.documentsDirectory()
        ).path
        filesAppInstruction = CorpusLoader.filesAppCorpusInstruction(
            appDisplayName: Self.resolvedAppDisplayName()
        )
        reloadCorpus()
    }

    func reloadCorpus() {
        let folder = CorpusLoader.ensureDocumentsCorpusDirectory()
        documentsCorpusPath = folder.url.path
        documentsDirectoryExists = folder.directoryExists
        documentsManifestExists = folder.manifestExists
        expectedDocumentsFolderName = CorpusLoader.documentsDirectoryName

        let loaded = CorpusLoader.load()
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

    func stopCapture() {
        engine.stopEngineOutputCapture()
    }

    private func startCapture(seconds: Int) {
        do {
            try engine.startEngineOutputCapture(durationSeconds: seconds)
        } catch {
            captureStatusText = error.localizedDescription
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
            captureStatusText = "Saved engine mix (\(seconds)s): \(url.path)"
        case .failed(let message):
            captureStatusText = "Capture failed: \(message)"
        }
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
