// MainMenuView.swift
// AstroTerm - Ana menü ekranı: animasyonlu gezegen, başlık, oyna butonu

import SwiftUI

// MARK: - Paylaşılan Stil (Diğer ekranlar için de görünür)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Yıldız verisi yapısı
struct StarInfo: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
}

/// Oyunun ana menü ekranı
struct MainMenuView: View {

    @ObservedObject var viewModel: GameViewModel
    var onPlay: () -> Void

    // MARK: - Animasyon Durumları
    @State private var titleScale: CGFloat = 0.7
    @State private var titleOpacity: Double = 0
    @State private var planetRotation: Double = 0
    @State private var planetScale: CGFloat = 0.85
    @State private var starsOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.9
    @State private var buttonOpacity: Double = 0
    @State private var orbitAngle1: Double = 0
    @State private var orbitAngle2: Double = 0
    
    // Ses kontrolleri için görünürlük durumu
    @State private var showVolumeSlider: Bool = false
    @State private var showCredits: Bool = false

    // MARK: - Stabil Yıldız Pozisyonları
    // @State kullanarak yıldızların her render'da veya view re-init'te yer değiştirmesini engelliyoruz.
    @State private var starPositions: [StarInfo] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: - Arka Plan
                spaceBackground(size: geo.size)

                // MARK: - Yıldızlar
                starsLayer(size: geo.size)
                    .opacity(starsOpacity)

                // MARK: - Gezegen (Sol Alt)
                planetView(size: geo.size)

                // MARK: - Yörünge Nesneleri
                orbitingObjects(center: CGPoint(x: geo.size.width * 0.30, y: geo.size.height * 0.70))

                // MARK: - Başlık
                VStack(spacing: 0) {
                    titleSection
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)

                    Spacer()

