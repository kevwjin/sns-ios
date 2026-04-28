import SwiftUI

struct MatchMessagesView: View {
    let matchName: String

    @State private var draftMessage = ""
    @State private var messages: [MatchMessage] = MockData.initialMatchMessages

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isFromUser {
                                Spacer(minLength: 40)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(message.text)
                                    .font(.subheadline)
                                    .foregroundStyle(message.isFromUser ? .white : .primary)
                                Text(message.timestamp)
                                    .font(.caption2)
                                    .foregroundStyle(message.isFromUser ? .white.opacity(0.85) : .secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        message.isFromUser
                                        ? AnyShapeStyle(Color.accentColor)
                                        : AnyShapeStyle(.ultraThinMaterial)
                                    )
                            )

                            if !message.isFromUser {
                                Spacer(minLength: 40)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.white)

            HStack(spacing: 8) {
                TextField("Message \(matchName)", text: $draftMessage)
                    .textFieldStyle(.roundedBorder)

                Button("Send") {
                    sendMessage()
                }
                .disabled(draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color.white)
        }
        .background(Color.white)
        .navigationTitle(matchName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendMessage() {
        let trimmed = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(MatchMessage(isFromUser: true, text: trimmed, timestamp: "Now"))
        draftMessage = ""
    }
}
