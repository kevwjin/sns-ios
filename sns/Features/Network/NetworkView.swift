import SwiftUI

struct NetworkView: View {
    @State private var searchText = ""
    @Bindable var appState: AppState

    private var filteredContacts: [AppContact] {
        guard !searchText.isEmpty else { return [] }
        return appState.contacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var filteredGroups: [AppGroup] {
        guard !searchText.isEmpty else { return [] }
        return appState.groups.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Browse") {
                    NavigationLink {
                        ContactsView(appState: appState)
                            .navigationTitle("Contacts")
                    } label: {
                        Text("Contacts")
                    }

                    NavigationLink {
                        GroupsView(groups: $appState.groups, allContacts: appState.contacts)
                            .navigationTitle("Groups")
                    } label: {
                        Text("Groups")
                    }
                }

                Section {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                        Text("People in the same groups are more likely to be recommended to each other.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if !searchText.isEmpty {
                    if !filteredContacts.isEmpty {
                        Section("Contacts") {
                            ForEach(filteredContacts) { contact in
                                HStack(spacing: 12) {
                                    Image(systemName: "person.crop.circle.fill")
                                        .foregroundStyle(.secondary)
                                    Text(contact.name)
                                }
                            }
                        }
                    }

                    if !filteredGroups.isEmpty {
                        Section("Groups") {
                            ForEach(filteredGroups) { group in
                                HStack(spacing: 12) {
                                    Image(systemName: "person.2.fill")
                                        .foregroundStyle(.secondary)
                                    Text(group.name)
                                }
                            }
                        }
                    }

                    if filteredContacts.isEmpty && filteredGroups.isEmpty {
                        Section {
                            Text("No results")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Network")
            .searchable(text: $searchText, prompt: "Search for contacts or groups")
        }
    }
}
