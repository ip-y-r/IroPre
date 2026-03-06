// MARK: - カラーパレット View（カラーファースト操作）
import SwiftUI

struct PaletteView: View {
    let gridSize: GridSize
    let selectedColorIndex: Int?
    let isDarkMode: Bool
    let onColorSelected: (Int) -> Void

    private var colors: [PuzzleColor] { ColorPalette.colors(for: gridSize) }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(colors, id: \.index) { puzzleColor in
                PaletteColorButton(
                    puzzleColor: puzzleColor,
                    isSelected: selectedColorIndex == puzzleColor.index,
                    isDarkMode: isDarkMode,
                    onTap: { onColorSelected(puzzleColor.index) }
                )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorPalette.cardFill(isDark: isDarkMode))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - PaletteColorButton

private struct PaletteColorButton: View {
    let puzzleColor: PuzzleColor
    let isSelected: Bool
    let isDarkMode: Bool
    let onTap: () -> Void

    private var color: Color { puzzleColor.color(isDarkMode: isDarkMode) }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 選択時のダブルリング（外側: カード背景色、内側: その色）
                if isSelected {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            isDarkMode ? Color(hex: "#1A1A2E") : Color.white,
                            lineWidth: 3
                        )
                        .padding(-3)

                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(color, lineWidth: 2)
                        .padding(-5)
                }

                // 3D グラデーション本体
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [color.opacity(0.93), color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .shadow(
                        color: color.opacity(isSelected ? 0.55 : 0.3),
                        radius: isSelected ? 8 : 4,
                        x: 0, y: isSelected ? 5 : 3
                    )
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(
                .spring(response: Constants.Animation.paletteSelectResponse,
                        dampingFraction: Constants.Animation.paletteSelectDamping),
                value: isSelected
            )
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(puzzleColor.localizedName)
        .accessibilityHint(isSelected ? "選択中。もう一度タップで解除" : "タップして色を選択")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    VStack(spacing: 16) {
        PaletteView(gridSize: .small, selectedColorIndex: 2, isDarkMode: false, onColorSelected: { _ in })
            .padding()

        PaletteView(gridSize: .large, selectedColorIndex: 5, isDarkMode: true, onColorSelected: { _ in })
            .padding()
            .background(Color(hex: "#0F0F1A"))
    }
}
