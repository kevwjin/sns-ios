//
//  snsTests.swift
//  snsTests
//
//  Created by Kevin Jin on 3/27/26.
//

import Foundation
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

        #expect(state.matchingLocation == "SoMa")
        #expect(state.matchingRadiusMiles == 10)
        #expect(state.extendRadiusIfNeeded == false)
        #expect(state.matchPolicy == .mutualsOnly)
    }

    @Test func appStateUsesDefaultProfileCriteria() {
        let state = AppState.mock()

        #expect(state.gender == .female)
        #expect(state.pronouns == .sheHer)
        #expect(state.sexuality == .notListed)
        #expect(state.substanceUse.isEmpty)
        #expect(state.profileSummary == "24, Female")
        #expect(state.substanceUseSummary == "None listed")
    }

    @Test func appStateDefaultsMatchCriteriaToOpenToAll() {
        let state = AppState.mock()

        #expect(state.preferredGenders == Set(GenderIdentity.allCases))
        #expect(state.preferredSexualities == Set(SexualityOption.allCases))
        #expect(state.acceptedSubstanceUse == Set(SubstanceUseCategory.allCases))
        #expect(state.preferredGendersSummary == "Open to all")
        #expect(state.preferredSexualitiesSummary == "Open to all")
        #expect(state.acceptedSubstanceUseSummary == "Open to all")
    }

    @Test func appStateSummarizesPartialCriteriaSelections() {
        let state = AppState.mock()

        state.substanceUse = [.drinking, .marijuana]
        state.preferredGenders = [.female, .nonbinary]
        state.preferredSexualities = []
        state.acceptedSubstanceUse = [.drinking]

        #expect(state.substanceUseSummary == "Marijuana, Drinking")
        #expect(state.preferredGendersSummary == "Female, Nonbinary")
        #expect(state.preferredSexualitiesSummary == "None selected")
        #expect(state.acceptedSubstanceUseSummary == "Drinking")
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

    @Test func weeklyAvailabilityDefaultsToIncomplete() {
        let state = AppState.mock()

        #expect(state.weeklyAvailability.isEmpty)
        #expect(!state.hasCompleteWeeklyAvailability)
        #expect(state.weeklyAvailabilitySummary == "No availability")
    }

    @Test func weeklyAvailabilitySelectedDayWithoutWindowDoesNotUnlockEnrollment() {
        let state = AppState.mock()
        let calendar = testCalendar()
        let date = testDate(year: 2026, month: 4, day: 30, hour: 12, calendar: calendar)
        let components = calendar.dateComponents([.calendar, .era, .year, .month, .day], from: date)

        state.setWeeklyAvailabilityDates([components], calendar: calendar)

        #expect(state.weeklyAvailability.count == 1)
        #expect(state.weeklyAvailability[0].windows.isEmpty)
        #expect(!state.hasCompleteWeeklyAvailability)
    }

    @Test func weeklyAvailabilityInvalidWindowDoesNotUnlockEnrollment() {
        let state = AppState.mock()
        let calendar = testCalendar()
        let startTime = testDate(year: 2026, month: 4, day: 30, hour: 18, calendar: calendar)
        let endTime = testDate(year: 2026, month: 4, day: 30, hour: 18, calendar: calendar)

        state.weeklyAvailability = [
            WeeklyAvailabilityDay(date: startTime, windows: [
                AvailabilityWindow(startTime: startTime, endTime: endTime)
            ])
        ]

        #expect(!state.hasCompleteWeeklyAvailability)
        #expect(state.weeklyAvailabilitySummary == "No availability")
    }

    @Test func weeklyAvailabilityValidWindowUnlocksEnrollment() {
        let state = AppState.mock()
        let calendar = testCalendar()
        let day = testDate(year: 2026, month: 4, day: 30, hour: 12, calendar: calendar)

        state.weeklyAvailability = [WeeklyAvailabilityDay(date: day)]
        state.addAvailabilityWindow(on: day, calendar: calendar)

        #expect(state.hasCompleteWeeklyAvailability)
        #expect(state.weeklyAvailabilitySummary == "1 time window")
    }

    @Test func weeklyAvailabilitySupportsMultipleWindowsPerDay() {
        let state = AppState.mock()
        let calendar = testCalendar()
        let day = testDate(year: 2026, month: 4, day: 30, hour: 12, calendar: calendar)

        state.weeklyAvailability = [WeeklyAvailabilityDay(date: day)]
        state.addAvailabilityWindow(on: day, calendar: calendar)
        state.addAvailabilityWindow(on: day, calendar: calendar)

        #expect(state.weeklyAvailability[0].windows.count == 2)
        #expect(state.hasCompleteWeeklyAvailability)
        #expect(state.weeklyAvailabilitySummary == "2 time windows")
    }

    @Test func weeklyAvailabilityCalendarReturnsMondayThroughSunday() {
        let calendar = testCalendar()
        let thursday = testDate(year: 2026, month: 4, day: 30, hour: 12, calendar: calendar)
        let weekDates = WeeklyAvailabilityCalendar.currentWeekDates(containing: thursday, calendar: calendar)
        let weekdays = weekDates.map { WeeklyAvailabilityCalendar.configuredCalendar(from: calendar).component(.weekday, from: $0) }

        #expect(weekDates.count == 7)
        #expect(weekdays == [2, 3, 4, 5, 6, 7, 1])
    }

    @Test func locationSuggestionFormatsDisplayName() {
        let neighborhood = LocationSuggestion(title: "Hayes Valley", subtitle: "San Francisco, CA")
        let city = LocationSuggestion(title: "San Francisco")

        #expect(neighborhood.displayName == "Hayes Valley, San Francisco, CA")
        #expect(city.displayName == "San Francisco")
    }

    @Test func locationSuggestionCarriesNeighborhoodMapping() {
        let marketStreet = MockData.locationSuggestions(matching: "123 Market").first { $0.title == "123 Market St" }
        let city = MockData.locationSuggestions(matching: "San Francisco").first { $0.title == "San Francisco" }

        #expect(marketStreet?.neighborhoodName == "Financial District")
        #expect(marketStreet?.neighborhoodMappingDescription == "Maps to Financial District")
        #expect(city?.neighborhoodName == "SoMa")
    }

    @Test func locationSuggestionSearchMatchesMultipleLocationInputs() {
        #expect(MockData.locationSuggestions(matching: "hayes").contains { $0.title == "Hayes Valley" })
        #expect(MockData.locationSuggestions(matching: "sf").contains { $0.title == "San Francisco" })
        #expect(MockData.locationSuggestions(matching: "123 Market").contains { $0.title == "123 Market St" })
        #expect(MockData.locationSuggestions(matching: "94102").contains { $0.title == "Hayes Valley" })
    }

    @Test func locationSuggestionSearchIsSanFranciscoOnly() {
        #expect(MockData.locationSuggestions(matching: "Brooklyn").isEmpty)
        #expect(MockData.locationSuggestions(matching: "Santa Monica").isEmpty)
        #expect(MockData.locationSuggestions(matching: "Seattle").isEmpty)
    }

    @Test func locationSuggestionSearchIgnoresEmptyQuery() {
        #expect(MockData.locationSuggestions(matching: "").isEmpty)
        #expect(MockData.locationSuggestions(matching: "   ").isEmpty)
    }

    @Test func rootSearchFindsContactsByName() {
        let state = AppState.mock()
        let results = RootSearchIndex.results(for: "Ava", in: state)

        #expect(results.pages.isEmpty)
        #expect(results.contactIDs == [state.contacts[0].id])
        #expect(results.groupIDs.isEmpty)
        #expect(results.isSearching)
        #expect(!results.isEmpty)
    }

    @Test func rootSearchFindsGroupsByName() {
        let state = AppState.mock()
        let results = RootSearchIndex.results(for: "Study", in: state)

        #expect(results.pages.isEmpty)
        #expect(results.contactIDs.isEmpty)
        #expect(results.groupIDs == [state.groups[0].id])
    }

    @Test func rootSearchFindsPagesByTitleAndKeyword() {
        let state = AppState.mock()
        let radiusResults = RootSearchIndex.results(for: "radius", in: state)
        let inboxResults = RootSearchIndex.results(for: "mail", in: state)

        #expect(radiusResults.pages == [.radius])
        #expect(inboxResults.pages == [.inbox])
    }

    @Test func rootSearchTrimsWhitespace() {
        let state = AppState.mock()
        let results = RootSearchIndex.results(for: "  Ava  ", in: state)

        #expect(results.query == "Ava")
        #expect(results.contactIDs == [state.contacts[0].id])
    }

    @Test func rootSearchHandlesEmptyAndNoResultQueries() {
        let state = AppState.mock()
        let emptyResults = RootSearchIndex.results(for: "   ", in: state)
        let noResults = RootSearchIndex.results(for: "zzzzzz", in: state)

        #expect(!emptyResults.isSearching)
        #expect(emptyResults.isEmpty)
        #expect(noResults.isSearching)
        #expect(noResults.isEmpty)
    }

    @Test func appRouterDefaultsToMatchWithEmptyPaths() {
        let router = AppRouter()

        #expect(router.selectedTab == .match)
        #expect(router.lastContentTab == .match)
        #expect(router.matchPath.isEmpty)
        #expect(router.networkPath.isEmpty)
        #expect(router.profilePath.isEmpty)
        #expect(router.searchPath.isEmpty)
        #expect(router.isRootSearchPresented == false)
        #expect(router.activeRootModal == nil)
    }

    @Test func appRouterTracksLastContentTab() {
        let router = AppRouter()

        router.select(.network)

        #expect(router.selectedTab == .network)
        #expect(router.lastContentTab == .network)

        router.select(.profile)

        #expect(router.selectedTab == .profile)
        #expect(router.lastContentTab == .profile)

        router.select(.search)

        #expect(router.selectedTab == .search)
        #expect(router.lastContentTab == .profile)
    }

    @Test func appRouterDismissesSearchToLastContentTab() {
        let router = AppRouter()
        router.select(.profile)
        router.select(.search)
        router.isRootSearchPresented = true

        router.dismissSearch()

        #expect(router.selectedTab == .profile)
        #expect(router.lastContentTab == .profile)
        #expect(router.isRootSearchPresented == false)
    }

    @Test func appRouterOpensDestinationsOnExpectedPaths() {
        let router = AppRouter()
        let contactID = AppContact(name: "Ava Thompson").id

        router.openPage(.radius)
        router.openContact(contactID, from: .network)
        router.openPage(.sexuality, from: .profile)
        router.openMyCard(from: .search)
        router.openMatchMessages("Ava Thompson", from: .match)

        #expect(router.matchPath == [.page(.radius), .matchMessages("Ava Thompson")])
        #expect(router.networkPath == [.contact(contactID)])
        #expect(router.profilePath == [.page(.sexuality)])
        #expect(router.searchPath == [.myCard])
    }

    @Test func appRouterShowsAndDismissesRootModal() {
        let router = AppRouter()

        router.showRootModal(.privateMailInfo)

        #expect(router.activeRootModal == .privateMailInfo)

        router.dismissRootModal()

        #expect(router.activeRootModal == nil)
    }

    @Test func appRouterFutureFlowHooksAreNoOps() {
        let router = AppRouter()

        router.startOnboarding()
        router.openMatchRelease()

        #expect(router.selectedTab == .match)
        #expect(router.lastContentTab == .match)
        #expect(router.matchPath.isEmpty)
        #expect(router.networkPath.isEmpty)
        #expect(router.profilePath.isEmpty)
        #expect(router.searchPath.isEmpty)
        #expect(router.activeRootModal == nil)
    }

    private func testCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }

    private func testDate(year: Int, month: Int, day: Int, hour: Int, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour
        ))!
    }
}
