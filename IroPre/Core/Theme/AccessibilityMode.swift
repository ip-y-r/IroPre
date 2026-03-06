// MARK: - アクセシビリティモード定義
import SwiftUI

/// 色覚多様性対応モード（PRD 3.5）
enum AccessibilityDisplayMode: String, CaseIterable, Sendable {
    /// 通常の色表示
    case color = "color"
    /// 色にパターンオーバーレイを重ねる
    case pattern = "pattern"
    /// 色の代わりにシンボルで表示
    case symbol = "symbol"

    var displayName: String {
        switch self {
        case .color:   return "カラー"
        case .pattern: return "パターン"
        case .symbol:  return "シンボル"
        }
    }

    var description: String {
        switch self {
        case .color:   return "通常の色表示"
        case .pattern: return "色にパターンを重ねて表示（色覚サポート）"
        case .symbol:  return "色の代わりに記号で表示（色覚サポート）"
        }
    }
}

// MARK: - アクセシビリティパターン

/// 各色に割り当てられたパターン識別子
enum CellPattern: Int, CaseIterable, Sendable {
    case solid     = 1  // 無地
    case dots      = 2  // ドット
    case stripes   = 3  // ストライプ
    case grid      = 4  // グリッド
    case diagonal  = 5  // 斜め線
    case crosshatch = 6 // クロスハッチ
    case circles   = 7  // 小円
    case zigzag    = 8  // ジグザグ
    case waves     = 9  // 波

    static func pattern(for colorIndex: Int) -> CellPattern {
        CellPattern(rawValue: colorIndex) ?? .solid
    }
}

// MARK: - アクセシビリティシンボル

/// 各色に割り当てられたSF Symbolsアイコン
enum CellSymbol: Int, CaseIterable, Sendable {
    case circle    = 1
    case square    = 2
    case triangle  = 3
    case star      = 4
    case diamond   = 5
    case pentagon  = 6
    case heart     = 7
    case cross     = 8
    case moon      = 9

    var sfSymbolName: String {
        switch self {
        case .circle:   return "circle.fill"
        case .square:   return "square.fill"
        case .triangle: return "triangle.fill"
        case .star:     return "star.fill"
        case .diamond:  return "diamond.fill"
        case .pentagon: return "pentagon.fill"
        case .heart:    return "heart.fill"
        case .cross:    return "cross.fill"
        case .moon:     return "moon.fill"
        }
    }

    static func symbol(for colorIndex: Int) -> CellSymbol {
        CellSymbol(rawValue: colorIndex) ?? .circle
    }
}
