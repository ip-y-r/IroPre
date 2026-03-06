// MARK: - パズル生成エンジン
import Foundation

/// パズル生成プロトコル
protocol PuzzleGenerating: Sendable {
    func generate(gridSize: GridSize, difficulty: Difficulty, level: Int) -> Result<Puzzle, PuzzleGeneratorError>
}

enum PuzzleGeneratorError: Error, Sendable {
    case generationFailed
    case timeout
    case invalidParameters
}

/// バックトラッキングによるパズル生成エンジン
struct PuzzleGenerator: PuzzleGenerating {
    private let validator = PuzzleValidator()

    // MARK: - Public API

    func generate(gridSize: GridSize, difficulty: Difficulty, level: Int) -> Result<Puzzle, PuzzleGeneratorError> {
        guard let solution = generateSolution(gridSize: gridSize) else {
            return .failure(.generationFailed)
        }

        let initialBoard = createPuzzle(from: solution, gridSize: gridSize, difficulty: difficulty)
        let puzzleId = "gen_\(gridSize.rawValue)_lv\(String(format: "%03d", level))_\(UUID().uuidString.prefix(8))"

        let puzzle = Puzzle(
            id: puzzleId,
            level: level,
            gridSize: gridSize,
            difficulty: difficulty,
            initialBoard: initialBoard,
            solution: solution
        )
        return .success(puzzle)
    }

    // MARK: - Solution Generation (バックトラッキング)

    private func generateSolution(gridSize: GridSize) -> [[Int]]? {
        let size = gridSize.rawValue
        var board = Array(repeating: Array(repeating: 0, count: size), count: size)
        let numbers = Array(1...size).shuffled()

        if backtrack(board: &board, gridSize: gridSize, numbers: numbers) {
            return board
        }
        return nil
    }

    private func backtrack(board: inout [[Int]], gridSize: GridSize, numbers: [Int]) -> Bool {
        let size = gridSize.rawValue

        // 空きマスを探す
        for row in 0..<size {
            for col in 0..<size {
                guard board[row][col] == 0 else { continue }

                for num in numbers.shuffled() {
                    if validator.isPlacementValid(board: board, row: row, col: col, value: num, gridSize: gridSize) {
                        board[row][col] = num
                        if backtrack(board: &board, gridSize: gridSize, numbers: numbers) {
                            return true
                        }
                        board[row][col] = 0
                    }
                }
                return false  // どの値もダメ
            }
        }
        return true  // 全マス埋まった
    }

    // MARK: - Puzzle Creation (セルの削除)

    private func createPuzzle(from solution: [[Int]], gridSize: GridSize, difficulty: Difficulty) -> [[Int]] {
        let size = gridSize.rawValue
        var board = solution

        let cellsToRemove = removeCellCount(gridSize: gridSize, difficulty: difficulty)

        // ランダムな順序でセルを削除
        var positions = (0..<size).flatMap { row in
            (0..<size).map { col in (row, col) }
        }.shuffled()

        var removed = 0
        for (row, col) in positions {
            if removed >= cellsToRemove { break }
            let backup = board[row][col]
            board[row][col] = 0

            // 解の一意性チェック（簡易版: 解が存在するかだけ確認）
            if countSolutions(board: board, gridSize: gridSize) == 1 {
                removed += 1
            } else {
                // 一意性が失われる場合は復元
                board[row][col] = backup
            }
        }

        return board
    }

    /// 難易度と盤面サイズに応じた削除セル数
    private func removeCellCount(gridSize: GridSize, difficulty: Difficulty) -> Int {
        let total = gridSize.rawValue * gridSize.rawValue
        let ratio: Double
        switch (gridSize, difficulty) {
        case (.small, .beginner):  ratio = 0.25
        case (.small, .easy):      ratio = 0.38
        case (.small, .medium):    ratio = 0.50
        case (.small, _):          ratio = 0.56

        case (.medium, .beginner): ratio = 0.33
        case (.medium, .easy):     ratio = 0.42
        case (.medium, .medium):   ratio = 0.50
        case (.medium, _):         ratio = 0.58

        case (.large, .beginner):  ratio = 0.44
        case (.large, .easy):      ratio = 0.50
        case (.large, .medium):    ratio = 0.56
        case (.large, .hard):      ratio = 0.61
        case (.large, .expert):    ratio = 0.67
        }
        return Int(Double(total) * ratio)
    }

    // MARK: - Uniqueness Check

    /// 解の個数をカウント（最大2まで。2以上なら非一意と判断）
    private func countSolutions(board: [[Int]], gridSize: GridSize, limit: Int = 2) -> Int {
        var board = board
        var count = 0
        solve(board: &board, gridSize: gridSize, count: &count, limit: limit)
        return count
    }

    private func solve(board: inout [[Int]], gridSize: GridSize, count: inout Int, limit: Int) {
        guard count < limit else { return }
        let size = gridSize.rawValue

        for row in 0..<size {
            for col in 0..<size {
                guard board[row][col] == 0 else { continue }

                for num in 1...size {
                    if validator.isPlacementValid(board: board, row: row, col: col, value: num, gridSize: gridSize) {
                        board[row][col] = num
                        solve(board: &board, gridSize: gridSize, count: &count, limit: limit)
                        board[row][col] = 0
                    }
                }
                return
            }
        }
        count += 1
    }
}
