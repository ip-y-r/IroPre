// MARK: - セルモデル
import Foundation

/// 盤面上の位置を表す型
struct CellPosition: Equatable, Hashable, Sendable {
    let row: Int
    let col: Int
}

/// パズル盤面の1マスを表すモデル
struct Cell: Identifiable, Equatable, Sendable {
    let id: UUID
    let row: Int
    let col: Int
    /// セルに配置された色インデックス（0=空き、1〜N=色番号）
    var colorIndex: Int
    /// 初期配置（ヒントマス）かどうか
    let isPreset: Bool
    /// エラーハイライト状態
    var isError: Bool

    init(row: Int, col: Int, colorIndex: Int, isPreset: Bool) {
        self.id = UUID()
        self.row = row
        self.col = col
        self.colorIndex = colorIndex
        self.isPreset = isPreset
        self.isError = false
    }

    /// 空きマスかどうか
    var isEmpty: Bool { colorIndex == 0 }

    /// ユーザーが変更可能かどうか
    var isEditable: Bool { !isPreset }
}
