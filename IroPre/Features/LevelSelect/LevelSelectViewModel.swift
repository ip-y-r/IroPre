// MARK: - レベル選択画面 ViewModel
import Foundation

@Observable
final class LevelSelectViewModel {
    var selectedGridSize: GridSize = .small

    func levels(for gridSize: GridSize) -> [Int] {
        Array(gridSize.levelRange)
    }

    func isCleared(level: Int) -> Bool {
        // TODO: Phase 2 でリポジトリと接続
        return false
    }
}