                    // MARK: - Oyna Butonu + Yüksek Puan
                    bottomSection
                        .scaleEffect(buttonScale)
                        .opacity(buttonOpacity)
                }
                .padding(.top, 60)
                .padding(.bottom, 80) // Home Indicator'dan daha uzağa, daha yukarı taşı

                // MARK: - Ses Ayarları (Sağ Üst)
                VStack {
                    HStack {
                        Spacer()
                        soundSettingsStack
                            .padding(.top, 56)
                            .padding(.trailing, 20)
                    }
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { 
            // Yıldızları sadece bir kez oluştur
            if starPositions.isEmpty {
                generateStars()
            }
            startAnimations()
            viewModel.startMusic()
        }
    }

    // MARK: - Yıldız Üretimi
    private func generateStars() {
        var newStars: [StarInfo] = []
        for _ in 0..<80 {
            newStars.append(StarInfo(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.3...0.9)
            ))
        }
        starPositions = newStars
    }

    // MARK: - Ses Ayarları Paneli
    private var soundSettingsStack: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack(spacing: 12) {
                if showVolumeSlider {
                    // Modern Volume Slider
                    HStack(spacing: 8) {
                        Image(systemName: "music.note")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Slider(value: Binding(
                            get: { Double(viewModel.musicVolume) },
                            set: { viewModel.musicVolume = Float($0) }
                        ), in: 0...1)
                        .tint(Color(red: 0.40, green: 0.80, blue: 1.0))
                        .frame(width: 120)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                            .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }

                // Toggle Button
                Button(action: {
                    withAnimation(.spring()) {
                        showVolumeSlider.toggle()
                    }
                }) {
                    Image(systemName: viewModel.isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(viewModel.isMusicEnabled
                            ? Color(red: 0.40, green: 0.80, blue: 1.0)
                            : Color.white.opacity(0.40))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.45))
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            viewModel.isMusicEnabled
                                                ? Color(red: 0.40, green: 0.80, blue: 1.0).opacity(0.50)
                                                : Color.white.opacity(0.15),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            if showVolumeSlider {
                // SFX Toggle (Hızlı erişim)
                Button(action: {
                    viewModel.toggleSfx()
                }) {
                    HStack {
                        Text("SFX")
                            .font(.system(size: 10, weight: .bold))
                        Image(systemName: viewModel.isSfxEnabled ? "bolt.fill" : "bolt.slash.fill")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(viewModel.isSfxEnabled ? .yellow : .white.opacity(0.3))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.black.opacity(0.4)))
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Uzay Arka Planı
    private func spaceBackground(size: CGSize) -> some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.10, green: 0.04, blue: 0.18), location: 0),
                .init(color: Color(red: 0.07, green: 0.07, blue: 0.22), location: 0.45),
                .init(color: Color(red: 0.05, green: 0.11, blue: 0.24), location: 1.0),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Yıldız Katmanı
    private func starsLayer(size: CGSize) -> some View {
        // drawingGroup() ekleyerek yoğun render yükünü GPU'ya taşıyoruz ve titremeyi önlüyoruz.
        ZStack {
            ForEach(starPositions) { star in
                Circle()
                    .fill(Color.white.opacity(star.opacity))
                    .frame(width: star.size, height: star.size)
                    .position(x: star.x * size.width, y: star.y * size.height)
            }
        }
        .drawingGroup()
    }

    // MARK: - Gezegen Görünümü
    private func planetView(size: CGSize) -> some View {
        ZStack {
            // Dış hale
            Circle()
                .fill(Color(red: 0.35, green: 0.15, blue: 0.55).opacity(0.25))
                .frame(width: 420, height: 420)

            // Ana gezegen
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.45, green: 0.38, blue: 0.55),
                            Color(red: 0.25, green: 0.18, blue: 0.38),
                            Color(red: 0.12, green: 0.08, blue: 0.22),
                        ]),
                        center: .center,
                        startRadius: 30,
                        endRadius: 200
                    )
                )
                .frame(width: 360, height: 360)
                .overlay(
                    // Kraterleri
                    ZStack {
                        craterCircle(x: -60, y: 30, r: 35, alpha: 0.35)
                        craterCircle(x: 40, y: -50, r: 20, alpha: 0.30)
                        craterCircle(x: -20, y: -80, r: 45, alpha: 0.28)
                        craterCircle(x: 80, y: 60, r: 15, alpha: 0.32)
                        craterCircle(x: -90, y: -20, r: 25, alpha: 0.25)
                    }
                )
                .overlay(
                    // Yüzey parlaması
                    Ellipse()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 180, height: 100)
                        .offset(x: -30, y: -70)
                )
                .scaleEffect(planetScale)
                .shadow(color: Color(red: 0.50, green: 0.25, blue: 0.80).opacity(0.35), radius: 40)
        }
        .position(x: -30, y: size.height * 0.78)
    }

    private func craterCircle(x: CGFloat, y: CGFloat, r: CGFloat, alpha: Double) -> some View {
        Circle()
            .fill(Color.black.opacity(alpha))
            .frame(width: r * 2, height: r * 2)
            .offset(x: x, y: y)
    }

    // MARK: - Yörünge Nesneleri (Dekoratif)
    private func orbitingObjects(center: CGPoint) -> some View {
        ZStack {
            // Küçük uydu 1
            Circle()
                .fill(Color(red: 0.30, green: 0.70, blue: 1.0))
                .frame(width: 12, height: 12)
                .offset(x: 160 * cos(orbitAngle1), y: 70 * sin(orbitAngle1))
                .position(center)

            // Küçük uydu 2 (farklı renk)
            Circle()
                .fill(Color(red: 1.0, green: 0.55, blue: 0.15))
                .frame(width: 8, height: 8)
                .offset(x: 200 * cos(orbitAngle2), y: 90 * sin(orbitAngle2))
                .position(center)
        }
    }

    // MARK: - Başlık Bölümü
    private var titleSection: some View {
        VStack(spacing: 12) {
            // ASTRO + TERM birbirine yakın
            VStack(spacing: 2) {
                // Astro kelimesi
                HStack(spacing: 0) {
                    Text("ASTRO")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.40, green: 0.80, blue: 1.0),
                                    Color(red: 0.60, green: 0.40, blue: 1.0),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                // TERM kelimesi
                HStack(spacing: 0) {
                    Text("TERM")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.15),
                                    Color(red: 1.0, green: 0.55, blue: 0.10),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color(red: 1.0, green: 0.60, blue: 0.10).opacity(0.60), radius: 14)
                }
            }

            // Alt başlık
            Text("İngilizce-Türkçe Kelime Macerası")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.70))
                .tracking(1.5)

            // Yıldız dekorasyonu
            HStack(spacing: 6) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.15).opacity(0.80))
                        .font(.system(size: 10))
                }
            }
        }
    }

    // MARK: - Alt Bölüm (Buton + Puan)
    private var bottomSection: some View {
        VStack(spacing: 14) {
            // Yüksek Puan
            if viewModel.highScore > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.10))
                    Text("EN YÜKSEK: \(viewModel.highScore)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.30))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.50))
                        .overlay(
                            Capsule()
                                .strokeBorder(Color(red: 1.0, green: 0.80, blue: 0.10).opacity(0.40), lineWidth: 1)
                        )
                )
            }

            // Oyna Butonu
            Button(action: onPlay) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text("OYNA")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .tracking(4)
                }
                .foregroundColor(.white)
                .frame(width: 220, height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.45, blue: 0.05),
                                    Color(red: 0.70, green: 0.25, blue: 0.02),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    Color(red: 1.0, green: 0.70, blue: 0.30).opacity(0.60),
                                    lineWidth: 2
                                )
                        )
                )
                .shadow(color: Color(red: 0.90, green: 0.45, blue: 0.05).opacity(0.60), radius: 20, y: 8)
            }
            .buttonStyle(ScaleButtonStyle())

            // CEFR Seviyesi bilgisi
            Text("A1 → C2 • 200+ Kelime")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.white.opacity(0.45))
                .padding(.bottom, 12)

            // CREDITS Butonu (Apple Review için ToS ve Privacy Policy içerir)
            Button(action: {
                showCredits = true
            }) {
                Text("CREDITS & LEGAL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.70)) // Görünürlüğü artır
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.08)) // Hafif dolgu ekle
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.20), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .sheet(isPresented: $showCredits) {
            CreditsView()
        }
    }

    // MARK: - Animasyonları Başlat
    private func startAnimations() {
        // Arka plan yıldızları
        withAnimation(.easeIn(duration: 1.2)) {
            starsOpacity = 1.0
        }

        // Gezegen
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
            planetScale = 1.0
        }

        // Başlık
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.5)) {
            titleScale = 1.0
            titleOpacity = 1.0
        }

        // Buton
        withAnimation(.spring(response: 0.5, dampingFraction: 0.70).delay(0.9)) {
            buttonScale = 1.0
            buttonOpacity = 1.0
        }

        // Yörünge animasyonu
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            orbitAngle1 = .pi * 2
        }
        withAnimation(.linear(duration: 12.0).repeatForever(autoreverses: false).delay(1.0)) {
            orbitAngle2 = .pi * 2
        }
    }
}

