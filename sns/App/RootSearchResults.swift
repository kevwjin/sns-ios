import Foundation

struct RootSearchResults {
    let query: String
    let pages: [RootSearchPage]
    let contactIDs: [AppContact.ID]
    let groupIDs: [AppGroup.ID]

    var isSearching: Bool {
        !query.isEmpty
    }

    var isEmpty: Bool {
        pages.isEmpty && contactIDs.isEmpty && groupIDs.isEmpty
    }
}

enum RootSearchIndex {
    static func results(
        for query: String,
        contacts: [AppContact],
        groups: [AppGroup]
    ) -> RootSearchResults {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedQuery.isEmpty else {
            return RootSearchResults(query: "", pages: [], contactIDs: [], groupIDs: [])
        }

        let pages = RootSearchPage.allCases.filter { $0.matches(normalizedQuery) }
        let contactIDs = contacts
            .filter { $0.name.localizedCaseInsensitiveContains(normalizedQuery) }
            .map(\.id)
        let groupIDs = groups
            .filter { $0.name.localizedCaseInsensitiveContains(normalizedQuery) }
            .map(\.id)

        return RootSearchResults(
            query: normalizedQuery,
            pages: pages,
            contactIDs: contactIDs,
            groupIDs: groupIDs
        )
    }

    static func results(for query: String, in appState: AppState) -> RootSearchResults {
        results(for: query, contacts: appState.contacts, groups: appState.groups)
    }
}
