// MARK: - 設定画面 ViewModel
import Foundation
import SwiftData

@Observable
@MainActor
final class SettingsViewModel {
    var isDarkMode: Bool = false
    var accessibilityMode: AccessibilityDisplayMode = .color
    var isTimerVisible: Bool = true
    var isErrorCheckEnabled: Bool = true
    var isSoundEnabled: Bool = true
    var isHapticsEnabled: Bool = true

    private let context: ModelContext
    private var record: UserSettings?

    init() {
        self.context = SwiftDataManager.shared.container.mainContext
        loadSettings()
    }

    /// SwiftData へ現在の値をすべて保存する
    func persist() {
        guard let record else { return }
        record.isDarkMode = isDarkMode
        record.accessibilityMode = accessibilityMode.rawValue
        record.isTimerVisible = isTimerVisible
        record.isErrorCheckEnabled = isErrorCheckEnabled
        record.isSoundEnabled = isSoundEnabled
        record.isHapticsEnabled = isHapticsEnabled
        try? context.save()
    }

    // MARK: - Private

    private func loadSettings() {
        let descriptor = FetchDescriptor<UserSettings>()
        if let existing = try? context.fetch(descriptor).first {
            record = existing
            isDarkMode = existing.isDarkMode
            accessibilityMode = AccessibilityDisplayMode(rawValue: existing.accessibilityMode) ?? .color
            isTimerVisible = existing.isTimerVisible
            isErrorCheckEnabled = existing.isErrorCheckEnabled
            isSoundEnabled = existing.isSoundEnabled
            isHapticsEnabled = existing.isHapticsEnabled
        } else {
            let newRecord = UserSettings()
            context.insert(newRecord)
            try? context.save()
            record = newRecord
        }
    }
}
