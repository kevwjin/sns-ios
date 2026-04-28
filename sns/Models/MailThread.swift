import Foundation

struct MailThread: Identifiable {
    let id = UUID()
    var correspondentName: String
    var subject: String
    var preview: String
    var timestamp: String
    var isUnread: Bool
    var messages: [MailMessage]
}
