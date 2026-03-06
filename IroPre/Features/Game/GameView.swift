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

                // 盤面（ポーズ中は非表示）
                if let gameState = viewModel.gameState {
                    if !viewModel.isPaused {
                        BoardView(
                            gameState: gameState,
                            isDarkMode: settings.isDarkMode,
                            selectedPosition: viewModel.selectedCellPosition,
                            onCellTap: { row, col in viewModel.tapCell(row: row, col: col) }
                        )
                        .padding(.horizontal, 16)
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                            .padding(.horizontal, 16)
                    }

                    Spacer()

                    // ツールバー（undo・消す・ヒント）
                    GameToolbarView(
                        canUndo: !(gameState.moveHistory.isEmpty),
                        onUndo: { viewModel.undo() },
                        onErase: { viewModel.eraseSelectedCell() },
                        onCellHint: { viewModel.requestHint() },
                        onErrorCheck: { viewModel.requestErrorCheck() },
                        onBlockHint: { viewModel.requestBlockHint() }
                    )

                    // カラーパレット
                    PaletteView(
                        gridSize: gridSize,
                        selectedColorIndex: gameState.selectedColorIndex,
                        isDarkMode: settings.isDarkMode,
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
                    onDismiss: { dismiss() }
                )
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadPuzzle()
        }
        .onDisappear {
            viewModel.stopTimer()
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
                .monospacedDigit()

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
    let onCellHint: () -> Void
    let onErrorCheck: () -> Void
    let onBlockHint: () -> Void

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

            Menu {
                Button(action: onCellHint) {
                    Label("マスヒント", systemImage: "square.dashed")
                }
                Button(action: onErrorCheck) {
                    Label("エラーチェック", systemImage: "exclamationmark.triangle.fill")
                }
                Button(action: onBlockHint) {
                    Label("ブロックヒント", systemImage: "rectangle.split.2x2.fill")
                }
            } label: {
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

// MARK: - GameClearOverlay

private struct GameClearOverlay: View {
    let elapsedTime: TimeInterval
    let hintsUsed: Int
    let starRating: Int
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Text("クリア！")
                    .font(FontManager.title())
                    .foregroundStyle(.white)

                // 星評価
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { star in
                        Image(systemName: star <= starRating ? "star.fill" : "star")
                            .font(.system(size: 32))
                            .foregroundStyle(star <= starRating ? Color(hex: "#F1C40F") : .white.opacity(0.4))
                    }
                }

                // タイム・ヒント情報
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text(timeString(elapsedTime))
                            .monospacedDigit()
                    }
                    .font(FontManager.headline())
                    .foregroundStyle(.white)

                    if hintsUsed > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                            Text("ヒント \(hintsUsed)回")
                        }
                        .font(FontManager.body())
                        .foregroundStyle(.white.opacity(0.8))
                    }
                }

                Button(action: onDismiss) {
                    Text("レベル選択へ")
                        .font(FontManager.button())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .foregroundStyle(ColorPalette.accent)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.buttonCornerRadius))
                }
                .padding(.horizontal, 40)
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 32)
        }
    }

    private func timeString(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationStack {
        GameView(level: 1, gridSize: .small)
            .environment(SettingsViewModel())
    }
}
