import Foundation

enum FoFMatchPolicy: String, CaseIterable {
    case fofReferralOnly
    case anyMatch
    case anyMatchIfNoFoFReferral

    var label: String {
        switch self {
        case .fofReferralOnly:
            return "FoF referral only"
        case .anyMatch:
            return "Any match"
        case .anyMatchIfNoFoFReferral:
            return "Any match if no FoF referral"
        }
    }
}
