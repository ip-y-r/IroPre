// MARK: - ヒントエンジン
import Foundation

/// ヒント種別（PRD 4.3）
enum HintType: Sendable {
    /// 選択マスの正解色を表示（各パズル最大3回）
    case cellHint(row: Int, col: Int)
    /// 現在の誤りをハイライト（各パズル最大5回）
    case errorCheck
    /// 指定ブロック内の1色を確定（各パズル最大1回）
    case blockHint(blockRow: Int, blockCol: Int)
}

/// ヒント結果
enum HintResult: Sendable {
    case cellHint(row: Int, col: Int, colorIndex: Int)
    case errorPositions(Set<CellPosition>)
    case blockHint(row: Int, col: Int, colorIndex: Int)
    case limitReached(HintType)
    case alreadyCorrect
}

/// ヒント提供プロトコル
protocol HintProviding: Sendable {
    func provideHint(type: HintType, state: GameState) -> HintResult
}

/// ヒントエンジン実装
struct HintEngine: HintProviding {
    private let validator = PuzzleValidator()

    func provideHint(type: HintType, state: GameState) -> HintResult {
        switch type {
        case let .cellHint(row, col):
            return provideCellHint(row: row, col: col, state: state)

        case .errorCheck:
            return provideErrorCheck(state: state)

        case let .blockHint(blockRow, blockCol):
            return provideBlockHint(blockRow: blockRow, blockCol: blockCol, state: state)
        }
    }

    // MARK: - Private

    private func provideCellHint(row: Int, col: Int, state: GameState) -> HintResult {
        guard state.hintsUsed < GameState.maxHints else {
            return .limitReached(.cellHint(row: row, col: col))
        }
        let cell = state.cells[row][col]
        guard cell.isEditable else { return .alreadyCorrect }

        let correctValue = state.puzzle.solution[row][col]
        if cell.colorIndex == correctValue {
            return .alreadyCorrect
        }
        return .cellHint(row: row, col: col, colorIndex: correctValue)
    }

    private func provideErrorCheck(state: GameState) -> HintResult {
        guard state.errorCheckCount < GameState.maxErrorChecks else {
            return .limitReached(.errorCheck)
        }
        let errors = validator.findErrors(
            board: state.currentBoardArray,
            solution: state.puzzle.solution,
            gridSize: state.puzzle.gridSize
        )
        return .errorPositions(errors)
    }

    private func provideBlockHint(blockRow: Int, blockCol: Int, state: GameState) -> HintResult {
        // blockHintは各パズル1回のみ（hintsUsed で管理、別カウンタに分けることも可能）
        let gridSize = state.puzzle.gridSize
        let startRow = blockRow * gridSize.blockRows
        let startCol = blockCol * gridSize.blockCols

        // ブロック内の空きマスから1つ選んで正解を示す
        var candidates: [(row: Int, col: Int)] = []
        for r in startRow..<(startRow + gridSize.blockRows) {
            for c in startCol..<(startCol + gridSize.blockCols) {
                if state.cells[r][c].isEditable && state.cells[r][c].isEmpty {
                    candidates.append((r, c))
                }
            }
        }

        guard let chosen = candidates.randomElement() else {
            return .alreadyCorrect
        }
        let correctValue = state.puzzle.solution[chosen.row][chosen.col]
        return .blockHint(row: chosen.row, col: chosen.col, colorIndex: correctValue)
    }
}
