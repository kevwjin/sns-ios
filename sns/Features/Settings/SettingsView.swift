import SwiftUI

private let matchGenderOptions = ["Women", "Men", "No preference"]

struct SettingsView: View {
    @Bindable var appState: AppState
    @State private var showProfileSheet = false
    @State private var showMatchCriteriaSheet = false

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

                Section("Match Criteria") {
                    Button {
                        showMatchCriteriaSheet = true
                    } label: {
                        HStack {
                            Text("Edit Match Criteria")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)

                    preferenceValueRow(title: "Match With", value: appState.preferredGender)
                    preferenceValueRow(title: "Age Range", value: "\(appState.preferredAgeMin)-\(appState.preferredAgeMax)")
                    preferenceValueRow(title: "Location", value: appState.matchingLocation)
                    preferenceValueRow(title: "Radius", value: "Within \(appState.matchingRadiusMiles) mi")
                    preferenceValueRow(title: "Match Policy", value: appState.matchPolicy.label)
                }

            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showProfileSheet) {
                NavigationStack {
                    ProfileView(
                        age: $appState.age,
                        gender: $appState.gender
                    )
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showProfileSheet = false
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showMatchCriteriaSheet) {
                NavigationStack {
                    PreferencesView(
                        preferredGender: $appState.preferredGender,
                        preferredAgeMin: $appState.preferredAgeMin,
                        preferredAgeMax: $appState.preferredAgeMax,
                        matchPolicy: $appState.matchPolicy
                    )
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showMatchCriteriaSheet = false
                            }
                        }
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

struct ProfileView: View {
    @Binding var age: Int
    @Binding var gender: String

    private let genderOptions = ["Woman", "Man", "Non-binary", "Prefer not to say"]

    var body: some View {
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

struct MatchWithView: View {
    @Binding var preferredGender: String

    var body: some View {
        Form {
            Section("Match With") {
                Picker("Match With", selection: $preferredGender) {
                    ForEach(matchGenderOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
            }
        }
        .navigationTitle("Match With")
    }
}

struct AgeRangePreferenceView: View {
    @Binding var preferredAgeMin: Int
    @Binding var preferredAgeMax: Int

    var body: some View {
        Form {
            Section("Age Range") {
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
                    .accessibilityIdentifier("Age Range Slider")

                    HStack {
                        Text("18")
                        Spacer()
                        Text("99")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Age Range")
    }
}

struct MatchPolicyView: View {
    @Binding var matchPolicy: MatchPolicy

    var body: some View {
        Form {
            Section("Match Policy") {
                Picker("Match Policy", selection: $matchPolicy) {
                    ForEach(MatchPolicy.allCases, id: \.self) { policy in
                        Text(policy.label).tag(policy)
                    }
                }
            }
        }
        .navigationTitle("Match Policy")
    }
}

struct PreferencesView: View {
    @Binding var preferredGender: String
    @Binding var preferredAgeMin: Int
    @Binding var preferredAgeMax: Int
    @Binding var matchPolicy: MatchPolicy

    var body: some View {
        Form {
            Section("Match Criteria") {
                Picker("Match With", selection: $preferredGender) {
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

            Section("Mutuals") {
                Picker("Match Policy", selection: $matchPolicy) {
                    ForEach(MatchPolicy.allCases, id: \.self) { policy in
                        Text(policy.label).tag(policy)
                    }
                }
            }
        }
        .navigationTitle("Match Criteria")
    }
}
