// MARK: - 実績画面 View
import SwiftUI

struct AchievementsView: View {
    @State private var viewModel = AchievementsViewModel()
    @Environment(SettingsViewModel.self) private var settings

    private var isDark: Bool { settings.isDarkMode }

    private var allAchievements: [Achievement] {
        AchievementCategory.allCases.flatMap { viewModel.achievements(for: $0) }
    }

    var body: some View {
        let unlocked = allAchievements.filter { viewModel.record(for: $0.id)?.isUnlocked == true }.count
        let total    = allAchievements.count

        ScrollView {
            VStack(spacing: 0) {
                // 解除数サマリー
                HStack(spacing: 4) {
                    Text("\(unlocked)")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(ColorPalette.puzzleColors[0].light)
                    Text("/ \(total) 解除")
                        .font(.system(size: 14))
                        .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                        .padding(.top, 12)
                }
                .padding(.vertical, 16)

                // カテゴリごと
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    let achs = viewModel.achievements(for: category)
                    if !achs.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.displayName)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .padding(.horizontal, 16)

                            VStack(spacing: 8) {
                                ForEach(achs) { achievement in
                                    let record   = viewModel.record(for: achievement.id)
                                    let unlocked = record?.isUnlocked ?? false
                                    AchievementCardView(
                                        achievement: achievement,
                                        record: record,
                                        unlocked: unlocked,
                                        accentColor: ColorPalette.puzzleColors[(achievement.id.hashValue % 9 + 9) % 9].light,
                                        isDark: isDark
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .background(ColorPalette.appBackground(isDark: isDark).ignoresSafeArea())
        .navigationTitle("実績")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}

// MARK: - AchievementCardView

private struct AchievementCardView: View {
    let achievement: Achievement
    let record: AchievementRecord?
    let unlocked: Bool
    let accentColor: Color
    let isDark: Bool

    var body: some View {
        HStack(spacing: 12) {
            // アイコン
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(unlocked
                          ? AnyShapeStyle(LinearGradient(
                                colors: [accentColor.opacity(0.2), accentColor.opacity(0.08)],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                          : AnyShapeStyle(Color.clear))
                    .frame(width: 44, height: 44)
                Image(systemName: unlocked ? achievement.sfSymbolName : "lock.fill")
                    .font(.system(size: unlocked ? 22 : 18))
                    .foregroundStyle(unlocked ? accentColor : ColorPalette.secondaryTextColor(isDark: isDark))
            }

            // テキスト
            VStack(alignment: .leading, spacing: 3) {
                Text(achievement.titleKey)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))
                Text(achievement.descriptionKey)
                    .font(.system(size: 11))
                    .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))

                if let progress = record?.progress, !unlocked {
                    ProgressView(value: progress)
                        .tint(accentColor)
                        .padding(.top, 2)
                }
            }

            Spacer()

            if unlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(hex: "#27AE60"))
            }
        }
        .padding(12)
        .background(
            unlocked
                ? AnyShapeStyle(ColorPalette.cardFill(isDark: isDark))
                : AnyShapeStyle(isDark ? Color(hex: "#16162B") : Color(hex: "#F0F0F7"))
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: unlocked ? .black.opacity(0.07) : .clear, radius: 4, x: 0, y: 2)
        .opacity(unlocked ? 1.0 : 0.55)
    }
}

// MARK: - AchievementCategory displayName

extension AchievementCategory {
    var displayName: String {
        switch self {
        case .beginner:   return "はじめて"
        case .speed:      return "スピード"
        case .collection: return "コレクション"
        case .challenge:  return "チャレンジ"
        case .streak:     return "連続プレイ"
        }
    }
}

#Preview {
    NavigationStack {
        AchievementsView()
            .environment(SettingsViewModel())
    }
}
