import SwiftUI

struct MatchingRadiusView: View {
    @Binding var radiusMiles: Int
    @Binding var extendRadiusIfNeeded: Bool

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Within \(radiusMiles) mi")
                        .font(.title2.weight(.semibold))

                    SingleValueSlider(
                        value: $radiusMiles,
                        bounds: 1...50,
                        accessibilityLabel: "Radius Slider"
                    )
                        .frame(height: 36)
                        .accessibilityIdentifier("Radius Slider")

                    HStack {
                        Text("1 mi")
                        Spacer()
                        Text("50 mi")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            } footer: {
                Text(extendRadiusIfNeeded ? "If there are no matches within this radius, people outside it can be considered." : "People outside this radius are not eligible for matching.")
            }

            Section {
                Toggle("Extend if needed", isOn: $extendRadiusIfNeeded)
            }
        }
        .navigationTitle("Radius")
    }
}
