// MARK: - 設定画面 ViewModel
import Foundation

@Observable
final class SettingsViewModel {
    // TODO: Phase 3 で SwiftData UserSettings と接続
    var isDarkMode: Bool = false
    var accessibilityMode: AccessibilityDisplayMode = .color
    var isTimerVisible: Bool = true
    var isErrorCheckEnabled: Bool = true
    var isSoundEnabled: Bool = true
    var isHapticsEnabled: Bool = true

    func updateDarkMode(_ value: Bool) {
        isDarkMode = value
        // TODO: Phase 3 で永続化
    }
}
