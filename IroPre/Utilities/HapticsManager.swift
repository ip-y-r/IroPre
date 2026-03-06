// MARK: - ハプティクス管理
import UIKit

/// ハプティクスフィードバック管理（PRD Phase 4）
enum HapticsManager {
    /// 衝撃フィードバック（タップ・配置など）
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    /// 通知フィードバック（クリア・エラーなど）
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    /// 選択フィードバック（パレット色選択など）
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
