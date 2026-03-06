// MARK: - 実績画面 ViewModel
import Foundation

@Observable
final class AchievementsViewModel {
    private var records: [String: AchievementRecord] = [:]
    private let repository: AchievementRepositoryProtocol

    init(repository: AchievementRepositoryProtocol = AchievementRepository()) {
        self.repository = repository
    }

    @MainActor
    func load() async {
        let loaded = (try? await repository.loadAll()) ?? []
        records = Dictionary(uniqueKeysWithValues: loaded.map { ($0.achievementId, $0) })
    }

    func achievements(for category: AchievementCategory) -> [Achievement] {
        Achievement.allAchievements.filter { $0.category == category }
    }

    func record(for achievementId: String) -> AchievementRecord? {
        records[achievementId]
    }
}
