import SwiftUI

struct RootView: View {
    @State private var appState = AppState.mock()
    @State private var router = AppRouter()
    @State private var homeViewModel = HomeViewModel()

    private var unreadMailCount: Int {
        MockData.mailThreads.filter(\.isUnread).count
    }

    var body: some View {
        TabView(selection: Binding(
            get: { router.selectedTab },
            set: { router.select($0) }
        )) {
            Tab("Match", systemImage: RootTab.match.systemImage, value: RootTab.match) {
                NavigationStack(path: $router.matchPath) {
                    List {
                        matchSections
                    }
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                    .listStyle(.insetGrouped)
                    .sheet(isPresented: $homeViewModel.showBatchInfoSheet) {
                        BatchInfoSheet(batchEndsAtText: homeViewModel.batchEndsAtText)
                    }
                    .alert("Confirm Enrollment", isPresented: $homeViewModel.showEnrollConfirmation) {
                        Button("Cancel", role: .cancel) {
                            homeViewModel.cancelEnrollment()
                        }
                        Button("Confirm Enroll") {
                            homeViewModel.confirmEnrollment()
                        }
                    } message: {
                        Text("This action cannot be undone.")
                    }
                    .onDisappear {
                        homeViewModel.cancelMatchSimulation()
                    }
                    .navigationDestination(for: RootDestination.self) { destination in
                        rootDestination(for: destination)
                    }
                }
                .toolbarVisibility(router.matchPath.isEmpty ? .visible : .hidden, for: .tabBar)
            }

            Tab("Network", systemImage: RootTab.network.systemImage, value: RootTab.network) {
                NavigationStack(path: $router.networkPath) {
                    List {
                        networkSections
                    }
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                    .listStyle(.insetGrouped)
                    .alert("Private Mail", isPresented: privateMailInfoBinding) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("Mail is designed for private, slower messages. Delivery may take longer because messages are routed in a way that avoids exposing direct connection details. Use it like email, not instant chat.")
                    }
                    .navigationDestination(for: RootDestination.self) { destination in
                        rootDestination(for: destination)
                    }
                }
                .toolbarVisibility(router.networkPath.isEmpty ? .visible : .hidden, for: .tabBar)
            }

            Tab("Profile", systemImage: RootTab.profile.systemImage, value: RootTab.profile) {
                NavigationStack(path: $router.profilePath) {
                    ProfileTabView(appState: appState)
                        .navigationDestination(for: RootDestination.self) { destination in
                            rootDestination(for: destination)
                        }
                }
                .toolbarVisibility(router.profilePath.isEmpty ? .visible : .hidden, for: .tabBar)
            }

            Tab("Search", systemImage: RootTab.search.systemImage, value: RootTab.search, role: .search) {
                NavigationStack(path: $router.searchPath) {
                    RootSearchView(
                        appState: appState,
                        isSearchPresented: $router.isRootSearchPresented
                    ) {
                        router.dismissSearch()
                    }
                    .navigationDestination(for: RootDestination.self) { destination in
                        rootDestination(for: destination)
                    }
                }
                .toolbarVisibility(router.searchPath.isEmpty ? .visible : .hidden, for: .tabBar)
            }
            .accessibilityIdentifier("Search Tab")
        }
        .tabViewSearchActivation(.searchTabSelection)
    }

    @ViewBuilder
    private var matchSections: some View {
        Section("This Week") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Label("Weekly Batch", systemImage: "calendar.badge.clock")
                        .font(.headline)

                    Spacer()

                    Button {
                        homeViewModel.showBatchInfoSheet = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("Batch Info")
                }

                WeeklyAvailabilityEditor(
                    appState: appState,
                    isLocked: homeViewModel.isEnrolledInBatch
                )

                Divider()
                    .padding(.vertical, 2)

                SlideToEnrollControl(
                    isEnrolledInBatch: homeViewModel.isEnrolledInBatch,
                    isEnabled: appState.hasCompleteWeeklyAvailability,
                    resetTrigger: homeViewModel.sliderResetTrigger
                ) {
                    homeViewModel.showEnrollConfirmation = true
                }

                Text(batchEnrollmentStatusText)
                    .font(.subheadline)
                    .foregroundStyle(homeViewModel.isEnrolledInBatch ? .green : .secondary)
            }
            .padding(.vertical, 6)

            if homeViewModel.hasMatchThisWeek {
                NavigationLink(value: RootDestination.matchMessages(homeViewModel.simulatedMatchName)) {
                    valueRow(
                        title: "Current Match",
                        value: homeViewModel.simulatedMatchName,
                        systemImage: "message.fill"
                    )
                }
            } else {
                valueRow(
                    title: "Current Match",
                    value: "No match yet",
                    systemImage: "message"
                )
            }
        }
    }

    private var batchEnrollmentStatusText: String {
        if homeViewModel.isEnrolledInBatch {
            return "You're enrolled for this week."
        }

        if appState.hasCompleteWeeklyAvailability {
            return "Enrolling is final and cannot be undone."
        }

        return "Add at least one available time window before enrolling."
    }

    @ViewBuilder
    private var networkSections: some View {
        Section {
            NavigationLink(value: RootDestination.page(.inbox)) {
                valueRow(title: "Inbox", value: "\(unreadMailCount) unread", systemImage: "envelope.fill")
            }
            .accessibilityIdentifier("Mail Inbox Row")
        } header: {
            HStack {
                Text("Mail")
                Spacer()
                Button {
                    router.showRootModal(.privateMailInfo)
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Private Mail Info")
            }
        }

        Section("Network") {
            NavigationLink(value: RootDestination.myCard) {
                valueRow(title: "My Card", value: appState.myCard.name, systemImage: "person.crop.circle.fill")
            }

            NavigationLink(value: RootDestination.page(.contacts)) {
                valueRow(title: "Contacts", value: "\(appState.contacts.count)", systemImage: "person.2.fill")
            }

            NavigationLink(value: RootDestination.page(.groups)) {
                valueRow(title: "Groups", value: "\(appState.groups.count)", systemImage: "rectangle.3.group.fill")
            }
            .accessibilityIdentifier("Groups Row")
        }

        Section("Logbook") {
            NavigationLink(value: RootDestination.page(.logbook)) {
                valueRow(title: "Logbook", value: "\(MockData.logbookItems.count) events", systemImage: "checklist")
            }
            .accessibilityIdentifier("Logbook Row")
        }
    }

    private func valueRow(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 22)

            Text(title)

            Spacer()

            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    private var privateMailInfoBinding: Binding<Bool> {
        Binding(
            get: { router.activeRootModal == .privateMailInfo },
            set: { isPresented in
                if !isPresented {
                    router.dismissRootModal()
                }
            }
        )
    }

    @ViewBuilder
    private func rootDestination(for destination: RootDestination) -> some View {
        switch destination {
        case .page(let page):
            rootPageDestination(for: page)
        case .profileField(let field):
            profileFieldDestination(for: field)
        case .contact(let id):
            if let contact = contactBinding(for: id) {
                ContactDetailView(contact: contact, groups: $appState.groups)
            } else {
                Text("Contact unavailable")
            }
        case .myCard:
            ContactDetailView(contact: $appState.myCard, groups: $appState.groups)
        case .matchMessages(let matchName):
            MatchMessagesView(matchName: matchName)
        }
    }

    @ViewBuilder
    private func rootPageDestination(for page: RootSearchPage) -> some View {
        switch page {
        case .inbox:
            MailInboxView(threads: MockData.mailThreads)
        case .contacts:
            ContactsView(appState: appState)
                .navigationTitle("Contacts")
        case .groups:
            GroupsView(groups: $appState.groups, allContacts: appState.contacts)
                .navigationTitle("Groups")
        case .logbook:
            LogbookView(items: MockData.logbookItems)
        case .location:
            MatchingLocationView(location: $appState.matchingLocation)
        case .radius:
            MatchingRadiusView(
                radiusMiles: $appState.matchingRadiusMiles,
                extendRadiusIfNeeded: $appState.extendRadiusIfNeeded
            )
        case .matchWith:
            MatchGenderPreferenceView(preferredGenders: $appState.preferredGenders)
        case .sexuality:
            MatchSexualityPreferenceView(preferredSexualities: $appState.preferredSexualities)
        case .substanceUse:
            MatchSubstanceUsePreferenceView(acceptedSubstanceUse: $appState.acceptedSubstanceUse)
        case .ageRange:
            AgeRangePreferenceView(
                preferredAgeMin: $appState.preferredAgeMin,
                preferredAgeMax: $appState.preferredAgeMax
            )
        case .matchPolicy:
            MatchPolicyView(matchPolicy: $appState.matchPolicy)
        case .profile:
            AccountProfileView(
                age: $appState.age,
                gender: $appState.gender,
                pronouns: $appState.pronouns,
                sexuality: $appState.sexuality,
                substanceUse: $appState.substanceUse
            )
        }
    }

    @ViewBuilder
    private func profileFieldDestination(for field: ProfileField) -> some View {
        switch field {
        case .age:
            AccountAgeView(age: $appState.age)
        case .gender:
            AccountSingleSelectView(title: field.title, selection: $appState.gender)
        case .pronouns:
            AccountSingleSelectView(title: field.title, selection: $appState.pronouns)
        case .sexuality:
            AccountSingleSelectView(title: field.title, selection: $appState.sexuality)
        case .substanceUse:
            AccountSubstanceUseView(substanceUse: $appState.substanceUse)
        }
    }

    private func contactBinding(for id: AppContact.ID) -> Binding<AppContact>? {
        guard let index = appState.contacts.firstIndex(where: { $0.id == id }) else { return nil }
        return $appState.contacts[index]
    }
}

