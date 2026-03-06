// MARK: - レベル選択画面 View
import SwiftUI

struct LevelSelectView: View {
    @State private var viewModel = LevelSelectViewModel()

    var body: some View {
        VStack {
            // 盤面サイズタブ
            Picker("盤面サイズ", selection: $viewModel.selectedGridSize) {
                ForEach(GridSize.allCases, id: \.self) { size in
                    Text(size.displayName).tag(size)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // レベルグリッド
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 5),
                    spacing: 12
                ) {
                    ForEach(viewModel.levels(for: viewModel.selectedGridSize), id: \.self) { level in
                        NavigationLink(destination: GameView(level: level, gridSize: viewModel.selectedGridSize)) {
                            LevelCellView(level: level, isCleared: viewModel.isCleared(level: level))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("レベル選択")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadClearedLevels()
        }
        .onChange(of: viewModel.selectedGridSize) {
            Task { await viewModel.loadClearedLevels() }
        }
    }
}

// MARK: - LevelCellView

private struct LevelCellView: View {
    let level: Int
    let isCleared: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isCleared ? Color(hex: "#27AE60").opacity(0.15) : Color(.systemGray6))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)

            VStack(spacing: 2) {
                Text("\(level)")
                    .font(FontManager.headline())
                    .foregroundStyle(isCleared ? Color(hex: "#27AE60") : .primary)

                if isCleared {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(hex: "#27AE60"))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    NavigationStack {
        LevelSelectView()
    }
}
