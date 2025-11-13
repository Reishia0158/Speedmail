import Foundation
import Network
import UserNotifications

/// Gmail IMAP IDLE servisi - Gerçek zamanlı mail bildirimleri
actor GmailIMAPService {
    private var connection: NWConnection?
    private var isRunning = false
    private var credentials: GoogleCredentials // var yaptık - token yenileme için
    private let account: Account
    
    // Gmail IMAP sunucusu
    private let host = "imap.gmail.com"
    private let port: UInt16 = 993
    
    // Token yenileme için callback
    private var onCredentialsUpdated: ((GoogleCredentials) -> Void)?
    
    init(credentials: GoogleCredentials, account: Account, onCredentialsUpdated: ((GoogleCredentials) -> Void)? = nil) {
        self.credentials = credentials
        self.account = account
        self.onCredentialsUpdated = onCredentialsUpdated
    }
    
    // Token güncelleme fonksiyonu
    func updateCredentials(_ newCredentials: GoogleCredentials) {
        self.credentials = newCredentials
    }
    
    // MARK: - IMAP IDLE Başlat
    
    func startListening() async throws {
        guard !isRunning else {
            print("⚠️ IMAP IDLE zaten çalışıyor")
            return
        }
        
        print("🔌 Gmail IMAP bağlantısı kuruluyor...")
        
        // TLS ile bağlantı oluştur
        let tlsOptions = NWProtocolTLS.Options()
        let parameters = NWParameters(tls: tlsOptions)
        parameters.includePeerToPeer = false
        
        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!)
        connection = NWConnection(to: endpoint, using: parameters)
        
        connection?.stateUpdateHandler = { [weak self] state in
            Task { await self?.handleConnectionState(state) }
        }
        
        connection?.start(queue: .global(qos: .userInitiated))
        isRunning = true
        
        // Bağlantı kurulana kadar bekle
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 saniye
        
        // IMAP login ve IDLE başlat
        try await authenticate()
        try await selectInbox()
        try await startIDLE()
    }
    
    func stopListening() {
        print("🔌 IMAP IDLE durduruluyor...")
        connection?.cancel()
        connection = nil
        isRunning = false
    }
    
    // MARK: - Bağlantı Durumu
    
    private func handleConnectionState(_ state: NWConnection.State) {
        switch state {
        case .ready:
            print("✅ Gmail IMAP bağlantısı kuruldu")
        case .failed(let error):
            print("❌ IMAP bağlantı hatası: \(error)")
            // Bağlantı koptuysa otomatik yeniden bağlan
            if isRunning {
                Task {
                    print("🔄 Bağlantı koptu, 5 saniye sonra yeniden bağlanılıyor...")
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    if isRunning {
                        print("🔄 Otomatik yeniden bağlanma başlatılıyor...")
                        try? await startListening()
                    }
                }
            }
        case .waiting(let error):
            print("⏳ IMAP bağlantı bekliyor: \(error)")
        case .cancelled:
            print("🔌 IMAP bağlantısı kapatıldı")
            // Eğer hala çalışıyorsa yeniden bağlan
            if isRunning {
                Task {
                    print("🔄 Bağlantı iptal edildi, 3 saniye sonra yeniden bağlanılıyor...")
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    if isRunning {
                        print("🔄 Otomatik yeniden bağlanma başlatılıyor...")
                        try? await startListening()
                    }
                }
            }
        default:
            break
        }
    }
    
    // MARK: - IMAP Komutları
    
    private func authenticate() async throws {
        // Token kontrolü - süresi dolmuşsa yenile
        if credentials.isExpired || credentials.expirationDate.timeIntervalSinceNow < 300 {
            print("⚠️ Token süresi dolmak üzere, yenileniyor...")
            await refreshTokenIfNeeded()
        }
        
        // IMAP sunucudan ilk yanıtı al (banner) - timeout ile
        _ = try await receiveWithTimeout(seconds: 10)
        
        // XOAUTH2 ile authenticate (Gmail OAuth token kullan)
        let authString = buildXOAuth2String()
        try await send("A001 AUTHENTICATE XOAUTH2 \(authString)")
        let authResponse = try await receiveWithTimeout(seconds: 10)
        
        if !authResponse.contains("A001 OK") {
            // 401 hatası alırsak token yenile ve tekrar dene
            if authResponse.contains("401") || authResponse.contains("AUTHENTICATE failed") {
                print("🔄 Authentication başarısız, token yenileniyor...")
                await refreshTokenIfNeeded()
                
                // Yeniden dene
                let retryAuthString = buildXOAuth2String()
                try await send("A001 AUTHENTICATE XOAUTH2 \(retryAuthString)")
                let retryResponse = try await receiveWithTimeout(seconds: 10)
                
                if !retryResponse.contains("A001 OK") {
                    print("❌ IMAP authentication başarısız (retry): \(retryResponse)")
                    throw IMAPError.authenticationFailed
                }
            } else {
                print("❌ IMAP authentication başarısız: \(authResponse)")
                throw IMAPError.authenticationFailed
            }
        }
        
        print("✅ IMAP authentication başarılı")
    }
    
    private func selectInbox() async throws {
        try await send("A002 SELECT INBOX")
        let response = try await receiveWithTimeout(seconds: 10)
        
        if !response.contains("A002 OK") {
            print("❌ INBOX seçilemedi: \(response)")
            throw IMAPError.selectFailed
        }
        
        print("✅ INBOX seçildi")
    }
    
    private func startIDLE() async throws {
        print("🔔 IMAP IDLE başlatılıyor...")
        try await send("A003 IDLE")
        
        // IDLE onayını timeout ile bekle (5 saniye)
        let idleResponse = try await receiveWithTimeout(seconds: 5)
        if !idleResponse.contains("+ idling") {
            print("❌ IDLE başlatılamadı: \(idleResponse)")
            throw IMAPError.idleFailed
        }
        
        print("✅ IMAP IDLE aktif - Yeni mailler anında bildirilecek!")
        
        // IDLE yanıtlarını dinle
        Task {
            await listenForIDLENotifications()
        }
    }
    
    private func listenForIDLENotifications() async {
        // Token yenileme kontrolü için periyodik task
        let tokenRefreshTask = Task {
            while isRunning {
                // Token süresi dolmadan 5 dakika önce yenile
                let timeUntilExpiry = credentials.expirationDate.timeIntervalSinceNow
                if timeUntilExpiry < 300 { // 5 dakikadan az kaldıysa
                    print("🔄 Token süresi dolmak üzere (\(Int(timeUntilExpiry))s kaldı), yenileniyor...")
                    await refreshTokenIfNeeded()
                }
                // Her 1 dakikada bir kontrol et
                try? await Task.sleep(nanoseconds: 60 * 1_000_000_000)
            }
        }
        
        while isRunning {
            do {
                // Timeout ile receive (29 dakika - Gmail IDLE timeout'u 30 dakika)
                // Ancak daha kısa timeout kullanıp periyodik olarak yeniden başlatmak daha güvenli
                let response = try await receiveWithTimeout(seconds: 25 * 60) // 25 dakika
                
                // Yeni mail geldi mi kontrol et
                if response.contains("EXISTS") {
                    print("📬 Yeni mail tespit edildi!")
                    await sendNotification()
                    
                    // IDLE'dan çık ve yeniden başlat (EXISTS sonrası gerekli)
                    try await send("DONE")
                    _ = try? await receiveWithTimeout(seconds: 5) // DONE yanıtını al
                    print("🔄 IDLE modundan çıkıldı, yeniden başlatılıyor...")
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 saniye bekle
                    
                    // IDLE'ı yeniden başlat
                    try await restartIDLE()
                }
                
            } catch IMAPError.timeout {
                // Timeout oldu - bağlantı hala canlı olabilir, IDLE'ı yeniden başlat
                print("⏱️ IMAP receive timeout (30s) - IDLE yeniden başlatılıyor...")
                do {
                    try await send("DONE")
                    _ = try? await receiveWithTimeout(seconds: 5) // DONE yanıtını al
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 saniye bekle
                    try await restartIDLE()
                    print("✅ IDLE yeniden başlatıldı (timeout sonrası)")
                } catch {
                    print("⚠️ IDLE yeniden başlatma hatası (timeout): \(error.localizedDescription)")
                    // Hata durumunda bir sonraki catch bloğuna düşecek
                }
                
            } catch {
                print("⚠️ IDLE dinleme hatası: \(error.localizedDescription)")
                
                // Bağlantıyı tamamen yeniden kur (daha agresif)
                if isRunning {
                    print("🔄 IMAP bağlantısı yeniden kuruluyor...")
                    stopListening() // Önce mevcut bağlantıyı temizle
                    
                    // Exponential backoff: 3s, 5s, 10s
                    var retryDelay: UInt64 = 3_000_000_000 // 3 saniye
                    var retryCount = 0
                    let maxRetries = 3
                    
                    while isRunning && retryCount < maxRetries {
                        try? await Task.sleep(nanoseconds: retryDelay)
                        
                        if isRunning {
                            print("🔄 Yeniden bağlanma deneniyor (\(retryCount + 1)/\(maxRetries))...")
                            do {
                                try await startListening()
                                print("✅ Yeniden bağlanma başarılı!")
                                break // Başarılı, döngüden çık
                            } catch {
                                print("❌ Yeniden bağlanma başarısız: \(error.localizedDescription)")
                                retryCount += 1
                                retryDelay = min(retryDelay * 2, 10_000_000_000) // Max 10 saniye
                            }
                        }
                    }
                    
                    if retryCount >= maxRetries {
                        print("⚠️ Maksimum yeniden bağlanma denemesi aşıldı, durduruluyor")
                    }
                }
            }
        }
        
        // Token refresh task'ı iptal et
        tokenRefreshTask.cancel()
    }
    
    // MARK: - Token Yenileme
    
    private func refreshTokenIfNeeded() async {
        guard credentials.isExpired || credentials.expirationDate.timeIntervalSinceNow < 300 else {
            return // Token hala geçerli
        }
        
        print("🔄 IMAP için token yenileniyor...")
        do {
            // MainActor'de çalışan refresh fonksiyonunu çağır
            let newCredentials = try await GoogleOAuthManager.shared.refresh(using: credentials.refreshToken)
            self.credentials = newCredentials
            
            // Callback'i actor'dan çıkarıp MainActor'de çağır
            let callback = self.onCredentialsUpdated
            await MainActor.run {
                callback?(newCredentials)
            }
            
            print("✅ IMAP token yenilendi")
            
            // Token yenilendi, bağlantıyı yeniden kur (XOAUTH2 token değişti)
            if isRunning {
                print("🔄 Token yenilendi, IMAP bağlantısı yeniden kuruluyor...")
                stopListening()
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 saniye bekle
                if isRunning {
                    try? await startListening()
                }
            }
        } catch {
            print("❌ Token yenileme başarısız: \(error.localizedDescription)")
        }
    }
    
    // Timeout ile receive
    private func receiveWithTimeout(seconds: TimeInterval) async throws -> String {
        return try await withThrowingTaskGroup(of: String.self) { group in
            // Ana receive task
            group.addTask {
                return try await self.receive()
            }
            
            // Timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw IMAPError.timeout
            }
            
            // İlk tamamlanan task'ı al
            guard let result = try await group.next() else {
                throw IMAPError.timeout
            }
            
            group.cancelAll() // Diğer task'ı iptal et
            return result
        }
    }
    
    // IDLE'ı kontrol olmadan yeniden başlat (EXISTS sonrası için)
    private func restartIDLE() async throws {
        print("🔔 IMAP IDLE yeniden başlatılıyor...")
        
        // Önce token kontrolü yap
        if credentials.isExpired || credentials.expirationDate.timeIntervalSinceNow < 300 {
            print("⚠️ Token süresi dolmak üzere, yenileniyor...")
            await refreshTokenIfNeeded()
        }
        
        try await send("A003 IDLE")
        
        // IDLE onayını timeout ile bekle (5 saniye)
        let idleResponse = try await receiveWithTimeout(seconds: 5)
        if !idleResponse.contains("+ idling") {
            print("❌ IDLE yeniden başlatılamadı: \(idleResponse)")
            throw IMAPError.idleFailed
        }
        
        print("✅ IMAP IDLE yeniden aktif!")
    }
    
    // MARK: - Network İşlemleri
    
    private func send(_ command: String) async throws {
        guard let connection = connection else {
            throw IMAPError.notConnected
        }
        
        let data = (command + "\r\n").data(using: .utf8)!
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.send(content: data, completion: .contentProcessed { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            })
        }
    }
    
    private func receive() async throws -> String {
        guard let connection = connection else {
            throw IMAPError.notConnected
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isComplete, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = String(data: data, encoding: .utf8) {
                    continuation.resume(returning: response)
                } else {
                    continuation.resume(throwing: IMAPError.invalidResponse)
                }
            }
        }
    }
    
    // MARK: - XOAUTH2
    
    private func buildXOAuth2String() -> String {
        let authString = "user=\(account.emailAddress)\u{0001}auth=Bearer \(credentials.accessToken)\u{0001}\u{0001}"
        return authString.data(using: .utf8)!.base64EncodedString()
    }
    
    // MARK: - Bildirim Gönder
    
    private func sendNotification() async {
        // En son maili Gmail API'den al
        guard let latestMail = try? await fetchLatestMail() else {
            print("⚠️ Son mail alınamadı, basit bildirim gönderiliyor")
            await sendSimpleNotification()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "📬 Yeni Mail"
        content.subtitle = latestMail.sender
        content.body = latestMail.subject
        content.sound = .default
        content.threadIdentifier = account.emailAddress // Bildirimleri grupla
        content.categoryIdentifier = "MAIL_NOTIFICATION"
        content.userInfo = [
            "account": account.emailAddress,
            "sender": latestMail.sender,
            "subject": latestMail.subject
        ]
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Bildirim gönderildi: \(latestMail.subject)")
        } catch {
            print("❌ Bildirim gönderilemedi: \(error)")
        }
    }
    
    private func sendSimpleNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "📬 Yeni Mail"
        content.body = "\(account.displayName) hesabınıza yeni bir mail geldi"
        content.sound = .default
        content.threadIdentifier = account.emailAddress
        content.categoryIdentifier = "MAIL_NOTIFICATION"
        content.userInfo = ["account": account.emailAddress]
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Gmail API İşlemleri
    
    private func fetchLatestMail() async throws -> (sender: String, subject: String)? {
        // En son mesajın ID'sini al
        guard let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=1&labelIds=INBOX") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        struct MessageListResponse: Decodable {
            let messages: [MessageReference]?
        }
        
        struct MessageReference: Decodable {
            let id: String
        }
        
        let listResponse = try JSONDecoder().decode(MessageListResponse.self, from: data)
        guard let messageID = listResponse.messages?.first?.id else {
            return nil
        }
        
        // Mesaj detayını al
        guard let detailURL = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(messageID)?format=metadata&metadataHeaders=Subject&metadataHeaders=From") else {
            return nil
        }
        
        var detailRequest = URLRequest(url: detailURL)
        detailRequest.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        
        let (detailData, _) = try await URLSession.shared.data(for: detailRequest)
        
        struct MessageDetail: Decodable {
            let payload: Payload
            
            struct Payload: Decodable {
                let headers: [Header]
            }
            
            struct Header: Decodable {
                let name: String
                let value: String
            }
        }
        
        let detail = try JSONDecoder().decode(MessageDetail.self, from: detailData)
        
        let subjectHeader = detail.payload.headers.first { $0.name == "Subject" }?.value ?? "Konu yok"
        let fromHeader = detail.payload.headers.first { $0.name == "From" }?.value ?? "Bilinmeyen Gönderen"
        
        // "Name <email@example.com>" formatından sadece ismi al
        let senderName: String
        if let startIndex = fromHeader.firstIndex(of: "<") {
            senderName = String(fromHeader[..<startIndex]).trimmingCharacters(in: .whitespaces)
        } else {
            senderName = fromHeader
        }
        
        return (sender: senderName.isEmpty ? fromHeader : senderName, subject: subjectHeader)
    }
}

// MARK: - Errors

enum IMAPError: LocalizedError {
    case notConnected
    case authenticationFailed
    case selectFailed
    case idleFailed
    case invalidResponse
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .notConnected: return "IMAP bağlantısı yok"
        case .authenticationFailed: return "IMAP authentication başarısız"
        case .selectFailed: return "INBOX seçilemedi"
        case .idleFailed: return "IDLE başlatılamadı"
        case .invalidResponse: return "Geçersiz IMAP yanıtı"
        case .timeout: return "IMAP yanıt zaman aşımı"
        }
    }
}
