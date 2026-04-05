// AstroTermApp.swift
// AstroTerm - Uygulama giriş noktası
// Bundle ID: com.galaxywords.app
// Minimum iOS: 16.0

import SwiftUI
import AppTrackingTransparency
import GoogleMobileAds

/// AstroTerm uygulamasının ana giriş noktası
@main
struct AstroTermApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: - Uygulama Başlatma
    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea()
                .preferredColorScheme(.dark)
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIApplication.didBecomeActiveNotification
                    )
                ) { _ in
                    // Uygulama aktif olunca ATT iznini iste (iOS 14.5+ zorunlu)
                    requestTrackingPermission()
                }
        }
    }

    // MARK: - App Tracking Transparency (ATT) İzni
    /// Apple bu diyaloğu göstermeden reklam verisi toplanamaz.
    /// İzin verilmese de uygulama çalışır; sadece hedefsiz reklam gösterilir.
    private func requestTrackingPermission() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }

        // Ekran tam yüklendikten sonra sor (Apple yönergesi)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    // İzin sonucundan bağımsız: AdMob başlat
                    AdManager.setup()
                }
            }
        }
    }

    // MARK: - Görünüm Yapılandırması
    private func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Uygulama Temsilcisi (Ekran Yönü Kilidi)
class AppDelegate: NSObject, UIApplicationDelegate {

    static var orientationLock: UIInterfaceOrientationMask = .landscape

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
