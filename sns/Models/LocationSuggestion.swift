import Foundation

struct LocationSuggestion: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let keywords: [String]

    init(title: String, subtitle: String = "", keywords: [String] = []) {
        self.id = [title, subtitle].filter { !$0.isEmpty }.joined(separator: "|")
        self.title = title
        self.subtitle = subtitle
        self.keywords = keywords
    }

    var displayName: String {
        guard !subtitle.isEmpty else { return title }
        return "\(title), \(subtitle)"
    }

    func matches(_ query: String) -> Bool {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return false }

        let searchableText = ([title, subtitle, displayName] + keywords)
            .joined(separator: " ")

        return searchableText.localizedCaseInsensitiveContains(trimmedQuery)
    }
}
