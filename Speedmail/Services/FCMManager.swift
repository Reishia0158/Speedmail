import Foundation
import FirebaseMessaging
import FirebaseFunctions
import UserNotifications

/// Firebase Cloud Messaging Yöneticisi
/// Anlık mail bildirimleri için FCM token yönetimi
@MainActor
final class FCMManager: NSObject, ObservableObject {
    static let shared = FCMManager()
    
    @Published private(set) var fcmToken: String?
    @Published private(set) var isRegistered: Bool = false
    
    private override init() {
        super.init()
    }
    
    /// FCM token'ı al ve kaydet
    func registerForRemoteNotifications() {
        Messaging.messaging().delegate = self
        
        // Mevcut token'ı al
        Messaging.messaging().token { token, error in
            if let error = error {
                print("❌ FCM token alınamadı: \(error.localizedDescription)")
                return
            }
            
            if let token = token {
                Task { @MainActor in
                    self.fcmToken = token
                    self.isRegistered = true
                    print("✅ FCM Token alındı: \(token)")
                    
            // Token'ı backend'e gönder (email bilgisi AppViewModel'den gelecek)
            // Şimdilik sadece token'ı kaydet
            UserDefaults.standard.set(token, forKey: "fcm_token")
                }
            }
        }
    }
    
    /// Token'ı Firebase Functions'a kaydet
    func sendTokenToBackend(token: String, email: String) async {
        let functions = Functions.functions()
        let saveToken = functions.httpsCallable("saveFCMToken")
        
        do {
            let result = try await saveToken.call([
                "token": token,
                "email": email
            ])
            print("✅ FCM Token Firebase'e kaydedildi: \(email)")
            if let data = result.data as? [String: Any] {
                print("📤 Backend yanıtı: \(data)")
            }
        } catch {
            print("❌ FCM Token kaydetme hatası: \(error.localizedDescription)")
        }
    }
    
    /// Gmail Watch API'yi başlat (Firebase Functions üzerinden)
    func setupGmailWatch(accessToken: String, refreshToken: String, email: String) async {
        let functions = Functions.functions()
        let setupWatch = functions.httpsCallable("setupGmailWatch")
        
        do {
            let result = try await setupWatch.call([
                "accessToken": accessToken,
                "refreshToken": refreshToken,
                "email": email
            ])
            print("✅ Gmail Watch başlatıldı: \(email)")
            if let data = result.data as? [String: Any] {
                print("📤 Watch yanıtı: \(data)")
            }
        } catch {
            print("❌ Gmail Watch başlatma hatası: \(error.localizedDescription)")
        }
    }
    
    /// Belirli bir konu için subscribe ol
    func subscribeToTopic(_ topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print("❌ Topic subscribe hatası (\(topic)): \(error.localizedDescription)")
            } else {
                print("✅ Topic'e subscribe olundu: \(topic)")
            }
        }
    }
    
    /// Belirli bir konudan unsubscribe ol
    func unsubscribeFromTopic(_ topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print("❌ Topic unsubscribe hatası (\(topic)): \(error.localizedDescription)")
            } else {
                print("✅ Topic'ten unsubscribe olundu: \(topic)")
            }
        }
    }
    
    /// Gmail hesabı için topic subscribe
    func subscribeToGmailAccount(email: String) {
        // Email'i topic formatına çevir (@ ve . karakterlerini değiştir)
        let topic = email.replacingOccurrences(of: "@", with: "_at_")
                        .replacingOccurrences(of: ".", with: "_dot_")
        subscribeToTopic("gmail_\(topic)")
    }
    
    /// Gmail hesabı için topic unsubscribe
    func unsubscribeFromGmailAccount(email: String) {
        let topic = email.replacingOccurrences(of: "@", with: "_at_")
                        .replacingOccurrences(of: ".", with: "_dot_")
        unsubscribeFromTopic("gmail_\(topic)")
    }
}

// MARK: - MessagingDelegate
extension FCMManager: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        Task { @MainActor in
            self.fcmToken = fcmToken
            self.isRegistered = true
            print("🔄 FCM Token yenilendi: \(fcmToken)")
            
            // Token'ı backend'e gönder (email bilgisi AppViewModel'den gelecek)
            // Şimdilik sadece token'ı kaydet
            UserDefaults.standard.set(fcmToken, forKey: "fcm_token")
        }
    }
}

