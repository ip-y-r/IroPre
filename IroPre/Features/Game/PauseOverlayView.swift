// MARK: - ポーズ画面（盤面非表示）
import SwiftUI

struct PauseOverlayView: View {
    var isDark: Bool = false
    let onResume: () -> Void
    var onLevelSelect: (() -> Void)? = nil
    let onHome: () -> Void

    var body: some View {
        ZStack {
            ColorPalette.appBackground(isDark: isDark).opacity(0.97)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // ポーズアイコン
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorPalette.primaryGradient)
                        .shadow(color: Color(hex: "#4A90D9").opacity(0.4), radius: 16, x: 0, y: 8)
                    Image(systemName: "pause.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
                .frame(width: 64, height: 64)

                Text("一時停止")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))

                VStack(spacing: 10) {
                    // 続ける
                    Button(action: onResume) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("続ける")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(ColorPalette.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color(hex: "#4A90D9").opacity(0.4), radius: 8, x: 0, y: 4)
                    }

                    // レベル選択へ
                    Button(action: { onLevelSelect?() ?? onHome() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.grid.2x2.fill")
                            Text("レベル選択へ")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(ColorPalette.cardFill(isDark: isDark))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
                    }

                    // ホームへ
                    Button(action: onHome) {
                        HStack(spacing: 6) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 14))
                            Text("ホームへ")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                        .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    PauseOverlayView(isDark: false, onResume: {}, onHome: {})
}
