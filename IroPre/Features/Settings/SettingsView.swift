// MARK: - 設定画面 View
import SwiftUI

struct SettingsView: View {
    @Environment(SettingsViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        Form {
            // 表示設定
            Section("表示") {
                Toggle("ダークモード", isOn: $vm.isDarkMode)

                Picker("アクセシビリティモード", selection: $vm.accessibilityMode) {
                    ForEach(AccessibilityDisplayMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
            }

            // ゲーム設定
            Section("ゲーム") {
                Toggle("タイマーを表示", isOn: $vm.isTimerVisible)
                Toggle("エラーチェックを有効化", isOn: $vm.isErrorCheckEnabled)
            }

            // サウンド・ハプティクス
            Section("サウンド・振動") {
                Toggle("サウンドエフェクト", isOn: $vm.isSoundEnabled)
                Toggle("ハプティクス", isOn: $vm.isHapticsEnabled)
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
        .onChange(of: viewModel.isDarkMode) { viewModel.persist() }
        .onChange(of: viewModel.accessibilityMode) { viewModel.persist() }
        .onChange(of: viewModel.isTimerVisible) { viewModel.persist() }
        .onChange(of: viewModel.isErrorCheckEnabled) { viewModel.persist() }
        .onChange(of: viewModel.isSoundEnabled) { viewModel.persist() }
        .onChange(of: viewModel.isHapticsEnabled) { viewModel.persist() }
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
            .environment(SettingsViewModel())
    }
}
