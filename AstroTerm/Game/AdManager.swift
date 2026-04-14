// AdManager.swift
// AstroTerm - Merkezi Reklam Yöneticisi (GoogleMobileAds SDK)

import Foundation
import UIKit
import GoogleMobileAds

final class AdManager: NSObject {

    static let shared = AdManager()
    private override init() { super.init() }

    // MARK: - Reklam Birimi ID'leri
    enum AdUnitID {
        static let rewardedTest     = "ca-app-pub-3940256099942544/1712485313"
        static let interstitialTest = "ca-app-pub-3940256099942544/4411468910"

        // ⚠️ rewardedProd: AdMob konsolundaki Ödüllü Reklam birimi ID'si
        static let rewardedProd     = "ca-app-pub-7827833155145240/1673721117"
        
        // ⚠️ interstitialProd: Buraya Geçiş Reklamı (Interstitial) ID'sini girin
        // Not: Ödüllü reklam ID'sini buraya yazmak çakışmaya neden olabilir.
        static let interstitialProd = "" 

        #if DEBUG
        static let rewarded     = rewardedTest
        static let interstitial = interstitialTest
        #else
        static let rewarded     = rewardedProd
        static let interstitial = interstitialProd
        #endif
    }

    // MARK: - Yüklü Reklamlar
    private var loadedRewardedAd: GADRewardedAd?
    private var loadedInterstitialAd: GADInterstitialAd?

    // Aktif gösterim callback'leri
    private var rewardedCompletion: ((Bool) -> Void)?
    private var interstitialCompletion: (() -> Void)?
    private var rewardedDidEarnReward = false

    // Reklam henüz hazır değilken gelen bekleyen istek
    private var pendingRewardedCompletion: ((Bool) -> Void)?
    
    /// En son alınan reklam hatası (Hata ayıklama için)
    private(set) var lastErrorMessage: String? = nil

    // MARK: - SDK Başlatma
    static func setup() {
        GADMobileAds.sharedInstance().start { _ in
            AdManager.shared.preloadRewardedAd()
            
            // Sadece bir ID tanımlıysa Interstitial yüklemeyi atla (ID çakışmasını önlemek için)
            if !AdUnitID.interstitial.isEmpty && AdUnitID.interstitial != AdUnitID.rewarded {
                AdManager.shared.preloadInterstitialAd()
            }
        }
    }

