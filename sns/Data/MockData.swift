import Foundation

enum MockData {
    static let contacts: [AppContact] = [
        AppContact(name: "Ava Thompson"),
        AppContact(name: "Noah Kim"),
        AppContact(name: "Mia Patel"),
        AppContact(name: "Liam Chen"),
        AppContact(name: "Sophia Martinez"),
        AppContact(name: "Ethan Johnson")
    ]

    static let groups: [AppGroup] = [
        AppGroup(name: "Study Group", members: [contacts[0], contacts[1], contacts[2]]),
        AppGroup(name: "Weekend Hikes", members: [contacts[3], contacts[4]])
    ]

    static let logbookItems: [ActivityItem] = [
        ActivityItem(title: "Enrolled in this week's batch", detail: "You're in for Sunday release.", timestamp: "2h ago", symbol: "checkmark.circle.fill"),
        ActivityItem(title: "Added Ava Thompson", detail: "New contact added to your network.", timestamp: "Yesterday", symbol: "person.badge.plus"),
        ActivityItem(title: "Created Weekend Hikes", detail: "Group now has 5 members.", timestamp: "2d ago", symbol: "person.2.fill"),
        ActivityItem(title: "Updated discovery preferences", detail: "Age range updated to 21-27.", timestamp: "3d ago", symbol: "slider.horizontal.3")
    ]

    static let initialMatchMessages: [MatchMessage] = [
        MatchMessage(isFromUser: false, text: "Hey! Nice to match with you this week.", timestamp: "9:41 AM"),
        MatchMessage(isFromUser: true, text: "Likewise, hope your week is going well.", timestamp: "9:42 AM"),
        MatchMessage(isFromUser: false, text: "It is! Want to grab coffee tomorrow?", timestamp: "9:43 AM")
    ]
}
