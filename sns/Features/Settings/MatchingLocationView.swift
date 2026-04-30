import SwiftUI

struct MatchingLocationView: View {
    @Binding var location: String
    @State private var query = ""

    private var suggestions: [LocationSuggestion] {
        MockData.locationSuggestions(matching: query)
    }

    private var isSearching: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Current")
                    Spacer()
                    Text(location)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifier("Current Matching Location")
                }
            } header: {
                Text("Matching Location")
            }

            Section {
                TextField("Address, neighborhood, or zip", text: $query)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("Location Search Field")
            } header: {
                Text("Search")
            } footer: {
                if !isSearching {
                    Text("Choose a suggestion to update your matching location.")
                }
            }

            if isSearching {
                Section {
                    if suggestions.isEmpty {
                        Text("No locations found")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(suggestions) { suggestion in
                            Button {
                                location = suggestion.displayName
                                query = ""
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "location.magnifyingglass")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(suggestion.title)
                                            .foregroundStyle(.primary)
                                        if !suggestion.subtitle.isEmpty {
                                            Text(suggestion.subtitle)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("Location Suggestion \(suggestion.displayName)")
                        }
                    }
                } header: {
                    Text("Suggestions")
                }
            }
        }
        .navigationTitle("Location")
    }
}
