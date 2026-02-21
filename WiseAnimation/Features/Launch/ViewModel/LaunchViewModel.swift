import SwiftUI
import Combine


@MainActor
class LaunchViewModel: ObservableObject {
    let onComplete: () -> Void

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    func animationDidComplete() {
        onComplete()
    }
}
