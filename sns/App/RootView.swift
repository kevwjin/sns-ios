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

                SlideToEnrollControl(
                    isEnrolledInBatch: homeViewModel.isEnrolledInBatch,
                    resetTrigger: homeViewModel.sliderResetTrigger
                ) {
                    homeViewModel.showEnrollConfirmation = true
                }

                Text(homeViewModel.isEnrolledInBatch ? "You're enrolled for this week." : "Enrolling is final and cannot be undone.")
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

        Section("Match Criteria") {
            NavigationLink(value: RootDestination.page(.location)) {
                valueRow(title: "Location", value: appState.matchingLocation, systemImage: "location.fill")
            }
            .accessibilityIdentifier("Location Row")

            NavigationLink(value: RootDestination.page(.radius)) {
                valueRow(title: "Radius", value: "Within \(appState.matchingRadiusMiles) mi", systemImage: "scope")
            }
            .accessibilityIdentifier("Radius Row")

            NavigationLink(value: RootDestination.page(.matchWith)) {
                valueRow(title: "Match With", value: appState.preferredGender, systemImage: "person.2.circle")
            }
            .accessibilityIdentifier("Match With Row")

            NavigationLink(value: RootDestination.page(.ageRange)) {
                valueRow(title: "Age Range", value: "\(appState.preferredAgeMin)-\(appState.preferredAgeMax)", systemImage: "slider.horizontal.3")
            }
            .accessibilityIdentifier("Age Range Row")

            NavigationLink(value: RootDestination.page(.matchPolicy)) {
                valueRow(title: "Match Policy", value: appState.matchPolicy.label, systemImage: "person.2.wave.2.fill")
            }
            .accessibilityIdentifier("Match Policy Row")
        }

        Section("Account") {
            NavigationLink(value: RootDestination.page(.profile)) {
                valueRow(title: "Profile", value: "\(appState.age), \(appState.gender)", systemImage: "person.text.rectangle")
            }
        }
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
            MatchWithView(preferredGender: $appState.preferredGender)
        case .ageRange:
            AgeRangePreferenceView(
                preferredAgeMin: $appState.preferredAgeMin,
                preferredAgeMax: $appState.preferredAgeMax
            )
        case .matchPolicy:
            MatchPolicyView(matchPolicy: $appState.matchPolicy)
        case .profile:
            ProfileView(age: $appState.age, gender: $appState.gender)
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

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var filteredPages: [RootSearchPage] {
        guard isSearching else { return [] }
        return RootSearchPage.allCases.filter { $0.matches(searchText) }
    }

    private var filteredContactIDs: [AppContact.ID] {
        guard isSearching else { return [] }
        return appState.contacts
            .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            .map(\.id)
    }

    private var filteredGroupIDs: [AppGroup.ID] {
        guard isSearching else { return [] }
        return appState.groups
            .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            .map(\.id)
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
        if !isSearching {
            Section {
                Text("Search pages, contacts, or groups")
                    .foregroundStyle(.secondary)
            }
        } else if filteredPages.isEmpty && filteredContactIDs.isEmpty && filteredGroupIDs.isEmpty {
            Section {
                Text("No results")
                    .foregroundStyle(.secondary)
            }
        }

        if !filteredPages.isEmpty {
            Section("Pages") {
                ForEach(filteredPages) { page in
                    NavigationLink(value: RootDestination.page(page)) {
                        valueRow(title: page.title, value: "", systemImage: page.systemImage)
                    }
                    .accessibilityIdentifier("Quick Search Page \(page.title)")
                }
            }
        }

        if !filteredContactIDs.isEmpty {
            Section("Contacts") {
                ForEach(filteredContactIDs, id: \.self) { id in
                    if let contact = contactBinding(for: id) {
                        NavigationLink(value: RootDestination.contact(id)) {
                            valueRow(title: contact.wrappedValue.name, value: "", systemImage: "person.crop.circle.fill")
                        }
                    }
                }
            }
        }

        if !filteredGroupIDs.isEmpty {
            Section("Groups") {
                ForEach(filteredGroupIDs, id: \.self) { id in
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
