// MARK: - TimeInterval 拡張
import Foundation

extension TimeInterval {
    /// "MM:SS" 形式の文字列
    var timerString: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// "X分X秒" 形式（結果表示用）
    var displayString: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        if minutes == 0 {
            return "\(seconds)秒"
        }
        return "\(minutes)分\(seconds)秒"
    }
}
