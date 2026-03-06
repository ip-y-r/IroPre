// MARK: - 実績リポジトリ プロトコル & 実装
import Foundation
import SwiftData

// MARK: - Protocol

protocol AchievementRepositoryProtocol: Sendable {
    func loadAll() async throws -> [AchievementRecord]
    func updateProgress(achievementId: String, progress: Double) async throws
    func unlock(achievementId: String) async throws
}

// MARK: - Implementation

final class AchievementRepository: AchievementRepositoryProtocol {
    private let container: ModelContainer

    init(container: ModelContainer = SwiftDataManager.shared.container) {
        self.container = container
    }

    @MainActor
    func loadAll() async throws -> [AchievementRecord] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<AchievementRecord>()
        var records = try context.fetch(descriptor)

        // 未登録の実績を初期化
        let existingIds = Set(records.map { $0.achievementId })
        for achievement in Achievement.allAchievements where !existingIds.contains(achievement.id) {
            let record = AchievementRecord(achievementId: achievement.id)
            context.insert(record)
            records.append(record)
        }
        if context.hasChanges {
            try context.save()
        }
        return records
    }

    @MainActor
    func updateProgress(achievementId: String, progress: Double) async throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<AchievementRecord>(
            predicate: #Predicate { $0.achievementId == achievementId }
        )
        if let record = try context.fetch(descriptor).first {
            record.updateProgress(progress)
            try context.save()
        }
    }

    @MainActor
    func unlock(achievementId: String) async throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<AchievementRecord>(
            predicate: #Predicate { $0.achievementId == achievementId }
        )
        if let record = try context.fetch(descriptor).first {
            record.unlock()
            try context.save()
        }
    }
}
