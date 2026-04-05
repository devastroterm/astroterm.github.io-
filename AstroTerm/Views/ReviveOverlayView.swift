// ReviveOverlayView.swift
// AstroTerm - Oyuncu can kaybedince çıkan "Canlan" teklif ekranı

import SwiftUI

/// Oyuncu hayatını kaybettiğinde oyunun üzerine bindirilir.
/// Geri sayım süresinde reklam izleyerek canlanma teklif edilir.
struct ReviveOverlayView: View {

    // MARK: - Parametreler
    let revivesLeft: Int           // Bu oturumda kalan canlanma hakkı
    let maxRevives: Int            // Oturum başına toplam canlanma hakkı
    var onWatchAd: () -> Void      // Reklam izle → canlan
    var onDecline: () -> Void      // Vazgeç → oyun bitti

    // MARK: - Durum
    @State private var countdown: Int = 5
    @State private var countdownScale: CGFloat = 1.0
    @State private var isLoadingAd: Bool = false
    @State private var ringProgress: Double = 1.0
    @State private var didComplete: Bool = false   // Reklam işlendi mi? Timer'ı kapat

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // MARK: - Arka Plan
            Color.black.opacity(0.82)
                .ignoresSafeArea()

            // Kırmızı kenar parıltısı (tehlike hissi)
            RoundedRectangle(cornerRadius: 0)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.15, blue: 0.05).opacity(0.70),
                            Color.clear,
                            Color(red: 1.0, green: 0.15, blue: 0.05).opacity(0.70),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Başlık
                VStack(spacing: 6) {
                    Text("🚀")
                        .font(.system(size: 48))

                    Text("GEMİN YIKILIYOR!")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.30, blue: 0.10),
                                    Color(red: 1.0, green: 0.70, blue: 0.10),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color(red: 1.0, green: 0.40, blue: 0.10).opacity(0.70), radius: 12)

                    Text("Reklam izle, kaldığın yerden devam et!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 24)

                // MARK: - Geri Sayım Zembereği
                ZStack {
                    // Arka halka
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 8)
                        .frame(width: 90, height: 90)

                    // İlerleme halkası
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            Color(red: 1.0, green: 0.55, blue: 0.10),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: ringProgress)

                    // Sayaç
                    Text("\(countdown)")
                        .font(.system(size: 38, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .scaleEffect(countdownScale)
                        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: countdownScale)
                }
                .padding(.bottom, 28)

                // MARK: - Canlanma Hakkı Göstergesi
                HStack(spacing: 8) {
                    ForEach(0..<maxRevives, id: \.self) { i in
                        Circle()
                            .fill(i < (maxRevives - revivesLeft + 1)
                                  ? Color(red: 1.0, green: 0.55, blue: 0.10)
                                  : Color.white.opacity(0.20))
                            .frame(width: 10, height: 10)
                    }
                    Text("canlanma hakkı")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.45))
                }
                .padding(.bottom, 24)

                // MARK: - Reklam İzle Butonu
                Button(action: handleWatchAd) {
                    ZStack {
                        if isLoadingAd {
                            HStack(spacing: 10) {
                                ProgressView()
                                    .tint(.white)
                                Text("Reklam yükleniyor...")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        } else {
                            HStack(spacing: 12) {
                                Image(systemName: "play.rectangle.fill")
                                    .font(.system(size: 20, weight: .bold))
                                Text("REKLAM İZLE VE DEVAM ET")
                                    .font(.system(size: 16, weight: .black))
                                    .tracking(0.5)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: 320)
                    .frame(height: 58)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.10, green: 0.75, blue: 0.45),
                                        Color(red: 0.05, green: 0.55, blue: 0.30),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(Color.white.opacity(0.30), lineWidth: 1.5)
                            )
                    )
                    .shadow(color: Color(red: 0.10, green: 0.75, blue: 0.45).opacity(0.55), radius: 16, y: 6)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(isLoadingAd)
                .padding(.bottom, 14)

                // MARK: - Vazgeç Butonu
                Button(action: {
                    AdManager.shared.cancelPendingRewardedRequest()
                    onDecline()
                }) {
                    Text("Vazgeç")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.40))
                        .underline()
                }
                .disabled(isLoadingAd)
            }
            .padding(.horizontal, 32)
        }
        .onReceive(timer) { _ in
            // Reklam işlendi veya yükleniyorsa timer'ı durdur
            guard !isLoadingAd, !didComplete else { return }
            if countdown > 0 {
                countdown -= 1
                // Halka animasyonu
                ringProgress = Double(countdown) / 5.0
                // Sayaç sıçrama efekti
                countdownScale = 1.25
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    countdownScale = 1.0
                }
            } else {
                didComplete = true
                AdManager.shared.cancelPendingRewardedRequest()
                onDecline()
            }
        }
    }

    // MARK: - Reklam İzle
    private func handleWatchAd() {
        isLoadingAd = true
        AdManager.shared.showRewardedAd { rewarded in
            DispatchQueue.main.async {
                didComplete = true   // Timer artık onDecline() çağıramaz
                isLoadingAd = false
                if rewarded {
                    onWatchAd()
                } else {
                    // Reklam atlandı veya başarısız
                    onDecline()
                }
            }
        }
    }
}
