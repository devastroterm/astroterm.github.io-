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

        // ⚠️ rewardedProd: AdMob konsolundaki Rewarded Ad Unit ID'ni gir
        //    Format: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY  (ortada / olmalı)
        static let rewardedProd     = "ca-app-pub-7827833155145240/BURAYA_REWARDED_ID"
        static let interstitialProd = "ca-app-pub-7827833155145240/1673721117"

        #if DEBUG
        static let rewarded     = rewardedTest
        static let interstitial = interstitialTest
        #else
        static let rewarded     = rewardedProd
        static let interstitial = interstitialProd
        #endif
    }

    // MARK: - Yüklü Reklamlar
    private var loadedRewardedAd: RewardedAd?
    private var loadedInterstitialAd: InterstitialAd?

    // Aktif gösterim callback'leri
    private var rewardedCompletion: ((Bool) -> Void)?
    private var interstitialCompletion: (() -> Void)?
    private var rewardedDidEarnReward = false

    // Reklam henüz hazır değilken gelen bekleyen istek
    private var pendingRewardedCompletion: ((Bool) -> Void)?

    // MARK: - SDK Başlatma
    static func setup() {
        MobileAds.shared.start { _ in
            AdManager.shared.preloadRewardedAd()
            AdManager.shared.preloadInterstitialAd()
        }
    }

    // MARK: - Ödüllü Reklam Ön Yükleme
    func preloadRewardedAd() {
        let request = Request()
        RewardedAd.load(with: AdUnitID.rewarded, request: request) { [weak self] ad, error in
            guard let self else { return }

            if let error {
                print("[AdMob] Rewarded yükleme hatası: \(error.localizedDescription)")
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

            self.loadedRewardedAd = ad
            self.loadedRewardedAd?.fullScreenContentDelegate = self
            print("[AdMob] Rewarded reklam hazır")

            // showRewardedAd() çağrıldığında reklam yoktu — şimdi otomatik göster
            if let cb = self.pendingRewardedCompletion,
               let vc = self.rootViewController(),
               let readyAd = self.loadedRewardedAd {
                self.pendingRewardedCompletion = nil
                DispatchQueue.main.async {
                    self.presentRewardedAd(readyAd, from: vc, completion: cb)
                }
            }
        }
    }

    private var pendingInterstitialCompletion: (() -> Void)?

    // MARK: - Geçiş Reklamı Ön Yükleme
    func preloadInterstitialAd() {
        let request = Request()
        InterstitialAd.load(with: AdUnitID.interstitial, request: request) { [weak self] ad, error in
            guard let self else { return }
            
            if let error {
                print("[AdMob] Interstitial yükleme hatası: \(error.localizedDescription)")
                if let cb = self.pendingInterstitialCompletion {
                    self.pendingInterstitialCompletion = nil
                    DispatchQueue.main.async { cb() }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    self.preloadInterstitialAd()
                }
                return
            }
            self.loadedInterstitialAd = ad
            self.loadedInterstitialAd?.fullScreenContentDelegate = self
            print("[AdMob] Interstitial reklam hazır")
            
            if let cb = self.pendingInterstitialCompletion,
               let vc = self.rootViewController(),
               let readyAd = self.loadedInterstitialAd {
                self.pendingInterstitialCompletion = nil
                self.interstitialCompletion = cb
                DispatchQueue.main.async {
                    readyAd.present(from: vc)
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
            // completion(false) ÇAĞIRMA — yükleme spinner görünür kalsın
            print("[AdMob] Rewarded reklam yükleniyor, lütfen bekleyin...")
            pendingRewardedCompletion = completion
            preloadRewardedAd()
        }
    }

    private func presentRewardedAd(_ ad: RewardedAd, from vc: UIViewController, completion: @escaping (Bool) -> Void) {
        rewardedCompletion = completion
        rewardedDidEarnReward = false
        ad.present(from: vc) { [weak self] in
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
            ad.present(from: vc)
        } else {
            print("[AdMob] Interstitial reklam yükleniyor, lütfen bekleyin...")
            pendingInterstitialCompletion = completion
            preloadInterstitialAd()
            
            // Eğer reklam 2 saniye içinde hazır olmazsa Timeout ile oyunu başlat
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
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
}

// MARK: - FullScreenContentDelegate
extension AdManager: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        if ad is RewardedAd {
            loadedRewardedAd = nil
            preloadRewardedAd()
            let cb = rewardedCompletion
            let earned = rewardedDidEarnReward
            rewardedCompletion = nil
            DispatchQueue.main.async { cb?(earned) }
        } else if ad is InterstitialAd {
            loadedInterstitialAd = nil
            preloadInterstitialAd()
            let cb = interstitialCompletion
            interstitialCompletion = nil
            DispatchQueue.main.async { cb?() }
        }
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[AdMob] Reklam gösterilemedi: \(error.localizedDescription)")
        if ad is RewardedAd {
            let cb = rewardedCompletion
            rewardedCompletion = nil
            DispatchQueue.main.async { cb?(false) }
            preloadRewardedAd()
        } else if ad is InterstitialAd {
            let cb = interstitialCompletion
            interstitialCompletion = nil
            DispatchQueue.main.async { cb?() }
            preloadInterstitialAd()
        }
    }
}
