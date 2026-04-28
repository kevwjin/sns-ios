import SwiftUI

struct GroupsView: View {
    @Binding var groups: [AppGroup]
    let allContacts: [AppContact]
    @State private var searchText = ""
    @State private var selectedGroupIndex: Int?
    @State private var isEditingGroups = false
    @State private var editMode: EditMode = .inactive
    @State private var showPriorityInfo = false
    @State private var showAddGroupAlert = false
    @State private var newGroupName = ""
    @State private var pendingDeleteGroupIndex: Int?

    private var filteredGroupIndices: [Int] {
        groups.indices.filter { index in
            searchText.isEmpty || groups[index].name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            ForEach(filteredGroupIndices, id: \.self) { index in
                HStack(spacing: 12) {
                    if isEditingGroups {
                        Button {
                            pendingDeleteGroupIndex = index
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }

                    Image(systemName: "person.2.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    if isEditingGroups {
                        Text(groups[index].name)
                            .foregroundStyle(.primary)
                    } else {
                        Button {
                            selectedGroupIndex = index
                        } label: {
                            Text(groups[index].name)
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
            .onMove { fromOffsets, toOffset in
                guard searchText.isEmpty else { return }
                groups.move(fromOffsets: fromOffsets, toOffset: toOffset)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search Groups")
        .environment(\.editMode, $editMode)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showPriorityInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel("Group Priority Info")
            }

            if isEditingGroups {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddGroupAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create Group")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditingGroups ? "Done" : "Edit") {
                    withAnimation {
                        let newValue = !isEditingGroups
                        isEditingGroups = newValue
                        editMode = newValue ? .active : .inactive
                    }
                }
            }
        }
        .alert("Group Priority", isPresented: $showPriorityInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Higher-priority groups are favored more when a match is connected through that group.")
        }
        .alert("Add Group", isPresented: $showAddGroupAlert) {
            TextField("Group name", text: $newGroupName)
            Button("Cancel", role: .cancel) {
                newGroupName = ""
            }
            Button("Add") {
                let trimmedName = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedName.isEmpty else { return }
                groups.insert(AppGroup(name: trimmedName, members: []), at: 0)
                newGroupName = ""
            }
        } message: {
            Text("Create a new group.")
        }
        .alert("Delete Group?", isPresented: Binding(
            get: { pendingDeleteGroupIndex != nil },
            set: { isPresented in
                if !isPresented {
                    pendingDeleteGroupIndex = nil
                }
            }
        )) {
            Button("Cancel", role: .cancel) {
                pendingDeleteGroupIndex = nil
            }
            Button("Delete", role: .destructive) {
                if let pendingDeleteGroupIndex, groups.indices.contains(pendingDeleteGroupIndex) {
                    groups.remove(at: pendingDeleteGroupIndex)
                }
                pendingDeleteGroupIndex = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: Binding(
            get: { selectedGroupIndex != nil },
            set: { isPresented in
                if !isPresented {
                    selectedGroupIndex = nil
                }
            }
        )) {
            if let selectedGroupIndex {
                GroupMembersSheetView(group: $groups[selectedGroupIndex], allContacts: allContacts)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct AddContactToGroupsSheetView: View {
    @Binding var groups: [AppGroup]
    let contact: AppContact

    @Environment(\.dismiss) private var dismiss

    private var availableGroupIndices: [Int] {
        groups.indices.filter { groupIndex in
            !groups[groupIndex].members.contains(where: { $0.id == contact.id })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if availableGroupIndices.isEmpty {
                    Text("This contact is already in all groups.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(availableGroupIndices, id: \.self) { groupIndex in
                        Button {
                            groups[groupIndex].members.append(contact)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "person.2.fill")
                                    .foregroundStyle(.secondary)
                                Text(groups[groupIndex].name)
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Add to Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct GroupMembersSheetView: View {
    @Binding var group: AppGroup
    let allContacts: [AppContact]

    @State private var isEditingMembers = false
    @State private var showAddMembersSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(group.members) { member in
                    HStack(spacing: 12) {
                        if isEditingMembers {
                            Button {
                                removeMember(member.id)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }

                        Image(systemName: "person.crop.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        Text(member.name)
                    }
                    .padding(.vertical, 2)
                }
            }
            .listStyle(.plain)
            .navigationTitle(group.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isEditingMembers ? "Done" : "Edit") {
                        withAnimation {
                            isEditingMembers.toggle()
                        }
                    }
                }

                if isEditingMembers {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            showAddMembersSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add Members")
                    }
                }
            }
            .sheet(isPresented: $showAddMembersSheet) {
                AddMembersToGroupSheetView(
                    availableContacts: allContacts.filter { contact in
                        !group.members.contains(where: { $0.id == contact.id })
                    }
                ) { selectedMembers in
                    group.members.append(contentsOf: selectedMembers)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private func removeMember(_ id: AppContact.ID) {
        group.members.removeAll { $0.id == id }
    }
}

struct AddMembersToGroupSheetView: View {
    let availableContacts: [AppContact]
    let onAddMembers: ([AppContact]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedContactIDs: Set<AppContact.ID> = []

    var body: some View {
        NavigationStack {
            List(availableContacts) { contact in
                Button {
                    toggleSelection(for: contact.id)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: selectedContactIDs.contains(contact.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedContactIDs.contains(contact.id) ? .green : .secondary)

                        Text(contact.name)
                            .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Add Members")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let selectedMembers = availableContacts.filter { selectedContactIDs.contains($0.id) }
                        onAddMembers(selectedMembers)
                        dismiss()
                    }
                    .disabled(selectedContactIDs.isEmpty)
                }
            }
        }
    }

    private func toggleSelection(for id: AppContact.ID) {
        if selectedContactIDs.contains(id) {
            selectedContactIDs.remove(id)
        } else {
            selectedContactIDs.insert(id)
        }
    }
}
