import SwiftUI

struct AnalyzerScreen: View {
    @ObservedObject var detector: UltrasoundDetector

    var body: some View {
        ZStack {
            Retro.bg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    header
                    statusPanel
                    spectrumPanel
                    waterfallPanel
                    readouts
                    nyquistNote
                    warningBar
                    startButton
                }
                .padding()
            }
        }
    }

    private var header: some View {
        HStack {
            Text(L("超音波チェッカー", "Ultrasound Checker"))
                .font(.title2.bold())
                .foregroundStyle(Retro.dial)
            Spacer()
            Circle()
                .fill(detector.isRunning ? Retro.lcd : Retro.lcdDim)
                .frame(width: 12, height: 12)
                .shadow(color: detector.isRunning ? Retro.lcd : .clear, radius: 6)
        }
    }

    private var statusPanel: some View {
        VStack(spacing: 8) {
            Text(detector.ultrasoundDetected
                 ? L("超音波を検出", "Ultrasound detected")
                 : L("超音波なし", "No ultrasound"))
                .font(.title3.bold())
                .foregroundStyle(detector.ultrasoundDetected ? Retro.hot : Retro.lcdDim)
            if detector.ultrasoundDetected {
                Text(String(format: "%.1f kHz", detector.peakFrequency / 1000))
                    .font(.system(size: 44, weight: .bold, design: .monospaced))
                    .foregroundStyle(Retro.lcd)
                    .shadow(color: Retro.lcd.opacity(0.5), radius: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Retro.panel)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var spectrumPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("スペクトル", "Spectrum"))
                .font(.caption).foregroundStyle(Retro.lcdDim)
            SpectrumView(spectrum: detector.spectrum, sampleRate: detector.sampleRate,
                         bandLow: detector.bandLow, bandHigh: detector.bandHigh)
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            HStack {
                Text("0")
                Spacer()
                Text(String(format: "%.0f kHz", detector.sampleRate / 2000))
            }
            .font(.caption2).foregroundStyle(Retro.lcdDim)
        }
        .padding()
        .background(Retro.panel)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var waterfallPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("ウォーターフォール", "Waterfall"))
                .font(.caption).foregroundStyle(Retro.lcdDim)
            WaterfallView(rows: detector.waterfall)
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(Retro.panel)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var readouts: some View {
        HStack(spacing: 12) {
            readout(L("ピーク", "PEAK"), String(format: "%.1f", detector.peakFrequency / 1000), "kHz")
            readout(L("レベル", "LEVEL"), String(format: "%.0f", detector.peakLevelDb), "dB")
        }
    }

    private func readout(_ title: String, _ value: String, _ unit: String) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption2).foregroundStyle(Retro.lcdDim)
            Text(value)
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .foregroundStyle(Retro.lcd)
            Text(unit).font(.caption2).foregroundStyle(Retro.lcdDim)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Retro.bg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var nyquistNote: some View {
        Text(L("この端末のマイクは最大 \(String(format: "%.0f", detector.sampleRate / 2000)) kHz まで解析できます。",
               "This device's mic can analyze up to \(String(format: "%.0f", detector.sampleRate / 2000)) kHz."))
            .font(.caption)
            .foregroundStyle(Retro.lcdDim)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var warningBar: some View {
        if detector.permissionDenied {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                Text(L("マイクを許可してください", "Please allow microphone access"))
            }
            .foregroundStyle(Retro.amber)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Retro.amber.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var startButton: some View {
        Button {
            if detector.isRunning { detector.stop() } else { detector.start() }
        } label: {
            Text(detector.isRunning ? L("停止", "Stop") : L("計測開始", "Start"))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(detector.isRunning ? Color(red: 0.6, green: 0.2, blue: 0.2) : Retro.needle)
                .foregroundStyle(detector.isRunning ? .white : Retro.bg)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
