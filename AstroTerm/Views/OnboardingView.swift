// OnboardingView.swift
// AstroTerm - 3 ekranlı tanıtım rehberi (Türkçe)

import SwiftUI

/// Yeni oyunculara oyun mekaniklerini öğreten 3 ekranlı tanıtım
struct OnboardingView: View {

    var onComplete: () -> Void

    @State private var currentPage: Int = 0

    // MARK: - Sayfa İçerikleri
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "player_ship",
            title: "GÖREV BRİFİNGİ",
            description: "Astro-Dilbilimci olarak görevin, Babil Ağı'ndaki kaosu durdurmak! Galaksiyi kurtarmak için kelimelerin gücünü kullan.",
            highlightColor: Color.blue,
            demoContent: AnyView(WelcomeMissionDemo())
        ),
        OnboardingPage(
            imageName: "player_ship",
            title: "LAZER MUHAREBESİ",
            description: "Ekranın ortasındaki Türkçe kelimenin İngilizce karşılığını taşıyan gemiyi belirle ve kelimeyi vurararak patlat!",
            highlightColor: Color.cyan,
            demoContent: AnyView(CombatTrainingDemo())
        ),
        OnboardingPage(
            imageName: "enemy_b1",
            title: "DÜŞMAN İSTİHBARATI",
            description: "Her seviyede farklı düşmanlar seni bekliyor. Bazıları hızlı, bazıları ise (C2'de) karşı ateş açabiliyor!",
            highlightColor: Color.red,
            demoContent: AnyView(EnemyIntelDemo())
        ),
        OnboardingPage(
            imageName: "char_drone",
            title: "KOZMİK USTALIK",
            description: "Ardışık 5 doğru atış x2 kombo başlatır. Zor anlarda 'Yavaşlatma' yeteneğini kullanmayı unutma!",
            highlightColor: Color.purple,
            demoContent: AnyView(MasteryDemo())
        ),
    ]

    var body: some View {
        ZStack {
            // Arka Plan
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.04, blue: 0.18),
                    Color(red: 0.05, green: 0.08, blue: 0.22),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                VStack(spacing: 0) {
                    // MARK: - Sayfa İçeriği
                    TabView(selection: $currentPage) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                            pageView(page: page, index: index)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)

                    // MARK: - Alt Kontroller
                    bottomControls
                        .padding(.bottom, max(20, geo.safeAreaInsets.bottom))
                }
                .padding(.leading, geo.safeAreaInsets.leading)
                .padding(.trailing, geo.safeAreaInsets.trailing)
            }
        }
    }

    // MARK: - Tek Sayfa Görünümü
    private func pageView(page: OnboardingPage, index: Int) -> some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)

            // Demo İçeriği (Genişletildi)
            page.demoContent
                .frame(maxHeight: 160)
                .padding(.horizontal, 20)
                .layoutPriority(1)

            // Metin
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(1.2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(page.description)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 40) // Sayfa noktalarına değmemesi için alt boşluk artırıldı
        }
    }

    // MARK: - Alt Kontroller
    private var bottomControls: some View {
        VStack(spacing: 12) {
            // Sayfa Noktaları
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .fill(i == currentPage ? Color.white : Color.white.opacity(0.30))
                        .frame(width: i == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.4), value: currentPage)
                }
            }

            // İleri / Başla Butonu
            Button(action: nextOrComplete) {
                HStack(spacing: 10) {
                    Text(currentPage < pages.count - 1 ? "İleri" : "Oyuna Başla!")
                        .font(.system(size: 16, weight: .bold))

                    Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "play.fill")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(width: 180, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            currentPage < pages.count - 1
                            ? Color(red: 0.20, green: 0.45, blue: 0.80)
                            : Color(red: 0.90, green: 0.45, blue: 0.05)
                        )
                )
                .shadow(
                    color: (currentPage < pages.count - 1
                            ? Color.blue : Color(red: 0.90, green: 0.45, blue: 0.05)).opacity(0.50),
                    radius: 12, y: 6
                )
            }
            .buttonStyle(ScaleButtonStyle())

            // Atla
            if currentPage < pages.count - 1 {
                Button(action: { onComplete() }) {
                    Text("Geç")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.40))
                }
            }
        }
    }

    private func nextOrComplete() {
        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentPage += 1
            }
        } else {
            onComplete()
        }
    }
}

