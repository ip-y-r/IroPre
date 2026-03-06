// MARK: - ホーム画面 View
import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(SettingsViewModel.self) private var settings

    private var isDark: Bool { settings.isDarkMode }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // ─── ロゴ + タイトル ───
                    VStack(spacing: 8) {
                        AppLogoView(size: 88)
                            .padding(.top, 28)

                        Text("IroPre")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))

                        Text("色で解く、新しい数独体験")
                            .font(FontManager.body())
                            .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                    }
                    .padding(.bottom, 16)

                    // ─── 前回の続きカード ───
                    ResumeCard(isDark: isDark)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                    // ─── スタッツ行 ───
                    StatsRow(isDark: isDark)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)

                    // ─── メインボタン ───
                    VStack(spacing: 10) {
                        NavigationLink(destination: LevelSelectView()) {
                            HomeActionButton(
                                label: "ゲームスタート",
                                systemImage: "play.fill",
                                gradient: ColorPalette.primaryGradient
                            )
                        }

                        NavigationLink(destination: LevelSelectView()) {
                            HomeActionButton(
                                label: "レベルを選ぶ",
                                systemImage: "square.grid.2x2.fill",
                                gradient: ColorPalette.successGradient
                            )
                        }

                        NavigationLink(destination: AchievementsView()) {
                            HomeActionButton(
                                label: "実績",
                                systemImage: "trophy.fill",
                                gradient: LinearGradient(
                                    colors: [Color(hex: "#F1C40F"), Color(hex: "#F39C12")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                    // ─── サブアクション ───
                    HStack(spacing: 32) {
                        NavigationLink(destination: SettingsView()) {
                            IconSubAction(systemImage: "gearshape.fill", label: "設定", isDark: isDark)
                        }
                        NavigationLink(destination: TutorialView()) {
                            IconSubAction(systemImage: "questionmark.circle.fill", label: "遊び方", isDark: isDark)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(ColorPalette.appBackground(isDark: isDark).ignoresSafeArea())
        }
    }
}

// MARK: - AppLogoView（3×3 カラーグリッド + レインボーグラデーション背景）

struct AppLogoView: View {
    let size: CGFloat

    private let colors: [Color] = [
        Color(hex: "#FF6B6B"), Color(hex: "#4A90D9"), Color(hex: "#27AE60"),
        Color(hex: "#F1C40F"), .white,                Color(hex: "#9B59B6"),
        Color(hex: "#E67E22"), Color(hex: "#FF9FF3"), Color(hex: "#00CEC9"),
    ]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28)
                .fill(LinearGradient(
                    colors: [Color(hex: "#FF6B6B"), Color(hex: "#4A90D9"),
                             Color(hex: "#27AE60"), Color(hex: "#F1C40F")],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .shadow(color: Color(hex: "#4A90D9").opacity(0.4), radius: 16, x: 0, y: 8)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: size * 0.04), count: 3),
                spacing: size * 0.04
            ) {
                ForEach(0..<9, id: \.self) { i in
                    RoundedRectangle(cornerRadius: size * 0.06)
                        .fill(i == 4
                              ? AnyShapeStyle(Color.white.opacity(0.9))
                              : AnyShapeStyle(colors[i]))
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(size * 0.12)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - ResumeCard

private struct ResumeCard: View {
    let isDark: Bool

    var body: some View {
        HStack(spacing: 14) {
            // ミニカラーグリッド
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                ForEach(0..<9, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ColorPalette.puzzleColors[i].light.opacity(i < 5 ? 1 : 0.3))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .frame(width: 48, height: 48)
            .padding(5)
            .background(isDark ? Color(hex: "#16162B") : Color(hex: "#F0F0F7"))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text("前回の続き")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text("Lv.12 — 6×6")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(isDark ? Color(hex: "#333355") : Color(hex: "#EEEEEE"))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(ColorPalette.primaryGradient)
                            .frame(width: geo.size.width * 0.44)
                    }
                }
                .frame(height: 5)

                Text("進行中... 4/9 マス")
                    .font(.system(size: 10))
                    .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
            }

            Spacer()

            // プレイボタン
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(ColorPalette.primaryGradient)
                    .shadow(color: Color(hex: "#4A90D9").opacity(0.4), radius: 6, x: 0, y: 3)
                Image(systemName: "play.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
            }
            .frame(width: 36, height: 36)
        }
        .padding(14)
        .background(ColorPalette.cardFill(isDark: isDark))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 4)
    }
}

// MARK: - StatsRow

private struct StatsRow: View {
    let isDark: Bool

    private let stats: [(value: String, label: String, color: Color)] = [
        ("42", "クリア",  Color(hex: "#27AE60")),
        ("7",  "連続日", Color(hex: "#FF6B6B")),
        ("00:34", "ベスト", Color(hex: "#4A90D9")),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(stats, id: \.label) { stat in
                VStack(spacing: 2) {
                    Text(stat.value)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(stat.color)
                    Text(stat.label)
                        .font(.system(size: 10))
                        .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(ColorPalette.cardFill(isDark: isDark))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
    }
}

// MARK: - HomeActionButton

private struct HomeActionButton: View {
    let label: String
    let systemImage: String
    let gradient: LinearGradient

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
            Text(label)
                .font(.system(size: 15, weight: .bold, design: .rounded))
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - IconSubAction

private struct IconSubAction: View {
    let systemImage: String
    let label: String
    let isDark: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(ColorPalette.cardFill(isDark: isDark))
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                    .foregroundStyle(ColorPalette.iconColor(isDark: isDark))
            }
            .frame(width: 44, height: 44)

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
        }
    }
}

#Preview {
    HomeView()
        .environment(SettingsViewModel())
}
