import Foundation

struct Account: Identifiable, Hashable, Sendable {
    enum AccentColorToken: String, CaseIterable, Identifiable, Sendable {
        case ocean
        case coral
        case lime
        case violet
        case graphite
        case amber

        var id: String { rawValue }
    }

    let id: UUID
    var displayName: String
    var emailAddress: String
    var accentColor: AccentColorToken

    init(id: UUID = UUID(), displayName: String, emailAddress: String, accentColor: AccentColorToken) {
        self.id = id
        self.displayName = displayName
        self.emailAddress = emailAddress
        self.accentColor = accentColor
    }
}

struct MailParticipant: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var email: String

    init(id: UUID = UUID(), name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

struct MailAttachment: Identifiable, Hashable, Sendable {
    let id: UUID
    var fileName: String
    var fileSize: Int

    init(id: UUID = UUID(), fileName: String, fileSize: Int) {
        self.id = id
        self.fileName = fileName
        self.fileSize = fileSize
    }
}

enum MailboxCategory: String, CaseIterable, Identifiable, Sendable {
    case inbox
    case sent
    case spam
    case trash
    case drafts

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inbox: return "Gelen Kutusu"
        case .sent: return "Gönderilen"
        case .spam: return "Spam"
        case .trash: return "Silinen"
        case .drafts: return "Taslaklar"
        }
    }
    
    var gmailLabel: String {
        switch self {
        case .inbox: return "INBOX"
        case .sent: return "SENT"
        case .spam: return "SPAM"
        case .trash: return "TRASH"
        case .drafts: return "DRAFT"
        }
    }
    
    var systemImage: String {
        switch self {
        case .inbox: return "tray.fill"
        case .sent: return "paperplane.fill"
        case .spam: return "exclamationmark.octagon.fill"
        case .trash: return "trash.fill"
        case .drafts: return "doc.text.fill"
        }
    }
}

struct MailMessage: Identifiable, Hashable, Sendable {
    let id: UUID
    var gmailMessageId: String? // Gmail API message ID
    var subject: String
    var preview: String
    var body: String
    var sender: MailParticipant
    var recipients: [MailParticipant]
    var category: MailboxCategory
    var receivedAt: Date
    var isRead: Bool
    var isFlagged: Bool
    var attachments: [MailAttachment]

    init(
        id: UUID = UUID(),
        gmailMessageId: String? = nil,
        subject: String,
        preview: String,
        body: String,
        sender: MailParticipant,
        recipients: [MailParticipant],
        category: MailboxCategory,
        receivedAt: Date,
        isRead: Bool = false,
        isFlagged: Bool = false,
        attachments: [MailAttachment] = []
    ) {
        self.id = id
        self.gmailMessageId = gmailMessageId
        self.subject = subject
        self.preview = preview
        self.body = body
        self.sender = sender
        self.recipients = recipients
        self.category = category
        self.receivedAt = receivedAt
        self.isRead = isRead
        self.isFlagged = isFlagged
        self.attachments = attachments
    }
}

struct DraftMessage: Sendable {
    var to: String = ""
    var cc: String = ""
    var subject: String = ""
    var body: String = ""
}

extension MailMessage {
    static func samples(for account: Account) -> [MailMessage] {
        let now = Date()
        let teammates = [
            MailParticipant(name: "Selin Aksoy", email: "selin@swiftpost.co"),
            MailParticipant(name: "Kerem Şahin", email: "kerem@swiftpost.co"),
            MailParticipant(name: "Derya Korkmaz", email: "derya@swiftpost.co"),
            MailParticipant(name: "Studio Nova", email: "hello@studionova.io")
        ]

        let scheduler = Calendar.current

        let messages: [MailMessage] = [
            MailMessage(
                subject: "Yeni ürün lansmanı için son hazırlıklar",
                preview: "Sunum dosyalarını güncelledim, hızlıca bakabilirsen harika olur.",
                body: "Merhaba \(account.displayName),\n\nSunumun yeni sürümünü ekledim. Pazartesi toplantısı öncesi göz atmanı isterim.",
                sender: teammates[0],
                recipients: [MailParticipant(name: account.displayName, email: account.emailAddress)],
                category: .inbox,
                receivedAt: scheduler.date(byAdding: .minute, value: -10, to: now) ?? now,
                isRead: false,
                isFlagged: true,
                attachments: [MailAttachment(fileName: "Lansman-v7.key", fileSize: 6_144_000)]
            ),
            MailMessage(
                subject: "Speedmail beta erişimi",
                preview: "Geri bildirimlerinizi toplamak için mini bir form hazırladık.",
                body: "Herkese merhaba, beta erişimi açılıyor! Uygulama içi geri bildirim butonunu test etmeyi unutmayın.",
                sender: teammates[1],
                recipients: [MailParticipant(name: account.displayName, email: account.emailAddress)],
                category: .inbox,
                receivedAt: scheduler.date(byAdding: .hour, value: -2, to: now) ?? now,
                isRead: true,
                isFlagged: true
            ),
            MailMessage(
                subject: "WWDC notları",
                preview: "Vision Pro oturumundan birkaç önemli başlık çıkardım.",
                body: "SwiftData ve yeni observation API'si için küçük bir demo hazırladım.",
                sender: teammates[2],
                recipients: [MailParticipant(name: account.displayName, email: account.emailAddress)],
                category: .inbox,
                receivedAt: scheduler.date(byAdding: .day, value: -1, to: now) ?? now,
                isRead: true,
                isFlagged: false
            ),
            MailMessage(
                subject: "Dribbble vitrininde yer aldınız",
                preview: "Yeni konsept tasarımınız bugün editör seçimine girdi.",
                body: "Tebrikler! Portfolyo linkinizi güncellemenizi öneririz.",
                sender: teammates[3],
                recipients: [MailParticipant(name: account.displayName, email: account.emailAddress)],
                category: .inbox,
                receivedAt: scheduler.date(byAdding: .day, value: -4, to: now) ?? now,
                isRead: false,
                isFlagged: true
            )
        ]

        return messages.sorted { $0.receivedAt > $1.receivedAt }
    }
}