    // MARK: - Ödüllü Reklam Ön Yükleme
    func preloadRewardedAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: AdUnitID.rewarded, request: request) { [weak self] ad, error in
            guard let self else { return }

            if let error {
                let msg = "[AdMob] Rewarded yükleme hatası: \(error.localizedDescription)"
                print(msg)
                self.lastErrorMessage = error.localizedDescription
                
                // Bekleyen istek varsa hata bildir
                if let cb = self.pendingRewardedCompletion {
                    self.pendingRewardedCompletion = nil
                    DispatchQueue.main.async { cb(false) }
                }
                // 30 sn sonra tekrar dene
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    self.preloadRewardedAd()
                }
                return
            }

            self.lastErrorMessage = nil

            self.loadedRewardedAd = ad
            self.loadedRewardedAd?.fullScreenContentDelegate = self
            print("[AdMob] Rewarded reklam hazır")

            // showRewardedAd() çağrıldığında reklam yoktu — şimdi otomatik göster
            if let cb = self.pendingRewardedCompletion {
                self.pendingRewardedCompletion = nil
                
                if let vc = self.rootViewController(),
                   let readyAd = self.loadedRewardedAd {
                    DispatchQueue.main.async {
                        self.presentRewardedAd(readyAd, from: vc, completion: cb)
                    }
                } else {
                    // VC bulunamadıysa veya reklam kaybolduysa
                    print("[AdMob] Rewarded reklam hazır ama gösterilemiyor (VC yok)")
                    DispatchQueue.main.async { cb(false) }
                }
            }
        }
    }

    private var pendingInterstitialCompletion: (() -> Void)?

    // MARK: - Geçiş Reklamı Ön Yükleme
    func preloadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: AdUnitID.interstitial, request: request) { [weak self] ad, error in
            guard let self else { return }
            
            if let error {
                print("[AdMob] Interstitial yükleme hatası: \(error.localizedDescription)")
                self.lastErrorMessage = error.localizedDescription
                
                if let cb = self.pendingInterstitialCompletion {
                    self.pendingInterstitialCompletion = nil
                    DispatchQueue.main.async { cb() }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    self.preloadInterstitialAd()
                }
                return
            }
            self.lastErrorMessage = nil
            self.loadedInterstitialAd = ad
            self.loadedInterstitialAd?.fullScreenContentDelegate = self
            print("[AdMob] Interstitial reklam hazır")
            
            if let cb = self.pendingInterstitialCompletion {
                self.pendingInterstitialCompletion = nil
                
                if let vc = self.rootViewController(),
                   let readyAd = self.loadedInterstitialAd {
                    self.interstitialCompletion = cb
                    DispatchQueue.main.async {
                        readyAd.present(fromRootViewController: vc)
                    }
                } else {
                    DispatchQueue.main.async { cb() }
                }
            }
        }
    }

    // MARK: - Ödüllü Reklam Göster
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard let vc = rootViewController() else {
            completion(false)
            return
        }

        if let ad = loadedRewardedAd {
            // Reklam hazır — hemen göster
            presentRewardedAd(ad, from: vc, completion: completion)
        } else {
            // Reklam henüz yüklenmemiş — yüklenince otomatik göster
            print("[AdMob] Rewarded reklam yükleniyor, lütfen bekleyin...")
            pendingRewardedCompletion = completion
            preloadRewardedAd()
            
            // ── TIMEOUT ──
            // Eğer reklam 7 saniye içinde hazır olmazsa UI kilitlenmesin diye hata döndür
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) { [weak self] in
                guard let self = self else { return }
                if let cb = self.pendingRewardedCompletion {
                    print("[AdMob] Rewarded timeout süresi aşıldı.")
                    self.lastErrorMessage = "Bağlantı zaman aşımına uğradı (AdMob Timeout)"
                    self.pendingRewardedCompletion = nil
                    cb(false)
                }
            }
        }
    }

    private func presentRewardedAd(_ ad: GADRewardedAd, from vc: UIViewController, completion: @escaping (Bool) -> Void) {
        rewardedCompletion = completion
        rewardedDidEarnReward = false
        ad.present(fromRootViewController: vc) { [weak self] in
            self?.rewardedDidEarnReward = true
        }
    }

    // MARK: - Geçiş Reklamı Göster
    func showInterstitialAd(completion: @escaping () -> Void) {
        guard let vc = rootViewController() else {
            completion()
            return
        }

        if let ad = loadedInterstitialAd {
            interstitialCompletion = completion
            ad.present(fromRootViewController: vc)
        } else {
            print("[AdMob] Interstitial reklam yükleniyor, lütfen bekleyin...")
            pendingInterstitialCompletion = completion
            preloadInterstitialAd()
            
            // Eğer reklam 2.5 saniye içinde hazır olmazsa Timeout ile oyunu başlat
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                guard let self = self else { return }
                if let cb = self.pendingInterstitialCompletion {
                    print("[AdMob] Interstitial timeout süresi aşıldı, reklam atlanıyor...")
                    self.pendingInterstitialCompletion = nil
                    cb()
                }
            }
        }
    }

    // MARK: - Bekleyen İsteği İptal Et
    /// Revive overlay kapandığında (kullanıcı Vazgeç'e bastı) bekleyen isteği temizle
    func cancelPendingRewardedRequest() {
        pendingRewardedCompletion = nil
    }

    // MARK: - Yardımcılar
    private func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first(where: \.isKeyWindow)?
            .rootViewController
    }

    // MARK: - Hata Teşhis (Debug)
    func showAdDebugMessage(from vc: UIViewController? = nil) {
        guard let currentVC = vc ?? rootViewController(),
              let error = lastErrorMessage else { return }
        
        let alert = UIAlertController(
            title: "Reklam Yüklenemedi",
            message: "Hata detayı: \(error)\n\n(Bu mesaj sadece teşhis içindir, uygulama doğrulanınca reklamlar gelecektir.)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        currentVC.present(alert, animated: true)
    }
}

// MARK: - GADFullScreenContentDelegate
extension AdManager: GADFullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if ad is GADRewardedAd {
            loadedRewardedAd = nil
            preloadRewardedAd()
            let cb = rewardedCompletion
            let earned = rewardedDidEarnReward
            rewardedCompletion = nil
            DispatchQueue.main.async { cb?(earned) }
        } else if ad is GADInterstitialAd {
            loadedInterstitialAd = nil
            preloadInterstitialAd()
            let cb = interstitialCompletion
            interstitialCompletion = nil
            DispatchQueue.main.async { cb?() }
        }
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[AdMob] Reklam gösterilemedi: \(error.localizedDescription)")
        if ad is GADRewardedAd {
            let cb = rewardedCompletion
            rewardedCompletion = nil
            DispatchQueue.main.async { cb?(false) }
            preloadRewardedAd()
        } else if ad is GADInterstitialAd {
            let cb = interstitialCompletion
            interstitialCompletion = nil
            DispatchQueue.main.async { cb?() }
            preloadInterstitialAd()
        }
    }
}
