import Foundation
import CryptoKit

actor GmailMailboxService: MailboxServiceProtocol {
    private var credentials: GoogleCredentials
    init(credentials: GoogleCredentials) {
        self.credentials = credentials
    }
    
    // Güncel credentials'ı al (token yenilenmiş olabilir)
    func getCurrentCredentials() -> GoogleCredentials {
        return credentials
    }
    
    // Token güncelleme fonksiyonu (IMAP'ten gelen yeni token için)
    func updateCredentials(_ newCredentials: GoogleCredentials) {
        self.credentials = newCredentials
    }

    // Protocol requirement
    func fetchMessages(for account: Account) async throws -> [MailMessage] {
        let result = try await fetchMessages(for: account, category: .inbox)
        return result.messages
    }
    
    // Gmail-specific method with category
    func fetchMessages(for account: Account, category: MailboxCategory, maxResults: Int = 100, pageToken: String? = nil) async throws -> (messages: [MailMessage], nextPageToken: String?) {
        try await ensureToken()
        let (messageIds, nextToken) = try await fetchMessageIDs(category: category, maxResults: maxResults, pageToken: pageToken)
        
        // Rate limit'i aşmamak için paralel istekleri azalt ve batch'lere böl
        let batchSize = 10 // Aynı anda max 10 istek
        var results: [MailMessage] = []
        
        for batchStart in stride(from: 0, to: messageIds.count, by: batchSize) {
            let batchEnd = min(batchStart + batchSize, messageIds.count)
            let batch = Array(messageIds[batchStart..<batchEnd])
            
            let batchMessages = try await withThrowingTaskGroup(of: MailMessage?.self) { group -> [MailMessage] in
                for id in batch {
                    group.addTask {
                        return try await self.fetchMessageDetail(id: id, account: account)
                    }
                }
                
                var msgs: [MailMessage] = []
                for try await message in group {
                    if let message { msgs.append(message) }
                }
                return msgs
            }
            
            results.append(contentsOf: batchMessages)
            
            // Batch'ler arası kısa bekleme (rate limit için)
            if batchEnd < messageIds.count {
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 saniye
            }
        }
        
        // Gmail API'den sıralı geliyor ama yine de garantiye alalım
        return (messages: results.sorted { $0.receivedAt > $1.receivedAt }, nextPageToken: nextToken)
    }

    func send(draft: DraftMessage, from account: Account) async throws -> MailMessage {
        print("📤 Gmail'den mail gönderiliyor...")
        
        // RFC 2822 formatında MIME mesajı oluştur
        let rawMessage = createRFC2822Message(draft: draft, from: account)
        let base64EncodedMessage = rawMessage.data(using: .utf8)!
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        // Gmail API'ye gönder
        guard let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/send") else {
            throw GmailServiceError.apiFailure
        }
        
        try await ensureToken()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["raw": base64EncodedMessage]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw GmailServiceError.apiFailure
        }
        
        if (200..<300).contains(http.statusCode) {
            print("✅ Gmail mesajı gönderildi!")
            
            // Gönderilen mesajı döndür
            return MailMessage(
                id: UUID(),
                gmailMessageId: nil,
                subject: draft.subject,
                preview: String(draft.body.prefix(100)),
                body: draft.body,
                sender: MailParticipant(name: account.displayName, email: account.emailAddress),
                recipients: [MailParticipant(name: "", email: draft.to)],
                category: .sent,
                receivedAt: Date(),
                isRead: true,
                isFlagged: false
            )
        } else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Bilinmeyen hata"
            print("❌ Gmail gönderme hatası (HTTP \(http.statusCode)): \(errorMsg)")
            throw GmailServiceError.apiFailure
        }
    }
    
    private func createRFC2822Message(draft: DraftMessage, from account: Account) -> String {
        var message = ""
        message += "From: \(account.emailAddress)\r\n"
        message += "To: \(draft.to)\r\n"
        
        if !draft.cc.isEmpty {
            message += "Cc: \(draft.cc)\r\n"
        }
        
        message += "Subject: \(draft.subject)\r\n"
        message += "Content-Type: text/plain; charset=\"UTF-8\"\r\n"
        message += "MIME-Version: 1.0\r\n"
        message += "\r\n"
        message += draft.body
        
        return message
    }

    func update(message: MailMessage, for account: Account) async throws -> MailMessage {
        // Gmail message ID'si yoksa güncelleme yapılamaz
        guard let gmailMsgId = message.gmailMessageId else {
            print("⚠️ Gmail message ID bulunamadı, güncelleme atlanıyor")
            return message
        }
        
        // Eğer mesaj okundu olarak işaretleniyorsa, UNREAD label'ini kaldır
        if message.isRead {
            print("📖 Gmail mesajı okundu olarak işaretleniyor: \(gmailMsgId) | Konu: \(message.subject.prefix(30))")
            try await removeLabel(messageId: gmailMsgId, labelId: "UNREAD")
            print("✅ Gmail mesajı başarıyla okundu olarak işaretlendi")
        } else {
            print("ℹ️ Mesaj zaten okunmuş veya okunmamış olarak işaretlenmemiş")
        }
        
        return message
    }
    
    // Gmail API: Mesajdan label kaldır
    private func removeLabel(messageId: String, labelId: String) async throws {
        guard let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(messageId)/modify") else {
            throw GmailServiceError.apiFailure
        }
        
        try await ensureToken()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // UNREAD label'ini kaldır
        let body = ["removeLabelIds": [labelId]]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw GmailServiceError.apiFailure
        }
        
        if (200..<300).contains(http.statusCode) {
            print("✅ Gmail label kaldırıldı: \(labelId) (Message ID: \(messageId))")
        } else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Bilinmeyen hata"
            print("❌ Gmail label kaldırma hatası (HTTP \(http.statusCode)): \(errorMsg)")
            throw GmailServiceError.apiFailure
        }
    }

    func delete(message: MailMessage, for account: Account) async throws {
        // Gmail message ID'si yoksa sil
        guard let gmailMsgId = message.gmailMessageId else {
            print("⚠️ Gmail message ID bulunamadı, silme atlanıyor")
            return
        }
        
        print("🗑️ Gmail'den siliniyor: \(gmailMsgId)")
        
        // Gmail API: Mesajı çöp kutusuna taşı (trash)
        guard let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(gmailMsgId)/trash") else {
            throw GmailServiceError.apiFailure
        }
        
        try await ensureToken()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw GmailServiceError.apiFailure
        }
        
        if (200..<300).contains(http.statusCode) {
            print("✅ Gmail mesajı silindi: \(gmailMsgId)")
        } else {
            print("❌ Gmail silme hatası (HTTP \(http.statusCode))")
            throw GmailServiceError.apiFailure
        }
    }

    func simulateIncomingMessage(for account: Account) async throws {
        // Gmail gerçek veriden beslendiği için simülasyona gerek yok
    }

    // MARK: - Helpers

    private func fetchMessageIDs(category: MailboxCategory, maxResults: Int = 100, pageToken: String? = nil) async throws -> (messageIds: [String], nextPageToken: String?) {
        // Gmail labelIds kullanarak kategoriye göre mailleri çek
        // Gmail API otomatik olarak en yeniden eskiye sıralı döndürür
        var urlComponents = URLComponents(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "labelIds", value: category.gmailLabel)
        ]
        
        if let pageToken = pageToken {
            queryItems.append(URLQueryItem(name: "pageToken", value: pageToken))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            print("❌ URL oluşturulamadı: \(category.gmailLabel)")
            return ([], nil)
        }
        
        print("📧 Gmail API'den mesajlar çekiliyor: \(category.title) (\(category.gmailLabel)) - maxResults: \(maxResults)")
        let data = try await authorizedData(from: url)
        struct Response: Decodable {
            let messages: [Reference]?
            let nextPageToken: String?
            
            struct Reference: Decodable { let id: String }
        }
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        let messageIds = decoded.messages?.map(\.id) ?? []
        print("✅ \(messageIds.count) mesaj bulundu: \(category.title)\(decoded.nextPageToken != nil ? " (daha fazla var)" : "")")
        return (messageIds, decoded.nextPageToken)
    }

    private func fetchMessageDetail(id: String, account: Account) async throws -> MailMessage? {
        // format=full ile tam mesaj içeriğini al (body dahil)
        guard let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(id)?format=full") else {
            return nil
        }
        let data = try await authorizedData(from: url)
        let message = try JSONDecoder().decode(GmailMessage.self, from: data)
        return message.asMailMessage(for: account)
    }

    private func authorizedData(from url: URL) async throws -> Data {
        try await ensureToken()
        var request = URLRequest(url: url)
        request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse {
            if (200..<300).contains(http.statusCode) {
                return data
            } else {
                // Detaylı hata logu
                let errorMsg = String(data: data, encoding: .utf8) ?? "Bilinmeyen hata"
                print("❌ Gmail API Hatası (HTTP \(http.statusCode)): \(errorMsg)")
                
                // 401 = Token expired, tekrar dene
                if http.statusCode == 401 {
                    print("🔄 Token expired, yenileniyor...")
                    credentials = try await GoogleOAuthManager.shared.refresh(using: credentials.refreshToken)
                    // Tekrar dene
                    var retryRequest = URLRequest(url: url)
                    retryRequest.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
                    let (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)
                    guard let retryHttp = retryResponse as? HTTPURLResponse, (200..<300).contains(retryHttp.statusCode) else {
                        throw GmailServiceError.apiFailure
                    }
                    return retryData
                }
                
                throw GmailServiceError.apiFailure
            }
        }
        
        throw GmailServiceError.apiFailure
    }

    private func ensureToken() async throws {
        guard credentials.isExpired else { return }
        print("🔄 Token süresi doldu, yenileniyor...")
        credentials = try await GoogleOAuthManager.shared.refresh(using: credentials.refreshToken)
        print("✅ Token yenilendi")
        
        // Yeni token'ı Keychain'e kaydet
        // Email'i credentials'tan alamıyoruz, bu yüzden tüm hesapları güncelle
        // NOT: Bu kısım AppViewModel'den çağrılmalı
    }
}

