import SwiftUI
import UniformTypeIdentifiers

/// Private developer UI. Intentionally not the customer-facing instrument.
struct HarnessView: View {
    @StateObject private var model = HarnessViewModel()
    @State private var isUploadingCorpus = false

    var body: some View {
        NavigationStack {
            List {
                gateSection
                transportSection
                rateSection
                directionSection
                corpusSection
                nowSection
                audioGateRunSection
                captureSection
                storageDiagnosticsSection
                logSection
            }
            .navigationTitle("Audio Harness")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reload corpus") {
                        model.reloadCorpus()
                    }
                }
            }
            .fileImporter(
                isPresented: $isUploadingCorpus,
                allowedContentTypes: [.folder, .wav, .json],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    model.importCorpus(from: urls)
                case .failure(let error):
                    model.lastMessage = "Corpus upload failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private var gateSection: some View {
        Section("Canonical audio gate") {
            Text(model.audioGateStatus)
                .font(.body.weight(.semibold))
            Text("Dev fixtures exist only to exercise plumbing. They cannot pass the 15–20 minute product gate.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var transportSection: some View {
        Section("Transport") {
            HStack {
                Button(model.isRunning ? "STOP" : "START") {
                    if model.isRunning {
                        model.stop()
                    } else {
                        model.start()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(model.isRunning ? .red : .green)

                Spacer()
                Text(model.isRunning ? "RUNNING" : "STOPPED")
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(model.isRunning ? .green : .secondary)
            }
            if let message = model.lastMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
        }
    }

    private var rateSection: some View {
        Section("Sweep rate") {
            Picker("Sweep rate", selection: rateBinding) {
                ForEach(SweepRate.allCases, id: \.self) { rate in
                    Text("\(rate.milliseconds) ms").tag(rate)
                }
            }
            .pickerStyle(.segmented)
            Text("Current cadence: \(model.sweepRate.milliseconds) ms")
                .font(.system(.footnote, design: .monospaced))
        }
    }

    private var directionSection: some View {
        Section("Traversal direction") {
            Picker("Direction", selection: directionBinding) {
                Text("FWD").tag(SweepDirection.forward)
                Text("REV").tag(SweepDirection.reverse)
            }
            .pickerStyle(.segmented)
            Text("Current: \(model.direction.debugLabel) — ordered walk through eligible assets")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var corpusSection: some View {
        Section("Corpus") {
            Button("Upload corpus") {
                isUploadingCorpus = model.prepareCorpusUpload()
            }
            Text("Pick the prepared SpiritBoxPhase1Corpus folder, or manifest.json plus the WAV files. This replaces Documents/SpiritBoxPhase1Corpus.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            LabeledContent("Source", value: model.corpusSourceDescription)
            LabeledContent("Asset count", value: "\(model.corpusCount)")
            LabeledContent("Skipped malformed", value: "\(model.skippedMalformedCount)")
            LabeledContent("Documents folder exists", value: model.documentsDirectoryExists ? "yes" : "no")
            LabeledContent("manifest.json exists", value: model.documentsManifestExists ? "yes" : "no")
            LabeledContent("Expected folder", value: model.expectedDocumentsFolderName)
            Text(model.corpusLabel)
            if model.isDevFixtureCorpus {
                Text("DEV / TEST ONLY — synthetic fixtures, not Phase 1 human source")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
            Text(model.filesAppInstruction)
                .font(.footnote)
            Text("Copy the complete Phase 1 folder contents there (manifest.json + WAV files), or tap Upload corpus. Files shows the app display name; it may differ from the internal target name.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var nowSection: some View {
        Section("Last scheduled fragment") {
            LabeledContent("Asset") {
                Text(model.currentAssetID ?? "—")
                    .font(.system(.body, design: .monospaced))
            }
            LabeledContent("Voice family") {
                Text(model.currentVoiceFamily ?? "—")
                    .font(.system(.body, design: .monospaced))
            }
        }
    }

    private var audioGateRunSection: some View {
        Section("AUDIO GATE RUN") {
            Text("Creates a Documents/AudioGateRuns bundle (WAV, events, summaries, listening notes). Diagnostic only — this does not decide the canonical audio gate.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            if model.isDevFixtureCorpus {
                Text("ENGINEERING ONLY — DEV FIXTURES CANNOT PASS THE AUDIO GATE")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.orange)
            }
            Button("2-minute smoke run") {
                model.startTwoMinuteSmokeRun()
            }
            Text("Exercises the full bundle-generation pathway. Usable with DevFixtures.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button("Start 20-minute test") {
                model.startTwentyMinuteEvaluationRun()
            }
            Text(
                model.isDevFixtureCorpus
                    ? "A 20-minute DevFixtures run is not a canonical gate attempt."
                    : "Starts the sweep automatically and produces the full artifact set for the listening procedure."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
            Button("Stop run early") {
                model.stopAudioGateRun()
            }
            audioGateRunStatusBlock
            Text(model.audioGateFilesInstruction)
                .font(.footnote)
            Text("Retrieve the run folder there. Do not rely on a container UUID path.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var audioGateRunStatusBlock: some View {
        switch model.audioGateRunState {
        case .idle:
            LabeledContent("Run status", value: "idle")
        case .running(let runID, let elapsed, let duration, let directoryName, let corpusSource, let isDevFixture):
            LabeledContent("Run status", value: "running")
            LabeledContent("Run ID", value: runID)
            LabeledContent("Elapsed / requested", value: "\(elapsed)s / \(duration)s")
            LabeledContent("Corpus source", value: corpusSource)
            LabeledContent("Artifact folder", value: directoryName)
            if isDevFixture {
                Text("ENGINEERING ONLY — DEV FIXTURES CANNOT PASS THE AUDIO GATE")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.orange)
            }
        case .finalized(let runID, let completion, let captured, let duration, let directoryName, let corpusSource, let isDevFixture, let failureMessage):
            LabeledContent("Run status", value: completion.rawValue)
            LabeledContent("Run ID", value: runID)
            LabeledContent("Elapsed / requested", value: "\(captured)s / \(duration)s")
            LabeledContent("Corpus source", value: corpusSource)
            LabeledContent("Artifact folder", value: directoryName)
            if let failureMessage {
                Text(failureMessage)
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
            if isDevFixture {
                Text("ENGINEERING ONLY — DEV FIXTURES CANNOT PASS THE AUDIO GATE")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.orange)
            }
        }
        Text(model.audioGateRunsDirectoryPath)
            .font(.system(.caption, design: .monospaced))
            .textSelection(.enabled)
    }

    private var captureSection: some View {
        Section("Engine output capture") {
            Text("Captures the rendered mix (noise + fragments). This is not customer session / microphone recording.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button("Capture final mix (2 min)") {
                model.startTwoMinuteCapture()
            }
            Button("Capture final mix (20 min, manual gate)") {
                model.startTwentyMinuteCapture()
            }
            Button("Stop capture") {
                model.stopCapture()
            }
            Text(model.captureStatusText)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
            Text("Files → \(model.filesLocationInstruction)")
                .font(.footnote)
        }
    }

    private var storageDiagnosticsSection: some View {
        Section("Storage diagnostics") {
            LabeledContent("Documents available", value: model.documentsAvailable ? "YES" : "NO")
            LabeledContent("Files sharing expected", value: model.filesSharingExpected ? "YES" : "NO")
            LabeledContent("EngineOutputCaptures exists", value: model.engineOutputCapturesExists ? "YES" : "NO")
            LabeledContent("HARNESS_FILES.txt exists", value: model.harnessFilesTxtExists ? "YES" : "NO")
            LabeledContent("Last capture", value: model.lastCaptureFilename)
            LabeledContent("Last capture exists", value: model.lastCaptureExists ? "YES" : "NO")
            LabeledContent("Last capture size", value: model.lastCaptureSize)
            Text("Files location:")
                .font(.footnote)
            Text("Files → \(model.filesLocationInstruction)")
                .font(.footnote)
            if !model.documentsDebugPath.isEmpty {
                Text(model.documentsDebugPath)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
    }

    private var logSection: some View {
        Section("Event log") {
            if model.events.isEmpty {
                Text("No fragment events yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(model.events) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.assetID)
                            .font(.system(.caption, design: .monospaced).weight(.semibold))
                        Text(event.debugLine)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var rateBinding: Binding<SweepRate> {
        Binding(
            get: { model.sweepRate },
            set: { model.applySweepRate($0) }
        )
    }

    private var directionBinding: Binding<SweepDirection> {
        Binding(
            get: { model.direction },
            set: { model.applyDirection($0) }
        )
    }
}
