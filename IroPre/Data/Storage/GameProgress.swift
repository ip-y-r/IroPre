// MARK: - ゲーム進捗 SwiftData モデル
import Foundation
import SwiftData

@Model
final class GameProgress {
    var puzzleId: String
    var level: Int
    var gridSize: Int
    /// 現在の盤面状態（行×列、0=空きマス）
    var currentBoard: [[Int]]
    /// 操作履歴（undo用）
    var moveHistory: [MoveRecord]
    var hintsUsed: Int
    var elapsedTime: TimeInterval
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        puzzleId: String,
        level: Int,
        gridSize: Int,
        currentBoard: [[Int]],
        moveHistory: [MoveRecord] = [],
        hintsUsed: Int = 0,
        elapsedTime: TimeInterval = 0,
        isCompleted: Bool = false
    ) {
        self.puzzleId = puzzleId
        self.level = level
        self.gridSize = gridSize
        self.currentBoard = currentBoard
        self.moveHistory = moveHistory
        self.hintsUsed = hintsUsed
        self.elapsedTime = elapsedTime
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func touch() {
        updatedAt = Date()
    }
}

// MARK: - MoveRecord（undo用の操作履歴レコード）
struct MoveRecord: Codable, Sendable {
    let row: Int
    let col: Int
    let previousValue: Int
    let newValue: Int
    let timestamp: Date

    init(row: Int, col: Int, previousValue: Int, newValue: Int) {
        self.row = row
        self.col = col
        self.previousValue = previousValue
        self.newValue = newValue
        self.timestamp = Date()
    }
}
