// MARK: - 実績画面 ViewModel
import Foundation

@Observable
final class AchievementsViewModel {
    // TODO: Phase 3 で AchievementRepository と接続
    private var records: [String: AchievementRecord] = [:]

    func achievements(for category: AchievementCategory) -> [Achievement] {
        Achievement.allAchievements.filter { $0.category == category }
    }

    func record(for achievementId: String) -> AchievementRecord? {
        records[achievementId]
    }
}
