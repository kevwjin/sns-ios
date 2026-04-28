import Foundation

struct MatchMessage: Identifiable {
    let id = UUID()
    let isFromUser: Bool
    let text: String
    let timestamp: String
}
