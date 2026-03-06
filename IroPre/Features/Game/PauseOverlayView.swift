// MARK: - ポーズ画面（盤面非表示）
import SwiftUI

struct PauseOverlayView: View {
    let onResume: () -> Void
    let onHome: () -> Void

    var body: some View {
        ZStack {
            // 背景ブラー（盤面を隠す）
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(ColorPalette.accent)

                Text("一時停止中")
                    .font(FontManager.title())

                Text("盤面を非表示にしています")
                    .font(FontManager.body())
                    .foregroundStyle(.secondary)

                VStack(spacing: 16) {
                    Button(action: onResume) {
                        Label("続ける", systemImage: "play.fill")
                            .font(FontManager.button())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ColorPalette.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button(action: onHome) {
                        Label("ホームに戻る", systemImage: "house.fill")
                            .font(FontManager.button())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    PauseOverlayView(onResume: {}, onHome: {})
}
