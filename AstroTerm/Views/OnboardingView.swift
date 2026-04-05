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
            emoji: "🎯",
            title: "Türkçe kelimeyi bul!",
            description: "Ekranın ortasında bir Türkçe kelime görürsün. Bu kelimeyi İngilizce karşılığını taşıyan düşman gemisini hedeflemelisin!",
            highlightColor: Color(red: 0.30, green: 0.70, blue: 1.0),
            demoContent: AnyView(TurkishWordDemo())
        ),
        OnboardingPage(
            emoji: "🚀",
            title: "Doğru gemiyi vur!",
            description: "Düşman gemiler sağdan gelir. Her gemide bir İngilizce kelime vardır. Sadece doğru kelimeyi taşıyan gemiyi vur!",
            highlightColor: Color(red: 0.20, green: 0.85, blue: 0.40),
            demoContent: AnyView(EnemyShipDemo())
        ),
        OnboardingPage(
            emoji: "❤️",
            title: "3 canın var, dikkatli ol!",
            description: "Yanlış gemiyi vurmak veya düşmanın üssüne ulaşması 1 can kaybettirir. 5 doğru üst üste → 2x puan komobusu!",
            highlightColor: Color(red: 0.90, green: 0.20, blue: 0.20),
            demoContent: AnyView(LivesDemo())
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
                    .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Tek Sayfa Görünümü
    private func pageView(page: OnboardingPage, index: Int) -> some View {
        VStack(spacing: 6) {
            Spacer(minLength: 10)

            // Emoji İkon
            Text(page.emoji)
                .font(.system(size: 40))
                .shadow(color: page.highlightColor.opacity(0.50), radius: 16)

            // Demo İçeriği
            page.demoContent
                .frame(maxHeight: 110)
                .padding(.horizontal, 20)
                .layoutPriority(1)

            // Metin
            VStack(spacing: 6) {
                Text(page.title)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [page.highlightColor, page.highlightColor.opacity(0.70)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .shadow(color: page.highlightColor.opacity(0.40), radius: 8)
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)

                Text(page.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 24)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 10)
        }
        .padding(.vertical, 10)
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
    let emoji: String
    let title: String
    let description: String
    let highlightColor: Color
    let demoContent: AnyView
}

// MARK: - Demo: Türkçe Kelime Paneli
struct TurkishWordDemo: View {
    @State private var glow = false

    var body: some View {
        VStack(spacing: 10) {
            Text("Türkçe Kelime:")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.white.opacity(0.55))

            HStack(spacing: 16) {
                Image(systemName: "arrow.down")
                    .foregroundColor(Color(red: 0.30, green: 0.70, blue: 1.0))
                    .font(.system(size: 20, weight: .bold))

                Text("elma")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(red: 0.08, green: 0.12, blue: 0.30).opacity(0.90))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(
                                        Color(red: 0.30, green: 0.65, blue: 1.0).opacity(glow ? 1.0 : 0.40),
                                        lineWidth: 2
                                    )
                            )
                    )
                    .shadow(
                        color: Color(red: 0.30, green: 0.65, blue: 1.0).opacity(glow ? 0.60 : 0.20),
                        radius: glow ? 12 : 4
                    )

                Image(systemName: "arrow.down")
                    .foregroundColor(Color(red: 0.30, green: 0.70, blue: 1.0))
                    .font(.system(size: 20, weight: .bold))
            }

            Text("= apple (İngilizce)")
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.50))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }
}

// MARK: - Demo: Düşman Gemiler
struct EnemyShipDemo: View {
    @State private var offset: CGFloat = 100
    @State private var highlighted = false

    var body: some View {
        ZStack {
            // Düşman gemileri
            HStack(spacing: 16) {
                // Yanlış kelime gemisi
                shipLabel(word: "house", correct: false)
                    .offset(x: offset)

                // Doğru kelime gemisi
                shipLabel(word: "apple", correct: true)
                    .offset(x: offset)
                    .scaleEffect(highlighted ? 1.10 : 1.0)
                    .shadow(
                        color: Color(red: 0.20, green: 0.90, blue: 0.40).opacity(highlighted ? 0.70 : 0),
                        radius: 12
                    )

                // Yanlış kelime gemisi
                shipLabel(word: "car", correct: false)
                    .offset(x: offset)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                offset = 0
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(1.4)) {
                highlighted = true
            }
        }
    }

    private func shipLabel(word: String, correct: Bool) -> some View {
        VStack(spacing: 4) {
            // Basit gemi şekli
            RoundedRectangle(cornerRadius: 8)
                .fill(correct
                      ? Color(red: 0.20, green: 0.60, blue: 0.80)
                      : Color(red: 0.55, green: 0.18, blue: 0.75))
                .frame(width: 55, height: 28)
                .overlay(
                    // Nozul
                    Triangle()
                        .fill(correct
                              ? Color(red: 0.15, green: 0.45, blue: 0.65)
                              : Color(red: 0.40, green: 0.12, blue: 0.60))
                        .frame(width: 12, height: 20)
                        .offset(x: 28)
                )

            // Kelime balonu
            Text(word)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.05, green: 0.05, blue: 0.20).opacity(0.90))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(
                                    correct
                                        ? Color(red: 0.30, green: 1.0, blue: 0.50).opacity(0.80)
                                        : Color.white.opacity(0.30),
                                    lineWidth: correct ? 1.5 : 0.5
                                )
                        )
                )
        }
    }
}

// MARK: - Demo: Canlar
struct LivesDemo: View {
    @State private var livesLost = 0

    var body: some View {
        VStack(spacing: 20) {
            // Can ikonları
            HStack(spacing: 14) {
                ForEach(0..<3) { i in
                    Image(systemName: i < (3 - livesLost) ? "shield.fill" : "shield")
                        .font(.system(size: 36))
                        .foregroundColor(
                            i < (3 - livesLost)
                                ? Color(red: 0.20, green: 0.80, blue: 0.35)
                                : Color.gray.opacity(0.35)
                        )
                        .shadow(
                            color: i < (3 - livesLost)
                                ? Color(red: 0.20, green: 0.80, blue: 0.35).opacity(0.50)
                                : .clear,
                            radius: 8
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: livesLost)
                }
            }

            // Kombo göstergesi
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.10))
                Text("5 doğru = x2 KOMBO!")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.90, blue: 0.20))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(red: 0.30, green: 0.15, blue: 0.05).opacity(0.80))
                    .overlay(
                        Capsule()
                            .strokeBorder(Color(red: 1.0, green: 0.80, blue: 0.10).opacity(0.60), lineWidth: 1.5)
                    )
            )
        }
        .onAppear {
            // Can kaybı animasyonu (demo amaçlı)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { livesLost = 1 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation { livesLost = 0 }
            }
        }
    }
}

// MARK: - Üçgen Şekli
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
