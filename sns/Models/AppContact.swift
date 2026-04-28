import Foundation

struct AppContact: Identifiable, Hashable {
    let id = UUID()
    var firstName: String
    var lastName: String
    var bio: String
    var phone: String
    var email: String
    var pronouns: String
    var address: String
    var websiteURL: String
    var birthday: Date?
    var notes: String
    var useForFoFRecommendations: Bool

    var name: String {
        let combined = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return combined.isEmpty ? "Unnamed Contact" : combined
    }

    init(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: " ", maxSplits: 1).map(String.init)
        self.firstName = parts.first ?? ""
        self.lastName = parts.count > 1 ? parts[1] : ""
        self.bio = ""
        self.phone = ""
        self.email = ""
        self.pronouns = ""
        self.address = ""
        self.websiteURL = ""
        self.birthday = nil
        self.notes = ""
        self.useForFoFRecommendations = true
    }
}
