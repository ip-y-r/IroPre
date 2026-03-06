// MARK: - 盤面 View
import SwiftUI

struct BoardView: View {
    let gameState: GameState
    var isDarkMode: Bool = false
    var displayMode: AccessibilityDisplayMode = .color
    var selectedPosition: CellPosition? = nil
    var onCellTap: ((Int, Int) -> Void)?

    private var gridSize: GridSize { gameState.puzzle.gridSize }
    private var n: Int { gridSize.rawValue }
    private var numBlockCols: Int { n / gridSize.blockCols }
    private var numBlockRows: Int { n / gridSize.blockRows }

    /// ボード内余白 8pt、セル間隔 3pt、ブロック間隔 6pt からセルサイズを逆算
    private func cellSize(for boardWidth: CGFloat) -> CGFloat {
        let inner = boardWidth - 16
        // 水平方向の総間隔: セル間は 3pt × (n-1) ＋ ブロック境界に追加 3pt × (numBlockCols-1)
        let spacing = CGFloat(n - 1) * 3 + CGFloat(numBlockCols - 1) * 3
        return (inner - spacing) / CGFloat(n)
    }

    var body: some View {
        GeometryReader { geo in
            let cs = cellSize(for: geo.size.width)

            ZStack {
                // ボード背景
                RoundedRectangle(cornerRadius: 16)
                    .fill(ColorPalette.boardBackground(isDark: isDarkMode))
                    .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)

                // セルグリッド（ブロックグループ方式）
                VStack(spacing: 6) {
                    ForEach(0..<numBlockRows, id: \.self) { br in
                        HStack(spacing: 6) {
                            ForEach(0..<numBlockCols, id: \.self) { bc in
                                VStack(spacing: 3) {
                                    ForEach(0..<gridSize.blockRows, id: \.self) { r in
                                        HStack(spacing: 3) {
                                            ForEach(0..<gridSize.blockCols, id: \.self) { c in
                                                let row = br * gridSize.blockRows + r
                                                let col = bc * gridSize.blockCols + c
                                                CellView(
                                                    cell: gameState.cells[row][col],
                                                    gridSize: gridSize,
                                                    isSelected: selectedPosition == CellPosition(row: row, col: col),
                                                    isDarkMode: isDarkMode,
                                                    displayMode: displayMode
                                                )
                                                .frame(width: cs, height: cs)
                                                .onTapGesture { onCellTap?(row, col) }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(8)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - CellView

struct CellView: View {
    let cell: Cell
    let gridSize: GridSize
    let isSelected: Bool
    let isDarkMode: Bool
    var displayMode: AccessibilityDisplayMode = .color

    private var cellColor: Color? {
        guard !cell.isEmpty,
              let puzzleColor = ColorPalette.color(for: cell.colorIndex) else { return nil }
        return puzzleColor.color(isDarkMode: isDarkMode)
    }

    var body: some View {
        ZStack {
            // 3D グラデーション背景
            RoundedRectangle(cornerRadius: 10)
                .fill(cellGradient)
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)

            // 色覚対応オーバーレイ
            if !cell.isEmpty {
                switch displayMode {
                case .pattern:
                    PatternOverlayView(pattern: CellPattern.pattern(for: cell.colorIndex))
                        .padding(4)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .symbol:
                    Image(systemName: CellSymbol.symbol(for: cell.colorIndex).sfSymbolName)
                        .font(.system(size: symbolFontSize, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                case .color:
                    EmptyView()
                }
            }

            // 選択リング
            if isSelected && !cell.isPreset {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(ColorPalette.accent, lineWidth: 2.5)
            }

            // エラーリング
            if cell.isError {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(ColorPalette.error, lineWidth: 2)
            }
        }
        .animation(
            .spring(response: Constants.Animation.colorPlaceResponse,
                    dampingFraction: Constants.Animation.colorPlaceDamping),
            value: cell.colorIndex
        )
        .accessibilityElement()
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint(accessibilityHintText)
        .accessibilityAddTraits(cell.isPreset ? .isStaticText : [])
    }

    // MARK: - Private

    private var cellGradient: AnyShapeStyle {
        if let color = cellColor {
            return AnyShapeStyle(LinearGradient(
                colors: [color.opacity(0.93), color],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        }
        return AnyShapeStyle(ColorPalette.emptyCellFill(isDark: isDarkMode))
    }

    private var shadowColor: Color {
        if let color = cellColor { return color.opacity(0.35) }
        return .black.opacity(isDarkMode ? 0.25 : 0.07)
    }

    private var shadowRadius: CGFloat { cellColor != nil ? 4 : 2 }
    private var shadowY: CGFloat    { cellColor != nil ? 4 : 2 }

    private var symbolFontSize: CGFloat {
        switch gridSize {
        case .small:  return 18
        case .medium: return 13
        case .large:  return 10
        }
    }

    private var accessibilityLabelText: String {
        let pos = "\(cell.row + 1)行\(cell.col + 1)列"
        if cell.isEmpty { return "\(pos) 空きマス" }
        let name = ColorPalette.color(for: cell.colorIndex)?.localizedName ?? "不明"
        return "\(pos) \(name)\(cell.isPreset ? "（固定）" : "")\(cell.isError ? "（エラー）" : "")"
    }

    private var accessibilityHintText: String {
        if cell.isPreset { return "" }
        return cell.isEmpty ? "タップして色を配置します" : "タップして色を変更します"
    }
}

// MARK: - PatternOverlayView（色覚多様性対応パターン）

private struct PatternOverlayView: View {
    let pattern: CellPattern

    var body: some View {
        Canvas { context, size in
            switch pattern {
            case .solid:      break
            case .dots:       drawDots(context: context, size: size)
            case .stripes:    drawStripes(context: context, size: size)
            case .grid:       drawGrid(context: context, size: size)
            case .diagonal:   drawDiagonal(context: context, size: size)
            case .crosshatch: drawCrosshatch(context: context, size: size)
            case .circles:    drawCircles(context: context, size: size)
            case .zigzag:     drawZigzag(context: context, size: size)
            case .waves:      drawWaves(context: context, size: size)
            }
        }
    }

    private func drawDots(context: GraphicsContext, size: CGSize) {
        let spacing: CGFloat = 8
        var x: CGFloat = 4
        while x < size.width {
            var y: CGFloat = 4
            while y < size.height {
                context.fill(Path(ellipseIn: CGRect(x: x-2, y: y-2, width: 4, height: 4)),
                             with: .color(.white.opacity(0.55)))
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
        let segW: CGFloat = 6, amp: CGFloat = 5
        var path = Path()
        var x: CGFloat = 0, goUp = true
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

#Preview {
    let puzzle = Puzzle(
        id: "preview", level: 1, gridSize: .small, difficulty: .beginner,
        initialBoard: [[1,0,0,4],[0,3,1,0],[0,1,4,0],[4,0,0,2]],
        solution:     [[1,2,3,4],[4,3,1,2],[2,1,4,3],[3,4,2,1]]
    )
    BoardView(gameState: GameState(puzzle: puzzle), isDarkMode: false,
              selectedPosition: CellPosition(row: 1, col: 1))
        .frame(width: 300, height: 300)
        .padding()
}
