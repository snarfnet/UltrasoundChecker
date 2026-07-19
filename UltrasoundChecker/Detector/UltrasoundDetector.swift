import Foundation
import AVFoundation
import Accelerate

/// Captures microphone audio and runs an FFT to detect ultrasonic energy
/// (18–24 kHz) from mosquito repellers, dog whistles, pest deterrents and
/// ultrasonic beacons. All processing is on-device; nothing is recorded or sent.
final class UltrasoundDetector: NSObject, ObservableObject {
    @Published var isRunning = false
    @Published var permissionDenied = false
    @Published var sampleRate: Double = 48000
    @Published var peakFrequency: Double = 0     // Hz of strongest ultrasonic bin
    @Published var peakLevelDb: Double = -120     // dBFS of that peak
    @Published var ultrasoundDetected = false
    @Published var spectrum: [Float] = []         // downsampled magnitudes for display (0..1)
    @Published var waterfall: [[Float]] = []      // recent spectra, newest last

    /// Ultrasonic band of interest.
    let bandLow: Double = 18000
    let bandHigh: Double = 24000
    private let detectDb: Double = -70            // threshold to call it "detected"

    private let engine = AVAudioEngine()
    private let fftSize = 4096
    private var fft: vDSP.FFT<DSPSplitComplex>?
    private var window = [Float]()
    private let displayBins = 64
    private let waterfallRows = 40

    override init() {
        super.init()
        fft = vDSP.FFT(log2n: vDSP_Length(log2(Double(fftSize))), radix: .radix2, ofType: DSPSplitComplex.self)
        window = [Float](repeating: 0, count: fftSize)
        vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HANN_NORM))
        spectrum = [Float](repeating: 0, count: displayBins)
    }

    func start() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            guard let self else { return }
            DispatchQueue.main.async {
                if granted { self.permissionDenied = false; self.run() }
                else { self.permissionDenied = true }
            }
        }
    }

    private func run() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .measurement, options: [])
        try? session.setActive(true)
        // Ask for the highest sample rate we can get, for maximum Nyquist headroom.
        try? session.setPreferredSampleRate(48000)

        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)
        sampleRate = format.sampleRate

        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: UInt32(fftSize), format: format) { [weak self] buffer, _ in
            self?.process(buffer)
        }

        do {
            try engine.start()
            isRunning = true
        } catch {
            isRunning = false
        }
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        isRunning = false
    }

    private func process(_ buffer: AVAudioPCMBuffer) {
        guard let channel = buffer.floatChannelData?[0] else { return }
        let available = Int(buffer.frameLength)
        guard available >= fftSize, let fft else { return }

        var windowed = [Float](repeating: 0, count: fftSize)
        vDSP_vmul(channel, 1, window, 1, &windowed, 1, vDSP_Length(fftSize))

        let half = fftSize / 2
        var realp = [Float](repeating: 0, count: half)
        var imagp = [Float](repeating: 0, count: half)
        var magnitudes = [Float](repeating: 0, count: half)

        realp.withUnsafeMutableBufferPointer { rp in
            imagp.withUnsafeMutableBufferPointer { ip in
                var split = DSPSplitComplex(realp: rp.baseAddress!, imagp: ip.baseAddress!)
                windowed.withUnsafeBufferPointer { wp in
                    wp.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: half) { cp in
                        vDSP_ctoz(cp, 2, &split, 1, vDSP_Length(half))
                    }
                }
                var outR = [Float](repeating: 0, count: half)
                var outI = [Float](repeating: 0, count: half)
                outR.withUnsafeMutableBufferPointer { orp in
                    outI.withUnsafeMutableBufferPointer { oip in
                        var outSplit = DSPSplitComplex(realp: orp.baseAddress!, imagp: oip.baseAddress!)
                        fft.forward(input: split, output: &outSplit)
                        vDSP_zvabs(&outSplit, 1, &magnitudes, 1, vDSP_Length(half))
                    }
                }
            }
        }

        let binHz = sampleRate / Double(fftSize)
        let scale = 2.0 / Float(fftSize)

        // find peak within the ultrasonic band
        let loBin = max(1, Int(bandLow / binHz))
        let hiBin = min(half - 1, Int(bandHigh / binHz))
        var bestBin = loBin
        var bestMag: Float = 0
        if hiBin > loBin {
            for b in loBin...hiBin where magnitudes[b] > bestMag {
                bestMag = magnitudes[b]; bestBin = b
            }
        }
        let peakDb = 20 * log10(max(bestMag * scale, 1e-9))
        let peakHz = Double(bestBin) * binHz

        // build a display spectrum across the whole audible→ultrasonic range up to Nyquist
        var disp = [Float](repeating: 0, count: displayBins)
        let topBin = half - 1
        for i in 0..<displayBins {
            let start = i * topBin / displayBins + 1
            let end = max(start + 1, (i + 1) * topBin / displayBins)
            var m: Float = 0
            for b in start..<min(end, half) { m = max(m, magnitudes[b]) }
            let db = 20 * log10(max(m * scale, 1e-9))
            disp[i] = Float(max(0, min(1, (Double(db) + 90) / 90)))   // -90..0 dB → 0..1
        }

        DispatchQueue.main.async {
            self.peakFrequency = peakHz
            self.peakLevelDb = Double(peakDb)
            self.ultrasoundDetected = Double(peakDb) > self.detectDb
            self.spectrum = disp
            self.waterfall.append(disp)
            if self.waterfall.count > self.waterfallRows { self.waterfall.removeFirst() }
        }
    }

    func loadDemoState() {
        isRunning = true
        sampleRate = 48000
        peakFrequency = 20500
        peakLevelDb = -48
        ultrasoundDetected = true
        var disp = [Float](repeating: 0, count: displayBins)
        for i in 0..<displayBins {
            let f = Double(i) / Double(displayBins)
            disp[i] = Float(0.15 + 0.1 * sin(f * 12))
        }
        disp[Int(Double(displayBins) * 0.86)] = 0.95
        disp[Int(Double(displayBins) * 0.86) - 1] = 0.7
        spectrum = disp
        waterfall = (0..<waterfallRows).map { r in
            var row = disp
            let jitter = Float(r % 5) * 0.02
            row[Int(Double(displayBins) * 0.86)] = 0.95 - jitter
            return row
        }
    }
}
