// GameOverView.swift
// AstroTerm - Oyun bitti ekranı: istatistikler ve yeniden başlatma

import SwiftUI

/// Oyun bitti ekranı — puan özeti ve seçenekler
struct GameOverView: View {

    @ObservedObject var viewModel: GameViewModel
    var onRestart: () -> Void
    var onMenu: () -> Void
    var onRevive: () -> Void

    // MARK: - Reklam / Ödül Durumu
    @State private var isLoadingAd: Bool = false
    @State private var showRewardedStartBadge: Bool = false

    // MARK: - Animasyon Durumları
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = -40
    @State private var cardOpacity: Double = 0
    @State private var cardOffset: CGFloat = 40
    @State private var buttonsOpacity: Double = 0

    var body: some View {
        ZStack {
            // MARK: - Arka Plan
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.03, blue: 0.22),
                    Color(red: 0.05, green: 0.05, blue: 0.18),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Yıldız parçacıkları (dekoratif)
            starsDecoration

            // MARK: - Landscape düzeni: Sol sütun (başlık + puan) | Sağ sütun (istatistik + butonlar)
            HStack(spacing: 20) {

                // SOL SÜTUN: Başlık + Büyük Puan
                VStack(spacing: 12) {
                    gameOverTitle
                        .opacity(titleOpacity)
                        .offset(y: titleOffset)

                    scoreBlock
                        .opacity(cardOpacity)
                        .offset(y: cardOffset)
                }
                .frame(maxWidth: .infinity)

                // SAĞ SÜTUN: İstatistikler + Butonlar
                VStack(spacing: 12) {
                    statsGridCompact
                        .opacity(cardOpacity)
                        .offset(y: cardOffset)

                    actionButtons
                        .opacity(buttonsOpacity)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                titleOpacity = 1.0
                titleOffset = 0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
                cardOpacity = 1.0
                cardOffset = 0
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.7)) {
                buttonsOpacity = 1.0
            }
        }
    }

    // MARK: - Yıldız Dekorasyonu
    private var starsDecoration: some View {
        GeometryReader { geo in
            ForEach(0..<30, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.2...0.6)))
                    .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height)
                    )
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Başlık
    private var gameOverTitle: some View {
        VStack(spacing: 8) {
            Text("💫")
                .font(.system(size: 56))

            Text("OYUN BİTTİ")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.40, blue: 0.20),
                            Color(red: 1.0, green: 0.70, blue: 0.10),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color(red: 1.0, green: 0.50, blue: 0.10).opacity(0.60), radius: 12)

            Text("Seviye: \(viewModel.currentLevel.rawValue)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.70))
        }
    }

    // MARK: - Sol Sütun: Büyük Puan Bloğu
    private var scoreBlock: some View {
        VStack(spacing: 6) {
            Text("PUAN")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.white.opacity(0.55))
                .tracking(3)

            Text("\(viewModel.score)")
                .font(.system(size: 48, weight: .black, design: .monospaced))
                .foregroundColor(Color(red: 1.0, green: 0.90, blue: 0.20))
                .shadow(color: Color(red: 1.0, green: 0.80, blue: 0.10).opacity(0.50), radius: 10)

            if viewModel.score == viewModel.highScore && viewModel.score > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.10))
                        .font(.system(size: 13))
                    Text("Yeni Rekor!")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.90, blue: 0.30))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.06, green: 0.08, blue: 0.22).opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.40), radius: 16)
    }

    // MARK: - Sağ Sütun: Kompakt İstatistik Grid'i
    private var statsGridCompact: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 8) {
            statCell(
                icon: "checkmark.circle.fill",
                color: Color(red: 0.20, green: 0.80, blue: 0.35),
                value: "\(viewModel.enemiesDestroyed)",
                label: "Doğru"
            )
            statCell(
                icon: "xmark.circle.fill",
                color: Color(red: 0.90, green: 0.25, blue: 0.15),
                value: "\(viewModel.gameState.wrongAnswers)",
                label: "Yanlış"
            )
            statCell(
                icon: "percent",
                color: Color(red: 0.30, green: 0.65, blue: 1.0),
                value: String(format: "%.0f%%", viewModel.accuracy),
                label: "Doğruluk"
            )
            statCell(
                icon: "book.fill",
                color: Color(red: 0.60, green: 0.35, blue: 1.0),
                value: "\(viewModel.totalWordsLearned)",
                label: "Öğrenilen"
            )
            statCell(
                icon: "flag.fill",
                color: Color(red: 1.0, green: 0.55, blue: 0.10),
                value: "\(viewModel.wavesCompleted)",
                label: "Dalga"
            )
            statCell(
                icon: "crown.fill",
                color: Color(red: 1.0, green: 0.80, blue: 0.10),
                value: "\(viewModel.highScore)",
                label: "Rekor"
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.06, green: 0.08, blue: 0.22).opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.40), radius: 16)
    }

    private func statCell(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16))
            Text(value)
                .font(.system(size: 15, weight: .black, design: .monospaced))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(Color.white.opacity(0.50))
                .tracking(1)
        }
    }

    // MARK: - Aksiyon Butonları
    private var actionButtons: some View {
        VStack(spacing: 10) {

            if viewModel.revivesUsed < 2 {
                // ── Reklam İzle Can Kazan ──
                Button(action: handleRevive) {
                    ZStack {
                        if isLoadingAd && showRewardedStartBadge {
                            HStack(spacing: 8) {
                                ProgressView().tint(.white)
                                Text("Yükleniyor...")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        } else {
                            HStack(spacing: 10) {
                                Image(systemName: "play.tv.fill")
                                    .font(.system(size: 18, weight: .bold))
                                Text("CAN KAZAN")
                                    .font(.system(size: 18, weight: .black))
                                    .tracking(1)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.15, green: 0.85, blue: 0.35),
                                        Color(red: 0.05, green: 0.50, blue: 0.15),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color(red: 0.15, green: 0.85, blue: 0.35).opacity(0.50), radius: 12, y: 6)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(isLoadingAd)
            }

            // ── Tekrar Oyna ──
            Button(action: handleRestart) {
                ZStack {
                    if isLoadingAd && !showRewardedStartBadge {
                        HStack(spacing: 8) {
                            ProgressView().tint(.white)
                            Text("Hazırlanıyor...")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    } else {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .bold))
                            Text("TEKRAR OYNA")
                                .font(.system(size: 18, weight: .black))
                                .tracking(2)
                        }
                        .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.45, blue: 0.05),
                                    Color(red: 0.65, green: 0.25, blue: 0.02),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color(red: 0.90, green: 0.45, blue: 0.05).opacity(0.50), radius: 12, y: 6)
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(isLoadingAd)

            // ── Ana Menü ──
            Button(action: onMenu) {
                HStack(spacing: 10) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("ANA MENÜ")
                        .font(.system(size: 16, weight: .bold))
                        .tracking(2)
                }
                .foregroundColor(Color.white.opacity(0.80))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(isLoadingAd)
        }
    }

    // MARK: - Tekrar Oyna (Geçiş Reklamlı)
    private func handleRestart() {
        isLoadingAd = true
        AdManager.shared.showInterstitialAd {
            DispatchQueue.main.async {
                isLoadingAd = false
                onRestart()
            }
        }
    }

    // MARK: - Revive (Ödüllü Reklam)
    private func handleRevive() {
        isLoadingAd = true
        showRewardedStartBadge = true
        AdManager.shared.showRewardedAd { success in
            DispatchQueue.main.async {
                isLoadingAd = false
                showRewardedStartBadge = false
                if success {
                    onRevive()
                }
            }
        }
    }

}
