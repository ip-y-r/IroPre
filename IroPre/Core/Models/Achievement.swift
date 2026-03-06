// MARK: - 実績モデル
import Foundation

/// 実績カテゴリ
enum AchievementCategory: String, CaseIterable, Sendable {
    case beginner = "beginner"
    case speed = "speed"
    case collection = "collection"
    case challenge = "challenge"
    case streak = "streak"
}

/// 実績定義
struct Achievement: Identifiable, Sendable {
    let id: String
    let category: AchievementCategory
    let titleKey: String
    let descriptionKey: String
    let sfSymbolName: String

    // MARK: 全実績の定義（PRD 4.5）
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "first_clear",
            category: .beginner,
            titleKey: "achievement.firstClear.title",
            descriptionKey: "achievement.firstClear.description",
            sfSymbolName: "star.fill"
        ),
        Achievement(
            id: "speed_master",
            category: .speed,
            titleKey: "achievement.speedMaster.title",
            descriptionKey: "achievement.speedMaster.description",
            sfSymbolName: "bolt.fill"
        ),
        Achievement(
            id: "rainbow_complete",
            category: .collection,
            titleKey: "achievement.rainbowComplete.title",
            descriptionKey: "achievement.rainbowComplete.description",
            sfSymbolName: "paintpalette.fill"
        ),
        Achievement(
            id: "no_hint_master",
            category: .challenge,
            titleKey: "achievement.noHintMaster.title",
            descriptionKey: "achievement.noHintMaster.description",
            sfSymbolName: "brain.head.profile"
        ),
        Achievement(
            id: "seven_day_streak",
            category: .streak,
            titleKey: "achievement.sevenDayStreak.title",
            descriptionKey: "achievement.sevenDayStreak.description",
            sfSymbolName: "flame.fill"
        )
    ]
}
