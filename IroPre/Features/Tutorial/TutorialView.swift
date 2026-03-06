// MARK: - チュートリアル画面 View
import SwiftUI

struct TutorialView: View {
    @State private var viewModel = TutorialViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // ステップコンテンツ
            TabView(selection: $viewModel.currentStep) {
                ForEach(0..<TutorialViewModel.totalSteps, id: \.self) { step in
                    TutorialStepView(step: step)
                        .tag(step)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // プログレスドット
            HStack(spacing: 8) {
                ForEach(0..<TutorialViewModel.totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step == viewModel.currentStep ? ColorPalette.accent : Color(.systemGray4))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 16)

            // ナビゲーションボタン
            HStack {
                if viewModel.currentStep > 0 {
                    Button("前へ") {
                        withAnimation { viewModel.previousStep() }
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()

                if viewModel.isLastStep {
                    Button("はじめる") {
                        viewModel.complete()
                        dismiss()
                    }
                    .font(FontManager.button())
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(ColorPalette.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Button("次へ") {
                        withAnimation { viewModel.nextStep() }
                    }
                    .font(FontManager.button())
                    .foregroundStyle(ColorPalette.accent)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .navigationTitle("遊び方")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("スキップ") {
                    dismiss()
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - TutorialStepView

private struct TutorialStepView: View {
    let step: Int

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: iconName)
                .font(.system(size: 64))
                .foregroundStyle(ColorPalette.accent)
                .padding(.top, 40)

            Text(title)
                .font(FontManager.headline())
                .multilineTextAlignment(.center)

            Text(description)
                .font(FontManager.body())
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            Spacer()
        }
    }

    private var iconName: String {
        switch step {
        case 0: return "paintpalette.fill"
        case 1: return "square.grid.3x3.fill"
        case 2: return "hand.tap.fill"
        case 3: return "lightbulb.fill"
        default: return "star.fill"
        }
    }

    private var title: String {
        switch step {
        case 0: return "色で数独を解こう！"
        case 1: return "ルールを覚えよう"
        case 2: return "操作してみよう"
        case 3: return "困ったときは"
        default: return ""
        }
    }

    private var description: String {
        switch step {
        case 0: return "IroPreは数字の代わりに色を使う数独パズルです。色を選んでマスを埋めていきましょう。"
        case 1: return "縦・横の各列と太線で囲まれたブロック内に、同じ色が重複してはいけません。"
        case 2: return "まずパレットから色を選び（色が光ります）、次に空きマスをタップして色を配置します。同じ色を連続して配置できます。"
        case 3: return "「ヒント」で正解の色を表示、「消す」で色を削除、「もどす」で操作を取り消せます。"
        default: return ""
        }
    }
}

#Preview {
    NavigationStack {
        TutorialView()
    }
}
