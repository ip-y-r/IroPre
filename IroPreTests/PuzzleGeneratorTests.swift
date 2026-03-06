// MARK: - PuzzleGenerator ユニットテスト
import Testing
@testable import IroPre

struct PuzzleGeneratorTests {
    private let generator = PuzzleGenerator()
    private let validator = PuzzleValidator()

    @Test("4×4 パズル生成成功")
    func generate4x4() {
        let result = generator.generate(gridSize: .small, difficulty: .beginner, level: 1)
        switch result {
        case let .success(puzzle):
            #expect(puzzle.gridSize == .small)
            #expect(puzzle.level == 1)
            #expect(validator.isComplete(board: puzzle.solution, gridSize: .small))
        case .failure:
            Issue.record("パズル生成に失敗しました")
        }
    }

    @Test("6×6 パズル生成成功")
    func generate6x6() {
        let result = generator.generate(gridSize: .medium, difficulty: .easy, level: 21)
        switch result {
        case let .success(puzzle):
            #expect(puzzle.gridSize == .medium)
            #expect(validator.isComplete(board: puzzle.solution, gridSize: .medium))
        case .failure:
            Issue.record("6×6パズル生成に失敗しました")
        }
    }

    @Test("生成された initialBoard に空きマスが存在する")
    func initialBoardHasEmptyCells() {
        let result = generator.generate(gridSize: .small, difficulty: .easy, level: 5)
        if case let .success(puzzle) = result {
            #expect(puzzle.emptyCellCount > 0)
        }
    }

    @Test("solution が有効な盤面")
    func solutionIsValid() {
        let result = generator.generate(gridSize: .small, difficulty: .medium, level: 10)
        if case let .success(puzzle) = result {
            #expect(validator.isValid(board: puzzle.solution, gridSize: .small))
        }
    }
}
