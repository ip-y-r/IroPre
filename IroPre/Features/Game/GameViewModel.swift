// MARK: - ゲーム画面 ViewModel
import Foundation

@Observable
final class GameViewModel {
    private let level: Int
    private let gridSize: GridSize
    private let generator: PuzzleGenerating
    private let validator: PuzzleValidating
    private let hintEngine: HintProviding

    var gameState: GameState?
    var isPaused: Bool = false
    var selectedCellPosition: CellPosition?
    var errorPositions: Set<CellPosition> = []

    init(
        level: Int,
        gridSize: GridSize,
        generator: PuzzleGenerating = PuzzleGenerator(),
        validator: PuzzleValidating = PuzzleValidator(),
        hintEngine: HintProviding = HintEngine()
    ) {
        self.level = level
        self.gridSize = gridSize
        self.generator = generator
        self.validator = validator
        self.hintEngine = hintEngine
    }

    // MARK: - Puzzle Loading

    @MainActor
    func loadPuzzle() async {
        // TODO: Phase 2 でプリセット読み込みと動的生成のハイブリッドに切り替え
        let difficulty = difficulty(for: level)
        let result = generator.generate(gridSize: gridSize, difficulty: difficulty, level: level)
        switch result {
        case let .success(puzzle):
            gameState = GameState(puzzle: puzzle)
        case let .failure(error):
            print("パズル生成失敗: \(error)")
        }
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
        case .alreadyCorrect:
            break
        case .limitReached:
            break
        default:
            break
        }
    }

    func pause() {
        gameState?.phase = .paused
        isPaused = true
    }

    func resume() {
        gameState?.phase = .playing
        isPaused = false
    }

    // MARK: - Private

    private func checkCompletion() {
        guard let state = gameState else { return }
        guard state.isBoardFull else { return }

        if validator.isComplete(board: state.currentBoardArray, gridSize: state.puzzle.gridSize) {
            state.phase = .completed
        }
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
