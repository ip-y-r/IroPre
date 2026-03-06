// MARK: - 実績画面 View
import SwiftUI

struct AchievementsView: View {
    @State private var viewModel = AchievementsViewModel()

    var body: some View {
        List {
            ForEach(AchievementCategory.allCases, id: \.self) { category in
                Section(category.displayName) {
                    ForEach(viewModel.achievements(for: category)) { achievement in
                        AchievementRowView(
                            achievement: achievement,
                            record: viewModel.record(for: achievement.id)
                        )
                    }
                }
            }
        }
        .navigationTitle("実績")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
    }
}

// MARK: - AchievementRowView

private struct AchievementRowView: View {
    let achievement: Achievement
    let record: AchievementRecord?

    private var isUnlocked: Bool { record?.isUnlocked ?? false }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? ColorPalette.accent.opacity(0.15) : Color(.systemGray5))
                    .frame(width: 48, height: 48)

                Image(systemName: achievement.sfSymbolName)
                    .font(.system(size: 22))
                    .foregroundStyle(isUnlocked ? ColorPalette.accent : Color(.systemGray3))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.titleKey)
                    .font(FontManager.headline())
                    .foregroundStyle(isUnlocked ? .primary : .secondary)

                Text(achievement.descriptionKey)
                    .font(FontManager.body())
                    .foregroundStyle(.secondary)

                if let progress = record?.progress, !isUnlocked {
                    ProgressView(value: progress)
                        .tint(ColorPalette.accent)
                }
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color(hex: "#27AE60"))
            }
        }
        .padding(.vertical, 4)
        .opacity(isUnlocked ? 1.0 : 0.6)
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
    }
}
