// MARK: - ゲーム画面 View
import SwiftUI

struct GameView: View {
    let level: Int
    let gridSize: GridSize

    @State private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(SettingsViewModel.self) private var settings

    init(level: Int, gridSize: GridSize) {
        self.level = level
        self.gridSize = gridSize
        self._viewModel = State(wrappedValue: GameViewModel(level: level, gridSize: gridSize))
    }

    private var isDark: Bool { settings.isDarkMode }

    var body: some View {
        ZStack {
            ColorPalette.appBackground(isDark: isDark)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダー
                GameHeaderView(
                    level: level,
                    gridSize: gridSize,
                    elapsedTime: viewModel.gameState?.elapsedTime ?? 0,
                    isTimerVisible: settings.isTimerVisible,
                    isDark: isDark,
                    onPause: { viewModel.pause() }
                )
                .padding(.top, 8)

                Spacer()

                // 盤面（ポーズ中は非表示）
                if let gameState = viewModel.gameState {
                    if !viewModel.isPaused {
                        BoardView(
                            gameState: gameState,
                            isDarkMode: isDark,
                            displayMode: settings.accessibilityMode,
                            selectedPosition: viewModel.selectedCellPosition,
                            onCellTap: { row, col in
                                HapticsManager.impact(.medium)
                                SoundManager.shared.play(.place)
                                viewModel.tapCell(row: row, col: col)
                            }
                        )
                        .padding(.horizontal, 16)
                    } else {
                        Color.clear.aspectRatio(1, contentMode: .fit).padding(.horizontal, 16)
                    }

                    Spacer()

                    // ツールバー
                    GameToolbarView(
                        canUndo: !(gameState.moveHistory.isEmpty),
                        hintsRemaining: max(0, Constants.Game.maxHints - gameState.hintsUsed),
                        isDark: isDark,
                        onUndo:       { viewModel.undo() },
                        onErase:      { viewModel.eraseSelectedCell() },
                        onCellHint:   { viewModel.requestHint() },
                        onErrorCheck: { viewModel.requestErrorCheck() },
                        onBlockHint:  { viewModel.requestBlockHint() }
                    )

                    // カラーパレット
                    PaletteView(
                        gridSize: gridSize,
                        selectedColorIndex: gameState.selectedColorIndex,
                        isDarkMode: isDark,
                        onColorSelected: { index in
                            HapticsManager.selection()
                            viewModel.selectColor(index)
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                } else {
                    ProgressView()
                }
            }

            // ポーズオーバーレイ
            if viewModel.isPaused {
                PauseOverlayView(
                    isDark: isDark,
                    onResume: { viewModel.resume() },
                    onLevelSelect: {
                        viewModel.stopTimer()
                        dismiss()
                    },
                    onHome: {
                        viewModel.stopTimer()
                        dismiss()
                    }
                )
            }

            // クリアオーバーレイ
            if viewModel.gameState?.phase == .completed {
                GameClearOverlay(
                    elapsedTime: viewModel.gameState?.elapsedTime ?? 0,
                    hintsUsed: viewModel.gameState?.hintsUsed ?? 0,
                    starRating: viewModel.starRating,
                    isDark: isDark,
                    onDismiss: { dismiss() }
                )
            }
        }
        .navigationBarHidden(true)
        .task { await viewModel.loadPuzzle() }
        .onDisappear { viewModel.stopTimer() }
        .onChange(of: viewModel.gameState?.phase) { _, newPhase in
            if newPhase == .completed {
                HapticsManager.notification(.success)
                SoundManager.shared.play(.clear)
            }
        }
        .onChange(of: viewModel.errorPositions) { _, newPositions in
            if !newPositions.isEmpty {
                HapticsManager.notification(.error)
                SoundManager.shared.play(.error)
            }
        }
    }
}

// MARK: - GameHeaderView

private struct GameHeaderView: View {
    let level: Int
    let gridSize: GridSize
    let elapsedTime: TimeInterval
    let isTimerVisible: Bool
    let isDark: Bool
    let onPause: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            // タイトル行
            HStack {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(ColorPalette.iconColor(isDark: isDark))
                    .padding(4)

                Spacer()

                VStack(spacing: 1) {
                    Text("Level \(level)")
                        .font(.system(size: 12))
                        .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                    Text(gridSize.displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))
                }

                Spacer()

                Button(action: onPause) {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(ColorPalette.iconColor(isDark: isDark))
                        .padding(4)
                }
            }
            .padding(.horizontal, 20)

