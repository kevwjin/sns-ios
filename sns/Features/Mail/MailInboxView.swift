import SwiftUI

struct MailInboxView: View {
    @State private var threads: [MailThread]

    init(threads: [MailThread]) {
        _threads = State(initialValue: threads)
    }

    var body: some View {
        List {
            ForEach($threads) { $thread in
                NavigationLink {
                    MailThreadView(thread: $thread)
                } label: {
                    MailThreadRow(thread: thread)
                }
                .accessibilityIdentifier("Mail Thread \(thread.subject)")
            }
        }
        .listStyle(.plain)
        .navigationTitle("Inbox")
    }
}

private struct MailThreadRow: View {
    let thread: MailThread

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(thread.isUnread ? Color.accentColor : Color.clear)
                .frame(width: 8, height: 8)
                .padding(.top, 7)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(thread.correspondentName)
                        .font(.subheadline.weight(thread.isUnread ? .semibold : .regular))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(thread.timestamp)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(thread.subject)
                    .font(.subheadline.weight(thread.isUnread ? .semibold : .regular))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(thread.preview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        MailInboxView(threads: MockData.mailThreads)
    }
}
