// MARK: - アプリエントリポイント
import SwiftUI
import SwiftData

@main
struct IroPreApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(SwiftDataManager.shared.container)
        }
    }
}
