// MARK: - ホーム画面 View
import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // ロゴ
                AppLogoView()
                    .frame(width: 120, height: 120)

                Text("IroPre")
                    .font(FontManager.title())

                Text("色で解くパズル")
                    .font(FontManager.body())
                    .foregroundStyle(.secondary)

                Spacer()

                // メインアクション
                NavigationLink(destination: LevelSelectView()) {
                    Label("ゲームをはじめる", systemImage: "play.fill")
                        .font(FontManager.button())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorPalette.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // サブアクション
                HStack(spacing: 24) {
                    NavigationLink(destination: AchievementsView()) {
                        VStack {
                            Image(systemName: "trophy.fill")
                            Text("実績")
                                .font(FontManager.body())
                        }
                    }

                    NavigationLink(destination: TutorialView()) {
                        VStack {
                            Image(systemName: "questionmark.circle")
                            Text("遊び方")
                                .font(FontManager.body())
                        }
                    }

                    NavigationLink(destination: SettingsView()) {
                        VStack {
                            Image(systemName: "gearshape.fill")
                            Text("設定")
                                .font(FontManager.body())
                        }
                    }
                }
                .foregroundStyle(ColorPalette.accent)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
    }
}

// MARK: - AppLogoView（3×3 カラーグリッド）

private struct AppLogoView: View {
    private let colors: [Color] = [
        Color(hex: "#FF6B6B"), Color(hex: "#4A90D9"), Color(hex: "#27AE60"),
        Color(hex: "#F1C40F"), Color(hex: "#9B59B6"), Color(hex: "#E67E22"),
        Color(hex: "#FF9FF3"), Color(hex: "#00CEC9"), Color(hex: "#BADC58")
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
            ForEach(0..<9, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(colors[index])
                    .aspectRatio(1, contentMode: .fit)
                    .shadow(color: colors[index].opacity(0.4), radius: 4, x: 0, y: 2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
}
