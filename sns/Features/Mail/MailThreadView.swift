import SwiftUI

struct MailThreadView: View {
    @Binding var thread: MailThread
    @State private var draftReply = ""

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(thread.subject)
                            .font(.title3.weight(.semibold))

                        Text(thread.correspondentName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    ForEach(thread.messages) { message in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(message.senderName)
                                    .font(.subheadline.weight(.semibold))

                                Spacer()

                                Text(message.timestamp)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Text(message.body)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .listStyle(.insetGrouped)

            Divider()

            HStack(spacing: 8) {
                TextField("Reply", text: $draftReply, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)

                Button("Send") {
                    sendReply()
                }
                .disabled(draftReply.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("Mail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            thread.isUnread = false
        }
    }

    private func sendReply() {
        let trimmed = draftReply.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        thread.messages.append(
            MailMessage(
                senderName: "Me",
                body: trimmed,
                timestamp: "Now",
                isFromUser: true
            )
        )
        thread.preview = trimmed
        thread.timestamp = "Now"
        thread.isUnread = false
        draftReply = ""
    }
}
