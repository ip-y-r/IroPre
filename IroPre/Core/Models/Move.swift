// MARK: - 操作履歴モデル（undo用）
import Foundation

/// undo/redo 用の操作を表すモデル
struct Move: Sendable {
    let row: Int
    let col: Int
    let previousColorIndex: Int
    let newColorIndex: Int

    init(row: Int, col: Int, previousColorIndex: Int, newColorIndex: Int) {
        self.row = row
        self.col = col
        self.previousColorIndex = previousColorIndex
        self.newColorIndex = newColorIndex
    }
}
