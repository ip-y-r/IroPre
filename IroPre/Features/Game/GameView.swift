// MARK: - ゲーム画面 View
import SwiftUI

struct GameView: View {
    let level: Int
    let gridSize: GridSize

    @State private var viewModel: GameViewModel

    init(level: Int, gridSize: GridSize) {
        self.level = level
        self.gridSize = gridSize
        self._viewModel = State(wrappedValue: GameViewModel(level: level, gridSize: gridSize))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // ヘッダー
                GameHeaderView(
                    level: level,
                    elapsedTime: viewModel.gameState?.elapsedTime ?? 0,
                    onPause: { viewModel.pause() }
                )

                Spacer()

                // 盤面
                if let gameState = viewModel.gameState {
                    BoardView(gameState: gameState)
                        .padding(.horizontal, 16)

                    Spacer()

                    // ツールバー（ヒント・undo・消す）
                    GameToolbarView(
                        canUndo: !(gameState.moveHistory.isEmpty),
                        onUndo: { viewModel.undo() },
                        onErase: { viewModel.eraseSelectedCell() },
                        onHint: { viewModel.requestHint() }
                    )

                    // カラーパレット
                    PaletteView(
                        gridSize: gridSize,
                        selectedColorIndex: gameState.selectedColorIndex,
                        isDarkMode: false,
                        onColorSelected: { index in viewModel.selectColor(index) }
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
                    onResume: { viewModel.resume() },
                    onHome: { }
                )
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadPuzzle()
        }
    }
}

// MARK: - GameHeaderView

private struct GameHeaderView: View {
    let level: Int
    let elapsedTime: TimeInterval
    let onPause: () -> Void

    var body: some View {
        HStack {
            Text("Lv.\(level)")
                .font(FontManager.headline())

            Spacer()

            Text(timeString(elapsedTime))
                .font(FontManager.timer())

            Spacer()

            Button(action: onPause) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 20))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private func timeString(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - GameToolbarView

private struct GameToolbarView: View {
    let canUndo: Bool
    let onUndo: () -> Void
    let onErase: () -> Void
    let onHint: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            Button(action: onUndo) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 24))
                    Text("もどす")
                        .font(FontManager.body())
                }
            }
            .disabled(!canUndo)

            Button(action: onErase) {
                VStack(spacing: 4) {
                    Image(systemName: "eraser.fill")
                        .font(.system(size: 24))
                    Text("消す")
                        .font(FontManager.body())
                }
            }

            Button(action: onHint) {
                VStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 24))
                    Text("ヒント")
                        .font(FontManager.body())
                }
            }
        }
        .foregroundStyle(ColorPalette.accent)
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        GameView(level: 1, gridSize: .small)
    }
}
