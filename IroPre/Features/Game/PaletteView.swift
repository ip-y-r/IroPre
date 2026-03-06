// MARK: - カラーパレット View（カラーファースト操作）
import SwiftUI

struct PaletteView: View {
    let gridSize: GridSize
    let selectedColorIndex: Int?
    let isDarkMode: Bool
    let onColorSelected: (Int) -> Void

    private var colors: [PuzzleColor] { ColorPalette.colors(for: gridSize) }

    var body: some View {
        HStack(spacing: 10) {
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
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - PaletteColorButton

private struct PaletteColorButton: View {
    let puzzleColor: PuzzleColor
    let isSelected: Bool
    let isDarkMode: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(puzzleColor.color(isDarkMode: isDarkMode))
                    .shadow(
                        color: puzzleColor.color(isDarkMode: isDarkMode).opacity(isSelected ? 0.6 : 0.3),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )

                if isSelected {
                    Circle()
                        .strokeBorder(.white, lineWidth: 3)
                }
            }
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isSelected)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(puzzleColor.localizedName)
        .accessibilityHint(isSelected ? "選択中。もう一度タップで解除" : "タップして色を選択")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    VStack {
        PaletteView(
            gridSize: .small,
            selectedColorIndex: 2,
            isDarkMode: false,
            onColorSelected: { _ in }
        )
        .padding()

        PaletteView(
            gridSize: .large,
            selectedColorIndex: 5,
            isDarkMode: true,
            onColorSelected: { _ in }
        )
        .padding()
        .background(.black)
    }
}
