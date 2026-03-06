// MARK: - ゲームリポジトリ プロトコル & 実装
import Foundation
import SwiftData

// MARK: - Protocol

protocol GameRepositoryProtocol: Sendable {
    func saveProgress(_ state: GameState) async throws
    func loadProgress(puzzleId: String) async throws -> GameProgress?
    func deleteProgress(puzzleId: String) async throws
    func saveClearRecord(_ record: ClearRecord) async throws
    func loadClearRecord(puzzleId: String) async throws -> ClearRecord?
    func loadAllClearRecords() async throws -> [ClearRecord]
}

// MARK: - Implementation

final class GameRepository: GameRepositoryProtocol {
    private let container: ModelContainer

    init(container: ModelContainer = SwiftDataManager.shared.container) {
        self.container = container
    }

    @MainActor
    func saveProgress(_ state: GameState) async throws {
        let context = container.mainContext
        let puzzleId = state.puzzle.id

        // 既存データを更新 or 新規作成
        let descriptor = FetchDescriptor<GameProgress>(
            predicate: #Predicate { $0.puzzleId == puzzleId }
        )
        if let existing = try context.fetch(descriptor).first {
            existing.currentBoard = state.currentBoardArray
            existing.moveHistory = state.moveHistory.map {
                MoveRecord(
                    row: $0.row,
                    col: $0.col,
                    previousValue: $0.previousColorIndex,
                    newValue: $0.newColorIndex
                )
            }
            existing.hintsUsed = state.hintsUsed
            existing.elapsedTime = state.elapsedTime
            existing.isCompleted = state.phase == .completed
            existing.touch()
        } else {
            let progress = GameProgress(
                puzzleId: puzzleId,
                level: state.puzzle.level,
                gridSize: state.puzzle.gridSize.rawValue,
                currentBoard: state.currentBoardArray,
                hintsUsed: state.hintsUsed,
                elapsedTime: state.elapsedTime,
                isCompleted: state.phase == .completed
            )
            context.insert(progress)
        }
        try context.save()
    }

    @MainActor
    func loadProgress(puzzleId: String) async throws -> GameProgress? {
        let context = container.mainContext
        let descriptor = FetchDescriptor<GameProgress>(
            predicate: #Predicate { $0.puzzleId == puzzleId }
        )
        return try context.fetch(descriptor).first
    }

    @MainActor
    func deleteProgress(puzzleId: String) async throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<GameProgress>(
            predicate: #Predicate { $0.puzzleId == puzzleId }
        )
        if let existing = try context.fetch(descriptor).first {
            context.delete(existing)
            try context.save()
        }
    }

    @MainActor
    func saveClearRecord(_ record: ClearRecord) async throws {
        let context = container.mainContext
        context.insert(record)
        try context.save()
    }

    @MainActor
    func loadClearRecord(puzzleId: String) async throws -> ClearRecord? {
        let context = container.mainContext
        let descriptor = FetchDescriptor<ClearRecord>(
            predicate: #Predicate { $0.puzzleId == puzzleId },
            sortBy: [SortDescriptor(\.clearedAt, order: .reverse)]
        )
        return try context.fetch(descriptor).first
    }

    @MainActor
    func loadAllClearRecords() async throws -> [ClearRecord] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<ClearRecord>(
            sortBy: [SortDescriptor(\.clearedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
}
