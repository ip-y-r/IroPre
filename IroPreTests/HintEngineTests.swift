// MARK: - HintEngine ユニットテスト
import Testing
@testable import IroPre

struct HintEngineTests {
    private let engine = HintEngine()

    // MARK: - テスト用ヘルパー

    private func makeState(hintsUsed: Int = 0) -> GameState {
        let puzzle = Puzzle(
            id: "hint-test",
            level: 1,
            gridSize: .small,
            difficulty: .beginner,
            initialBoard: [[1, 0, 0, 0],
                           [0, 0, 0, 0],
                           [0, 0, 0, 0],
                           [0, 0, 0, 2]],
            solution:     [[1, 2, 3, 4],
                           [3, 4, 1, 2],
                           [2, 1, 4, 3],
                           [4, 3, 2, 1]]
        )
        let state = GameState(puzzle: puzzle)
        state.hintsUsed = hintsUsed
        return state
    }

    // MARK: - cellHint

    @Test("空きマスへの cellHint は正解色を返す")
    func cellHintReturnsCorrectColor() {
        let state = makeState()
        let result = engine.provideHint(type: .cellHint(row: 0, col: 1), state: state)
        if case let .cellHint(row, col, colorIndex) = result {
            #expect(row == 0)
            #expect(col == 1)
            #expect(colorIndex == 2) // solution[0][1] = 2
        } else {
            Issue.record("期待する cellHint 結果を得られませんでした: \(result)")
        }
    }

    @Test("既に正解が入っているマスへの cellHint は alreadyCorrect を返す")
    func cellHintOnCorrectCellReturnsAlreadyCorrect() {
        let state = makeState()
        // プリセットマスは isPreset=true なので alreadyCorrect になる
        let result = engine.provideHint(type: .cellHint(row: 0, col: 0), state: state)
        #expect(result == .alreadyCorrect)
    }

    @Test("ヒント上限到達で limitReached を返す")
    func cellHintAtLimitReturnsLimitReached() {
        let state = makeState(hintsUsed: GameState.maxHints)
        let result = engine.provideHint(type: .cellHint(row: 0, col: 1), state: state)
        if case .limitReached = result {
            // OK
        } else {
            Issue.record("limitReached が返されるべきでした: \(result)")
        }
    }

    @Test("ヒント残り1回で成功し、次回は limitReached")
    func cellHintExhaustLimit() {
        let state = makeState(hintsUsed: GameState.maxHints - 1)
        let result1 = engine.provideHint(type: .cellHint(row: 0, col: 1), state: state)
        guard case let .cellHint(_, _, color) = result1 else {
            Issue.record("1回目のヒントが失敗しました")
            return
        }
        #expect(color == 2)

        // GameViewModel がヒントを適用する動作をシミュレート
        state.hintsUsed += 1

        let result2 = engine.provideHint(type: .cellHint(row: 0, col: 2), state: state)
        if case .limitReached = result2 {
            // OK
        } else {
            Issue.record("2回目は limitReached になるべきでした: \(result2)")
        }
    }

    // MARK: - errorCheck

    @Test("正しい盤面の errorCheck は空集合を返す")
    func errorCheckOnCorrectBoardReturnsEmpty() {
        let puzzle = Puzzle(
            id: "ec-test",
            level: 1,
            gridSize: .small,
            difficulty: .beginner,
            initialBoard: [[1, 2, 3, 4],
                           [3, 4, 1, 2],
                           [2, 1, 4, 3],
                           [4, 3, 2, 1]],
            solution:     [[1, 2, 3, 4],
                           [3, 4, 1, 2],
                           [2, 1, 4, 3],
                           [4, 3, 2, 1]]
        )
        let state = GameState(puzzle: puzzle)
        let result = engine.provideHint(type: .errorCheck, state: state)
        if case let .errorPositions(errors) = result {
            #expect(errors.isEmpty)
        } else {
            Issue.record("errorPositions が返されるべきでした: \(result)")
        }
    }

    @Test("誤りのあるマスを errorCheck で検出できる")
    func errorCheckDetectsMistakes() {
        let state = makeState()
        state.selectedColorIndex = 9 // 明らかに誤りの色
        state.placeColor(row: 0, col: 1)

        let result = engine.provideHint(type: .errorCheck, state: state)
        if case let .errorPositions(errors) = result {
            #expect(errors.contains(CellPosition(row: 0, col: 1)))
        } else {
            Issue.record("errorPositions が返されるべきでした: \(result)")
        }
    }

    @Test("エラーチェック上限到達で limitReached を返す")
    func errorCheckAtLimitReturnsLimitReached() {
        let state = makeState()
        state.errorCheckCount = GameState.maxErrorChecks
        let result = engine.provideHint(type: .errorCheck, state: state)
        if case .limitReached = result {
            // OK
        } else {
            Issue.record("limitReached が返されるべきでした: \(result)")
        }
    }

    // MARK: - blockHint

    @Test("空きマスがあるブロックへの blockHint は正解を返す")
    func blockHintReturnsCorrectCell() {
        let state = makeState()
        let result = engine.provideHint(type: .blockHint(blockRow: 0, blockCol: 0), state: state)
        if case let .blockHint(row, col, colorIndex) = result {
            // 正解盤面の値と一致することを確認
            #expect(state.puzzle.solution[row][col] == colorIndex)
            #expect(state.cells[row][col].isEditable)
        } else {
            Issue.record("blockHint が返されるべきでした: \(result)")
        }
    }

    @Test("全マス埋まりブロックへの blockHint は alreadyCorrect を返す")
    func blockHintOnFullBlockReturnsAlreadyCorrect() {
        let puzzle = Puzzle(
            id: "bh-test",
            level: 1,
            gridSize: .small,
            difficulty: .beginner,
            initialBoard: [[1, 2, 3, 4],
                           [3, 4, 1, 2],
                           [2, 1, 4, 3],
                           [4, 3, 2, 1]],
            solution:     [[1, 2, 3, 4],
                           [3, 4, 1, 2],
                           [2, 1, 4, 3],
                           [4, 3, 2, 1]]
        )
        let state = GameState(puzzle: puzzle)
        let result = engine.provideHint(type: .blockHint(blockRow: 0, blockCol: 0), state: state)
        #expect(result == .alreadyCorrect)
    }
}

// MARK: - HintResult Equatable（テスト用）

extension HintResult: Equatable {
    public static func == (lhs: HintResult, rhs: HintResult) -> Bool {
        switch (lhs, rhs) {
        case (.alreadyCorrect, .alreadyCorrect):
            return true
        case let (.errorPositions(a), .errorPositions(b)):
            return a == b
        case let (.cellHint(r1, c1, v1), .cellHint(r2, c2, v2)):
            return r1 == r2 && c1 == c2 && v1 == v2
        case let (.blockHint(r1, c1, v1), .blockHint(r2, c2, v2)):
            return r1 == r2 && c1 == c2 && v1 == v2
        default:
            return false
        }
    }
}
