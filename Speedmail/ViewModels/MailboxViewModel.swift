import Foundation

@MainActor
final class MailboxViewModel: ObservableObject {
    @Published private(set) var messages: [MailMessage] = []
    @Published var searchQuery: String = ""
    @Published var selectedCategory: MailboxCategory = .inbox {
        didSet {
            if selectedCategory != oldValue {
                loadMailbox(force: true)
            }
        }
    }
    @Published var focusOnUnread: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    @Published var isSelectMode: Bool = false
    @Published var selectedMessages: Set<UUID> = []
    @Published var senderCategories: [String: [MailMessage]] = [:]
    @Published var isGroupedByCategory: Bool = false
    
    // Pagination
    private var nextPageToken: String? = nil
    var hasMoreMessages: Bool {
        nextPageToken != nil
    }

    let account: Account
    let service: MailboxServiceProtocol // internal yaptık ki AppViewModel erişebilsin

    init(account: Account, service: MailboxServiceProtocol) {
        self.account = account
        self.service = service
    }

    var visibleMessages: [MailMessage] {
        // loadMailbox zaten doğru kategoriden mesajları çekiyor, bu yüzden kategori filtresi gereksiz
        messages
            .filter { message in
                guard focusOnUnread else { return true }
                return message.isRead == false
            }
            .filter { message in
                guard !searchQuery.isEmpty else { return true }
                let query = searchQuery.lowercased()
                return message.subject.lowercased().contains(query)
                    || message.preview.lowercased().contains(query)
                    || message.sender.name.lowercased().contains(query)
                    || message.sender.email.lowercased().contains(query)
            }
            .sorted { $0.receivedAt > $1.receivedAt }
    }

