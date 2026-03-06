// MARK: - ゲーム状態管理モデル
import Foundation

/// ゲームの進行状態
enum GamePhase: Sendable {
    case playing
    case paused
    case completed
}

/// 現在のゲームセッション状態を保持するモデル
@Observable
final class GameState {
    var puzzle: Puzzle
    var cells: [[Cell]]
    var moveHistory: [Move]
    var selectedColorIndex: Int?
    var phase: GamePhase
    var elapsedTime: TimeInterval
    var hintsUsed: Int
    var errorCheckCount: Int
    var blockHintsUsed: Int

    // MARK: ヒント上限（PRD 4.3）
    static let maxHints = 3
    static let maxErrorChecks = 5
    static let maxBlockHints = 1

    init(puzzle: Puzzle) {
        self.puzzle = puzzle
        self.cells = puzzle.makeCells()
        self.moveHistory = []
        self.selectedColorIndex = nil
        self.phase = .playing
        self.elapsedTime = 0
        self.hintsUsed = 0
        self.errorCheckCount = 0
        self.blockHintsUsed = 0
    }

    // MARK: - セルへの色配置

    /// 指定マスに選択中の色を配置する
    @discardableResult
    func placeColor(row: Int, col: Int) -> Bool {
        guard phase == .playing else { return false }
        guard let colorIndex = selectedColorIndex else { return false }
        let cell = cells[row][col]
        guard cell.isEditable else { return false }

        let move = Move(
            row: row,
            col: col,
            previousColorIndex: cell.colorIndex,
            newColorIndex: colorIndex
        )
        cells[row][col].colorIndex = colorIndex
        cells[row][col].isError = false
        moveHistory.append(move)
        return true
    }

    /// 指定マスの色を消す
    @discardableResult
    func eraseCell(row: Int, col: Int) -> Bool {
        guard phase == .playing else { return false }
        let cell = cells[row][col]
        guard cell.isEditable, !cell.isEmpty else { return false }

        let move = Move(
            row: row,
            col: col,
            previousColorIndex: cell.colorIndex,
            newColorIndex: 0
        )
        cells[row][col].colorIndex = 0
        cells[row][col].isError = false
        moveHistory.append(move)
        return true
    }

    // MARK: - undo

    /// 直前の操作を1手戻す
    @discardableResult
    func undo() -> Bool {
        guard !moveHistory.isEmpty else { return false }
        let move = moveHistory.removeLast()
        cells[move.row][move.col].colorIndex = move.previousColorIndex
        cells[move.row][move.col].isError = false
        return true
    }

    /// 全操作をリセット（初期状態に戻す）
    func resetAll() {
        cells = puzzle.makeCells()
        moveHistory.removeAll()
        selectedColorIndex = nil
        hintsUsed = 0
        errorCheckCount = 0
        blockHintsUsed = 0
    }

    // MARK: - 盤面取得

    /// 現在の盤面を 2D Int 配列で返す（保存用）
    var currentBoardArray: [[Int]] {
        cells.map { row in row.map { $0.colorIndex } }
    }

    // MARK: - 完了チェック

    var isBoardFull: Bool {
        cells.flatMap { $0 }.allSatisfy { !$0.isEmpty }
    }
}
