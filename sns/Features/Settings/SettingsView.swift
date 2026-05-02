import PhotosUI
import SwiftUI
import UIKit

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
            Section {
                NavigationLink(value: RootDestination.myCard) {
                    HStack(spacing: 14) {
                        MyCardAvatarView(contact: appState.myCard, size: 56)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(appState.myCard.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("My Card")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .accessibilityIdentifier("My Card Row")
            }

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
            }

            Section("Substance Use") {
                substanceUseRows(
                    destination: .profileField(.substanceUse),
                    selection: appState.substanceUse,
                    selectedValue: "Listed",
                    unselectedValue: "Not listed",
                    accessibilityPrefix: "Account"
                )
            }

            Section("Logbook") {
                NavigationLink(value: RootDestination.page(.logbook)) {
                    preferenceValueRow(title: "Logbook", value: "\(MockData.logbookItems.count) events", systemImage: "checklist")
                }
                .accessibilityIdentifier("Logbook Row")
            }
        }
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

    private func substanceUseRows(
        destination: RootDestination,
        selection: Set<SubstanceUseCategory>,
        selectedValue: String,
        unselectedValue: String,
        accessibilityPrefix: String
    ) -> some View {
        ForEach(Array(SubstanceUseCategory.allCases), id: \.self) { substance in
            NavigationLink(value: destination) {
                preferenceValueRow(
                    title: substance.label,
                    value: selection.contains(substance) ? selectedValue : unselectedValue,
                    systemImage: substance.systemImage
                )
            }
            .accessibilityIdentifier("\(accessibilityPrefix) \(substance.label) Substance Use Row")
        }
    }
}

struct MyCardDetailView: View {
    @Binding var contact: AppContact
    @State private var isEditing = false
    @State private var isPhotoPickerPresented = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    MyCardAvatarView(contact: contact, size: 96)
                        .accessibilityIdentifier("My Card Avatar")

                    if isEditing && !isPhotoPickerDisabled {
                        Button {
                            isPhotoPickerPresented = true
                        } label: {
                            Label("Choose Photo", systemImage: "photo")
                        }
                        .accessibilityIdentifier("Choose My Card Photo")

                        if contact.photoData != nil {
                            Button("Remove Photo", role: .destructive) {
                                contact.photoData = nil
                                selectedPhotoItem = nil
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            if isEditing {
                Section("Name") {
                    TextField("First Name", text: $contact.firstName)
                        .textContentType(.givenName)
                        .accessibilityIdentifier("My Card First Name Field")
                    TextField("Last Name", text: $contact.lastName)
                        .textContentType(.familyName)
                        .accessibilityIdentifier("My Card Last Name Field")
                }

                Section("Preferred Contact") {
                    Picker("Method", selection: $contact.preferredContactMethod) {
                        ForEach(PreferredContactMethod.allCases) { method in
                            Text(method.label).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField(preferredContactPlaceholder, text: preferredContactBinding)
                        .keyboardType(preferredContactKeyboardType)
                        .textInputAutocapitalization(preferredContactAutocapitalization)
                        .autocorrectionDisabled(preferredContactAutocorrectionDisabled)
                        .accessibilityIdentifier("My Card Preferred Contact Field")
                }
            } else {
                Section("Name") {
                    detailRow(title: "First Name", value: contact.firstName)
                    detailRow(title: "Last Name", value: contact.lastName)
                }

                Section("Preferred Contact") {
                    detailRow(title: "Method", value: contact.preferredContactMethod.label)
                    detailRow(title: contact.preferredContactMethod.label, value: contact.preferredContactSummary)
                }
            }
        }
        .navigationTitle("My Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                await loadPhoto(from: newItem)
            }
        }
        .modifier(MyCardPhotoPickerModifier(
            isDisabled: isPhotoPickerDisabled,
            isPresented: $isPhotoPickerPresented,
            selection: $selectedPhotoItem
        ))
    }

    private var preferredContactPlaceholder: String {
        switch contact.preferredContactMethod {
        case .email:
            "Email"
        case .phone:
            "Phone"
        case .sns:
            "SNS handle"
        case .other:
            "Contact details"
        }
    }

    private var preferredContactKeyboardType: UIKeyboardType {
        switch contact.preferredContactMethod {
        case .email:
            .emailAddress
        case .phone:
            .phonePad
        case .sns, .other:
            .default
        }
    }

    private var preferredContactAutocapitalization: TextInputAutocapitalization {
        switch contact.preferredContactMethod {
        case .email, .sns:
            .never
        case .phone, .other:
            .sentences
        }
    }

    private var preferredContactAutocorrectionDisabled: Bool {
        switch contact.preferredContactMethod {
        case .email, .phone, .sns:
            true
        case .other:
            false
        }
    }

    private var preferredContactBinding: Binding<String> {
        Binding(
            get: {
                contact.preferredContactValue
            },
            set: { newValue in
                switch contact.preferredContactMethod {
                case .email:
                    contact.email = newValue
                case .phone:
                    contact.phone = newValue
                case .sns, .other:
                    contact.preferredContactDetail = newValue
                }
            }
        )
    }

    private var isPhotoPickerDisabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-snsUITestDisablePhotoPicker")
    }

    @ViewBuilder
    private func detailRow(title: String, value: String) -> some View {
        if !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            HStack {
                Text(title)
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        await MainActor.run {
            contact.photoData = data
        }
    }
}

private struct MyCardPhotoPickerModifier: ViewModifier {
    let isDisabled: Bool
    @Binding var isPresented: Bool
    @Binding var selection: PhotosPickerItem?

    func body(content: Content) -> some View {
        if isDisabled {
            content
        } else {
            content.photosPicker(isPresented: $isPresented, selection: $selection, matching: .images)
        }
    }
}

struct MyCardAvatarView: View {
    let contact: AppContact
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.16))

            if let photoData = contact.photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Text(contact.initials)
                    .font(.system(size: size * 0.38, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.accentColor)
                    .accessibilityIdentifier("My Card Initials Avatar")
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("My Card photo")
    }
}

extension SubstanceUseCategory {
    var systemImage: String {
        switch self {
        case .vaping: "wind"
        case .smoking: "flame"
        case .marijuana: "leaf"
        case .drinking: "wineglass"
        case .other: "ellipsis.circle"
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
                Stepper(value: $age, in: AgeDisplay.bounds) {
                    valueRow(title: "Age", value: AgeDisplay.label(for: age))
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
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Text(AgeDisplay.label(for: age))
                        .font(.title2.weight(.semibold))

                    SingleValueSlider(
                        value: $age,
                        bounds: AgeDisplay.bounds,
                        accessibilityLabel: "Age Slider"
                    )
                    .frame(height: 36)
                    .accessibilityIdentifier("Age Slider")

                    HStack {
                        Text("\(AgeDisplay.bounds.lowerBound)")
                        Spacer()
                        Text("\(AgeDisplay.bounds.upperBound)+")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
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
                    Text(AgeDisplay.rangeLabel(min: preferredAgeMin, max: preferredAgeMax))
                        .font(.title2.weight(.semibold))

                    AgeRangeSlider(
                        minValue: $preferredAgeMin,
                        maxValue: $preferredAgeMax,
                        bounds: AgeDisplay.bounds
                    )
                    .frame(height: 36)
                    .accessibilityIdentifier("Age Range Slider")

                    HStack {
                        Text("\(AgeDisplay.bounds.lowerBound)")
                        Spacer()
                        Text("\(AgeDisplay.bounds.upperBound)+")
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
