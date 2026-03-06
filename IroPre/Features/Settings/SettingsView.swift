// MARK: - 設定画面 View
import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            // 表示設定
            Section("表示") {
                Toggle("ダークモード", isOn: $viewModel.isDarkMode)
                    .onChange(of: viewModel.isDarkMode) { _, newValue in
                        viewModel.updateDarkMode(newValue)
                    }

                Picker("アクセシビリティモード", selection: $viewModel.accessibilityMode) {
                    ForEach(AccessibilityDisplayMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
            }

            // ゲーム設定
            Section("ゲーム") {
                Toggle("タイマーを表示", isOn: $viewModel.isTimerVisible)
                Toggle("エラーチェックを有効化", isOn: $viewModel.isErrorCheckEnabled)
            }

            // サウンド・ハプティクス
            Section("サウンド・振動") {
                Toggle("サウンドエフェクト", isOn: $viewModel.isSoundEnabled)
                Toggle("ハプティクス", isOn: $viewModel.isHapticsEnabled)
            }

            // チュートリアル再表示
            Section("ヘルプ") {
                NavigationLink(destination: TutorialView()) {
                    Label("チュートリアルを見る", systemImage: "questionmark.circle")
                }
            }

            // バージョン情報
            Section {
                HStack {
                    Text("バージョン")
                    Spacer()
                    Text(Bundle.main.appVersionString)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Bundle Extension

private extension Bundle {
    var appVersionString: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
