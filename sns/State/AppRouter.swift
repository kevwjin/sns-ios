import Foundation
import Observation

@Observable
final class AppRouter {
    var selectedTab: RootTab = .match
    var lastContentTab: RootTab = .match
    var matchPath: [RootDestination] = []
    var networkPath: [RootDestination] = []
    var profilePath: [RootDestination] = []
    var searchPath: [RootDestination] = []
    var isRootSearchPresented = false
    var activeRootModal: RootModal?

    func select(_ tab: RootTab) {
        selectedTab = tab

        if tab != .search {
            lastContentTab = tab
        }
    }

    func dismissSearch() {
        isRootSearchPresented = false
        selectedTab = lastContentTab
    }

    func open(_ destination: RootDestination, from source: RootTab? = nil) {
        switch source ?? selectedTab {
        case .match:
            matchPath.append(destination)
        case .network:
            networkPath.append(destination)
        case .profile:
            profilePath.append(destination)
        case .search:
            searchPath.append(destination)
        }
    }

    func openPage(_ page: RootSearchPage, from source: RootTab? = nil) {
        open(.page(page), from: source)
    }

    func openContact(_ id: AppContact.ID, from source: RootTab? = nil) {
        open(.contact(id), from: source)
    }

    func openMyCard(from source: RootTab? = nil) {
        open(.myCard, from: source)
    }

    func openMatchMessages(_ matchName: String, from source: RootTab? = nil) {
        open(.matchMessages(matchName), from: source)
    }

    func showRootModal(_ modal: RootModal) {
        activeRootModal = modal
    }

    func dismissRootModal() {
        activeRootModal = nil
    }

    func startOnboarding() {
        // Hook for future onboarding/profile setup routing.
    }

    func openMatchRelease() {
        // Hook for future match release routing.
    }
}

enum RootDestination: Hashable {
    case page(RootSearchPage)
    case profileField(ProfileField)
    case contact(AppContact.ID)
    case myCard
    case matchMessages(String)
}

enum RootModal: Hashable {
    case privateMailInfo
}

enum RootTab: String, CaseIterable, Identifiable {
    case match
    case network
    case profile
    case search

    var id: Self { self }

    var title: String {
        switch self {
        case .match: "Match"
        case .network: "Network"
        case .profile: "Profile"
        case .search: "Search"
        }
    }

    var systemImage: String {
        switch self {
        case .match: "sparkles"
        case .network: "person.2.fill"
        case .profile: "person.crop.circle"
        case .search: "magnifyingglass"
        }
    }
}

enum RootSearchPage: String, CaseIterable, Identifiable {
    case inbox
    case contacts
    case groups
    case logbook
    case location
    case radius
    case matchWith
    case sexuality
    case substanceUse
    case ageRange
    case matchPolicy
    case profile

    var id: Self { self }

    var title: String {
        switch self {
        case .inbox: "Inbox"
        case .contacts: "Contacts"
        case .groups: "Groups"
        case .logbook: "Logbook"
        case .location: "Location"
        case .radius: "Radius"
        case .matchWith: "Gender"
        case .sexuality: "Sexuality"
        case .substanceUse: "Substance Use"
        case .ageRange: "Age Range"
        case .matchPolicy: "Match Policy"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .inbox: "envelope.fill"
        case .contacts: "person.2.fill"
        case .groups: "rectangle.3.group.fill"
        case .logbook: "checklist"
        case .location: "location.fill"
        case .radius: "scope"
        case .matchWith: "person.2.circle"
        case .sexuality: "heart.circle"
        case .substanceUse: "checklist"
        case .ageRange: "slider.horizontal.3"
        case .matchPolicy: "person.2.wave.2.fill"
        case .profile: "person.text.rectangle"
        }
    }

    private var keywords: [String] {
        switch self {
        case .inbox: ["mail", "message", "messages", "private"]
        case .contacts: ["people", "person", "friends", "network"]
        case .groups: ["group", "priority", "mutuals", "referral"]
        case .logbook: ["history", "activity", "events"]
        case .location: ["city", "place", "area"]
        case .radius: ["distance", "range", "nearby", "miles"]
        case .matchWith: ["preferences", "criteria", "match", "gender"]
        case .sexuality: ["preferences", "criteria", "match", "sexuality"]
        case .substanceUse: ["preferences", "criteria", "match", "substance", "vaping", "smoking", "marijuana", "drinking"]
        case .ageRange: ["preferences", "criteria", "match", "age"]
        case .matchPolicy: ["preferences", "criteria", "match", "policy", "mutuals"]
        case .profile: ["account", "me", "gender", "age", "pronouns", "sexuality"]
        }
    }

    func matches(_ query: String) -> Bool {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return false }
        return title.localizedCaseInsensitiveContains(normalizedQuery)
            || keywords.contains { $0.localizedCaseInsensitiveContains(normalizedQuery) }
    }
}

enum ProfileField: String, Hashable {
    case age
    case gender
    case pronouns
    case sexuality
    case substanceUse

    var title: String {
        switch self {
        case .age: "Age"
        case .gender: "Gender"
        case .pronouns: "Pronouns"
        case .sexuality: "Sexuality"
        case .substanceUse: "Substance Use"
        }
    }
}
