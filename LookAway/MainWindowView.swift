import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject var timerManager: TimerManager

    @State private var workMinutes: Double = 20
    @State private var breakSeconds: Double = 20

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(spacing: 24) {
                    timerRing
                    settingsCard
                    actionButtons
                }
                .padding(24)
            }
        }
        .frame(width: 340)
        .background(Color(.windowBackgroundColor))
        .onAppear {
            workMinutes = timerManager.workInterval / 60
            breakSeconds = timerManager.breakDuration
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "eye.circle.fill")
                .font(.title2)
                .foregroundColor(.accentColor)
            Text("Look Away")
                .font(.headline)
            Spacer()
            statusBadge
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var statusBadge: some View {
        let (label, color): (String, Color) = timerManager.isOnBreak
            ? ("Break", .orange)
            : (timerManager.isRunning ? "Active" : "Paused", timerManager.isRunning ? .green : .secondary)

        return Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    // MARK: Timer Ring

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.15), lineWidth: 10)
                .frame(width: 170, height: 170)

            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(ringColor,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 170, height: 170)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timerManager.workTimeRemaining)
                .animation(.linear(duration: 1), value: timerManager.breakTimeRemaining)

            VStack(spacing: 4) {
                Text(timerManager.isOnBreak ? "BREAK" : (timerManager.isRunning ? "WORKING" : "PAUSED"))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .kerning(1.5)

                Text(timerManager.isOnBreak
                     ? "\(Int(timerManager.breakTimeRemaining))s"
                     : timerManager.formattedWorkTime)
                    .font(.system(size: 38, weight: .thin, design: .monospaced))
                    .foregroundColor(.primary)

                if !timerManager.isOnBreak {
                    Text("until break")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.top, 8)
    }

    private var ringProgress: CGFloat {
        if timerManager.isOnBreak {
            return timerManager.breakDuration > 0
                ? CGFloat(timerManager.breakProgress) : 0
        }
        let total = timerManager.workInterval
        guard total > 0 else { return 0 }
        return CGFloat(1 - timerManager.workTimeRemaining / total)
    }

    private var ringColor: Color {
        timerManager.isOnBreak ? .orange : .accentColor
    }

    // MARK: Settings Card

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("Settings", systemImage: "slider.horizontal.3")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)

            // Work interval
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Work interval")
                        .font(.callout)
                    Spacer()
                    Text("\(Int(workMinutes)) min")
                        .font(.callout.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                Slider(value: $workMinutes, in: 1...60, step: 1) { editing in
                    if !editing {
                        timerManager.workInterval = workMinutes * 60
                    }
                }
                .accentColor(.accentColor)
            }

            // Break duration
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Break duration")
                        .font(.callout)
                    Spacer()
                    Text("\(Int(breakSeconds)) sec")
                        .font(.callout.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                Slider(value: $breakSeconds, in: 5...120, step: 5) { editing in
                    if !editing {
                        timerManager.breakDuration = breakSeconds
                    }
                }
                .accentColor(.orange)
            }

            Divider()

            Toggle(isOn: $timerManager.soundEnabled) {
                Label("Sound at break", systemImage: "speaker.wave.2")
                    .font(.callout)
            }
        }
        .padding(16)
        .background(Color(.controlBackgroundColor).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button(timerManager.isRunning && !timerManager.isOnBreak ? "Pause" : "Resume") {
                    if timerManager.isRunning && !timerManager.isOnBreak {
                        timerManager.pause()
                    } else {
                        timerManager.start()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button("Reset Timer") {
                    timerManager.reset()
                    workMinutes = timerManager.workInterval / 60
                    breakSeconds = timerManager.breakDuration
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .frame(maxWidth: .infinity)

            Button("Preview Break Screen") {
                timerManager.triggerBreak()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 8)
    }
}