// MARK: - Credits & Legal View

struct CreditsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.11, blue: 0.24),
                        Color(red: 0.07, green: 0.07, blue: 0.22)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom Tab Picker
                    HStack(spacing: 20) {
                        tabButton(title: "CREDITS", index: 0)
                        tabButton(title: "PRIVACY", index: 1)
                        tabButton(title: "TERMS", index: 2)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                    Divider()
                        .background(Color.white.opacity(0.1))

                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            if selectedTab == 0 {
                                creditsContent
                            } else if selectedTab == 1 {
                                privacyPolicyContent
                            } else {
                                termsOfServiceContent
                            }
                        }
                        .padding(24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("İletişim & Yasal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.40, green: 0.80, blue: 1.0))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(selectedTab == index ? .white : .white.opacity(0.4))
                
                Capsule()
                    .fill(selectedTab == index ? Color(red: 0.40, green: 0.80, blue: 1.0) : Color.clear)
                    .frame(width: 40, height: 3)
            }
        }
    }

    // MARK: - Content Sections

    private var creditsContent: some View {
        VStack(alignment: .leading, spacing: 30) {
            creditSection(title: "Resmi Web Sitesi", names: ["astroterm.github.io"], isLink: true)
            creditSection(title: "Geliştirme", names: ["AstroTerm Geliştirme Ekibi", "dev.astroterm@gmail.com"])
            creditSection(title: "Sanat & Tasarım", names: ["AI-Assisted Sci-Fi Assets", "Universe Vector Graphics"])
            creditSection(title: "Müzik & Ses", names: ["Escape from Sector Nine (Theme)", "Custom Sound Synthesis Engine"])
            
            VStack(alignment: .leading, spacing: 10) {
                Text("TEKNOLOJİ")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(Color(red: 0.40, green: 0.80, blue: 1.0))
                
                Text("SwiftUI & SpriteKit frameworkleri ile Swift programlama dili kullanılarak modern Apple ekosistemi standartlarında geliştirilmiştir.")
                    .font(.system(size: 15))
                    .lineSpacing(4)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }

    private func creditSection(title: String, names: [String], isLink: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 14, weight: .black))
                .foregroundColor(Color(red: 0.40, green: 0.80, blue: 1.0))
            
            ForEach(names, id: \.self) { name in
                if isLink, let url = URL(string: "https://\(name)") {
                    Link(destination: url) {
                        HStack(spacing: 6) {
                            Text(name)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color(red: 0.40, green: 0.80, blue: 1.0))
                            Image(systemName: "safari")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.40, green: 0.80, blue: 1.0))
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text(name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
    }

    private var privacyPolicyContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            legalHeader("Gizlilik Politikası")
            
            legalText("AstroTerm, kullanıcı gizliliğine son derece önem vermektedir. Genel olarak uygulamamızın gizlilik yaklaşımı şöyledir:")
            
            legalBullet("Veri Toplama", "Uygulamamız herhangi bir kişisel veri (isim, e-posta, telefon, konum vb.) toplamaz, saklamaz ve paylaşmaz.")
            legalBullet("Üçüncü Taraflar", "Uygulama içinde reklam gösterimi için kullanılan Google AdMob servisi, anonim cihaz tanımlayıcıları kullanabilir. Bu veriler yalnızca reklam kişiselleştirme ve performans analizi için kullanılır.")
            legalBullet("Çocukların Gizliliği", "Uygulamamız çocuklar için güvenlidir ve herhangi bir hassas veri takibi yapmaz.")
            legalBullet("Kamera ve Mikrofon", "Uygulamamız cihazınızın kamerasına veya mikrofonuna hiçbir koşulda erişim sağlamaz.")
            
            legalText("Bu gizlilik politikası ile ilgili sorularınız için bizimle iletişime geçebilirsiniz.")
        }
    }

    private var termsOfServiceContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            legalHeader("Kullanım Koşulları")
            
            legalText("AstroTerm uygulamasını indirerek aşağıdaki koşulları kabul etmiş sayılırsınız:")
            
            legalBullet("Lisans", "AstroTerm, size bu uygulamayı kişisel, ticari olmayan kullanımınız için sınırlı ve devredilemez bir lisans hakkı vermektedir.")
            legalBullet("Kısıtlamalar", "Uygulamanın kaynak kodlarını kopyalamak, tersine mühendislik yapmak veya içeriğini izinsiz dağıtmak yasaktır.")
            legalBullet("Sorumluluk", "Uygulama 'olduğu gibi' sunulmaktadır. Yazılımsal hatalar veya skor kayıpları gibi durumlarda geliştirici ekip sorumlu tutulamaz.")
            legalBullet("Değişiklikler", "Geliştirici, kullanım koşullarını dilediği zaman güncelleme hakkını saklı tutar.")
            
            legalText("© 2026 AstroTerm. Tüm hakları saklıdır.")
        }
    }

    // MARK: - Legal Helpers

    private func legalHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.white)
            .padding(.bottom, 8)
    }

    private func legalText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15))
            .lineSpacing(6)
            .foregroundColor(.white.opacity(0.8))
    }

    private func legalBullet(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("• \(title)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.40, green: 0.80, blue: 1.0))
            
            Text(text)
                .font(.system(size: 15))
                .lineSpacing(4)
                .foregroundColor(.white.opacity(0.7))
                .padding(.leading, 12)
        }
    }
}
