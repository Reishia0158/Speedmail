import Foundation
import UserNotifications
import UIKit

/// Apple Push Notification Service yöneticisi
final class APNsManager: NSObject {
    static let shared = APNsManager()
    
    // ngrok backend URL (local development)
    private let backendURL = "https://aidful-jamison-effervescingly.ngrok-free.dev"
    private var deviceToken: String?
    
    private override init() {
        super.init()
    }
    
    /// APNs için device token kaydı yap
    func registerForPushNotifications() {
        // Önce mevcut izin durumunu kontrol et
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                // İzin zaten verilmiş, direkt kayıt yap
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if settings.authorizationStatus == .notDetermined {
                // İzin henüz istenmemiş, iste
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        print("✅ Bildirim izni verildi")
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    } else {
                        print("❌ Bildirim izni reddedildi")
                        if let error = error {
                            print("❌ Hata: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                // İzin reddedilmiş
                print("❌ Bildirim izni reddedilmiş")
            }
        }
    }
    
    /// Device token'ı backend'e kaydet
    func saveDeviceToken(_ token: Data, for email: String) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
        
        print("📱 Device Token: \(tokenString)")
        
        // Backend'e gönder
        Task {
            await registerDeviceToken(email: email, token: tokenString)
        }
    }
    
    /// Device token'ı backend'e kaydet
    private func registerDeviceToken(email: String, token: String) async {
        guard let url = URL(string: "\(backendURL)/register-device") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "deviceToken": token
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ Device token backend'e kaydedildi")
            } else {
                let errorMsg = String(data: data, encoding: .utf8) ?? "Bilinmeyen hata"
                print("❌ Device token kaydetme hatası: \(errorMsg)")
            }
        } catch {
            print("❌ Device token kaydetme hatası: \(error.localizedDescription)")
        }
    }
    
    /// Gmail Watch başlat
    func setupGmailWatch(email: String, accessToken: String, refreshToken: String) async {
        guard let url = URL(string: "\(backendURL)/setup-gmail-watch") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "accessToken": accessToken,
            "refreshToken": refreshToken
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ Gmail watch başlatıldı: \(email)")
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("   History ID: \(json["historyId"] ?? "N/A")")
                }
            } else {
                let errorMsg = String(data: data, encoding: .utf8) ?? "Bilinmeyen hata"
                print("❌ Gmail watch hatası: \(errorMsg)")
            }
        } catch {
            print("❌ Gmail watch hatası: \(error.localizedDescription)")
        }
    }
    
    /// Push notification geldiğinde çağrılır
    func handlePushNotification(userInfo: [AnyHashable: Any]) {
        print("📬 Push notification alındı: \(userInfo)")
        
        // Email ve historyId bilgilerini al
        if let email = userInfo["email"] as? String {
            print("   Email: \(email)")
            
            // Mailbox'ı yenile
            NotificationCenter.default.post(
                name: NSNotification.Name("RefreshMailbox"),
                object: nil,
                userInfo: ["email": email]
            )
        }
    }
}

