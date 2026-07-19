import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Retro.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        card(L("このアプリについて", "About")) {
                            infoRow(L("超音波チェッカーは、耳に聞こえない超音波（18〜24kHz）をマイクとFFTでリアルタイムに可視化するツールです。蚊よけ装置や犬笛、超音波ビーコンなどの発生源を探せます。",
                                      "Ultrasound Checker visualizes inaudible ultrasound (18–24 kHz) in real time using the mic and an FFT. Track down mosquito repellers, dog whistles, ultrasonic beacons and more."))
                        }
                        card(L("プライバシー", "Privacy")) {
                            infoRow(L("音声は端末内でのみ解析します。録音も保存も送信もしません。マイクは計測中だけ使います。",
                                      "Audio is analyzed only on your device. Nothing is recorded, saved, or uploaded. The mic is used only while measuring."))
                        }
                        card(L("免責", "Disclaimer")) {
                            infoRow(L("検出範囲は端末のマイク性能に依存します。教育・調査目的のアプリで、専門計測器の代わりにはなりません。",
                                      "Detection range depends on your device's mic. This is for education and exploration, not a substitute for professional instruments."))
                        }
                        card(L("サポート", "Support")) {
                            Link(L("サポートページ", "Support page"),
                                 destination: URL(string: "https://snarfnet.github.io/")!)
                                .foregroundStyle(Retro.lcd)
                        }
                        Text("© 2026 tokyonasu")
                            .font(.caption)
                            .foregroundStyle(Retro.lcdDim)
                    }
                    .padding()
                }
            }
            .navigationTitle(L("情報", "Info"))
        }
    }

    private func card(_ title: String, @ViewBuilder _ content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline).foregroundStyle(Retro.lcd)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Retro.panel)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func infoRow(_ text: String) -> some View {
        Text(text).foregroundStyle(Retro.dial).fixedSize(horizontal: false, vertical: true)
    }
}
