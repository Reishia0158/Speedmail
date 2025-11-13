import Foundation
import BackgroundTasks

/// Arka plan görevlerini yöneten manager
/// Not: Arka plan görevleri iOS'ta sınırlıdır ve sisteme bağlıdır
@MainActor
final class BackgroundTaskManager: ObservableObject {
    static let shared = BackgroundTaskManager()
    
    // Arka plan görevi identifier'ı
    // Bu identifier Info.plist'e eklenmeli
    private let refreshTaskIdentifier = "com.yunuskaynarpinar.Speedmail.mailRefresh"
    
    private init() {}
    
    // Arka plan görevlerini kaydet
    nonisolated func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: refreshTaskIdentifier,
            using: nil
        ) { task in
            Task {
                await BackgroundTaskManager.shared.handleMailRefresh(task: task as! BGAppRefreshTask)
            }
        }
    }
    
    // Arka plan yenileme görevini planla
    func scheduleMailRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        
        // En erken 15 dakika sonra çalıştır (iOS minimum süresi)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Arka plan görevi planlandı: \(request.earliestBeginDate?.description ?? "Bilinmiyor")")
        } catch {
            print("❌ Arka plan görevi planlanamadı: \(error.localizedDescription)")
        }
    }
    
    // Arka plan yenileme görevini iptal et
    func cancelAllBackgroundTasks() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: refreshTaskIdentifier)
        print("🚫 Tüm arka plan görevleri iptal edildi")
    }
    
    // Mail yenileme işlemini gerçekleştir
    private func handleMailRefresh(task: BGAppRefreshTask) async {
        // Görevin maksimum 30 saniye içinde tamamlanması gerekiyor
        task.expirationHandler = {
            print("⚠️ Arka plan görevi zaman aşımına uğradı")
        }
        
        do {
            print("🔄 Arka plan mail yenilemesi başlatıldı")
            
            // AppViewModel üzerinden mail kontrolü yap
            NotificationCenter.default.post(
                name: NSNotification.Name("BackgroundMailRefresh"),
                object: nil
            )
            
            // Yenileme için kısa süre bekle
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 saniye
            
            // Görevi başarılı olarak işaretle
            task.setTaskCompleted(success: true)
            print("✅ Arka plan mail yenilemesi tamamlandı")
            
            // Bir sonraki görevi planla
            await scheduleMailRefresh()
            
        } catch {
            print("❌ Arka plan mail yenilemesi başarısız: \(error.localizedDescription)")
            task.setTaskCompleted(success: false)
        }
    }
    
    // Test amaçlı: Hemen arka plan görevini tetikle (sadece geliştirme)
    func testBackgroundTask() {
        #if DEBUG
        // Bu fonksiyon sadece simulator'da terminal'den çağrılabilir:
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.yunuskaynarpinar.Speedmail.mailRefresh"]
        print("🧪 Arka plan görevi test modu - Terminal komutunu kullanın")
        #endif
    }
}

