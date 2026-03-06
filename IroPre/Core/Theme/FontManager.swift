// MARK: - フォント管理（SF Pro Rounded + Noto Sans JP）
import SwiftUI

/// フォント管理（PRD 7.7）
/// 英語: SF Pro Rounded、日本語: Noto Sans JP
enum FontManager {
    // MARK: - フォントウェイト定義

    enum Weight {
        case regular, semiBold, bold
    }

    // MARK: - アプリフォントの取得

    /// タイトル用フォント（28pt Bold）
    static func title() -> Font {
        .custom(notoSansJPName(.bold), size: 28, relativeTo: .title)
    }

    /// 見出し用フォント（18pt SemiBold）
    static func headline() -> Font {
        .custom(notoSansJPName(.semiBold), size: 18, relativeTo: .headline)
    }

    /// 本文用フォント（14pt Regular）
    static func body() -> Font {
        .custom(notoSansJPName(.regular), size: 14, relativeTo: .body)
    }

    /// タイマー用フォント（24pt Light / SF Mono）
    static func timer() -> Font {
        .system(size: 24, weight: .light, design: .monospaced)
    }

    /// ボタン用フォント（16pt Bold）
    static func button() -> Font {
        .custom(notoSansJPName(.bold), size: 16, relativeTo: .callout)
    }

    /// カスタムサイズ
    static func custom(size: CGFloat, weight: Weight = .regular) -> Font {
        .custom(notoSansJPName(weight), size: size)
    }

    // MARK: - Private

    private static func notoSansJPName(_ weight: Weight) -> String {
        switch weight {
        case .regular:  return "NotoSansJP-Regular"
        case .semiBold: return "NotoSansJP-SemiBold"
        case .bold:     return "NotoSansJP-Bold"
        }
    }
}

// MARK: - View Extension

extension View {
    func appFont(_ font: Font) -> some View {
        self.font(font)
    }
}
