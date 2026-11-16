import SwiftUI

struct ActiveRideView: View {
    @EnvironmentObject private var app: AppEnvironment
    @EnvironmentObject private var capture: RideCaptureService
    @Environment(\.dismiss) private var dismiss

    @State private var incident: Incident?
    @State private var endBusy = false
    @State private var lockBusy = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(capture.isRecording ? RidaryTheme.danger : RidaryTheme.textTertiary)
                            .frame(width: 9, height: 9)
                        Text(capture.isRecording ? "Ride in progress" : "Ride stopped")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                    }
                    Spacer()
                    Button("Minimize") {
                        dismiss()
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(RidaryTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(RidaryFormatters.duration(seconds: capture.elapsedS))
                        .font(.system(size: 58, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("elapsed")
                        .font(.footnote)
                        .foregroundStyle(RidaryTheme.textSecondary)
                }

                Text(RidaryFormatters.speed(kph: capture.currentSpeedKph))
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundStyle(RidaryTheme.accent)

                HStack(spacing: 10) {
                    StatTile(
                        icon: "point.topleft.down.to.point.bottomright.curvepath",
                        value: RidaryFormatters.distance(meters: capture.distanceM),
                        label: "distance"
                    )
                    StatTile(
                        icon: "exclamationmark.triangle",
                        value: "\(capture.eventCount)",
                        label: "moments",
                        tint: RidaryTheme.warning
                    )
                    StatTile(
                        icon: "waveform.path.ecg",
                        value: "\(capture.sampleCount)",
                        label: "samples"
                    )
                }

                if let lastEventTitle = capture.lastEventTitle {
                    HStack(spacing: 8) {
                        Image(systemName: "flag.fill")
                            .foregroundStyle(RidaryTheme.warning)
                        Text("Last flag: \(lastEventTitle)")
                            .font(.footnote)
                            .foregroundStyle(RidaryTheme.textSecondary)
                    }
                }

                if let error = capture.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(RidaryTheme.warning)
                }

                if let error = app.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(RidaryTheme.warning)
                }

                VStack(spacing: 12) {
                    Button {
                        Task {
                            lockBusy = true
                            if let created = await app.createIncident() {
                                incident = created
                            }
                            lockBusy = false
                        }
                    } label: {
                        if lockBusy {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Label("Lock last 30 seconds", systemImage: "lock.shield.fill")
                        }
                    }
                    .buttonStyle(RidaryPrimaryButtonStyle(tint: RidaryTheme.teal))
                    .disabled(lockBusy || !capture.isRecording)

                    Button {
                        Task {
                            endBusy = true
                            _ = await app.stopRide()
                            endBusy = false
                            dismiss()
                        }
                    } label: {
                        if endBusy {
                            ProgressView()
                        } else {
                            Text("End ride")
                        }
                    }
                    .buttonStyle(RidarySecondaryButtonStyle())
                    .disabled(endBusy)
                }

                Text("Locking preserves a private evidence window on this device. Nothing is uploaded unless you choose to share it.")
                    .font(.caption2)
                    .foregroundStyle(RidaryTheme.textTertiary)
            }
            .padding(20)
        }
        .background(RidaryTheme.background.ignoresSafeArea())
        .onAppear {
            capture.refreshElapsed()
        }
        .sheet(item: $incident) { created in
            NavigationStack {
                IncidentView(incident: created)
            }
        }
    }
}
