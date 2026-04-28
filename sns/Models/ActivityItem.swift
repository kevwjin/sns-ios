import Foundation

struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let timestamp: String
    let symbol: String
}
