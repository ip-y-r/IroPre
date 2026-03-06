// MARK: - チュートリアル画面 View
import SwiftUI

struct TutorialView: View {
    @State private var viewModel = TutorialViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(SettingsViewModel.self) private var settings

    private var isDark: Bool { settings.isDarkMode }

    var body: some View {
        VStack(spacing: 0) {
            // プログレスドット（上部）
            HStack(spacing: 8) {
                ForEach(0..<TutorialViewModel.totalSteps, id: \.self) { i in
                    Capsule()
                        .fill(i == viewModel.currentStep
                              ? AnyShapeStyle(ColorPalette.primaryGradient)
                              : AnyShapeStyle(isDark ? Color(hex: "#333355") : Color(hex: "#DDDDDD")))
                        .frame(width: i == viewModel.currentStep ? 24 : 8, height: 8)
                        .onTapGesture { withAnimation { viewModel.currentStep = i } }
                        .animation(.spring(response: 0.3), value: viewModel.currentStep)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 20)

            // ステップコンテンツ（タブビュー）
            TabView(selection: $viewModel.currentStep) {
                ForEach(0..<TutorialViewModel.totalSteps, id: \.self) { step in
                    TutorialStepView(step: step, isDark: isDark)
                        .tag(step)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // ナビゲーションボタン
            HStack(spacing: 10) {
                if viewModel.currentStep > 0 {
                    Button {
                        withAnimation { viewModel.previousStep() }
                    } label: {
                        Text("もどる")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isDark ? Color(hex: "#22223A") : Color(hex: "#F0F0F7"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                Button {
                    if viewModel.isLastStep {
                        viewModel.complete()
                        dismiss()
                    } else {
                        withAnimation { viewModel.nextStep() }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(viewModel.isLastStep ? "はじめる！" : "つぎへ")
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ColorPalette.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color(hex: "#4A90D9").opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)

            Button("スキップ") { dismiss() }
                .font(.system(size: 12))
                .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                .padding(.bottom, 24)
        }
        .background(ColorPalette.appBackground(isDark: isDark).ignoresSafeArea())
        .navigationTitle("遊び方")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("スキップ") { dismiss() }
                    .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
            }
        }
    }
}

// MARK: - TutorialStepView

private struct TutorialStepView: View {
    let step: Int
    let isDark: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // ステップアイコン
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 80, height: 80)
                    Image(systemName: iconName)
                        .font(.system(size: 36))
                        .foregroundStyle(iconColor)
                }
                .padding(.top, 8)

                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                        .multilineTextAlignment(.center)
                }

                // ステップ固有コンテンツ
                stepContent
                    .padding(.horizontal, 4)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 1:
            // ルール 3 項目
            VStack(spacing: 10) {
                ForEach(rules, id: \.0) { rule in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(rule.2.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Image(systemName: rule.1)
                                .font(.system(size: 18))
                                .foregroundStyle(rule.2)
                        }
                        Text(rule.0)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(ColorPalette.cardFill(isDark: isDark))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                }
            }

        case 3:
            // ツール説明
            HStack(spacing: 16) {
                ForEach(tools, id: \.0) { tool in
                    VStack(spacing: 6) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ColorPalette.cardFill(isDark: isDark))
                                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                            Image(systemName: tool.1)
                                .font(.system(size: 22))
                                .foregroundStyle(ColorPalette.iconColor(isDark: isDark))
                        }
                        .frame(width: 52, height: 52)
                        Text(tool.0)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(ColorPalette.primaryTextColor(isDark: isDark))
                        Text(tool.2)
                            .font(.system(size: 10))
                            .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                            .multilineTextAlignment(.center)
                    }
                }
            }

        default:
            Text(description)
                .font(.system(size: 14))
                .foregroundStyle(ColorPalette.secondaryTextColor(isDark: isDark))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 8)
        }
    }

    // MARK: - Data

    private var iconName: String {
        ["paintpalette.fill", "square.grid.3x3.fill", "hand.tap.fill", "lightbulb.fill"][safe: step] ?? "star.fill"
    }

    private var iconColor: Color {
        [Color(hex: "#4A90D9"), Color(hex: "#27AE60"), Color(hex: "#9B59B6"), Color(hex: "#F1C40F")][safe: step] ?? .blue
    }

    private var title: String {
        ["IroPreへようこそ！", "ルールはかんたん！", "やってみよう！", "困ったらヒント！"][safe: step] ?? ""
    }

    private var subtitle: String {
        ["色で数独を解こう", "3つだけ覚えよう", "マスをタップして色を置こう", "いつでも助けてもらえます"][safe: step] ?? ""
    }

    private var description: String {
        switch step {
        case 0: return "数字の代わりに色を使った新しい数独パズルです。誰でもかんたんに楽しめます！"
        case 2: return "まずパレットから色を選び（色が光ります）、次に空きマスをタップして色を配置します。同じ色を連続して置けます。"
        default: return ""
        }
    }

    private var rules: [(String, String, Color)] {
        [
            ("たて一列に同じ色は置けない",   "arrow.up.arrow.down",   Color(hex: "#FF6B6B")),
            ("よこ一列に同じ色は置けない",   "arrow.left.arrow.right", Color(hex: "#4A90D9")),
            ("ブロック内に同じ色は置けない", "square.grid.2x2.fill",   Color(hex: "#27AE60")),
        ]
    }

    private var tools: [(String, String, String)] {
        [
            ("ヒント",  "lightbulb.fill",        "正解の色を表示"),
            ("戻す",   "arrow.uturn.backward",  "操作を元に戻す"),
            ("消す",   "eraser.fill",            "色を消去"),
        ]
    }
}

// MARK: - Array safe subscript

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack {
        TutorialView()
            .environment(SettingsViewModel())
    }
}
