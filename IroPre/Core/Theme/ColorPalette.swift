// MARK: - カラーパレット定義（ライト9色 + ダーク9色）
import SwiftUI

/// パズルに使用する色の定義（PRD 3.4）
struct PuzzleColor: Sendable {
    let index: Int        // 1〜9
    let nameKey: String   // ローカライズキー
    let light: Color
    let dark: Color

    func color(isDarkMode: Bool) -> Color {
        isDarkMode ? dark : light
    }

    /// VoiceOver 用の日本語色名
    var localizedName: String {
        switch nameKey {
        case "color.red":    return "赤"
        case "color.blue":   return "青"
        case "color.green":  return "緑"
        case "color.yellow": return "黄"
        case "color.purple": return "紫"
        case "color.orange": return "オレンジ"
        case "color.pink":   return "ピンク"
        case "color.cyan":   return "シアン"
        case "color.lime":   return "黄緑"
        default:             return nameKey
        }
    }
}

/// カラーパレット管理
enum ColorPalette {
    // MARK: - ライトモード9色 + ダークモード9色

    static let puzzleColors: [PuzzleColor] = [
        PuzzleColor(
            index: 1,
            nameKey: "color.red",
            light: Color(hex: "#FF6B6B"),
            dark:  Color(hex: "#E74C3C")
        ),
        PuzzleColor(
            index: 2,
            nameKey: "color.blue",
            light: Color(hex: "#4A90D9"),
            dark:  Color(hex: "#3498DB")
        ),
        PuzzleColor(
            index: 3,
            nameKey: "color.green",
            light: Color(hex: "#27AE60"),
            dark:  Color(hex: "#2ECC71")
        ),
        PuzzleColor(
            index: 4,
            nameKey: "color.yellow",
            light: Color(hex: "#F1C40F"),
            dark:  Color(hex: "#F39C12")
        ),
        PuzzleColor(
            index: 5,
            nameKey: "color.purple",
            light: Color(hex: "#9B59B6"),
            dark:  Color(hex: "#8E44AD")
        ),
        PuzzleColor(
            index: 6,
            nameKey: "color.orange",
            light: Color(hex: "#E67E22"),
            dark:  Color(hex: "#D35400")
        ),
        PuzzleColor(
            index: 7,
            nameKey: "color.pink",
            light: Color(hex: "#FF9FF3"),
            dark:  Color(hex: "#FD79A8")
        ),
        PuzzleColor(
            index: 8,
            nameKey: "color.cyan",
            light: Color(hex: "#00CEC9"),
            dark:  Color(hex: "#00B894")
        ),
        PuzzleColor(
            index: 9,
            nameKey: "color.lime",
            light: Color(hex: "#BADC58"),
            dark:  Color(hex: "#6AB04C")
        )
    ]

    // MARK: - アクセサ

    /// インデックス（1〜9）から PuzzleColor を取得
    static func color(for index: Int) -> PuzzleColor? {
        guard index >= 1 && index <= puzzleColors.count else { return nil }
        return puzzleColors[index - 1]
    }

    /// 盤面サイズに応じたパレットカラーのサブセット
    static func colors(for gridSize: GridSize) -> [PuzzleColor] {
        Array(puzzleColors.prefix(gridSize.rawValue))
    }

    // MARK: - UI カラー

    static let background = Color("AppBackground")
    static let surface = Color("AppSurface")
    static let primaryText = Color("AppPrimaryText")
    static let secondaryText = Color("AppSecondaryText")
    static let accent = Color(hex: "#4A90D9")
    static let error = Color(hex: "#FF3B30")
    static let cellBorder = Color(hex: "#C0C0C0")
    static let blockBorder = Color(hex: "#2C3E50")
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
