// MARK: - SwiftData コンテナ管理
import Foundation
import SwiftData

final class SwiftDataManager: @unchecked Sendable {
    static let shared = SwiftDataManager()

    let container: ModelContainer

    private init() {
        let schema = Schema([
            GameProgress.self,
            ClearRecord.self,
            AchievementRecord.self,
            UserSettings.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("SwiftDataManager: コンテナの初期化に失敗しました — \(error)")
        }
    }

    /// テスト用のインメモリコンテナを作成
    static func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            GameProgress.self,
            ClearRecord.self,
            AchievementRecord.self,
            UserSettings.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
