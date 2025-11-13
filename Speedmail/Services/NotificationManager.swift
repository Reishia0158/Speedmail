import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    // Bildirim izni durumunu kontrol et
    func checkAuthorizationStatus() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            await MainActor.run {
                self.authorizationStatus = settings.authorizationStatus
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // Bildirim izni iste
    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        
        await MainActor.run {
            self.isAuthorized = granted
            self.authorizationStatus = granted ? .authorized : .denied
        }
        
        return granted
    }
    
    // Yeni mail bildirimi gönder
    func sendNewMailNotification(from sender: String, subject: String, preview: String, account: String) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📬 Yeni Mail - \(account)"
        content.subtitle = "Gönderen: \(sender)"
        content.body = "\(subject)\n\(preview)"
        content.sound = .default
        content.badge = NSNumber(value: await getUnreadCount() + 1)
        content.categoryIdentifier = "MAIL_NOTIFICATION"
        content.userInfo = ["sender": sender, "subject": subject]
        
        // Hemen göster
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // nil = hemen göster
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Bildirim gönderilemedi: \(error.localizedDescription)")
        }
    }
    
    // Toplu yeni mail bildirimi
    func sendBulkNewMailNotification(count: Int, account: String) async {
        guard isAuthorized, count > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📬 \(count) Yeni Mail"
        content.body = "\(account) hesabınıza \(count) yeni mesaj geldi"
        content.sound = .default
        content.badge = NSNumber(value: await getUnreadCount() + count)
        content.categoryIdentifier = "BULK_MAIL_NOTIFICATION"
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Toplu bildirim gönderilemedi: \(error.localizedDescription)")
        }
    }
    
    // Tüm bildirimleri temizle
    func clearAllNotifications() async {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        await setBadgeCount(0)
    }
    
    // Badge sayısını güncelle
    func setBadgeCount(_ count: Int) async {
        await UNUserNotificationCenter.current().setBadgeCount(count)
    }
    
    // Okunmamış mail sayısını al (basit implementasyon)
    private func getUnreadCount() async -> Int {
        let center = UNUserNotificationCenter.current()
        let notifications = await center.deliveredNotifications()
        return notifications.count
    }
    
    // Bildirim kategorilerini kaydet
    func setupNotificationCategories() {
        let markReadAction = UNNotificationAction(
            identifier: "MARK_READ",
            title: "Okundu İşaretle",
            options: []
        )
        
        let deleteAction = UNNotificationAction(
            identifier: "DELETE",
            title: "Sil",
            options: .destructive
        )
        
        let mailCategory = UNNotificationCategory(
            identifier: "MAIL_NOTIFICATION",
            actions: [markReadAction, deleteAction],
            intentIdentifiers: [],
            options: []
        )
        
        let bulkCategory = UNNotificationCategory(
            identifier: "BULK_MAIL_NOTIFICATION",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([mailCategory, bulkCategory])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    // Uygulama ön plandayken bildirimi göster
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Bildirime tıklandığında
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "MARK_READ":
            print("Okundu işaretlendi: \(userInfo)")
        case "DELETE":
            print("Silindi: \(userInfo)")
        case UNNotificationDefaultActionIdentifier:
            print("Bildirime tıklandı: \(userInfo)")
        default:
            break
        }
        
        completionHandler()
    }
}

