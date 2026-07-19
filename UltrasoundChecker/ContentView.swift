import SwiftUI

struct ContentView: View {
    @StateObject private var detector = UltrasoundDetector()
    @State private var selection = 0

    static var screenshotMode: Int? {
        for arg in CommandLine.arguments {
            if arg.hasPrefix("SCREENSHOT_MODE_"), let n = Int(arg.dropFirst("SCREENSHOT_MODE_".count)) {
                return n
            }
        }
        return nil
    }

    var body: some View {
        TabView(selection: $selection) {
            AnalyzerScreen(detector: detector)
                .tabItem { Label(L("計測", "Analyze"), systemImage: "waveform") }
                .tag(0)
            GuideView()
                .tabItem { Label(L("使い方", "Guide"), systemImage: "book") }
                .tag(1)
            InfoView()
                .tabItem { Label(L("情報", "Info"), systemImage: "info.circle") }
                .tag(2)
        }
        .tint(Retro.lcd)
        .preferredColorScheme(.dark)
        .onAppear {
            if let mode = Self.screenshotMode {
                detector.loadDemoState()
                selection = min(max(mode - 1, 0), 2)
            }
        }
    }
}
