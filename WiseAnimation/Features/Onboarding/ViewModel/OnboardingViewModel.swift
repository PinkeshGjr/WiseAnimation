import SwiftUI
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    var onGetStarted: (() -> Void)?

    init(onGetStarted: (() -> Void)? = nil) {
        self.onGetStarted = onGetStarted
    }

    func getStartedTapped() {
        onGetStarted?()
    }

    func checkRatesTapped() {
        // Handle check rates logic in the future
    }
}
