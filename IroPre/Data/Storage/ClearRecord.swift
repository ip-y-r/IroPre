// MARK: - クリア履歴 SwiftData モデル
import Foundation
import SwiftData

@Model
final class ClearRecord {
    var puzzleId: String
    var level: Int
    var gridSize: Int
    var clearTime: TimeInterval
    var hintsUsed: Int
    /// ★評価 (1〜3)
    var starRating: Int
    var score: Int
    var clearedAt: Date

    init(
        puzzleId: String,
        level: Int,
        gridSize: Int,
        clearTime: TimeInterval,
        hintsUsed: Int,
        starRating: Int,
        score: Int
    ) {
        self.puzzleId = puzzleId
        self.level = level
        self.gridSize = gridSize
        self.clearTime = clearTime
        self.hintsUsed = hintsUsed
        self.starRating = max(1, min(3, starRating))
        self.score = max(0, score)
        self.clearedAt = Date()
    }
}