    func loadMailbox(force: Bool = false) {
        if isLoading && !force { return }
        isLoading = true
        errorMessage = nil
        nextPageToken = nil // Reset pagination

        Task {
            do {
                // GmailMailboxService için kategori parametresi ekle - İlk yüklemede 100 mesaj
                if let gmailService = service as? GmailMailboxService {
                    let result = try await gmailService.fetchMessages(for: account, category: selectedCategory, maxResults: 100)
                    await MainActor.run {
                        self.messages = result.messages
                        self.nextPageToken = result.nextPageToken
                        self.isLoading = false
                    }
                } else {
                let fetched = try await service.fetchMessages(for: account)
                await MainActor.run {
                    self.messages = fetched
                    self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    /// Daha fazla mesaj yükle (infinite scroll için)
    func loadMoreMessages() {
        guard hasMoreMessages, !isLoadingMore, let pageToken = nextPageToken else { return }
        isLoadingMore = true

        Task {
            do {
                if let gmailService = service as? GmailMailboxService {
                    let result = try await gmailService.fetchMessages(for: account, category: selectedCategory, maxResults: 50, pageToken: pageToken)
                    await MainActor.run {
                        // Yeni mesajları ekle (duplicate kontrolü yap)
                        let existingIds = Set(self.messages.map { $0.id })
                        let newMessages = result.messages.filter { !existingIds.contains($0.id) }
                        self.messages.append(contentsOf: newMessages)
                        self.nextPageToken = result.nextPageToken
                        self.isLoadingMore = false
                        print("✅ \(newMessages.count) yeni mesaj yüklendi. Toplam: \(self.messages.count)")
                    }
                } else {
                    await MainActor.run {
                        self.isLoadingMore = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoadingMore = false
                }
            }
        }
    }

    func toggleReadState(for message: MailMessage) {
        print("🔄 toggleReadState çağrıldı: \(message.subject.prefix(30)) | isRead: \(message.isRead)")
        // Eğer mesaj okunmamışsa, okundu olarak işaretle
        // (Mail açıldığında çağrılıyor, toggle değil direkt okundu yap)
        if !message.isRead {
            print("✅ Mail okunmamış, update çağrılıyor...")
            update(message: message, mutate: { $0.isRead = true })
        } else {
            print("ℹ️ Mail zaten okunmuş, update atlanıyor")
        }
    }

    func toggleFlag(for message: MailMessage) {
        update(message: message, mutate: { $0.isFlagged.toggle() })
    }

    func delete(_ message: MailMessage) {
        Task {
            do {
                try await service.delete(message: message, for: account)
            await MainActor.run {
                self.messages.removeAll { $0.id == message.id }
                    print("✅ Mesaj listeden kaldırıldı")
                }
            } catch {
                print("❌ Silme hatası: \(error.localizedDescription)")
            }
        }
    }

    func markAllAsRead() {
        let unread = messages.filter { !$0.isRead }
        guard !unread.isEmpty else { return }

        Task {
            for var message in unread {
                message.isRead = true
                _ = try? await service.update(message: message, for: account)
            }
            await MainActor.run {
                self.messages = self.messages.map { message in
                    var updated = message
                    updated.isRead = true
                    return updated
                }
            }
        }
    }

    func send(draft: DraftMessage, completion: @escaping (Result<MailMessage, Error>) -> Void) {
        Task {
            do {
                let sent = try await service.send(draft: draft, from: account)
                await MainActor.run {
                    self.messages.insert(sent, at: 0)
                }
                await MainActor.run {
                    completion(.success(sent))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }

    private func update(message: MailMessage, mutate: @escaping (inout MailMessage) -> Void) {
        Task {
            var workingMessage = message
            mutate(&workingMessage)
            
            // Gmail API'ye update gönder
            do {
                let updated = try await service.update(message: workingMessage, for: account)
                await MainActor.run {
                    guard let index = self.messages.firstIndex(where: { $0.id == updated.id }) else {
                        print("⚠️ Mail bulunamadı, güncelleme atlanıyor")
                        return
                    }
                    self.messages[index] = updated
                    print("✅ Mail güncellendi: \(updated.subject.prefix(30))")
                }
            } catch {
                print("❌ Mail güncelleme hatası: \(error.localizedDescription)")
                // Hata olsa bile local state'i güncelle (UI için)
                await MainActor.run {
                    guard let index = self.messages.firstIndex(where: { $0.id == workingMessage.id }) else { return }
                    self.messages[index] = workingMessage
                }
            }
        }
    }
    
    // MARK: - Kategori Özellikleri
    
    /// Mailleri gönderene göre grupla (gönderen adına göre)
    func categorizeBySender() {
        isGroupedByCategory = true
        var grouped: [String: [MailMessage]] = [:]
        
        for message in messages {
            // Gönderen adı boş değilse adı kullan, yoksa email kullan
            let senderKey = message.sender.name.isEmpty ? message.sender.email : message.sender.name
            if grouped[senderKey] == nil {
                grouped[senderKey] = []
            }
            grouped[senderKey]?.append(message)
        }
        
        // Her kategoriyi tarih sırasına göre sırala
        for (key, msgs) in grouped {
            grouped[key] = msgs.sorted { $0.receivedAt > $1.receivedAt }
        }
        
        senderCategories = grouped
        print("✅ \(grouped.count) farklı gönderen bulundu")
    }
    
    /// Kategorilendirmeyi iptal et
    func uncategorize() {
        isGroupedByCategory = false
        senderCategories = [:]
    }
    
    /// Seçili mesajları sil
    func deleteSelectedMessages() {
        for id in selectedMessages {
            if let message = messages.first(where: { $0.id == id }) {
                delete(message)
            }
        }
        selectedMessages.removeAll()
        isSelectMode = false
    }
    
    /// Seçili mesajları okundu olarak işaretle
    func markSelectedAsRead() {
        for id in selectedMessages {
            if let message = messages.first(where: { $0.id == id }) {
                toggleReadState(for: message)
            }
        }
        selectedMessages.removeAll()
    }
}
