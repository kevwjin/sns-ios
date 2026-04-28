import SwiftUI

struct LogbookView: View {
    let items: [ActivityItem]

    var body: some View {
        List(items) { item in
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: item.symbol)
                    .foregroundStyle(.secondary)
                    .frame(width: 22)

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                    Text(item.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(item.timestamp)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Logbook")
    }
}
