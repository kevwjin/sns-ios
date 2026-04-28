import Foundation

struct MailMessage: Identifiable {
    let id = UUID()
    let senderName: String
    let body: String
    let timestamp: String
    let isFromUser: Bool
}