private struct RootSearchView: View {
    @Bindable var appState: AppState
    @Binding var isSearchPresented: Bool
    let onDismissSearch: () -> Void

    @State private var searchText = ""
    @State private var selectedGroupID: AppGroup.ID?

    private var rootSearchResults: RootSearchResults {
        RootSearchIndex.results(for: searchText, in: appState)
    }

    var body: some View {
        List {
            searchResults
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, isPresented: $isSearchPresented, prompt: "Quick Search")
        .onAppear {
            isSearchPresented = true
        }
        .onChange(of: isSearchPresented) { oldValue, newValue in
            if oldValue && !newValue {
                dismissSearch()
            }
        }
        .sheet(isPresented: Binding(
            get: { selectedGroupID != nil },
            set: { isPresented in
                if !isPresented {
                    selectedGroupID = nil
                }
            }
        )) {
            if let selectedGroupID, let group = groupBinding(for: selectedGroupID) {
                GroupMembersSheetView(group: group, allContacts: appState.contacts)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    @ViewBuilder
    private var searchResults: some View {
        if !rootSearchResults.isSearching {
            Section {
                Text("Search pages, contacts, or groups")
                    .foregroundStyle(.secondary)
            }
        } else if rootSearchResults.isEmpty {
            Section {
                Text("No results")
                    .foregroundStyle(.secondary)
            }
        }

        if !rootSearchResults.pages.isEmpty {
            Section("Pages") {
                ForEach(rootSearchResults.pages) { page in
                    NavigationLink(value: RootDestination.page(page)) {
                        valueRow(title: page.title, value: "", systemImage: page.systemImage)
                    }
                    .accessibilityIdentifier("Quick Search Page \(page.title)")
                }
            }
        }

        if !rootSearchResults.contactIDs.isEmpty {
            Section("Contacts") {
                ForEach(rootSearchResults.contactIDs, id: \.self) { id in
                    if let contact = contactBinding(for: id) {
                        NavigationLink(value: RootDestination.contact(id)) {
                            valueRow(title: contact.wrappedValue.name, value: "", systemImage: "person.crop.circle.fill")
                        }
                    }
                }
            }
        }

        if !rootSearchResults.groupIDs.isEmpty {
            Section("Groups") {
                ForEach(rootSearchResults.groupIDs, id: \.self) { id in
                    if let group = groupBinding(for: id) {
                        Button {
                            selectedGroupID = id
                        } label: {
                            valueRow(title: group.wrappedValue.name, value: "\(group.wrappedValue.members.count) members", systemImage: "person.2.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func valueRow(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 22)

            Text(title)

            Spacer()

            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func contactBinding(for id: AppContact.ID) -> Binding<AppContact>? {
        guard let index = appState.contacts.firstIndex(where: { $0.id == id }) else { return nil }
        return $appState.contacts[index]
    }

    private func groupBinding(for id: AppGroup.ID) -> Binding<AppGroup>? {
        guard let index = appState.groups.firstIndex(where: { $0.id == id }) else { return nil }
        return $appState.groups[index]
    }

    private func dismissSearch() {
        searchText = ""
        onDismissSearch()
    }
}

private struct WeeklyAvailabilityEditor: View {
    @Bindable var appState: AppState
    let isLocked: Bool

    private var calendar: Calendar {
        WeeklyAvailabilityCalendar.configuredCalendar()
    }

    private var selectedDateComponents: Binding<Set<DateComponents>> {
        Binding(
            get: {
                Set(appState.weeklyAvailability.map {
                    calendar.dateComponents([.calendar, .era, .year, .month, .day], from: $0.date)
                })
            },
            set: {
                appState.setWeeklyAvailabilityDates($0, calendar: calendar)
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Label("Availability", systemImage: "calendar")
                    .font(.headline)

                Spacer()

                Text(appState.weeklyAvailabilitySummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let weekRange = WeeklyAvailabilityCalendar.currentWeekDateRange(calendar: calendar) {
                VStack(alignment: .leading, spacing: 0) {
                    MultiDatePicker(
                        "Available Days",
                        selection: selectedDateComponents,
                        in: weekRange
                    )
                    .disabled(isLocked)
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("Weekly Availability Calendar")
            }

            if appState.weeklyAvailability.isEmpty {
                Text("Select the days you can meet this week.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(appState.weeklyAvailability) { day in
                        if let dayBinding = availabilityDayBinding(for: day.id) {
                            availabilityDayView(day: dayBinding)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("Weekly Availability Editor")
    }

    @ViewBuilder
    private func availabilityDayView(day: Binding<WeeklyAvailabilityDay>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(day.wrappedValue.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                    .font(.subheadline.weight(.semibold))

                Spacer()

                if !isLocked {
                    Button {
                        appState.addAvailabilityWindow(on: day.wrappedValue.date, calendar: calendar)
                    } label: {
                        Label("Add Window", systemImage: "plus.circle")
                    }
                    .font(.caption)
                    .buttonStyle(.borderless)
                    .accessibilityIdentifier("Add Availability Window")
                }
            }

            if day.wrappedValue.windows.isEmpty {
                Text(isLocked ? "No time windows added." : "Add a time window for this day.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(day.windows) { $window in
                    if isLocked {
                        readOnlyWindowRow(window)
                    } else {
                        editableWindowRow(window: $window, day: day.wrappedValue.date)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }

    private func editableWindowRow(window: Binding<AvailabilityWindow>, day: Date) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            DatePicker(
                "Start",
                selection: window.startTime,
                displayedComponents: .hourAndMinute
            )
            .accessibilityIdentifier("Availability Start Time")

            DatePicker(
                "End",
                selection: window.endTime,
                displayedComponents: .hourAndMinute
            )
            .accessibilityIdentifier("Availability End Time")

            HStack {
                if !window.wrappedValue.isValid {
                    Text("End time must be after start time.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Spacer()

                Button(role: .destructive) {
                    appState.removeAvailabilityWindow(window.wrappedValue.id, on: day, calendar: calendar)
                } label: {
                    Label("Remove", systemImage: "minus.circle")
                }
                .font(.caption)
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 4)
    }

    private func readOnlyWindowRow(_ window: AvailabilityWindow) -> some View {
        HStack {
            Image(systemName: "clock")
                .foregroundStyle(.secondary)
                .frame(width: 18)

            Text("\(window.startTime.formatted(date: .omitted, time: .shortened))-\(window.endTime.formatted(date: .omitted, time: .shortened))")
                .font(.subheadline)

            Spacer()
        }
    }

    private func availabilityDayBinding(for id: WeeklyAvailabilityDay.ID) -> Binding<WeeklyAvailabilityDay>? {
        guard let index = appState.weeklyAvailability.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        return $appState.weeklyAvailability[index]
    }
}

private struct BatchInfoSheet: View {
    let batchEndsAtText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Batch Info")
                .font(.headline)

            Text("Each week's batch closes \(batchEndsAtText).")
                .font(.subheadline)

            Text("When the batch ends, your match is released automatically if you are enrolled.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Who you match with is based on your match criteria.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("For this MVP mock, matched users are assigned either a cafe or walk activity at a vetted San Francisco spot.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .presentationDetents([.fraction(0.36)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    RootView()
}
