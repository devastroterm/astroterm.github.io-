// LevelUpView.swift
// AstroTerm - Seviye atlama kutlama ekranı

import SwiftUI

/// Yeni seviyeye geçildiğinde gösterilen animasyonlu kutlama ekranı
struct LevelUpView: View {

    let newLevel: CEFRLevel

    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0
    @State private var particlesVisible: Bool = false
    @State private var badgeScale: CGFloat = 0.5
    @State private var textOffset: CGFloat = 20
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            // MARK: - Arka Plan Karartma (Daha hafif)
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { /* Etkileşimi engelle */ }

            // MARK: - Kutlama Patlaması
            celebrationParticles

            // MARK: - Ana İçerik (Glassmorphism & Neon)
            VStack(spacing: 14) {
                
                // Üst Simge ve Neon Parlama (Daha da küçültüldü)
                ZStack {
                    Circle()
                        .fill(levelColor.opacity(0.3))
                        .frame(width: 70, height: 70)
                        .blur(radius: 12)
                        .opacity(glowOpacity)

                    Text("🚀")
                        .font(.system(size: 44))
                        .shadow(color: levelColor.opacity(0.6), radius: 10)
                        .scaleEffect(scale)
                }

                VStack(spacing: 4) {
                    Text("YENİ SEVİYE")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(levelColor)
                        .tracking(3)
                    
                    Text("HEDEFİNİ YÜKSELTTİN!")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .offset(y: textOffset)

                // MERKEZİ ROZET (Daha da küçültüldü)
                ZStack {
                    // Dairesel Dekoratif Halkalar
                    Circle()
                        .stroke(levelColor.opacity(0.3), lineWidth: 1)
                        .frame(width: 80, height: 80)
                        .scaleEffect(glowOpacity > 0 ? 1.1 : 0.8)
                    
                    Circle()
                        .stroke(levelColor.opacity(0.15), lineWidth: 1)
                        .frame(width: 100, height: 100)
                        .scaleEffect(glowOpacity > 0 ? 1.2 : 0.7)

                    // Ana Rozet (Glass)
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 65, height: 65)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [levelColor.opacity(1.0), levelColor.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: levelColor.opacity(0.4), radius: 12)

                    Text(newLevel.rawValue)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: levelColor, radius: 6)
                }
                .scaleEffect(badgeScale)

                // Bilgi Alanı
                VStack(spacing: 8) {
                    Text(levelDescription)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                    
                    // Seviye Detayları
                    HStack(spacing: 8) {
                        statChip(icon: "bolt.fill", text: "\(newLevel.enemyCount) Düşman", color: .orange)
                        statChip(icon: "speedometer", text: "Hız + %15", color: .cyan)
                    }
                }
                .offset(y: textOffset)
                .opacity(opacity)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear, .white.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.0
                            )
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 25, x: 0, y: 12)
            .frame(maxWidth: 340) // Daha da dar bir kart
            .padding(.horizontal, 20)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear { startAnimations() }
    }

    private func statChip(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.1))
        .clipShape(Capsule())
    }

    // MARK: - Parçacık Patlaması
    private var celebrationParticles: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<16, id: \.self) { i in
                    let angle = Double(i) * (360.0 / 16.0)
                    let speed = CGFloat.random(in: 60...160)
                    
                    Circle()
                        .fill(particleColors[i % particleColors.count])
                        .frame(width: CGFloat.random(in: 3...6))
                        .shadow(color: particleColors[i % particleColors.count], radius: 2)
                        .offset(
                            x: particlesVisible ? cos(angle * .pi / 180) * speed : 0,
                            y: particlesVisible ? sin(angle * .pi / 180) * speed : 0
                        )
                        .opacity(particlesVisible ? 0 : 1)
                        .scaleEffect(particlesVisible ? 0.3 : 1.0)
                }
            }
            .position(x: geo.size.width/2, y: geo.size.height/2)
        }
    }

    private let particleColors: [Color] = [.yellow, .cyan, .pink, .green, .orange, .purple]

    private var levelColor: Color {
        switch newLevel {
        case .a1: return Color(red: 0.30, green: 0.85, blue: 0.40)
        case .a2: return Color(red: 0.40, green: 0.90, blue: 0.55)
        case .b1: return Color(red: 0.20, green: 0.60, blue: 1.0)
        case .b2: return Color(red: 0.60, green: 0.30, blue: 1.0)
        case .c1: return Color(red: 1.0, green: 0.40, blue: 0.20)
        case .c2: return Color(red: 1.0, green: 0.80, blue: 0.10)
        }
    }

    private var levelDescription: String {
        switch newLevel {
        case .a1: return "Temel kelimelerle yolculuğun başlıyor."
        case .a2: return "Günlük yaşamda artık daha rahatsın."
        case .b1: return "Orta seviye zorluklara hazırsın."
        case .b2: return "Karmaşık yapıları çözmeye başladın."
        case .c1: return "İleri düzey bir gezgin oldun!"
        case .c2: return "Dilin efendisi, galaksinin hakimi!"
        }
    }

    private func startAnimations() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1.0
            opacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            glowOpacity = 1.0
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) {
            badgeScale = 1.0
            textOffset = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 1.2)) {
                particlesVisible = true
            }
        }
    }
}
