// MARK: - 盤面 View
import SwiftUI

struct BoardView: View {
    let gameState: GameState
    var isDarkMode: Bool = false
    var displayMode: AccessibilityDisplayMode = .color
    var selectedPosition: CellPosition? = nil
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
                                    isSelected: selectedPosition == CellPosition(row: row, col: col),
                                    isDarkMode: isDarkMode,
                                    displayMode: displayMode
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
    let isDarkMode: Bool
    var displayMode: AccessibilityDisplayMode = .color

    var body: some View {
        ZStack {
            // セル背景
            Rectangle()
                .fill(backgroundColor)
                .overlay(
                    Rectangle()
                        .stroke(ColorPalette.cellBorder, lineWidth: 0.5)
                )

            // 選択ハイライト
            if isSelected && !cell.isPreset {
                Rectangle()
                    .fill(ColorPalette.accent.opacity(0.15))
            }

            // 色（配置時スプリングアニメーション）
            if !cell.isEmpty {
                RoundedRectangle(cornerRadius: 6)
                    .fill(colorForCell)
                    .padding(4)
                    .shadow(color: colorForCell.opacity(0.4), radius: 3, x: 0, y: 2)
                    .transition(.scale(scale: 0.3, anchor: .center).combined(with: .opacity))

                // 色覚対応オーバーレイ
                switch displayMode {
                case .pattern:
                    PatternOverlayView(pattern: CellPattern.pattern(for: cell.colorIndex))
                        .padding(4)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                case .symbol:
                    Image(systemName: CellSymbol.symbol(for: cell.colorIndex).sfSymbolName)
                        .font(.system(size: symbolSize, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                case .color:
                    EmptyView()
                }
            }

            // エラーハイライト
            if cell.isError {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(ColorPalette.error, lineWidth: 2)
                    .padding(4)
            }

            // 選択枠
            if isSelected && !cell.isPreset {
                Rectangle()
                    .stroke(ColorPalette.accent, lineWidth: 1.5)
            }
        }
        .animation(
            .spring(
                response: Constants.Animation.colorPlaceResponse,
                dampingFraction: Constants.Animation.colorPlaceDamping
            ),
            value: cell.colorIndex
        )
        // MARK: VoiceOver
        .accessibilityElement()
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint(accessibilityHintText)
        .accessibilityAddTraits(cell.isPreset ? .isStaticText : [])
    }

    // MARK: - Private

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
        return puzzleColor.color(isDarkMode: isDarkMode)
    }

    private var symbolSize: CGFloat {
        switch gridSize {
        case .small:  return 18
        case .medium: return 14
        case .large:  return 10
        }
    }

    private var accessibilityLabelText: String {
        let position = "\(cell.row + 1)行\(cell.col + 1)列"
        if cell.isEmpty {
            return "\(position) 空きマス"
        }
        let colorName = ColorPalette.color(for: cell.colorIndex)?.localizedName ?? "不明"
        let preset = cell.isPreset ? "（固定）" : ""
        let error = cell.isError ? "（エラー）" : ""
        return "\(position) \(colorName)\(preset)\(error)"
    }

    private var accessibilityHintText: String {
        if cell.isPreset { return "" }
        if cell.isEmpty { return "タップして色を配置します" }
        return "タップして色を変更します"
    }
}

// MARK: - PatternOverlayView（色覚多様性対応パターン）

private struct PatternOverlayView: View {
    let pattern: CellPattern

    var body: some View {
        Canvas { context, size in
            switch pattern {
            case .solid:
                break
            case .dots:
                drawDots(context: context, size: size)
            case .stripes:
                drawStripes(context: context, size: size)
            case .grid:
                drawGrid(context: context, size: size)
            case .diagonal:
                drawDiagonal(context: context, size: size)
            case .crosshatch:
                drawCrosshatch(context: context, size: size)
            case .circles:
                drawCircles(context: context, size: size)
            case .zigzag:
                drawZigzag(context: context, size: size)
            case .waves:
                drawWaves(context: context, size: size)
            }
        }
    }

