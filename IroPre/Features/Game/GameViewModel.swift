// MARK: - ゲーム画面 ViewModel
import Foundation

@MainActor
@Observable
final class GameViewModel {
    private let level: Int
    private let gridSize: GridSize
    private let generator: PuzzleGenerating
    private let validator: PuzzleValidating
    private let hintEngine: HintProviding
    private let repository: GameRepositoryProtocol

    var gameState: GameState?
    var isPaused: Bool = false
    var selectedCellPosition: CellPosition?
    var errorPositions: Set<CellPosition> = []

    private var timerTask: Task<Void, Never>?

    init(
        level: Int,
        gridSize: GridSize,
        generator: PuzzleGenerating = PuzzleGenerator(),
        validator: PuzzleValidating = PuzzleValidator(),
        hintEngine: HintProviding = HintEngine(),
        repository: GameRepositoryProtocol = GameRepository()
    ) {
        self.level = level
        self.gridSize = gridSize
        self.generator = generator
        self.validator = validator
        self.hintEngine = hintEngine
        self.repository = repository
    }

    // MARK: - Puzzle Loading

    func loadPuzzle() async {
        let difficulty = difficulty(for: level)
        let result = generator.generate(gridSize: gridSize, difficulty: difficulty, level: level)
        switch result {
        case let .success(puzzle):
            gameState = GameState(puzzle: puzzle)
            startTimer()
        case let .failure(error):
            print("パズル生成失敗: \(error)")
        }
    }

    // MARK: - Timer

    func startTimer() {
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                if gameState?.phase == .playing {
                    gameState?.elapsedTime += 1
                }
            }
        }
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    // MARK: - Game Actions

    func selectColor(_ index: Int) {
        guard let state = gameState else { return }
        if state.selectedColorIndex == index {
            state.selectedColorIndex = nil
        } else {
            state.selectedColorIndex = index
        }
    }

    func tapCell(row: Int, col: Int) {
        guard let state = gameState, state.phase == .playing else { return }
        errorPositions.removeAll()
        selectedCellPosition = CellPosition(row: row, col: col)

        if state.placeColor(row: row, col: col) {
            checkCompletion()
        }
    }

    func undo() {
        gameState?.undo()
        errorPositions.removeAll()
    }

    func eraseSelectedCell() {
        guard let pos = selectedCellPosition else { return }
        gameState?.eraseCell(row: pos.row, col: pos.col)
        errorPositions.removeAll()
    }

    func requestHint() {
        guard let state = gameState else { return }
        guard let pos = selectedCellPosition else { return }

        let result = hintEngine.provideHint(type: .cellHint(row: pos.row, col: pos.col), state: state)
        switch result {
        case let .cellHint(row, col, colorIndex):
            state.cells[row][col].colorIndex = colorIndex
            state.hintsUsed += 1
            checkCompletion()
        case .alreadyCorrect, .limitReached:
            break
        default:
            break
        }
    }

    func pause() {
        gameState?.phase = .paused
        isPaused = true
        stopTimer()
    }

    func resume() {
        gameState?.phase = .playing
        isPaused = false
        startTimer()
    }

    // MARK: - Star Rating

    var starRating: Int {
        guard let state = gameState else { return 1 }
        if state.hintsUsed == 0 { return 3 }
        if state.hintsUsed <= 1 { return 2 }
        return 1
    }

    // MARK: - Private

    private func checkCompletion() {
        guard let state = gameState else { return }
        guard state.isBoardFull else { return }

        if validator.isComplete(board: state.currentBoardArray, gridSize: state.puzzle.gridSize) {
            state.phase = .completed
            stopTimer()
            Task { await saveClearRecord() }
        }
    }

    private func saveClearRecord() async {
        guard let state = gameState else { return }
        let record = ClearRecord(
            puzzleId: state.puzzle.id,
            level: state.puzzle.level,
            gridSize: state.puzzle.gridSize.rawValue,
            clearTime: state.elapsedTime,
            hintsUsed: state.hintsUsed,
            starRating: starRating,
            score: computeScore(state: state)
        )
        try? await repository.saveClearRecord(record)
    }

    private func computeScore(state: GameState) -> Int {
        let timeBonus = max(0, 1000 - Int(state.elapsedTime))
        let hintPenalty = state.hintsUsed * 100
        return max(0, timeBonus - hintPenalty + 500)
    }

    private func difficulty(for level: Int) -> Difficulty {
        switch level {
        case 1...10:  return .beginner
        case 11...30: return .easy
        case 31...60: return .medium
        case 61...85: return .hard
        default:      return .expert
        }
    }
}
