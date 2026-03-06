// MARK: - ルートビュー
import SwiftUI

struct ContentView: View {
    @State private var settings = SettingsViewModel()

    var body: some View {
        HomeView()
            .environment(settings)
    }
}

#Preview {
    ContentView()
}