    private func drawDots(context: GraphicsContext, size: CGSize) {
        let spacing: CGFloat = 8
        var x: CGFloat = 4
        while x < size.width {
            var y: CGFloat = 4
            while y < size.height {
                context.fill(Path(ellipseIn: CGRect(x: x - 2, y: y - 2, width: 4, height: 4)), with: .color(.white.opacity(0.55)))
                y += spacing
            }
            x += spacing
        }
    }

    private func drawStripes(context: GraphicsContext, size: CGSize) {
        let spacing: CGFloat = 6
        var x: CGFloat = 0
        while x < size.width + size.height {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x - size.height, y: size.height))
            context.stroke(path, with: .color(.white.opacity(0.4)), lineWidth: 2)
            x += spacing
        }
    }

    private func drawGrid(context: GraphicsContext, size: CGSize) {
        let spacing: CGFloat = 8
        var x: CGFloat = spacing
        while x < size.width {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            context.stroke(path, with: .color(.white.opacity(0.4)), lineWidth: 1)
            x += spacing
        }
        var y: CGFloat = spacing
        while y < size.height {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(path, with: .color(.white.opacity(0.4)), lineWidth: 1)
            y += spacing
        }
    }

    private func drawDiagonal(context: GraphicsContext, size: CGSize) {
        let spacing: CGFloat = 7
        var x: CGFloat = -size.height
        while x < size.width {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x + size.height, y: size.height))
            context.stroke(path, with: .color(.white.opacity(0.45)), lineWidth: 2)
            x += spacing
        }
    }

    private func drawCrosshatch(context: GraphicsContext, size: CGSize) {
        drawStripes(context: context, size: size)
        let spacing: CGFloat = 6
        var x: CGFloat = 0
        while x < size.width + size.height {
            var path = Path()
            path.move(to: CGPoint(x: size.width - x, y: 0))
            path.addLine(to: CGPoint(x: size.width - x + size.height, y: size.height))
            context.stroke(path, with: .color(.white.opacity(0.35)), lineWidth: 2)
            x += spacing
        }
    }

    private func drawCircles(context: GraphicsContext, size: CGSize) {
        let radii: [CGFloat] = [size.width * 0.15, size.width * 0.3, size.width * 0.45]
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        for r in radii {
            let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
            context.stroke(Path(ellipseIn: rect), with: .color(.white.opacity(0.45)), lineWidth: 1.5)
        }
    }

    private func drawZigzag(context: GraphicsContext, size: CGSize) {
        let segW: CGFloat = 6
        let amp: CGFloat = 5
        var path = Path()
        var x: CGFloat = 0
        var goUp = true
        path.move(to: CGPoint(x: 0, y: size.height / 2))
        while x < size.width {
            x += segW
            let y = goUp ? size.height / 2 - amp : size.height / 2 + amp
            path.addLine(to: CGPoint(x: x, y: y))
            goUp.toggle()
        }
        context.stroke(path, with: .color(.white.opacity(0.55)), lineWidth: 2)
    }

    private func drawWaves(context: GraphicsContext, size: CGSize) {
        for offset in [size.height * 0.35, size.height * 0.65] {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: offset))
            var x: CGFloat = 0
            while x < size.width {
                path.addCurve(
                    to: CGPoint(x: x + 6, y: offset),
                    control1: CGPoint(x: x + 1.5, y: offset - 4),
                    control2: CGPoint(x: x + 4.5, y: offset + 4)
                )
                x += 6
            }
            context.stroke(path, with: .color(.white.opacity(0.5)), lineWidth: 1.5)
        }
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
        .allowsHitTesting(false)
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
    BoardView(
        gameState: GameState(puzzle: puzzle),
        isDarkMode: false,
        selectedPosition: CellPosition(row: 1, col: 1)
    )
    .frame(width: 300, height: 300)
    .padding()
}
