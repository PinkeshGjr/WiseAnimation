import SwiftUI
import Combine

@MainActor
class RootViewModel: ObservableObject {
    enum PostLaunchDestination {
        case onboarding
        // We can add other destinations here when ready
    }

    @Published var destination: PostLaunchDestination?

    let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    func decidePostLaunchDestination() -> PostLaunchDestination {
        // For now launch goes to onboarding. This decision point is where
        // you can add auth/token/first-install checks later.
        return .onboarding
    }
    
    func onLaunchComplete() {
        self.destination = decidePostLaunchDestination()
    }
    
    func onOnboardingComplete() {
        // Handle onboarding completion (e.g. going to auth or main app)
    }
}
