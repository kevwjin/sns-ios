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

    static let locationSuggestions: [LocationSuggestion] = [
        LocationSuggestion(title: "Hayes Valley", subtitle: "San Francisco, CA", keywords: ["94102", "neighborhood", "sf"]),
        LocationSuggestion(title: "Mission District", subtitle: "San Francisco, CA", keywords: ["94110", "neighborhood", "sf"]),
        LocationSuggestion(title: "SoMa", subtitle: "San Francisco, CA", keywords: ["94103", "south of market", "neighborhood", "sf"]),
        LocationSuggestion(title: "123 Market St", subtitle: "San Francisco, CA", keywords: ["94105", "address", "financial district"]),
        LocationSuggestion(title: "San Francisco", subtitle: "CA", keywords: ["94102", "94103", "94105", "94110", "city", "sf"]),
        LocationSuggestion(title: "Williamsburg", subtitle: "Brooklyn, NY", keywords: ["11211", "11249", "neighborhood"]),
        LocationSuggestion(title: "10012", subtitle: "New York, NY", keywords: ["soho", "nolita", "zip"]),
        LocationSuggestion(title: "Santa Monica", subtitle: "CA", keywords: ["90401", "90402", "city"]),
        LocationSuggestion(title: "Capitol Hill", subtitle: "Seattle, WA", keywords: ["98102", "neighborhood"]),
        LocationSuggestion(title: "Wicker Park", subtitle: "Chicago, IL", keywords: ["60622", "neighborhood"])
    ]

    static func locationSuggestions(matching query: String) -> [LocationSuggestion] {
        locationSuggestions.filter { $0.matches(query) }
    }

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

    static let mailThreads: [MailThread] = [
        MailThread(
            correspondentName: "Ava Thompson",
            subject: "Coffee after the batch?",
            preview: "I might be near Hayes Valley later this week.",
            timestamp: "Today",
            isUnread: true,
            messages: [
                MailMessage(senderName: "Ava Thompson", body: "I might be near Hayes Valley later this week. Want to find a quiet coffee spot?", timestamp: "Today, 9:12 AM", isFromUser: false),
                MailMessage(senderName: "Me", body: "That sounds good. Thursday afternoon is easiest for me.", timestamp: "Today, 9:30 AM", isFromUser: true)
            ]
        ),
        MailThread(
            correspondentName: "Noah Kim",
            subject: "Intro through Study Group",
            preview: "Mia said we should compare notes before Sunday.",
            timestamp: "Yesterday",
            isUnread: true,
            messages: [
                MailMessage(senderName: "Noah Kim", body: "Mia said we should compare notes before Sunday. I can send over a short summary tonight.", timestamp: "Yesterday, 7:44 PM", isFromUser: false)
            ]
        ),
        MailThread(
            correspondentName: "Liam Chen",
            subject: "Weekend Hikes route",
            preview: "The route I mentioned is better early in the morning.",
            timestamp: "Mon",
            isUnread: false,
            messages: [
                MailMessage(senderName: "Liam Chen", body: "The route I mentioned is better early in the morning. It gets crowded after 10.", timestamp: "Mon, 8:18 AM", isFromUser: false),
                MailMessage(senderName: "Me", body: "Good call. I will check the trail map before we pick a time.", timestamp: "Mon, 10:05 AM", isFromUser: true)
            ]
        )
    ]
}
