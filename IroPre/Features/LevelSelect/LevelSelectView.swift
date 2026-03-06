// MARK: - レベル選択画面 View
import SwiftUI

struct LevelSelectView: View {
    @State private var viewModel = LevelSelectViewModel()
    @Environment(SettingsViewModel.self) private var settings

    private var isDark: Bool { settings.isDarkMode }

    private let diffGroups: [(name: String, color: Color, range: ClosedRange<Int>)] = [
        ("初級",       Color(hex: "#27AE60"), 1...10),
        ("中級",       Color(hex: "#F1C40F"), 11...30),
        ("上級",       Color(hex: "#E67E22"), 31...60),
        ("エキスパート", Color(hex: "#9B59B6"), 61...100),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // ─── 盤面サイズタブ ───
            HStack(spacing: 6) {
                ForEach(GridSize.allCases, id: \.self) { size in
                    Button {
                        viewModel.selectedGridSize = size
                        Task { await viewModel.loadClearedLevels() }
                    } label: {
                        Text(size.displayName)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedGridSize == size
                                    ? AnyShapeStyle(ColorPalette.primaryGradient)
                                    : AnyShapeStyle(Color.clear)
                            )
                            .foregroundStyle(viewModel.selectedGridSize == size
                                             ? Color.white
                                             : ColorPalette.secondaryTextColor(isDark: isDark))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(
                                color: viewModel.selectedGridSize == size
                                    ? Color(hex: "#4A90D9").opacity(0.35) : .clear,
                                radius: 4, x: 0, y: 2
                            )
                    }
                }
            }
            .padding(4)
            .background(isDark ? Color(hex: "#1A1A2E") : Color(hex: "#F0F0F7"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // ─── 進捗バー ───
            let allLevels = viewModel.levels(for: viewModel.selectedGridSize)
            let cleared   = allLevels.filter { viewModel.isCleared(level: $0) }.count
            let total     = allLevels.count
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("進捗")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))
                        Spacer()
                        Text("\(cleared)/\(total) クリア")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(ColorPalette.accent)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isDark ? Color(hex: "#333355") : Color(hex: "#EEEEEE"))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(
                                    colors: [Color(hex: "#4A90D9"), Color(hex: "#27AE60")],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                                .frame(width: total > 0 ? geo.size.width * CGFloat(cleared) / CGFloat(total) : 0)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(14)
            .background(ColorPalette.cardFill(isDark: isDark))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            // ─── 難易度グループ ───
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(diffGroups, id: \.name) { group in
                        let levelsInGroup = Array(group.range)
                            .filter { viewModel.levels(for: viewModel.selectedGridSize).contains($0) }
                        if !levelsInGroup.isEmpty {
                            LevelDiffGroupView(
                                name: group.name,
                                color: group.color,
                                range: group.range,
                                levels: levelsInGroup,
                                isCleared: viewModel.isCleared(level:),
                                gridSize: viewModel.selectedGridSize,
                                isDark: isDark
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(ColorPalette.appBackground(isDark: isDark).ignoresSafeArea())
        .navigationTitle("レベル選択")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadClearedLevels() }
    }
}

// MARK: - LevelDiffGroupView

private struct LevelDiffGroupView: View {
    let name: String
    let color: Color
    let range: ClosedRange<Int>
    let levels: [Int]
    let isCleared: (Int) -> Bool
    let gridSize: GridSize
    let isDark: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // グループヘッダー
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .shadow(color: color.opacity(0.6), radius: 4)
                    .frame(width: 10, height: 10)
                Text(name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(color)
                Text("Lv.\(range.lowerBound)〜\(range.upperBound)")
                    .font(.system(size: 11))
                    .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
            }

            // レベルセルグリッド
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(levels, id: \.self) { level in
                    let isCleared = isCleared(level)
                    let stars = starRating(level: level, cleared: isCleared)
                    NavigationLink(destination: GameView(level: level, gridSize: gridSize)) {
                        LevelCellView(level: level, isCleared: isCleared, stars: stars, color: color, isDark: isDark)
                    }
                }
            }
        }
    }

    private func starRating(level: Int, cleared: Bool) -> Int {
        guard cleared else { return 0 }
        // サンプルスター（実際は ClearRecord から取得）
        if level % 3 == 0 { return 3 }
        if level % 3 == 1 { return 2 }
        return 1
    }
}

// MARK: - LevelCellView

private struct LevelCellView: View {
    let level: Int
    let isCleared: Bool
    let stars: Int
    let color: Color
    let isDark: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isCleared
                      ? AnyShapeStyle(LinearGradient(
                            colors: [color.opacity(0.85), color],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                      : AnyShapeStyle(ColorPalette.cardFill(isDark: isDark))
                )
                .shadow(color: isCleared ? color.opacity(0.35) : .black.opacity(0.06),
                        radius: isCleared ? 6 : 3, x: 0, y: isCleared ? 4 : 2)

            VStack(spacing: 2) {
                Text("\(level)")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(isCleared ? .white : ColorPalette.primaryTextColor(isDark: isDark))
                    .shadow(color: isCleared ? .black.opacity(0.2) : .clear, radius: 1, x: 0, y: 1)

                if isCleared {
                    HStack(spacing: 1) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < stars ? "star.fill" : "star")
                                .font(.system(size: 7))
                                .foregroundStyle(i < stars ? Color.white : Color.white.opacity(0.35))
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    NavigationStack {
        LevelSelectView()
            .environment(SettingsViewModel())
    }
}