enum GmailServiceError: LocalizedError {
    case unsupportedAction
    case apiFailure

    var errorDescription: String? {
        switch self {
        case .unsupportedAction: return "Bu Gmail işlemi henüz desteklenmiyor"
        case .apiFailure: return "Gmail API isteği başarısız"
        }
    }
}

private struct GmailMessage: Decodable {
    let id: String
    let snippet: String
    let labelIds: [String]? // Gmail label'leri (UNREAD, STARRED, vb.)
    let payload: Payload

    struct Payload: Decodable {
        let headers: [Header]
        let body: MessageBody?
        let parts: [MessagePart]?
    }

    struct Header: Decodable {
        let name: String
        let value: String
    }
    
    struct MessageBody: Decodable {
        let data: String?
        let size: Int?
    }
    
    struct MessagePart: Decodable {
        let mimeType: String?
        let body: MessageBody?
        let parts: [MessagePart]?
    }

    func asMailMessage(for account: Account) -> MailMessage? {
        guard let subject = header(named: "Subject"),
              let fromHeader = header(named: "From"),
              let dateString = header(named: "Date")
        else { return nil }

        let sender = MailParticipant(name: GmailHeaderParser.name(from: fromHeader), email: GmailHeaderParser.email(from: fromHeader))
        let receivedAt = GmailHeaderParser.parseDate(from: dateString)
        let identifier = UUID.gmailIdentifier(from: id)
        
        // Body içeriğini çıkar (base64 decode)
        let bodyContent = extractBody()
        
        // Gmail label'lerinden okunma durumunu ve kategoriyi kontrol et
        let labels = labelIds ?? []
        let isRead = !labels.contains("UNREAD") // UNREAD label'i YOKSA okunmuş demektir
        let isFlagged = labels.contains("STARRED") // STARRED label'i varsa yıldızlı
        
        // Kategoriyi label'lere göre belirle
        let category: MailboxCategory
        if labels.contains("SENT") {
            category = .sent
        } else if labels.contains("SPAM") {
            category = .spam
        } else if labels.contains("TRASH") {
            category = .trash
        } else if labels.contains("DRAFT") {
            category = .drafts
        } else {
            category = .inbox
        }
        
        return MailMessage(
            id: identifier,
            gmailMessageId: id, // Gmail message ID'sini sakla
            subject: subject,
            preview: snippet,
            body: bodyContent.isEmpty ? snippet : bodyContent,
            sender: sender,
            recipients: [MailParticipant(name: account.displayName, email: account.emailAddress)],
            category: category,
            receivedAt: receivedAt,
            isRead: isRead,
            isFlagged: isFlagged
        )
    }

