// MARK: - 実績 SwiftData モデル
import Foundation
import SwiftData

@Model
final class AchievementRecord {
    var achievementId: String
    var isUnlocked: Bool
    var unlockedAt: Date?
    /// 進捗率 (0.0〜1.0)
    var progress: Double

    init(achievementId: String, isUnlocked: Bool = false, progress: Double = 0.0) {
        self.achievementId = achievementId
        self.isUnlocked = isUnlocked
        self.unlockedAt = nil
        self.progress = max(0.0, min(1.0, progress))
    }

    func unlock() {
        guard !isUnlocked else { return }
        isUnlocked = true
        unlockedAt = Date()
        progress = 1.0
    }

    func updateProgress(_ value: Double) {
        progress = max(0.0, min(1.0, value))
        if progress >= 1.0 {
            unlock()
        }
    }
}