// MARK: - Onboarding Sayfa Modeli
struct OnboardingPage {
    let imageName: String
    let title: String
    let description: String
    let highlightColor: Color
    let demoContent: AnyView
}

// MARK: - NEW DEMOS

struct WelcomeMissionDemo: View {
    @State private var scale: CGFloat = 1.0
    var body: some View {
        ZStack {
            ForEach(0..<10) { _ in
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 2, height: 2)
                    .offset(x: .random(in: -150...150), y: .random(in: -60...60))
            }
            
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                    .frame(width: 200, height: 40)
                    .overlay(Text("GÖREV BAŞLIYOR").font(.system(size: 12, weight: .bold)).foregroundColor(.white))
                
                Text("ERİŞİM ONAYLANDI")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.cyan.opacity(0.7))
            }
        }
    }
}

struct CombatTrainingDemo: View {
    @State private var laserActive = false
    @State private var impact = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Türkçe Kelime - Üstte
            Text("elma")
                .font(.system(size: 18, weight: .black))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.15))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                )

            HStack(spacing: 0) {
                // Bizim Gemi - Solda
                Image("ship_beginner")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 65, height: 50)
                    .shadow(color: .cyan.opacity(0.3), radius: 10)
                
                // Lazer Efekti
                ZStack {
                    if laserActive {
                        Rectangle()
                            .fill(LinearGradient(colors: [.cyan, .white, .cyan], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 120, height: 4)
                            .glow(color: .cyan, radius: 4)
                            .transition(.scale(scale: 0, anchor: .leading))
                    }
                }
                .frame(width: 120)

                // Düşman Gemi + İngilizce Kelime - Sağda
                VStack(spacing: 6) {
                    Text("apple")
                        .font(.system(size: 12, weight: .bold))
                        .padding(6)
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.red.opacity(0.2)))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.red.opacity(0.4), lineWidth: 1))
                    
                    Image("enemy_a1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 45, height: 35)
                        .scaleEffect(impact ? 1.4 : 1.0)
                        .opacity(impact ? 0.3 : 1.0)
                        .rotationEffect(.degrees(impact ? 15 : 0))
                }
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                withAnimation(.easeIn(duration: 0.15)) { laserActive = true }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) { impact = true }
                    laserActive = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation { impact = false }
                }
            }
        }
    }
}

struct EnemyIntelDemo: View {
    private let enemies = ["enemy_a1", "enemy_b1", "enemy_c2"]
    @State private var index = 0
    
    var body: some View {
        HStack(spacing: 30) {
            ForEach(0..<3) { i in
                VStack(spacing: 10) {
                    Image(enemies[i])
                        .resizable()
                        .frame(width: 50, height: 40)
                        .scaleEffect(index == i ? 1.2 : 0.8)
                        .opacity(index == i ? 1 : 0.4)
                    
                    Text(i == 0 ? "Hızlı" : (i == 1 ? "Zikzak" : "Silahlı"))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(index == i ? .white : .white.opacity(0.3))
                }
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                withAnimation { index = (index + 1) % 3 }
            }
        }
    }
}

struct MasteryDemo: View {
    @State private var comboScale: CGFloat = 1.0
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                ForEach(0..<3) { i in
                    Image(systemName: "bolt.shield.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                        .glow(color: .green, radius: 5)
                }
            }
            
            Text("x2 COMBO")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.orange)
                .scaleEffect(comboScale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                        comboScale = 1.2
                    }
                }
        }
    }
}

extension View {
    func glow(color: Color, radius: CGFloat) -> some View {
        self.shadow(color: color, radius: radius)
            .shadow(color: color, radius: radius / 2)
    }
}

