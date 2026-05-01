import SwiftUI

struct SettingsView: View {
    @Bindable var appState: AppState

    var body: some View {
        NavigationStack {
            ProfileTabView(appState: appState)
        }
    }
}

struct ProfileTabView: View {
    @Bindable var appState: AppState

    var body: some View {
        List {
            Section("Account") {
                NavigationLink(value: RootDestination.profileField(.age)) {
                    preferenceValueRow(title: "Age", value: "\(appState.age)", systemImage: "number")
                }
                .accessibilityIdentifier("Account Age Row")

                NavigationLink(value: RootDestination.profileField(.gender)) {
                    preferenceValueRow(title: "Gender", value: appState.gender.label, systemImage: "person.fill")
                }
                .accessibilityIdentifier("Account Gender Row")

                NavigationLink(value: RootDestination.profileField(.pronouns)) {
                    preferenceValueRow(title: "Pronouns", value: appState.pronouns.label, systemImage: "text.bubble")
                }
                .accessibilityIdentifier("Account Pronouns Row")

                NavigationLink(value: RootDestination.profileField(.sexuality)) {
                    preferenceValueRow(title: "Sexuality", value: appState.sexuality.label, systemImage: "heart.circle")
                }
                .accessibilityIdentifier("Account Sexuality Row")

                NavigationLink(value: RootDestination.profileField(.substanceUse)) {
                    preferenceValueRow(title: "Substance Use", value: appState.substanceUseSummary, systemImage: "checklist")
                }
                .accessibilityIdentifier("Account Substance Use Row")
            }

            Section("Match Criteria") {
                NavigationLink(value: RootDestination.page(.location)) {
                    preferenceValueRow(title: "Location", value: appState.matchingLocation, systemImage: "location.fill")
                }
                .accessibilityIdentifier("Location Row")

                NavigationLink(value: RootDestination.page(.radius)) {
                    preferenceValueRow(title: "Radius", value: "Within \(appState.matchingRadiusMiles) mi", systemImage: "scope")
                }
                .accessibilityIdentifier("Radius Row")

                NavigationLink(value: RootDestination.page(.ageRange)) {
                    preferenceValueRow(title: "Age Range", value: "\(appState.preferredAgeMin)-\(appState.preferredAgeMax)", systemImage: "slider.horizontal.3")
                }
                .accessibilityIdentifier("Age Range Row")

                NavigationLink(value: RootDestination.page(.matchWith)) {
                    preferenceValueRow(title: "Gender", value: appState.preferredGendersSummary, systemImage: "person.2.circle")
                }
                .accessibilityIdentifier("Criteria Gender Row")

                NavigationLink(value: RootDestination.page(.sexuality)) {
                    preferenceValueRow(title: "Sexuality", value: appState.preferredSexualitiesSummary, systemImage: "heart.circle")
                }
                .accessibilityIdentifier("Criteria Sexuality Row")

                NavigationLink(value: RootDestination.page(.substanceUse)) {
                    preferenceValueRow(title: "Substance Use", value: appState.acceptedSubstanceUseSummary, systemImage: "checklist")
                }
                .accessibilityIdentifier("Criteria Substance Use Row")

                NavigationLink(value: RootDestination.page(.matchPolicy)) {
                    preferenceValueRow(title: "Match Policy", value: appState.matchPolicy.label, systemImage: "person.2.wave.2.fill")
                }
                .accessibilityIdentifier("Match Policy Row")
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
    }

    private func preferenceValueRow(title: String, value: String, systemImage: String) -> some View {
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
}

struct AccountProfileView: View {
    @Binding var age: Int
    @Binding var gender: GenderIdentity
    @Binding var pronouns: PronounOption
    @Binding var sexuality: SexualityOption
    @Binding var substanceUse: Set<SubstanceUseCategory>

    var body: some View {
        Form {
            Section("Account") {
                Stepper(value: $age, in: 18...99) {
                    valueRow(title: "Age", value: "\(age)")
                }

                Picker("Gender", selection: $gender) {
                    ForEach(GenderIdentity.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }

                Picker("Pronouns", selection: $pronouns) {
                    ForEach(PronounOption.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }

                Picker("Sexuality", selection: $sexuality) {
                    ForEach(SexualityOption.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
            }

            Section("Substance Use") {
                MultiSelectOptionsView(selection: $substanceUse)
            }
        }
        .navigationTitle("Account")
    }

    private func valueRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

struct AccountAgeView: View {
    @Binding var age: Int

    var body: some View {
        Form {
            Section("Age") {
                Stepper(value: $age, in: 18...99) {
                    HStack {
                        Text("Age")
                        Spacer()
                        Text("\(age)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Age")
    }
}

struct AccountSingleSelectView<Option: ProfileCriteriaOption>: View {
    let title: String
    @Binding var selection: Option

    var body: some View {
        Form {
            Section {
                ForEach(Array(Option.allCases), id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        HStack {
                            Text(option.label)
                                .foregroundStyle(.primary)
                            Spacer()
                            if selection == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text(title)
            }
        }
        .navigationTitle(title)
    }
}

struct AccountSubstanceUseView: View {
    @Binding var substanceUse: Set<SubstanceUseCategory>

    var body: some View {
        Form {
            Section {
                MultiSelectOptionsView(selection: $substanceUse)
            } header: {
                Text("Substance Use")
            } footer: {
                Text("Select any that apply to your own profile.")
            }
        }
        .navigationTitle("Substance Use")
    }
}

struct MatchGenderPreferenceView: View {
    @Binding var preferredGenders: Set<GenderIdentity>

    var body: some View {
        MatchCriteriaMultiSelectView(
            title: "Gender",
            footer: "Select the genders you are open to matching with.",
            selection: $preferredGenders
        )
    }
}

struct MatchSexualityPreferenceView: View {
    @Binding var preferredSexualities: Set<SexualityOption>

    var body: some View {
        MatchCriteriaMultiSelectView(
            title: "Sexuality",
            footer: "Select the sexualities you are open to matching with.",
            selection: $preferredSexualities
        )
    }
}

struct MatchSubstanceUsePreferenceView: View {
    @Binding var acceptedSubstanceUse: Set<SubstanceUseCategory>

    var body: some View {
        MatchCriteriaMultiSelectView(
            title: "Substance Use",
            footer: "Select the substance-use categories you are open to in a match.",
            selection: $acceptedSubstanceUse
        )
    }
}

struct AgeRangePreferenceView: View {
    @Binding var preferredAgeMin: Int
    @Binding var preferredAgeMax: Int

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Text("\(preferredAgeMin)-\(preferredAgeMax)")
                        .font(.title2.weight(.semibold))

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
                .padding(.vertical, 6)
            } footer: {
                Text("Only people in this age range are eligible for matching.")
            }
        }
        .navigationTitle("Age Range")
    }
}

struct MatchPolicyView: View {
    @Binding var matchPolicy: MatchPolicy

    var body: some View {
        Form {
            Section {
                ForEach(MatchPolicy.allCases, id: \.self) { policy in
                    Button {
                        matchPolicy = policy
                    } label: {
                        HStack {
                            Text(policy.label)
                                .foregroundStyle(.primary)
                            Spacer()
                            if matchPolicy == policy {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } footer: {
                Text("Choose how broadly this week's match can be selected.")
            }
        }
        .navigationTitle("Match Policy")
    }
}

struct MatchCriteriaMultiSelectView<Option: ProfileCriteriaOption>: View {
    let title: String
    let footer: String
    @Binding var selection: Set<Option>

    var body: some View {
        Form {
            Section {
                MultiSelectOptionsView(selection: $selection)
            } header: {
                Text(title)
            } footer: {
                Text(footer)
            }
        }
        .navigationTitle(title)
    }
}

struct MultiSelectOptionsView<Option: ProfileCriteriaOption>: View {
    @Binding var selection: Set<Option>

    var body: some View {
        ForEach(Array(Option.allCases), id: \.self) { option in
            Button {
                toggle(option)
            } label: {
                HStack {
                    Text(option.label)
                        .foregroundStyle(.primary)
                    Spacer()
                    if selection.contains(option) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func toggle(_ option: Option) {
        var updatedSelection = selection
        if updatedSelection.contains(option) {
            updatedSelection.remove(option)
        } else {
            updatedSelection.insert(option)
        }
        selection = updatedSelection
    }
}
