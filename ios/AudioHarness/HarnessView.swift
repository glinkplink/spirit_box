import SwiftUI

/// Private developer UI. Intentionally not the customer-facing instrument.
struct HarnessView: View {
    @StateObject private var model = HarnessViewModel()

    var body: some View {
        NavigationStack {
            List {
                gateSection
                transportSection
                rateSection
                directionSection
                corpusSection
                nowSection
                captureSection
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
            LabeledContent("Asset count", value: "\(model.corpusCount)")
            LabeledContent("Skipped malformed", value: "\(model.skippedMalformedCount)")
            LabeledContent("Source", value: model.corpusSourceDescription)
            Text(model.corpusLabel)
            if model.isDevFixtureCorpus {
                Text("DEV / TEST ONLY — synthetic fixtures, not Phase 1 human source")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
            Text("Drop Phase 1 here:\n\(model.documentsCorpusPath)")
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
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
            Text("Files:\n\(model.captureDirectoryPath)")
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
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
