import SwiftUI

enum Retro {
    static let bg = Color(red: 0.06, green: 0.07, blue: 0.09)
    static let panel = Color(red: 0.11, green: 0.13, blue: 0.16)
    static let bezel = Color(red: 0.18, green: 0.20, blue: 0.24)
    static let dial = Color(red: 0.92, green: 0.94, blue: 0.96)
    static let needle = Color(red: 0.40, green: 0.95, blue: 0.70)
    static let lcd = Color(red: 0.45, green: 0.95, blue: 0.75)
    static let lcdDim = Color(red: 0.24, green: 0.46, blue: 0.38)
    static let amber = Color(red: 1.00, green: 0.72, blue: 0.30)
    static let hot = Color(red: 1.00, green: 0.45, blue: 0.40)

    /// Spectrum bar colour by normalized magnitude 0..1.
    static func level(_ v: Double) -> Color {
        switch v {
        case ..<0.33: return lcd
        case ..<0.66: return amber
        default: return hot
        }
    }
}
