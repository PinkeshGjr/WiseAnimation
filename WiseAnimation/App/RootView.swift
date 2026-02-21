import SwiftUI

struct RootView: View {
    @StateObject private var viewModel: RootViewModel

    init(container: AppContainer) {
        _viewModel = StateObject(wrappedValue: RootViewModel(container: container))
    }

    var body: some View {
        Group {
            if let destination = viewModel.destination {
                switch destination {
                case .onboarding:
                    OnboardingView {
                        viewModel.onOnboardingComplete()
                    }
                }
            } else {
                LaunchExperienceView {
                    viewModel.onLaunchComplete()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.destination != nil)
    }
}
