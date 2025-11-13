import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Bildirim delegate'ini ayarla
        UNUserNotificationCenter.current().delegate = self
        
        // Remote notification kaydı (APNs için)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // APNs token alındığında backend'e kaydet
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Fly.io backend'e kaydet
        // Email bilgisi AppViewModel'den gelecek, şimdilik token'ı kaydet
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(tokenString, forKey: "apns_device_token")
        print("✅ APNs token alındı: \(tokenString)")
        
        // Eğer aktif hesap varsa, token'ı backend'e kaydet
        NotificationCenter.default.post(
            name: NSNotification.Name("APNsTokenReceived"),
            object: nil,
            userInfo: ["token": deviceToken]
        )
    }
    
    // Remote notification kayıt hatası
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Remote notification kayıt hatası: \(error.localizedDescription)")
    }
    
    // Uygulama ön plandayken bildirim geldiğinde
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Bildirimi göster
        completionHandler([.banner, .sound, .badge])
    }
    
    // Bildirime tıklandığında
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // Mail yenileme bildirimi
        NotificationCenter.default.post(
            name: NSNotification.Name("RefreshMailbox"),
            object: nil,
            userInfo: userInfo
        )
        
        completionHandler()
    }
}
