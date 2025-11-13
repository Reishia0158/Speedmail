import SwiftUI

@main
struct SpeedmailApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = AppViewModel()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // APNs bildirimleri için AppDelegate kullanılıyor
    }

    var body: some Scene {
        WindowGroup {
            DashboardView(viewModel: viewModel)
                .onAppear {
                    // APNs için device token kaydı (izin kontrolü içinde yapılıyor)
                    APNsManager.shared.registerForPushNotifications()
                    
                    // İlk açılışta hemen tüm hesapları yenile (Spark gibi)
                    Task {
                        await viewModel.refreshAllMailboxes()
                    }
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(oldPhase: oldPhase, newPhase: newPhase)
        }
    }
    
    // Uygulama durumu değişikliklerini yönet
    private func handleScenePhaseChange(oldPhase: ScenePhase, newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            print("✅ Uygulama aktif - Tüm hesaplar yenileniyor")
            // Uygulama ön plana geldiğinde TÜM hesapları yenile (Spark gibi)
            Task {
                await viewModel.refreshAllMailboxes()
                // IMAP bağlantılarını da yeniden başlat (iOS bağlantıyı kesmiş olabilir)
                viewModel.restartIMAPListeners()
            }
            
        case .inactive:
            print("⚠️ Uygulama inactive")
            
        case .background:
            print("🌙 Uygulama arka plana geçti")
            // iOS otomatik olarak Background App Refresh kullanacak
            
        @unknown default:
            break
        }
    }
}
