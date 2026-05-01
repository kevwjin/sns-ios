import Foundation
import Observation

struct AnonymousMatchProfile: Hashable {
    var age: Int
    var pronouns: String
    var neighborhood: String
    var bio: String
    var interests: [String]

    static let mock = AnonymousMatchProfile(
        age: 26,
        pronouns: "they/them",
        neighborhood: "Hayes Valley",
        bio: "Enjoys low-key coffee, neighborhood walks, and finding quiet places to talk.",
        interests: ["Coffee", "Walks", "Design", "Books"]
    )
}

@MainActor
@Observable
final class HomeViewModel {
    var isEnrolledInBatch = false
    var hasMatchThisWeek = false
    var showBatchInfoSheet = false
    var showEnrollConfirmation = false
    var showMatchInfoSheet = false
    var sliderResetTrigger = 0
    var secondsUntilMatchRelease = 5

    let batchEndsAtText = "Sunday at 11:59 PM"
    let matchProfile = AnonymousMatchProfile.mock

    private var matchTimerTask: Task<Void, Never>?

    init() {
        if ProcessInfo.processInfo.arguments.contains("-snsUITestHasMatch") {
            isEnrolledInBatch = true
            hasMatchThisWeek = true
        }
    }

    func cancelEnrollment() {
        sliderResetTrigger += 1
    }

    func confirmEnrollment() {
        isEnrolledInBatch = true
        hasMatchThisWeek = false
        beginMatchSimulation()
    }

    func cancelMatchSimulation() {
        matchTimerTask?.cancel()
        matchTimerTask = nil
    }

    private func beginMatchSimulation() {
        cancelMatchSimulation()
        secondsUntilMatchRelease = 5

        matchTimerTask = Task { [weak self] in
            guard let self else { return }

            while self.secondsUntilMatchRelease > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.secondsUntilMatchRelease -= 1
                }
            }

            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.hasMatchThisWeek = true
            }
        }
    }
}
