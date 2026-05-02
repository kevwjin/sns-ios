import Foundation

enum MatchPolicy: String, CaseIterable, Hashable {
    case mutualsOnly
    case anyEligibleMatch
    case anyEligibleMatchIfNoMutuals

    var label: String {
        switch self {
        case .mutualsOnly:
            return "Mutuals only"
        case .anyEligibleMatch:
            return "Any match"
        case .anyEligibleMatchIfNoMutuals:
            return "Any match if no mutuals"
        }
    }
}
