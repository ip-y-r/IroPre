// MARK: - レベル選択画面 ViewModel
import Foundation

@Observable
final class LevelSelectViewModel {
    var selectedGridSize: GridSize = .small

    private var clearedLevels: Set<Int> = []
    private let repository: GameRepositoryProtocol

    init(repository: GameRepositoryProtocol = GameRepository()) {
        self.repository = repository
    }

    @MainActor
    func loadClearedLevels() async {
        let records = (try? await repository.loadAllClearRecords()) ?? []
        let currentGridSize = selectedGridSize.rawValue
        clearedLevels = Set(records.filter { $0.gridSize == currentGridSize }.map { $0.level })
    }

    func levels(for gridSize: GridSize) -> [Int] {
        Array(gridSize.levelRange)
    }

    func isCleared(level: Int) -> Bool {
        clearedLevels.contains(level)
    }
}
