// MARK: - アプリ全体で使用する定数
import Foundation
import CoreGraphics

enum Constants {
    // MARK: - Layout

    enum Layout {
        /// セルの最小タップ領域
        static let minCellTapSize: CGFloat = 34
        /// 盤面の水平パディング
        static let boardHorizontalPadding: CGFloat = 16
        /// パレットの角丸
        static let paletteCornerRadius: CGFloat = 20
        /// ボタンの標準角丸
        static let buttonCornerRadius: CGFloat = 16
    }

    // MARK: - Animation

    enum Animation {
        /// 色配置スプリングアニメーション
        static let colorPlaceResponse: CGFloat = 0.3
        static let colorPlaceDamping: CGFloat = 0.65
        /// パレット選択スプリング
        static let paletteSelectResponse: CGFloat = 0.25
        static let paletteSelectDamping: CGFloat = 0.6
        /// スケール倍率（選択時）
        static let selectedScale: CGFloat = 1.15
    }

    // MARK: - Game

    enum Game {
        static let maxHints = 3
        static let maxErrorChecks = 5
        static let maxBlockHints = 1
        /// オートセーブ間隔（秒）
        static let autoSaveInterval: TimeInterval = 30
    }

    // MARK: - Score

    enum Score {
        /// ★3評価: ヒント0, 時間の50%以内
        static let threeStarHintLimit = 0
        /// ★2評価: ヒント1以下, 時間の75%以内
        static let twoStarHintLimit = 1
    }

    // MARK: - Haptics

    enum Haptics {
        static let isEnabled = true
    }
}
