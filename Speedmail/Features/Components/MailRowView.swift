import SwiftUI

struct MailRowView: View {
    var message: MailMessage

    private static let formatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Okunmamış mail işareti (daha belirgin)
            if !message.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(message.sender.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(Self.formatter.localizedString(for: message.receivedAt, relativeTo: Date()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(message.subject)
                    .font(.callout.weight(message.isRead ? .regular : .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(message.preview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if !message.attachments.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "paperclip")
                            .font(.caption)
                        Text("\(message.attachments.count) ek")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }

            if message.isFlagged {
                Image(systemName: "flag.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 8)
    }
}
