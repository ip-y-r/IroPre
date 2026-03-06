// MARK: - パズル検証エンジン
import Foundation

/// パズルの盤面が有効かどうかを検証するプロトコル
protocol PuzzleValidating: Sendable {
    func isValid(board: [[Int]], gridSize: GridSize) -> Bool
    func isComplete(board: [[Int]], gridSize: GridSize) -> Bool
    func findErrors(board: [[Int]], solution: [[Int]], gridSize: GridSize) -> Set<CellPosition>
    func isPlacementValid(board: [[Int]], row: Int, col: Int, value: Int, gridSize: GridSize) -> Bool
}

/// セル位置（エラーハイライト用）
struct CellPosition: Hashable, Sendable {
    let row: Int
    let col: Int
}

/// パズル検証の実装
struct PuzzleValidator: PuzzleValidating {

    // MARK: - Public API

    /// 盤面全体が有効（ルール違反なし）かどうか
    func isValid(board: [[Int]], gridSize: GridSize) -> Bool {
        let size = gridSize.rawValue
        for row in 0..<size {
            for col in 0..<size {
                let value = board[row][col]
                guard value != 0 else { continue }
                if !isPlacementValid(board: board, row: row, col: col, value: value, gridSize: gridSize) {
                    return false
                }
            }
        }
        return true
    }

    /// 盤面が完成しているか（全マス埋まり、かつ有効）
    func isComplete(board: [[Int]], gridSize: GridSize) -> Bool {
        let size = gridSize.rawValue
        for row in 0..<size {
            for col in 0..<size {
                if board[row][col] == 0 { return false }
            }
        }
        return isValid(board: board, gridSize: gridSize)
    }

    /// 現在の盤面と正解を比較してエラーマスを返す
    func findErrors(board: [[Int]], solution: [[Int]], gridSize: GridSize) -> Set<CellPosition> {
        var errors = Set<CellPosition>()
        let size = gridSize.rawValue
        for row in 0..<size {
            for col in 0..<size {
                let value = board[row][col]
                if value != 0 && value != solution[row][col] {
                    errors.insert(CellPosition(row: row, col: col))
                }
            }
        }
        return errors
    }

    /// 指定マスへの配置が現在有効かどうか（一時的に配置して検証）
    func isPlacementValid(board: [[Int]], row: Int, col: Int, value: Int, gridSize: GridSize) -> Bool {
        guard value != 0 else { return true }
        let size = gridSize.rawValue

        // 行チェック
        for c in 0..<size {
            if c != col && board[row][c] == value { return false }
        }

        // 列チェック
        for r in 0..<size {
            if r != row && board[r][col] == value { return false }
        }

        // ブロックチェック
        let blockStartRow = (row / gridSize.blockRows) * gridSize.blockRows
        let blockStartCol = (col / gridSize.blockCols) * gridSize.blockCols
        for r in blockStartRow..<(blockStartRow + gridSize.blockRows) {
            for c in blockStartCol..<(blockStartCol + gridSize.blockCols) {
                if (r != row || c != col) && board[r][c] == value { return false }
            }
        }

        return true
    }

    // MARK: - Internal Helpers

    /// ある行に同じ値の重複があるか
    func hasDuplicateInRow(_ board: [[Int]], row: Int, gridSize: GridSize) -> Bool {
        let values = board[row].filter { $0 != 0 }
        return values.count != Set(values).count
    }

    /// ある列に同じ値の重複があるか
    func hasDuplicateInColumn(_ board: [[Int]], col: Int, gridSize: GridSize) -> Bool {
        let size = gridSize.rawValue
        let values = (0..<size).map { board[$0][col] }.filter { $0 != 0 }
        return values.count != Set(values).count
    }

    /// あるブロックに同じ値の重複があるか
    func hasDuplicateInBlock(_ board: [[Int]], blockRow: Int, blockCol: Int, gridSize: GridSize) -> Bool {
        let startRow = blockRow * gridSize.blockRows
        let startCol = blockCol * gridSize.blockCols
        var values: [Int] = []
        for r in startRow..<(startRow + gridSize.blockRows) {
            for c in startCol..<(startCol + gridSize.blockCols) {
                let v = board[r][c]
                if v != 0 { values.append(v) }
            }
        }
        return values.count != Set(values).count
    }
}
