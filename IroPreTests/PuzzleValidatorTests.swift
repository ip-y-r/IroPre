// MARK: - PuzzleValidator ユニットテスト
import Testing
@testable import IroPre

struct PuzzleValidatorTests {
    private let validator = PuzzleValidator()

    @Test("有効な4×4盤面は isValid = true")
    func validBoard4x4() {
        let board = [
            [1, 2, 3, 4],
            [3, 4, 1, 2],
            [2, 1, 4, 3],
            [4, 3, 2, 1]
        ]
        #expect(validator.isValid(board: board, gridSize: .small) == true)
    }

    @Test("行に重複がある盤面は isValid = false")
    func invalidRowDuplicate() {
        let board = [
            [1, 1, 3, 4],
            [3, 4, 1, 2],
            [2, 1, 4, 3],
            [4, 3, 2, 1]
        ]
        #expect(validator.isValid(board: board, gridSize: .small) == false)
    }

    @Test("列に重複がある盤面は isValid = false")
    func invalidColumnDuplicate() {
        let board = [
            [1, 2, 3, 4],
            [1, 4, 2, 3],
            [2, 1, 4, 3],
            [4, 3, 2, 1]
        ]
        #expect(validator.isValid(board: board, gridSize: .small) == false)
    }

    @Test("空きマスがあると isComplete = false")
    func incompleteBoardNotComplete() {
        let board = [
            [1, 0, 3, 4],
            [3, 4, 1, 2],
            [2, 1, 4, 3],
            [4, 3, 2, 1]
        ]
        #expect(validator.isComplete(board: board, gridSize: .small) == false)
    }

    @Test("全マス埋まり有効な盤面は isComplete = true")
    func completeBoardIsComplete() {
        let board = [
            [1, 2, 3, 4],
            [3, 4, 1, 2],
            [2, 1, 4, 3],
            [4, 3, 2, 1]
        ]
        #expect(validator.isComplete(board: board, gridSize: .small) == true)
    }

    @Test("配置可能チェック — 有効")
    func validPlacement() {
        var board = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        board[0][0] = 1
        #expect(validator.isPlacementValid(board: board, row: 0, col: 1, value: 2, gridSize: .small) == true)
    }

    @Test("配置可能チェック — 行重複で無効")
    func invalidPlacementRowConflict() {
        var board = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        board[0][0] = 1
        #expect(validator.isPlacementValid(board: board, row: 0, col: 1, value: 1, gridSize: .small) == false)
    }

    @Test("エラー検出 — 正解と異なるマスを返す")
    func findErrors() {
        let board = [
            [1, 2, 3, 4],
            [3, 4, 1, 2],
            [2, 1, 4, 3],
            [4, 3, 2, 1]
        ]
        let solution = [
            [1, 2, 3, 4],
            [3, 4, 1, 2],
            [2, 1, 4, 3],
            [4, 3, 2, 1]
        ]
        let errors = validator.findErrors(board: board, solution: solution, gridSize: .small)
        #expect(errors.isEmpty)
    }
}
