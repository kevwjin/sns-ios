import SwiftUI

struct SettingsView: View {
    @Bindable var appState: AppState
    @State private var showProfileSheet = false
    @State private var showPreferencesSheet = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    Button {
                        showProfileSheet = true
                    } label: {
                        HStack {
                            Text("Edit Profile")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)

                    preferenceValueRow(title: "Age", value: "\(appState.age)")
                    preferenceValueRow(title: "Gender", value: appState.gender)
                }

                Section("Preferences") {
                    Button {
                        showPreferencesSheet = true
                    } label: {
                        HStack {
                            Text("Edit Preferences")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)

                    preferenceValueRow(title: "Gender", value: appState.preferredGender)
                    preferenceValueRow(title: "Age Range", value: "\(appState.preferredAgeMin)-\(appState.preferredAgeMax)")
                    preferenceValueRow(title: "Friend-of-Friend Referral", value: "\(appState.groups.count) ranked groups")
                    preferenceValueRow(title: "Matching Policy", value: appState.fofMatchPolicy.label)
                    preferenceValueRow(title: "FoF Contacts Enabled", value: "\(appState.fofSourceCount) contacts")
                }

            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showProfileSheet) {
                ProfileView(
                    age: $appState.age,
                    gender: $appState.gender
                )
            }
            .sheet(isPresented: $showPreferencesSheet) {
                PreferencesView(
                    preferredGender: $appState.preferredGender,
                    preferredAgeMin: $appState.preferredAgeMin,
                    preferredAgeMax: $appState.preferredAgeMax,
                    fofMatchPolicy: $appState.fofMatchPolicy,
                    groups: $appState.groups
                )
            }
        }
    }

    private func preferenceValueRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

}

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var age: Int
    @Binding var gender: String

    private let genderOptions = ["Woman", "Man", "Non-binary", "Prefer not to say"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    Stepper(value: $age, in: 18...99) {
                        preferenceValueRow(title: "Age", value: "\(age)")
                    }

                    Picker("Gender", selection: $gender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func preferenceValueRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

struct PreferencesView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var preferredGender: String
    @Binding var preferredAgeMin: Int
    @Binding var preferredAgeMax: Int
    @Binding var fofMatchPolicy: FoFMatchPolicy
    @Binding var groups: [AppGroup]

    private let matchGenderOptions = ["Women", "Men", "No preference"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Friendship Preferences") {
                    Picker("Gender", selection: $preferredGender) {
                        ForEach(matchGenderOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Age Range")
                            Spacer()
                            Text("\(preferredAgeMin)-\(preferredAgeMax)")
                                .foregroundStyle(.secondary)
                        }

                        AgeRangeSlider(
                            minValue: $preferredAgeMin,
                            maxValue: $preferredAgeMax,
                            bounds: 18...99
                        )
                        .frame(height: 36)

                        HStack {
                            Text("18")
                            Spacer()
                            Text("99")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                Section("Friend-of-Friend Referral") {
                    Picker("Match Type", selection: $fofMatchPolicy) {
                        ForEach(FoFMatchPolicy.allCases, id: \.self) { policy in
                            Text(policy.label).tag(policy)
                        }
                    }

                    NavigationLink {
                        FoFReferralRankingView(groups: $groups)
                    } label: {
                        HStack {
                            Text("Stack Rank Referral Groups")
                            Spacer()
                            Text("\(groups.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Preferences")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FoFReferralRankingView: View {
    @Binding var groups: [AppGroup]

    var body: some View {
        List {
            Section {
                ForEach(groups) { group in
                    HStack(spacing: 12) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.secondary)
                        Text(group.name)
                    }
                }
                .onMove { fromOffsets, toOffset in
                    groups.move(fromOffsets: fromOffsets, toOffset: toOffset)
                }
            } footer: {
                Text("Higher-ranked groups are prioritized as Friend-of-Friend referral sources.")
            }
        }
        .navigationTitle("Referral Ranking")
    }
}
