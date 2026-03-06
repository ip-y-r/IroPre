// MARK: - ユーザー設定 SwiftData モデル
import Foundation
import SwiftData

@Model
final class UserSettings {
    var isDarkMode: Bool
    /// アクセシビリティモード: "color" | "pattern" | "symbol"
    var accessibilityMode: String
    var isSoundEnabled: Bool
    var isHapticsEnabled: Bool
    var isErrorCheckEnabled: Bool
    var isTimerVisible: Bool
    var hasCompletedTutorial: Bool

    init(
        isDarkMode: Bool = false,
        accessibilityMode: String = "color",
        isSoundEnabled: Bool = true,
        isHapticsEnabled: Bool = true,
        isErrorCheckEnabled: Bool = true,
        isTimerVisible: Bool = true,
        hasCompletedTutorial: Bool = false
    ) {
        self.isDarkMode = isDarkMode
        self.accessibilityMode = accessibilityMode
        self.isSoundEnabled = isSoundEnabled
        self.isHapticsEnabled = isHapticsEnabled
        self.isErrorCheckEnabled = isErrorCheckEnabled
        self.isTimerVisible = isTimerVisible
        self.hasCompletedTutorial = hasCompletedTutorial
    }
}
