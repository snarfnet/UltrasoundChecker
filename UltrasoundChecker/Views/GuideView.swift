import SwiftUI

struct GuideView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Retro.bg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        section(L("使い方", "How to use")) {
                            step("1", L("「計測開始」をタップしてマイクを許可します。",
                                        "Tap Start and allow the microphone."))
                            step("2", L("スペクトルの右側（高周波側）に山が立つと超音波です。",
                                        "A peak on the right (high-frequency) side means ultrasound."))
                            step("3", L("18〜24kHzの帯でピークが出ると「超音波を検出」と表示します。",
                                        "When a peak appears in the 18–24 kHz band it shows 'Ultrasound detected'."))
                            step("4", L("音源に近づけると山が高くなります。発生源を探せます。",
                                        "Move closer to a source and the peak grows — use it to locate the emitter."))
                        }
                        section(L("何が見つかる？", "What it finds")) {
                            bullet(L("蚊よけ・害虫よけの超音波装置", "Mosquito / pest repellers"))
                            bullet(L("犬笛・動物よけ", "Dog whistles, animal deterrents"))
                            bullet(L("一部の防犯ブザーやビーコン", "Some alarms and ultrasonic beacons"))
                            bullet(L("古いブラウン管や一部電子機器の高周波音", "High-pitched whine from some electronics"))
                        }
                        section(L("原理", "How it works")) {
                            para(L("マイクの音をFFT（高速フーリエ変換）で周波数ごとに分解し、人の耳では聞こえない高い周波数の成分を測ります。検出できる上限は端末のマイクのサンプリング周波数で決まります（多くは最大24kHz付近）。",
                                   "The mic signal is split by frequency using an FFT, and the app measures the high-frequency content beyond human hearing. The upper limit depends on your device's mic sample rate — usually around 24 kHz."))
                        }
                        disclaimer
                    }
                    .padding()
                }
            }
            .navigationTitle(L("使い方", "Guide"))
        }
    }

    private func section(_ title: String, @ViewBuilder _ content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title3.bold()).foregroundStyle(Retro.lcd)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Retro.panel)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func step(_ num: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(num)
                .font(.headline)
                .foregroundStyle(Retro.bg)
                .frame(width: 28, height: 28)
                .background(Retro.lcd)
                .clipShape(Circle())
            Text(text).foregroundStyle(Retro.dial)
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•").foregroundStyle(Retro.lcd)
            Text(text).foregroundStyle(Retro.dial)
        }
    }

    private func para(_ text: String) -> some View {
        Text(text).foregroundStyle(Retro.dial).fixedSize(horizontal: false, vertical: true)
    }

    private var disclaimer: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(L("測定範囲や精度は端末のマイク性能に左右されます。専門の計測器の代わりにはなりません。",
                   "Range and accuracy depend on your device's mic. This is not a substitute for professional measurement equipment."))
                .font(.callout)
        }
        .foregroundStyle(Retro.amber)
        .padding()
        .background(Retro.amber.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
