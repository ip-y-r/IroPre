// MARK: - GameState ユニットテスト
import Testing
@testable import IroPre

struct GameStateTests {
    // MARK: - テスト用ヘルパー

    private func makeState() -> GameState {
        let puzzle = Puzzle(
            id: "test",
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
        return GameState(puzzle: puzzle)
    }

    // MARK: - 初期状態

    @Test("初期状態は playing フェーズ")
    func initialPhaseIsPlaying() {
        let state = makeState()
        #expect(state.phase == .playing)
    }

    @Test("初期状態は moveHistory が空")
    func initialMoveHistoryIsEmpty() {
        let state = makeState()
        #expect(state.moveHistory.isEmpty)
    }

    @Test("プリセットマスは isPreset = true")
    func presetCellIsPreset() {
        let state = makeState()
        #expect(state.cells[0][0].isPreset == true)
        #expect(state.cells[0][1].isPreset == false)
    }

    // MARK: - placeColor

    @Test("色選択後のセルタップで色が配置される")
    func placeColorSuccess() {
        let state = makeState()
        state.selectedColorIndex = 3
        let placed = state.placeColor(row: 0, col: 1)
        #expect(placed == true)
        #expect(state.cells[0][1].colorIndex == 3)
        #expect(state.moveHistory.count == 1)
    }

    @Test("プリセットマスには配置できない")
    func placeColorOnPresetFails() {
        let state = makeState()
        state.selectedColorIndex = 2
        let placed = state.placeColor(row: 0, col: 0)
        #expect(placed == false)
        #expect(state.cells[0][0].colorIndex == 1)
    }

    @Test("色未選択の場合は配置されない")
    func placeColorWithoutSelectionFails() {
        let state = makeState()
        state.selectedColorIndex = nil
        let placed = state.placeColor(row: 0, col: 1)
        #expect(placed == false)
    }

    // MARK: - eraseCell

    @Test("配置済みマスを消去できる")
    func eraseCellSuccess() {
        let state = makeState()
        state.selectedColorIndex = 2
        state.placeColor(row: 1, col: 0)
        let erased = state.eraseCell(row: 1, col: 0)
        #expect(erased == true)
        #expect(state.cells[1][0].colorIndex == 0)
    }

    @Test("空マスは消去できない")
    func eraseEmptyCellFails() {
        let state = makeState()
        let erased = state.eraseCell(row: 0, col: 1)
        #expect(erased == false)
    }

    @Test("プリセットマスは消去できない")
    func erasePresetCellFails() {
        let state = makeState()
        let erased = state.eraseCell(row: 0, col: 0)
        #expect(erased == false)
    }

    // MARK: - undo

    @Test("直前の配置を1手戻せる")
    func undoRestoresPreviousState() {
        let state = makeState()
        state.selectedColorIndex = 3
        state.placeColor(row: 0, col: 1)
        #expect(state.cells[0][1].colorIndex == 3)

        let undone = state.undo()
        #expect(undone == true)
        #expect(state.cells[0][1].colorIndex == 0)
        #expect(state.moveHistory.isEmpty)
    }

    @Test("履歴が空のときの undo は false")
    func undoOnEmptyHistoryReturnsFalse() {
        let state = makeState()
        let undone = state.undo()
        #expect(undone == false)
    }

    @Test("複数手を順番に undo できる")
    func undoMultipleMoves() {
        let state = makeState()
        state.selectedColorIndex = 2
        state.placeColor(row: 0, col: 1)
        state.selectedColorIndex = 3
        state.placeColor(row: 0, col: 2)

        state.undo()
        #expect(state.cells[0][2].colorIndex == 0)
        state.undo()
        #expect(state.cells[0][1].colorIndex == 0)
        #expect(state.moveHistory.isEmpty)
    }

    // MARK: - resetAll

    @Test("resetAll で初期盤面に戻る")
    func resetAllRestoresInitialBoard() {
        let state = makeState()
        state.selectedColorIndex = 2
        state.placeColor(row: 0, col: 1)
        state.placeColor(row: 1, col: 0)
        state.hintsUsed = 2

        state.resetAll()
        #expect(state.cells[0][1].colorIndex == 0)
        #expect(state.cells[1][0].colorIndex == 0)
        #expect(state.moveHistory.isEmpty)
        #expect(state.hintsUsed == 0)
    }

    // MARK: - isBoardFull

    @Test("全マス埋まりで isBoardFull = true")
    func isBoardFullWhenAllFilled() {
        let puzzle = Puzzle(
            id: "full",
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
        #expect(state.isBoardFull == true)
    }

    @Test("空きマスがある場合 isBoardFull = false")
    func isBoardFullWithEmptyCell() {
        let state = makeState()
        #expect(state.isBoardFull == false)
    }
}
