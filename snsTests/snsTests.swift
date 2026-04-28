//
//  snsTests.swift
//  snsTests
//
//  Created by Kevin Jin on 3/27/26.
//

import Testing
@testable import sns

struct snsTests {

    @Test func contactNameParsesFirstAndLastName() {
        let contact = AppContact(name: "Ava Thompson")

        #expect(contact.firstName == "Ava")
        #expect(contact.lastName == "Thompson")
        #expect(contact.name == "Ava Thompson")
    }

    @Test func blankContactUsesFallbackName() {
        let contact = AppContact(name: "   ")

        #expect(contact.firstName.isEmpty)
        #expect(contact.lastName.isEmpty)
        #expect(contact.name == "Unnamed Contact")
    }

    @Test func appStateCountsEligibleContacts() {
        var enabledContact = AppContact(name: "Ava Thompson")
        var disabledContact = AppContact(name: "Noah Kim")
        disabledContact.useForFoFRecommendations = false

        let state = AppState(
            myCard: AppContact(name: "My Name"),
            contacts: [enabledContact, disabledContact],
            groups: []
        )

        #expect(state.fofSourceCount == 1)

        enabledContact.useForFoFRecommendations = false
        state.contacts = [enabledContact, disabledContact]

        #expect(state.fofSourceCount == 0)
    }

    @Test func appStateAddsAndRemovesGroupMembership() {
        let contact = AppContact(name: "Ava Thompson")
        let state = AppState(
            myCard: AppContact(name: "My Name"),
            contacts: [contact],
            groups: [AppGroup(name: "Study Group", members: [])]
        )

        state.add(contact, toGroupAt: 0)

        #expect(state.groups[0].members.map(\.id) == [contact.id])

        state.add(contact, toGroupAt: 0)

        #expect(state.groups[0].members.count == 1)

        state.removeContact(contact.id, fromGroupAt: 0)

        #expect(state.groups[0].members.isEmpty)
    }

    @Test func appStateUsesDefaultMatchingCriteria() {
        let state = AppState.mock()

        #expect(state.matchingLocation == "San Francisco, CA")
        #expect(state.matchingRadiusMiles == 10)
        #expect(state.extendRadiusIfNeeded == false)
        #expect(state.matchPolicy == .mutualsOnly)
    }

    @Test func appStateUpdatesMatchingRadius() {
        let state = AppState.mock()

        state.matchingRadiusMiles = 25

        #expect(state.matchingRadiusMiles == 25)
    }

    @Test func appStateUpdatesRadiusFlexibility() {
        let state = AppState.mock()

        state.extendRadiusIfNeeded = true

        #expect(state.extendRadiusIfNeeded == true)
    }

}
