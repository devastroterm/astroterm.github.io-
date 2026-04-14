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
        GeometryReader { geo in
            ZStack {
                // MARK: - Arka Plan (Derin Uzay)
                Color(red: 0.02, green: 0.01, blue: 0.08).ignoresSafeArea()
                
                // Nebula parlaması (Onboarding tonunda mavi)
                RadialGradient(
                    colors: [Color.blue.opacity(0.15), Color.clear],
                    center: .center,
                    startRadius: 100,
                    endRadius: 600
                )
                .ignoresSafeArea()

                // Yıldız dekorasyonu
                starsDecoration

                // MARK: - İçerik (Yatay Bölünmüş)
                HStack(spacing: 40) {
                    // SOL TARAF: Başlık ve İstatistikler
                    VStack(alignment: .leading, spacing: 20) {
                        gameOverTitle
                        
                        scoreStatsPanel
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // SAĞ TARAF: Butonlar
                    actionButtons
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, max(40, geo.safeAreaInsets.leading))
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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

    private var gameOverTitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("BAĞLANTI KESİLDİ")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.cyan.opacity(0.6))
                .tracking(3)
            
            Text("GÖREV TAMAMLANAMADI")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .blue.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .blue.opacity(0.5), radius: 10)
            
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                Text("SEVIYE \(viewModel.currentLevel.rawValue)")
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white.opacity(0.4))
        }
    }

    // MARK: - Birleşik Skor ve İstatistik Paneli
    private var scoreStatsPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Ana Skor
            VStack(alignment: .leading, spacing: 2) {
                Text("TOPLAM SKOR")
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(2)
                
                Text("\(viewModel.score)")
                    .font(.system(size: 36, weight: .black, design: .monospaced))
                    .foregroundColor(.orange)
                    .shadow(color: .orange.opacity(0.5), radius: 10)
            }
            
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
            
            // Alt İstatistikler
            HStack(spacing: 30) {
                miniStat(label: "DOĞRU", value: "\(viewModel.enemiesDestroyed)", color: .green)
                miniStat(label: "YANLIŞ", value: "\(viewModel.gameState.wrongAnswers)", color: .red)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
        )
    }

    private func miniStat(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .black))
                .foregroundColor(.white.opacity(0.4))
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
    }

    // MARK: - Aksiyon Butonları
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if viewModel.revivesUsed < 2 {
                Button(action: handleRevive) {
                    HStack {
                        Image(systemName: "bolt.heart.fill")
                        Text("YENIDEN CANLAN")
                            .font(.system(size: 14, weight: .black))
                    }
                    .foregroundColor(.white)
                    .frame(width: 220, height: 44)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.8)))
                    .shadow(color: .green.opacity(0.3), radius: 10)
                }
                .buttonStyle(ScaleButtonStyle())
            }

            Button(action: handleRestart) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("TEKRAR DENE")
                        .font(.system(size: 14, weight: .black))
                }
                .foregroundColor(.white)
                .frame(width: 220, height: 44)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.8)))
                .shadow(color: .orange.opacity(0.3), radius: 10)
            }
            .buttonStyle(ScaleButtonStyle())

            Button(action: onMenu) {
                HStack {
                    Image(systemName: "house.fill")
                    Text("ANA MENÜYE DÖN")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 4)
            }
            .buttonStyle(ScaleButtonStyle())
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
