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
    let titleKey: String        // ローカライズキー（将来の多言語対応用）
    let descriptionKey: String
    let sfSymbolName: String

    /// 日本語タイトル
    var localizedTitle: String {
        switch id {
        case "first_clear":      return "はじめの一歩"
        case "first_4x4":        return "4×4デビュー"
        case "first_6x6":        return "6×6チャレンジ"
        case "first_9x9":        return "9×9征服"
        case "speed_30sec":      return "スピードスター"
        case "speed_master":     return "カラーマスター"
        case "rainbow_complete": return "レインボーコンプリート"
        case "perfect_100":      return "パーフェクト100"
        case "no_hint_master":   return "ノーヒントマスター"
        case "seven_day_streak": return "7日連続プレイ"
        default:                 return titleKey
        }
    }

    /// 日本語説明
    var localizedDescription: String {
        switch id {
        case "first_clear":      return "初めてパズルをクリアした"
        case "first_4x4":        return "4×4パズルを初めてクリア"
        case "first_6x6":        return "6×6パズルを初めてクリア"
        case "first_9x9":        return "9×9パズルを初めてクリア"
        case "speed_30sec":      return "任意のレベルを30秒以内にクリア"
        case "speed_master":     return "Lv.30を60秒以内にクリア"
        case "rainbow_complete": return "全盤面サイズ（4×4・6×6・9×9）でクリア"
        case "perfect_100":      return "全100レベルをクリアした"
        case "no_hint_master":   return "ヒントなしでLv.50をクリア"
        case "seven_day_streak": return "7日連続でプレイした"
        default:                 return descriptionKey
        }
    }

    // MARK: 全実績の定義（PRD 4.5）
    static let allAchievements: [Achievement] = [
        // はじめて
        Achievement(id: "first_clear",      category: .beginner,
                    titleKey: "achievement.firstClear.title",
                    descriptionKey: "achievement.firstClear.description",
                    sfSymbolName: "medal.fill"),
        Achievement(id: "first_4x4",        category: .beginner,
                    titleKey: "achievement.first4x4.title",
                    descriptionKey: "achievement.first4x4.description",
                    sfSymbolName: "square.grid.2x2.fill"),
        Achievement(id: "first_6x6",        category: .beginner,
                    titleKey: "achievement.first6x6.title",
                    descriptionKey: "achievement.first6x6.description",
                    sfSymbolName: "square.grid.3x2.fill"),
        Achievement(id: "first_9x9",        category: .beginner,
                    titleKey: "achievement.first9x9.title",
                    descriptionKey: "achievement.first9x9.description",
                    sfSymbolName: "square.grid.3x3.fill"),
        // スピード
        Achievement(id: "speed_30sec",      category: .speed,
                    titleKey: "achievement.speed30sec.title",
                    descriptionKey: "achievement.speed30sec.description",
                    sfSymbolName: "bolt.fill"),
        Achievement(id: "speed_master",     category: .speed,
                    titleKey: "achievement.speedMaster.title",
                    descriptionKey: "achievement.speedMaster.description",
                    sfSymbolName: "bolt.circle.fill"),
        // コレクション
        Achievement(id: "rainbow_complete", category: .collection,
                    titleKey: "achievement.rainbowComplete.title",
                    descriptionKey: "achievement.rainbowComplete.description",
                    sfSymbolName: "paintpalette.fill"),
        Achievement(id: "perfect_100",      category: .collection,
                    titleKey: "achievement.perfect100.title",
                    descriptionKey: "achievement.perfect100.description",
                    sfSymbolName: "crown.fill"),
        // チャレンジ
        Achievement(id: "no_hint_master",   category: .challenge,
                    titleKey: "achievement.noHintMaster.title",
                    descriptionKey: "achievement.noHintMaster.description",
                    sfSymbolName: "brain.head.profile"),
        // 連続プレイ
        Achievement(id: "seven_day_streak", category: .streak,
                    titleKey: "achievement.sevenDayStreak.title",
                    descriptionKey: "achievement.sevenDayStreak.description",
                    sfSymbolName: "flame.fill"),
    ]
}