            // タイマー
            if isTimerVisible {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.system(size: 14))
                        .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                    Text(timeString(elapsedTime))
                        .font(.system(
                            size: gridSize == .large ? 22 : 28,
                            weight: .light,
                            design: .monospaced
                        ))
                        .foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))
                        .monospacedDigit()
                }
            }
        }
    }

    private func timeString(_ time: TimeInterval) -> String {
        let m = Int(time) / 60, s = Int(time) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - GameToolbarView

private struct GameToolbarView: View {
    let canUndo: Bool
    let hintsRemaining: Int
    let isDark: Bool
    let onUndo: () -> Void
    let onErase: () -> Void
    let onCellHint: () -> Void
    let onErrorCheck: () -> Void
    let onBlockHint: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 24) {
                // ヒント（メニュー）
                Menu {
                    Button(action: onCellHint) {
                        Label("マスヒント",    systemImage: "square.dashed")
                    }
                    Button(action: onErrorCheck) {
                        Label("エラーチェック", systemImage: "exclamationmark.triangle.fill")
                    }
                    Button(action: onBlockHint) {
                        Label("ブロックヒント", systemImage: "rectangle.split.2x2.fill")
                    }
                } label: {
                    toolIcon(systemImage: "lightbulb.fill", label: "ヒント")
                }

                // 戻す
                Button(action: onUndo) {
                    toolIcon(systemImage: "arrow.uturn.backward", label: "戻す")
                }
                .disabled(!canUndo)
                .opacity(canUndo ? 1 : 0.4)

                // 消す
                Button(action: onErase) {
                    toolIcon(systemImage: "eraser.fill", label: "消す")
                }
            }
            .padding(.vertical, 8)

            // ヒント残り表示
            HStack(spacing: 4) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 11))
                Text("ヒント残り: \(hintsRemaining)/\(Constants.Game.maxHints) 回")
                    .font(.system(size: 11))
            }
            .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
            .padding(.bottom, 4)
        }
    }

    @ViewBuilder
    private func toolIcon(systemImage: String, label: String) -> some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(ColorPalette.cardFill(isDark: isDark))
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                    .foregroundStyle(ColorPalette.iconColor(isDark: isDark))
            }
            .frame(width: 44, height: 44)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
        }
    }
}

// MARK: - GameClearOverlay

private struct GameClearOverlay: View {
    let elapsedTime: TimeInterval
    let hintsUsed: Int
    let starRating: Int
    let isDark: Bool
    let onDismiss: () -> Void

    private let confettiColors: [Color] = ColorPalette.puzzleColors.map { $0.light }

    var body: some View {
        ZStack {
            ColorPalette.appBackground(isDark: isDark).opacity(0.97).ignoresSafeArea()
            ConfettiView().ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 24) {
                // パーティクルアイコン
                Image(systemName: "sparkles")
                    .font(.system(size: 56))
                    .foregroundStyle(ColorPalette.warningColor)

                Text("クリア！")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))

                Text("Level \(0) を完了しました")
                    .font(FontManager.body())
                    .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))

                // 星評価
                HStack(spacing: 6) {
                    ForEach(1...3, id: \.self) { star in
                        Image(systemName: star <= starRating ? "star.fill" : "star")
                            .font(.system(size: 28))
                            .foregroundStyle(star <= starRating
                                             ? ColorPalette.warningColor
                                             : ColorPalette.secondaryTextColor(isDark: isDark))
                    }
                }

                // ステータス行
                HStack(spacing: 12) {
                    ClearStatCard(icon: "timer",         value: timeString(elapsedTime), label: "タイム",  isDark: isDark)
                    ClearStatCard(icon: "lightbulb.fill", value: "\(hintsUsed)回",       label: "ヒント", isDark: isDark)
                    ClearStatCard(stars: starRating, isDark: isDark)
                }

                // ボタン
                VStack(spacing: 10) {
                    Button(action: onDismiss) {
                        HStack {
                            Text("次のレベルへ")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(ColorPalette.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color(hex: "#4A90D9").opacity(0.4), radius: 8, x: 0, y: 4)
                    }

                    Button(action: onDismiss) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("ホームに戻る")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(ColorPalette.cardFill(isDark: isDark))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding(32)
        }
    }

    private func timeString(_ time: TimeInterval) -> String {
        let m = Int(time) / 60, s = Int(time) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

private struct ClearStatCard: View {
    var icon: String = ""
    var value: String = ""
    var label: String = ""
    var stars: Int = 0
    let isDark: Bool

    var body: some View {
        VStack(spacing: 4) {
            if stars > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundStyle(i < stars ? ColorPalette.warningColor : ColorPalette.secondaryTextColor(isDark: isDark))
                    }
                }
                Text("評価").font(.system(size: 10)).foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
            } else {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(ColorPalette.accent)
                Text(value).font(.system(size: 15, weight: .bold)).foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))
                Text(label).font(.system(size: 10)).foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(ColorPalette.cardFill(isDark: isDark))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
    }
}

// MARK: - ConfettiView

private struct ConfettiView: View {
    private let colors: [Color] = ColorPalette.puzzleColors.map { $0.light }
    @State private var particles: [ConfettiParticleData] = []

    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { particle in
                ConfettiParticle(color: particle.color, delay: particle.delay, maxY: geo.size.height + 40)
                    .position(x: particle.x * geo.size.width, y: -20)
            }
        }
        .onAppear {
            particles = (0..<40).map { i in
                ConfettiParticleData(
                    x: CGFloat.random(in: 0.05...0.95),
                    color: colors[i % colors.count],
                    delay: Double(i) * 0.04
                )
            }
        }
    }
}

private struct ConfettiParticleData: Identifiable {
    let id = UUID()
    let x: CGFloat
    let color: Color
    let delay: Double
}

private struct ConfettiParticle: View {
    let color: Color
    let delay: Double
    let maxY: CGFloat

    @State private var y: CGFloat = 0
    @State private var opacity: Double = 1.0
    @State private var rotation: Double = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 8, height: 10)
            .rotationEffect(.degrees(rotation))
            .offset(y: y)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.8).delay(delay)) {
                    y = maxY
                    rotation = Double.random(in: 180...720)
                }
                withAnimation(.easeIn(duration: 0.4).delay(delay + 1.4)) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    NavigationStack {
        GameView(level: 1, gridSize: .small)
            .environment(SettingsViewModel())
    }
}
