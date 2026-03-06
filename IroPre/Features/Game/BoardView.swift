// MARK: - 盤面 View
import SwiftUI

struct BoardView: View {
    let gameState: GameState
    var onCellTap: ((Int, Int) -> Void)?

    private var gridSize: GridSize { gameState.puzzle.gridSize }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width
            let cellSize = size / CGFloat(gridSize.rawValue)

            ZStack {
                // セルグリッド
                VStack(spacing: 0) {
                    ForEach(0..<gridSize.rawValue, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<gridSize.rawValue, id: \.self) { col in
                                CellView(
                                    cell: gameState.cells[row][col],
                                    gridSize: gridSize,
                                    isSelected: gameState.selectedColorIndex != nil
                                )
                                .frame(width: cellSize, height: cellSize)
                                .onTapGesture {
                                    onCellTap?(row, col)
                                }
                            }
                        }
                    }
                }

                // ブロック境界線（太線）
                BlockBorderView(gridSize: gridSize, totalSize: size)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(ColorPalette.blockBorder, lineWidth: 2)
        )
    }
}

// MARK: - CellView

struct CellView: View {
    let cell: Cell
    let gridSize: GridSize
    let isSelected: Bool

    var body: some View {
        ZStack {
            // セル背景
            Rectangle()
                .fill(backgroundColor)
                .overlay(
                    Rectangle()
                        .stroke(ColorPalette.cellBorder, lineWidth: 0.5)
                )

            // 色
            if !cell.isEmpty {
                RoundedRectangle(cornerRadius: 6)
                    .fill(colorForCell)
                    .padding(4)
                    .shadow(color: colorForCell.opacity(0.4), radius: 3, x: 0, y: 2)
            }

            // エラーハイライト
            if cell.isError {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(ColorPalette.error, lineWidth: 2)
                    .padding(4)
            }
        }
    }

    private var backgroundColor: Color {
        if cell.isPreset {
            return Color(.systemGray5)
        }
        return Color(.systemBackground)
    }

    private var colorForCell: Color {
        guard let puzzleColor = ColorPalette.color(for: cell.colorIndex) else {
            return .clear
        }
        return puzzleColor.light  // TODO: Phase 3 でダークモード対応
    }
}

// MARK: - BlockBorderView（ブロック境界の太線）

private struct BlockBorderView: View {
    let gridSize: GridSize
    let totalSize: CGFloat

    var body: some View {
        Canvas { context, _ in
            let cellSize = totalSize / CGFloat(gridSize.rawValue)
            let blockBorderWidth: CGFloat = 2.5

            context.stroke(
                blockBorderPath(cellSize: cellSize),
                with: .color(ColorPalette.blockBorder),
                lineWidth: blockBorderWidth
            )
        }
    }

    private func blockBorderPath(cellSize: CGFloat) -> Path {
        var path = Path()
        let size = gridSize.rawValue

        // 水平線（ブロック境界）
        for row in stride(from: 0, through: size, by: gridSize.blockRows) {
            let y = CGFloat(row) * cellSize
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: totalSize, y: y))
        }

        // 垂直線（ブロック境界）
        for col in stride(from: 0, through: size, by: gridSize.blockCols) {
            let x = CGFloat(col) * cellSize
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: totalSize))
        }

        return path
    }
}

#Preview {
    let puzzle = Puzzle(
        id: "preview",
        level: 1,
        gridSize: .small,
        difficulty: .beginner,
        initialBoard: [[1, 0, 0, 4], [0, 3, 1, 0], [0, 1, 4, 0], [4, 0, 0, 2]],
        solution:     [[1, 2, 3, 4], [4, 3, 1, 2], [2, 1, 4, 3], [3, 4, 2, 1]]
    )
    BoardView(gameState: GameState(puzzle: puzzle))
        .frame(width: 300, height: 300)
        .padding()
}
