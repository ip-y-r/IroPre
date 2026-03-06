// MARK: - チュートリアル画面 ViewModel
import Foundation
import SwiftData

@Observable
final class TutorialViewModel {
    static let totalSteps = 4

    var currentStep: Int = 0

    var isLastStep: Bool { currentStep == Self.totalSteps - 1 }

    func nextStep() {
        guard currentStep < Self.totalSteps - 1 else { return }
        currentStep += 1
    }

    func previousStep() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    func complete() {
        let context = SwiftDataManager.shared.container.mainContext
        let descriptor = FetchDescriptor<UserSettings>()
        if let settings = try? context.fetch(descriptor).first {
            settings.hasCompletedTutorial = true
            try? context.save()
        }
    }
}
