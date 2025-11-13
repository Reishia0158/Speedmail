import Foundation
import UserNotifications

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var sessions: [AccountSession] = []
    @Published var selectedSessionID: UUID?
    @Published var isShowingComposer: Bool = false
    @Published var isShowingAddAccount: Bool = false
    @Published var composerDraft: DraftMessage = .init()
    @Published var toastMessage: String?
    @Published var isConnectingGmail: Bool = false

    private var autoRefreshTask: Task<Void, Never>?
    
    // IMAP IDLE listeners (her hesap için)
    private var imapListeners: [UUID: GmailIMAPService] = [:]
    
    // Her 5 dakikada bir otomatik kontrol (Background Refresh ile birlikte) - IMAP için backup
    private let autoRefreshInterval: TimeInterval = 300
    
    private let gmailScopes: [String] = [
        "openid",
        "https://www.googleapis.com/auth/userinfo.profile",
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/gmail.modify", // readonly yerine modify (silme için)
        "https://mail.google.com/" // IMAP/SMTP erişimi için (XOAUTH2)
    ]
    
    // Her hesap için son bilinen mesaj sayısını tut
    private var lastMessageCounts: [UUID: Int] = [:]

    init() {
        loadSavedAccounts()
        startAutoRefresh()
        setupNotificationObservers()
        setupAPNsObserver()
        // IMAP IDLE'ı hesaplar yüklendikten sonra başlat
    }
    
    private func setupAPNsObserver() {
        // APNs token alındığında backend'e kaydet
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("APNsTokenReceived"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let deviceToken = notification.userInfo?["token"] as? Data else { return }
            
            // Aktif hesap varsa token'ı kaydet
            if let email = self.activeSession?.account.emailAddress {
                APNsManager.shared.saveDeviceToken(deviceToken, for: email)
            }
        }
    }

    deinit {
        autoRefreshTask?.cancel()
        // IMAP listeners'ı Task içinde durdur
        let listeners = imapListeners
        Task {
            for (_, listener) in listeners {
                await listener.stopListening()
            }
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotificationObservers() {
        // Background refresh geldiğinde tüm hesapları kontrol et
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("BackgroundMailRefresh"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.checkAllAccountsForNewMail()
            }
        }
        
        // IMAP IDLE'dan yeni mail bildirimi geldiğinde
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NewMailArrived"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            if let accountEmail = notification.userInfo?["account"] as? String {
                print("📬 Yeni mail geldi: \(accountEmail)")
                // İlgili mailbox'ı yenile
                if let session = self.sessions.first(where: { $0.account.emailAddress == accountEmail }) {
                    session.mailboxViewModel.loadMailbox(force: true)
                }
            }
        }
    }

    var activeSession: AccountSession? {
        if let selectedID = selectedSessionID {
            return sessions.first { $0.id == selectedID }
        }
        return sessions.first
    }

    func select(session: AccountSession) {
        selectedSessionID = session.id
    }

    func refreshActiveMailbox(force: Bool = false) {
        guard let mailbox = activeSession?.mailboxViewModel else { return }
        mailbox.loadMailbox(force: force)
    }
    
    /// Tüm hesapların mailbox'larını yenile (Spark gibi)
    func refreshAllMailboxes() async {
        print("🔄 Tüm hesaplar yenileniyor...")
        for session in sessions {
            await MainActor.run {
                session.mailboxViewModel.loadMailbox(force: true)
            }
        }
        print("✅ Tüm hesaplar yenilendi")
    }

    func performQuickAction(_ action: QuickActionKind) {
        guard let mailbox = activeSession?.mailboxViewModel else { return }
        switch action {
        case .refresh:
            mailbox.loadMailbox(force: true)
        case .selectMode:
            mailbox.isSelectMode.toggle()
            mailbox.selectedMessages.removeAll() // Seçimleri temizle
        case .categorize:
            if mailbox.isGroupedByCategory {
                // Zaten kategorilendirildiyse, dağıt
                mailbox.uncategorize()
                toastMessage = "Kategoriler dağıtıldı"
            } else {
                // Kategorilendirme yap
                mailbox.categorizeBySender()
                toastMessage = "Mailler gönderene göre kategorilendirildi"
            }
        }
    }

    func presentComposer() {
        composerDraft = DraftMessage()
        isShowingComposer = true
    }

    func sendCurrentDraft() {
        guard let mailbox = activeSession?.mailboxViewModel else { return }
        mailbox.send(draft: composerDraft) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.toastMessage = "Mesaj gönderildi"
                self.isShowingComposer = false
                self.composerDraft = .init()
            case .failure(let error):
                self.toastMessage = "Gönderilemedi: \(error.localizedDescription)"
            }
        }
    }

    // Manuel hesap ekleme kaldırıldı - Sadece Gmail ile giriş yapılabilir
    
    func removeAccount(_ session: AccountSession) {
        // Keychain'den sil
        _ = KeychainHelper.shared.deleteGmailCredentials(for: session.account.emailAddress)
        
        // Session'dan çıkar
        sessions.removeAll { $0.id == session.id }
        
        // Seçili hesap silinmişse başka hesap seç
        if selectedSessionID == session.id {
            selectedSessionID = sessions.first?.id
        }
        
        toastMessage = "\(session.account.emailAddress) kaldırıldı"
    }

    func connectGmailAccount() {
        guard !isConnectingGmail else { return }
        isConnectingGmail = true

        Task {
            do {
                let credentials = try await GoogleOAuthManager.shared.signIn(scopes: gmailScopes)
                let profile = try await GmailProfileService().fetchProfile(using: credentials)
                
                // Önce eski credentials'ı sil (scope değişmiş olabilir)
                _ = KeychainHelper.shared.deleteGmailCredentials(for: profile.email)
                
                // Yeni credentials'ı Keychain'e kaydet
                _ = KeychainHelper.shared.saveGmailCredentials(credentials, for: profile.email)
                
                let account = Account(displayName: profile.name, emailAddress: profile.email, accentColor: .ocean)
                let gmailService = GmailMailboxService(credentials: credentials)
                let mailboxVM = MailboxViewModel(account: account, service: gmailService)
                mailboxVM.loadMailbox(force: true)
                let session = AccountSession(account: account, mailboxViewModel: mailboxVM)
                self.sessions.append(session)
                self.selectedSessionID = session.id
                self.toastMessage = "Gmail hesabı bağlandı ve kaydedildi"
                
                // APNs token'ı kaydet ve Gmail Watch'ı başlat
                Task {
                    // Eğer APNs token varsa kaydet
                    if let tokenString = UserDefaults.standard.string(forKey: "apns_device_token"),
                       let tokenData = Data(hexString: tokenString) {
                        APNsManager.shared.saveDeviceToken(tokenData, for: session.account.emailAddress)
                    }
                    
                    // Gmail Watch'ı başlat
                    await self.setupPushNotifications(for: session, credentials: credentials)
                }
                
                // Yeni hesap için IMAP IDLE başlat (backup olarak)
                Task {
                    await self.startIMAPListener(for: session)
                }
            } catch {
                self.toastMessage = "Gmail bağlanamadı: \(error.localizedDescription)"
            }
            self.isConnectingGmail = false
        }
    }

    private func loadSavedAccounts() {
        // Keychain'den kayıtlı Gmail hesaplarını yükle
        let savedEmails = KeychainHelper.shared.listSavedEmails()
        
        for email in savedEmails {
            if let credentials = KeychainHelper.shared.loadGmailCredentials(for: email) {
                Task {
                    do {
                        let profile = try await GmailProfileService().fetchProfile(using: credentials)
                        let account = Account(displayName: profile.name, emailAddress: profile.email, accentColor: .ocean)
                        let gmailService = GmailMailboxService(credentials: credentials)
                        let mailboxVM = MailboxViewModel(account: account, service: gmailService)
                        
                        await MainActor.run {
                            let session = AccountSession(account: account, mailboxViewModel: mailboxVM)
                            self.sessions.append(session)
                            mailboxVM.loadMailbox(force: true)
                            
                            // APNs token'ı kaydet ve Gmail Watch'ı başlat
                            Task {
                                // Eğer APNs token varsa kaydet
                                if let tokenString = UserDefaults.standard.string(forKey: "apns_device_token"),
                                   let tokenData = Data(hexString: tokenString) {
                                    APNsManager.shared.saveDeviceToken(tokenData, for: session.account.emailAddress)
                                }
                                
                                // Gmail Watch'ı başlat
                                await self.setupPushNotifications(for: session, credentials: credentials)
                            }
                            
                            // Hesap eklendikten sonra IMAP IDLE başlat (backup olarak)
                            Task {
                                await self.startIMAPListener(for: session)
                            }
                        }
                    } catch {
                        print("❌ Gmail hesabı yüklenemedi (\(email)): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    
    // MARK: - Otomatik Mail Kontrolü
    
    /// Otomatik mail yenileme sistemini başlat (her 10 saniyede bir)
    private func startAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = Task { [weak self] in
            guard let self else { return }
            
            // İlk yüklemede biraz bekle
            try? await Task.sleep(nanoseconds: 3 * 1_000_000_000) // 3 saniye
            
            while !Task.isCancelled {
                await self.checkAllAccountsForNewMail()
                
                // 10 saniye bekle
                try? await Task.sleep(nanoseconds: UInt64(self.autoRefreshInterval * 1_000_000_000))
            }
        }
    }
    
    /// Tüm hesapları kontrol et ve yeni mail varsa bildir
    func checkAllAccountsForNewMail() async {
        for session in sessions {
            await checkAccountForNewMail(session: session)
        }
    }
    
    /// Belirli bir hesabı kontrol et
    private func checkAccountForNewMail(session: AccountSession) async {
        do {
            let messages = try await session.mailboxViewModel.service.fetchMessages(for: session.account)
            let currentCount = messages.count
            let previousCount = lastMessageCounts[session.account.id] ?? currentCount
            
            // Yeni mesaj varsa
            if currentCount > previousCount {
                let newMailCount = currentCount - previousCount
                _ = messages.filter { !$0.isRead }.prefix(newMailCount)
                
                // Bildirim gönder (şimdilik basit toast)
                // TODO: Firebase FCM entegrasyonu eklenecek
                
                // Mailbox'ı güncelle
                await MainActor.run {
                    session.mailboxViewModel.loadMailbox(force: true)
                    self.toastMessage = "\(newMailCount) yeni mesaj geldi - \(session.account.emailAddress)"
                }
            }
            
            // Son mesaj sayısını güncelle
            lastMessageCounts[session.account.id] = currentCount
            
        } catch {
            print("❌ Mail kontrolü başarısız (\(session.account.emailAddress)): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Bildirim Ayarları
    
    /// Kullanıcıdan bildirim izni iste (basit versiyon)
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Bildirim izni verildi")
                    self.toastMessage = "Bildirim izni verildi"
                } else {
                    print("❌ Bildirim izni reddedildi")
                    if let error = error {
                        print("❌ Hata: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Push Notifications (Fly.io Backend + Gmail Watch)
    
    /// Push notification sistemini kur (APNs token + Gmail Watch)
    private func setupPushNotifications(for session: AccountSession, credentials: GoogleCredentials) async {
        // APNs device token'ı al (AppDelegate'den gelecek)
        // Şimdilik Gmail Watch'ı başlatalım, device token AppDelegate'den kaydedilecek
        
        // Gmail Watch API'yi başlat (Fly.io backend üzerinden)
        await APNsManager.shared.setupGmailWatch(
            email: session.account.emailAddress,
            accessToken: credentials.accessToken,
            refreshToken: credentials.refreshToken
        )
        
        print("✅ Push notification sistemi kuruldu: \(session.account.emailAddress)")
    }
    
    // MARK: - IMAP IDLE Management
    
    /// Tüm IMAP bağlantılarını yeniden başlat (uygulama ön plana geldiğinde)
    func restartIMAPListeners() {
        print("🔄 IMAP bağlantıları yeniden başlatılıyor...")
        Task {
            // Mevcut bağlantıları durdur
            for (_, listener) in imapListeners {
                await listener.stopListening()
            }
            imapListeners.removeAll()
            
            // Yeniden başlat
            for session in sessions {
                await startIMAPListener(for: session)
            }
            print("✅ IMAP bağlantıları yeniden başlatıldı")
        }
    }
    
    private func startIMAPListener(for session: AccountSession) async {
        print("🔌 IMAP IDLE başlatılıyor: \(session.account.emailAddress)")
        // Gmail service'den credentials al
        guard let gmailService = session.mailboxViewModel.service as? GmailMailboxService else {
            print("⚠️ Gmail service bulunamadı: \(session.account.emailAddress)")
            return
        }
        
        let credentials = await gmailService.getCurrentCredentials()
        
        // Token güncelleme callback'i
        let onCredentialsUpdated: (GoogleCredentials) -> Void = { [weak self] newCredentials in
            guard self != nil else { return }
            // Keychain'e kaydet
            _ = KeychainHelper.shared.saveGmailCredentials(newCredentials, for: session.account.emailAddress)
            print("✅ IMAP token güncellendi ve Keychain'e kaydedildi: \(session.account.emailAddress)")
            
            // Gmail service'e de yeni token'ı ver
            Task {
                await gmailService.updateCredentials(newCredentials)
            }
        }
        
        // IMAP listener oluştur
        let imapService = GmailIMAPService(
            credentials: credentials,
            account: session.account,
            onCredentialsUpdated: onCredentialsUpdated
        )
        imapListeners[session.id] = imapService
        
        // IDLE modunu başlat
        do {
            try await imapService.startListening()
            print("✅ IMAP IDLE başlatıldı: \(session.account.emailAddress)")
        } catch {
            print("❌ IMAP IDLE başlatılamadı: \(error.localizedDescription)")
        }
    }
}

enum QuickActionKind: CaseIterable, Identifiable {
    case refresh
    case selectMode
    case categorize

    var id: String { rawValue }
    
    var rawValue: String {
        switch self {
        case .refresh: return "refresh"
        case .selectMode: return "selectMode"
        case .categorize: return "categorize"
        }
    }

    func title(isGrouped: Bool) -> String {
        switch self {
        case .refresh: return "Yenile"
        case .selectMode: return "Seç"
        case .categorize: return isGrouped ? "Kategori Dağıt" : "Kategorilendir"
        }
    }
    
    func systemImage(isGrouped: Bool) -> String {
        switch self {
        case .refresh: return "arrow.clockwise"
        case .selectMode: return "checkmark.circle"
        case .categorize: return isGrouped ? "folder.badge.minus" : "folder.badge.plus"
        }
    }
}

struct AccountSession: Identifiable {
    let id: UUID
    var account: Account
    let mailboxViewModel: MailboxViewModel

    init(id: UUID = UUID(), account: Account, mailboxViewModel: MailboxViewModel) {
        self.id = id
        self.account = account
        self.mailboxViewModel = mailboxViewModel
    }
}
