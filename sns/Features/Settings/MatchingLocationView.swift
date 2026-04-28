import SwiftUI

struct MatchingLocationView: View {
    @Binding var location: String

    var body: some View {
        Form {
            Section {
                TextField("City, State", text: $location)
                    .textInputAutocapitalization(.words)
            } header: {
                Text("Matching Location")
            } footer: {
                Text("This mock location is only used to decide match eligibility.")
            }
        }
        .navigationTitle("Location")
    }
}
