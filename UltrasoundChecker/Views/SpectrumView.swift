import SwiftUI

/// Live bar spectrum. The ultrasonic band (18–24 kHz) is highlighted.
struct SpectrumView: View {
    var spectrum: [Float]
    var sampleRate: Double
    var bandLow: Double
    var bandHigh: Double

    var body: some View {
        GeometryReader { geo in
            let n = max(spectrum.count, 1)
            let barW = geo.size.width / CGFloat(n)
            let nyquist = sampleRate / 2
            ZStack(alignment: .bottomLeading) {
                // ultrasonic band highlight
                let x0 = geo.size.width * CGFloat(bandLow / nyquist)
                let x1 = geo.size.width * CGFloat(min(bandHigh, nyquist) / nyquist)
                Rectangle()
                    .fill(Retro.lcd.opacity(0.08))
                    .frame(width: max(0, x1 - x0))
                    .offset(x: x0)

                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(0..<n, id: \.self) { i in
                        let v = CGFloat(spectrum[i])
                        Rectangle()
                            .fill(Retro.level(Double(spectrum[i])))
                            .frame(width: max(1, barW - 1), height: max(1, v * geo.size.height))
                    }
                }
            }
            .background(Retro.bg)
        }
    }
}

/// Scrolling waterfall of recent spectra.
struct WaterfallView: View {
    var rows: [[Float]]

    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                guard !rows.isEmpty else { return }
                let rowH = size.height / CGFloat(rows.count)
                let cols = rows[0].count
                let colW = size.width / CGFloat(max(cols, 1))
                for (r, row) in rows.enumerated() {
                    let y = CGFloat(r) * rowH
                    for (c, v) in row.enumerated() {
                        let x = CGFloat(c) * colW
                        let color = Retro.level(Double(v)).opacity(0.25 + 0.75 * Double(v))
                        ctx.fill(Path(CGRect(x: x, y: y, width: colW + 1, height: rowH + 1)),
                                 with: .color(color))
                    }
                }
            }
            .background(Retro.bg)
        }
    }
}
