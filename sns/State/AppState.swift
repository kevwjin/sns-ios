import Foundation
import Observation

@Observable
final class AppState {
    var myCard: AppContact
    var contacts: [AppContact]
    var groups: [AppGroup]
    var age: Int
    var gender: String
    var preferredGender: String
    var preferredAgeMin: Int
    var preferredAgeMax: Int
    var matchPolicy: MatchPolicy
    var matchingLocation: String
    var matchingRadiusMiles: Int
    var extendRadiusIfNeeded: Bool

    var fofSourceCount: Int {
        contacts.filter(\.useForFoFRecommendations).count
    }

    init(
        myCard: AppContact,
        contacts: [AppContact],
        groups: [AppGroup],
        age: Int = 24,
        gender: String = "Woman",
        preferredGender: String = "No preference",
        preferredAgeMin: Int = 21,
        preferredAgeMax: Int = 27,
        matchPolicy: MatchPolicy = .mutualsOnly,
        matchingLocation: String = "San Francisco, CA",
        matchingRadiusMiles: Int = 10,
        extendRadiusIfNeeded: Bool = false
    ) {
        self.myCard = myCard
        self.contacts = contacts
        self.groups = groups
        self.age = age
        self.gender = gender
        self.preferredGender = preferredGender
        self.preferredAgeMin = preferredAgeMin
        self.preferredAgeMax = preferredAgeMax
        self.matchPolicy = matchPolicy
        self.matchingLocation = matchingLocation
        self.matchingRadiusMiles = matchingRadiusMiles
        self.extendRadiusIfNeeded = extendRadiusIfNeeded
    }

    static func mock() -> AppState {
        AppState(
            myCard: AppContact(name: "My Name"),
            contacts: MockData.contacts,
            groups: MockData.groups
        )
    }

    func add(_ contact: AppContact, toGroupAt groupIndex: Int) {
        guard groups.indices.contains(groupIndex), !groups[groupIndex].members.contains(where: { $0.id == contact.id }) else { return }
        groups[groupIndex].members.append(contact)
    }

    func removeContact(_ contactID: AppContact.ID, fromGroupAt groupIndex: Int) {
        guard groups.indices.contains(groupIndex) else { return }
        groups[groupIndex].members.removeAll { $0.id == contactID }
    }
}