    private func header(named name: String) -> String? {
        payload.headers.first { $0.name == name }?.value
    }
    
    private func extractBody() -> String {
        // 1. Önce direkt body'ye bak
        if let bodyData = payload.body?.data, !bodyData.isEmpty {
            return decodeBase64Body(bodyData)
        }
        
        // 2. Parts içinde text/plain veya text/html ara
        if let parts = payload.parts {
            return extractBodyFromParts(parts)
        }
        
        return ""
    }
    
    private func extractBodyFromParts(_ parts: [MessagePart]) -> String {
        // ÖNCE text/html ara (daha zengin içerik)
        for part in parts {
            if part.mimeType == "text/html", let bodyData = part.body?.data, !bodyData.isEmpty {
                let htmlBody = decodeBase64Body(bodyData)
                // HTML'i olduğu gibi döndür (strip etme!)
                return htmlBody
            }
            
            // Alt parts varsa recursive ara
            if let subParts = part.parts {
                let result = extractBodyFromParts(subParts)
                if !result.isEmpty {
                    return result
                }
            }
        }
        
        // text/html yoksa text/plain kullan
        for part in parts {
            if part.mimeType == "text/plain", let bodyData = part.body?.data, !bodyData.isEmpty {
                return decodeBase64Body(bodyData)
            }
        }
        
        return ""
    }
    
