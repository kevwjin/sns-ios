import SwiftUI

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
                ProfileView(
                    age: $appState.age,
                    gender: $appState.gender
                )
            }
            .sheet(isPresented: $showMatchCriteriaSheet) {
                PreferencesView(
                    preferredGender: $appState.preferredGender,
                    preferredAgeMin: $appState.preferredAgeMin,
                    preferredAgeMax: $appState.preferredAgeMax,
                    matchPolicy: $appState.matchPolicy
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
    @Binding var matchPolicy: MatchPolicy

    private let matchGenderOptions = ["Women", "Men", "No preference"]

    var body: some View {
        NavigationStack {
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
