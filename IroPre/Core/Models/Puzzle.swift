// MARK: - パズルモデル
import Foundation

/// パズルの盤面サイズ
enum GridSize: Int, CaseIterable, Codable, Sendable {
    case small = 4   // 4×4
    case medium = 6  // 6×6
    case large = 9   // 9×9

    /// ブロックサイズ（行数 × 列数）
    var blockRows: Int {
        switch self {
        case .small: return 2
        case .medium: return 2
        case .large: return 3
        }
    }

    var blockCols: Int {
        switch self {
        case .small: return 2
        case .medium: return 3
        case .large: return 3
        }
    }

    /// レベル範囲
    var levelRange: ClosedRange<Int> {
        switch self {
        case .small: return 1...20
        case .medium: return 21...50
        case .large: return 51...100
        }
    }

    var displayName: String {
        "\(rawValue)×\(rawValue)"
    }
}

/// 難易度
enum Difficulty: String, CaseIterable, Codable, Sendable {
    case beginner
    case easy
    case medium
    case hard
    case expert
}

/// パズルデータ
struct Puzzle: Identifiable, Sendable {
    let id: String
    let level: Int
    let gridSize: GridSize
    let difficulty: Difficulty
    /// ヒントとして配置済みの盤面（0=空き）
    let initialBoard: [[Int]]
    /// 正解の盤面
    let solution: [[Int]]

    var colorCount: Int { gridSize.rawValue }

    /// 空きマス数
    var emptyCellCount: Int {
        initialBoard.flatMap { $0 }.filter { $0 == 0 }.count
    }

    /// 盤面の全セルを Cell 配列で返す
    func makeCells() -> [[Cell]] {
        (0..<gridSize.rawValue).map { row in
            (0..<gridSize.rawValue).map { col in
                let value = initialBoard[row][col]
                return Cell(row: row, col: col, colorIndex: value, isPreset: value != 0)
            }
        }
    }
}