    private func decodeBase64Body(_ base64String: String) -> String {
        // Gmail API base64url kullanır (- ve _ ile)
        let base64 = base64String
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Padding ekle
        let paddedBase64: String
        let remainder = base64.count % 4
        if remainder > 0 {
            paddedBase64 = base64 + String(repeating: "=", count: 4 - remainder)
        } else {
            paddedBase64 = base64
        }
        
        guard let data = Data(base64Encoded: paddedBase64),
              let text = String(data: data, encoding: .utf8) else {
            return ""
        }
        
        return text
    }
    
    private func stripHTML(_ html: String) -> String {
        // Basit HTML tag temizleme
        var text = html
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension UUID {
    static func gmailIdentifier(from string: String) -> UUID {
        let hash = SHA256.hash(data: Data(string.utf8))
        let bytes = Array(hash.prefix(16))
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}

private enum GmailHeaderParser {
    static func name(from header: String) -> String {
        if let range = header.range(of: "<") {
            return header[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return header
    }

    static func email(from header: String) -> String {
        if let start = header.firstIndex(of: "<"), let end = header.firstIndex(of: ">") {
            return String(header[header.index(after: start)..<end])
        }
        return header
    }

    static func parseDate(from header: String) -> Date {
        // Parantez içindeki timezone'u temizle: "+0000 (UTC)" -> "+0000"
        var cleanHeader = header
        if let parenIndex = header.firstIndex(of: "(") {
            cleanHeader = String(header[..<parenIndex]).trimmingCharacters(in: .whitespaces)
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Gmail'den gelen farklı tarih formatlarını dene
        let formats = [
            "EEE, dd MMM yyyy HH:mm:ss Z",      // Tue, 11 Nov 2025 18:06:20 +0000
            "EEE, d MMM yyyy HH:mm:ss Z",       // Tue, 5 Nov 2025 18:06:20 +0000
            "dd MMM yyyy HH:mm:ss Z",           // 11 Nov 2025 18:06:20 +0000
            "d MMM yyyy HH:mm:ss Z",            // 9 Nov 2025 04:02:31 +0000
            "EEE, dd MMM yyyy HH:mm:ss zzz",    // Tue, 11 Nov 2025 11:49:39 GMT
            "yyyy-MM-dd'T'HH:mm:ssZ"            // ISO 8601
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: cleanHeader) {
                return date
            }
        }
        
        print("⚠️ Tarih parse edilemedi: \(header)")
        return Date()
    }
}
