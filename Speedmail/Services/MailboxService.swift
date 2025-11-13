import Foundation

protocol MailboxServiceProtocol {
    func fetchMessages(for account: Account) async throws -> [MailMessage]
    func send(draft: DraftMessage, from account: Account) async throws -> MailMessage
    func update(message: MailMessage, for account: Account) async throws -> MailMessage
    func delete(message: MailMessage, for account: Account) async throws
    func simulateIncomingMessage(for account: Account) async throws
}

actor MockMailboxService: MailboxServiceProtocol {
    private var storage: [UUID: [MailMessage]] = [:]
    private let generator = MailTemplateGenerator()

    func fetchMessages(for account: Account) async throws -> [MailMessage] {
        if storage[account.id] == nil {
            storage[account.id] = MailMessage.samples(for: account)
        }
        return storage[account.id]?.sorted { $0.receivedAt > $1.receivedAt } ?? []
    }

    func send(draft: DraftMessage, from account: Account) async throws -> MailMessage {
        var body = draft.body
        if body.isEmpty {
            body = "(Mesaj içeriği boş)"
        }

        let toParticipants = draft.to
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { MailParticipant(name: $0.components(separatedBy: "@").first ?? $0, email: $0) }

        let outgoing = MailMessage(
            subject: draft.subject.isEmpty ? "(Başlıksız)" : draft.subject,
            preview: String(body.prefix(120)),
            body: body,
            sender: MailParticipant(name: account.displayName, email: account.emailAddress),
            recipients: toParticipants,
            category: .inbox,
            receivedAt: Date(),
            isRead: true,
            isFlagged: false
        )

        var messages = storage[account.id] ?? []
        messages.insert(outgoing, at: 0)
        storage[account.id] = messages
        return outgoing
    }

    func update(message: MailMessage, for account: Account) async throws -> MailMessage {
        var messages = storage[account.id] ?? []
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index] = message
            storage[account.id] = messages
            return message
        }

        messages.insert(message, at: 0)
        storage[account.id] = messages
        return message
    }

    func delete(message: MailMessage, for account: Account) async throws {
        guard var messages = storage[account.id] else { return }
        messages.removeAll { $0.id == message.id }
        storage[account.id] = messages
    }

    func simulateIncomingMessage(for account: Account) async throws {
        var messages = storage[account.id] ?? []
        let incoming = generator.makeRandomMessage(for: account)
        messages.insert(incoming, at: 0)
        storage[account.id] = messages
    }
}

private struct MailTemplateGenerator: Sendable {
    private let subjects = [
        "Sürüm 3.1 için test listesi",
        "Bugünkü görüşme notları",
        "Taslak sözleşme üzerine",
        "Yeni müşteri akışı",
        "Takvim güncellemesi"
    ]

    private let previews = [
        "Toplantıda bahsettiğimiz maddeleri toparladım.",
        "Dosyadaki iki senaryo için de geri bildirim bıraktım.",
        "Kısa vadede uygulayabileceğimiz öneriler buldum.",
        "Önümüzdeki sprint için iş listesi hazır.",
        "Yeni takvim davetini gönderdim, teyit edersen sevinirim."
    ]

    private let senders = [
        MailParticipant(name: "Mina Arslan", email: "mina@productlab.io"),
        MailParticipant(name: "Ali Vural", email: "ali@studiofolk.co"),
        MailParticipant(name: "İpek Tan", email: "ipek@motionhaus.app"),
        MailParticipant(name: "CodeLab", email: "team@codelab.dev"),
        MailParticipant(name: "Notion", email: "team@notion.so")
    ]

    func makeRandomMessage(for account: Account) -> MailMessage {
        let subject = subjects.randomElement() ?? "Yeni mesaj"
        let preview = previews.randomElement() ?? ""
        let sender = senders.randomElement() ?? MailParticipant(name: "Speedmail", email: "hello@speedmail.app")
        let body = "Merhaba \(account.displayName),\n\n" + preview + "\n\nGörüşmek üzere!"

        return MailMessage(
            subject: subject,
            preview: preview,
            body: body,
            sender: sender,
            recipients: [MailParticipant(name: account.displayName, email: account.emailAddress)],
            category: .inbox,
            receivedAt: Date(),
            isRead: false,
            isFlagged: Bool.random()
        )
    }
}
