// MARK: - サウンド管理
import AVFoundation

/// 効果音の種類
enum SoundEffect: String {
    case place  = "place"
    case clear  = "clear"
    case error  = "error"
    case hint   = "hint"
    case erase  = "erase"
}

/// サウンドエフェクト管理（PRD Phase 4）
/// 音声ファイルが存在する場合のみ再生し、ない場合は無音で動作する
@MainActor
final class SoundManager {
    static let shared = SoundManager()

    private var players: [SoundEffect: AVAudioPlayer] = [:]

    private init() {
        preloadSounds()
    }

    func play(_ effect: SoundEffect) {
        players[effect]?.stop()
        players[effect]?.currentTime = 0
        players[effect]?.play()
    }

    // MARK: - Private

    private func preloadSounds() {
        let effects: [SoundEffect] = [.place, .clear, .error, .hint, .erase]
        for effect in effects {
            guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") else { continue }
            players[effect] = try? AVAudioPlayer(contentsOf: url)
            players[effect]?.prepareToPlay()
        }
    }
}
