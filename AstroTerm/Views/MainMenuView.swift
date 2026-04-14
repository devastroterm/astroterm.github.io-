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


/// Oyunun ana menü ekranı
struct MainMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    var onPlay: () -> Void
    var onShowTutorial: () -> Void // Yeni: Tutorial butonu için

    // MARK: - Animasyon Durumları
    @State private var titleScale: CGFloat = 0.7
    @State private var titleOpacity: Double = 0
    @State private var shipScale: CGFloat = 0.1
    @State private var shipOpacity: Double = 0
    @State private var shipRotation: Double = 0
    @State private var starsOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.9
    @State private var buttonOpacity: Double = 0
    @State private var hyperSpaceActive: Bool = false
    
    // Ses kontrolleri için görünürlük durumu
    @State private var showVolumeSlider: Bool = false
    @State private var showCredits: Bool = false

    // MARK: - Yıldız Animasyonu (Statik seed, TimelineView ile çizilir — @State mutation yok)
    // static let: tüm view ömrü boyunca bir kez hesaplanır, re-render tetiklemez
    private static let starSeeds: [(x: CGFloat, y: CGFloat, z0: CGFloat, size: CGFloat, opacity: Double)] = {
        (0..<150).map { _ in
            (CGFloat.random(in: -500...500),
             CGFloat.random(in: -500...500),
             CGFloat.random(in: 1...1000),
             CGFloat.random(in: 1...3),
             Double.random(in: 0.1...1.0))
        }
    }()
    @State private var animStart: Date = Date()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: - Arka Plan (Hyper-Space)
                hyperSpaceBackground(size: geo.size)
                    .opacity(starsOpacity)

                // MARK: - Merkezi Efekt (Gemi kaldırıldı, parlama kaldı)
                shipShowcase(size: geo.size)
                    .scaleEffect(shipScale)
                    .opacity(shipOpacity)
                    .offset(y: 10)

                // MARK: - Başlık ve Kontroller
                VStack(spacing: 0) {
                    titleSection
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                        .padding(.top, 20)

                    Spacer(minLength: 10)

                    // MARK: - Alt Bölüm (Oyna + Tutorial + Puan)
                    menuControls
                        .scaleEffect(buttonScale)
                        .opacity(buttonOpacity)
                        .padding(.bottom, max(10, geo.safeAreaInsets.bottom))
                }

                // MARK: - Ses Ayarları (Sağ Üst)
                VStack {
                    HStack {
                        Spacer()
                        soundSettingsStack
                            .padding(.top, max(20, geo.safeAreaInsets.top))
                            .padding(.trailing, max(20, geo.safeAreaInsets.trailing))
                    }
                    Spacer()
                }

                // MARK: - Menü Tanıtımı (Tutorial)
                if !viewModel.menuTutorialShown && viewModel.isMenuTutorialActive {
                    MenuTutorialView(viewModel: viewModel) {
                        withAnimation(.easeOut) {
                            viewModel.isMenuTutorialActive = false
                        }
                    }
                    .transition(AnyTransition.opacity)
                    .zIndex(100)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animStart = Date()

            // Açılış warp efekti: 1.2 saniye hızlı uçuş, sonra normal hız
            hyperSpaceActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.6)) {
                    hyperSpaceActive = false
                }
            }

            startAnimations()
            viewModel.startMusic()

            if !viewModel.menuTutorialShown {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeIn) {
                        viewModel.isMenuTutorialActive = true
                    }
                }
            }
        }
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

    // MARK: - Hyper-Space Arka Planı
    // TimelineView: sadece Canvas yeniden çizilir, MainMenuView'in geri kalanı re-render olmaz
    private func hyperSpaceBackground(size: CGSize) -> some View {
        ZStack {
            Color(red: 0.02, green: 0.01, blue: 0.08).ignoresSafeArea()

            RadialGradient(
                colors: [Color.purple.opacity(0.15), Color.clear],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )

            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { context, canvasSize in
                    let elapsed = CGFloat(timeline.date.timeIntervalSince(animStart))
                    // Orijinal: timer her 0.02s'de z'yi 2 azaltıyordu → 100 birim/saniye
                    // HyperSpace: 20 birim/frame × 50fps = 1000 birim/saniye
                    let speed: CGFloat = hyperSpaceActive ? 1000 : 100
                    let range: CGFloat = 999

                    for seed in Self.starSeeds {
                        // z: seed.z0'dan başlar, elapsed*speed kadar düşer, 1...999 arasında döner
                        var z = seed.z0 - elapsed * speed
                        // Modüler sarma: z'yi [1, 999] aralığında tut
                        z = z - floor(z / range) * range
                        if z < 1 { z += range }

                        let k = 120.0 / z
                        let px = seed.x * k + canvasSize.width / 2
                        let py = seed.y * k + canvasSize.height / 2

                        guard px >= 0, px <= canvasSize.width,
                              py >= 0, py <= canvasSize.height else { continue }

                        let r = (1.0 - z / 1000.0) * seed.size * 2
                        let opacity = (1.0 - z / 1000.0) * seed.opacity

                        var path = Path()
                        if hyperSpaceActive {
                            // Warp çizgisi: geçmiş konumdan şimdiye çizgi
                            let kPrev = 120.0 / (z + 80)
                            let ppx = seed.x * kPrev + canvasSize.width / 2
                            let ppy = seed.y * kPrev + canvasSize.height / 2
                            path.move(to: CGPoint(x: px, y: py))
                            path.addLine(to: CGPoint(x: ppx, y: ppy))
                            context.stroke(path, with: .color(.white.opacity(opacity)), lineWidth: r)
                        } else {
                            path.addEllipse(in: CGRect(x: px, y: py, width: r, height: r))
                            context.fill(path, with: .color(.white.opacity(opacity)))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Gemi Gösterimi (Görsel Efekt)
    private func shipShowcase(size: CGSize) -> some View {
        ZStack {
            // Arka plan parlaması (Mavi derinleşme efekti)
            Circle()
                .fill(Color.blue.opacity(0.12))
                .frame(width: size.width * 0.7, height: size.height * 0.8)
                .blur(radius: 60)
            
            // Gemi kaldırıldı (User isteği), sadece parlamalar ve lazer artığı kaldı
            Capsule()
                .fill(LinearGradient(colors: [.cyan.opacity(0.6), .purple.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                .frame(width: 2, height: size.height * 0.4)
                .offset(x: 40, y: -size.height * 0.2)
                .blur(radius: 1)
                .opacity(shipOpacity * 0.5)
        }
    }

    // MARK: - Başlık Bölümü
    private var titleSection: some View {
        VStack(spacing: 5) {
            // ASTRO + TERM birbirine yakın
            VStack(spacing: 0) {
                // Astro kelimesi
                HStack(spacing: 0) {
                    Text("ASTRO")
                        .font(.system(size: 40, weight: .black, design: .rounded))
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
                        .font(.system(size: 44, weight: .black, design: .rounded))
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
                        .shadow(color: Color(red: 1.0, green: 0.60, blue: 0.10).opacity(0.60), radius: 10)
                }
            }

            // Alt başlık
            Text("İngilizce-Türkçe Kelime Macerası")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.white.opacity(0.60))
                .tracking(1.2)

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

    // MARK: - Kontroller (Oyna, Tutorial, Puan)
    private var menuControls: some View {
        VStack(spacing: 15) {
            // --- 1. SATIR: ANA AKSİYON ---
            VStack(spacing: 10) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        hyperSpaceActive = true
                        shipScale = 2.0
                        shipOpacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        onPlay()
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("GÖREVE BAŞLA")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .tracking(1)
                    }
                    .foregroundColor(.white)
                    .frame(width: 240, height: 60)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        }
                    )
                    .shadow(color: .blue.opacity(0.5), radius: 20)
                }
                .buttonStyle(ScaleButtonStyle())

                // Tutorial Butonu
                Button(action: onShowTutorial) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("NASIL OYNANIR?")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white.opacity(0.04)))
                }
            }

            // --- 2. SATIR: İSTATİSTİKLER (Glassmorphism) ---
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SKOR")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.white.opacity(0.4))
                    Text("\(viewModel.highScore)")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(.cyan)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
                
                Button(action: { showCredits = true }) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.3))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.04)))
                }
            }
        }
        .sheet(isPresented: $showCredits) {
            CreditsView()
        }
    }

    private func startAnimations() {
        withAnimation(.easeIn(duration: 1.0)) {
            starsOpacity = 1.0
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
            shipScale = 1.0
            shipOpacity = 1.0
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.5)) {
            titleScale = 1.0
            titleOpacity = 1.0
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.70).delay(0.8)) {
            buttonScale = 1.0
            buttonOpacity = 1.0
        }
        
        // Ship floating animation
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            shipRotation = 5.0
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
            creditSection(title: "Resmi Web Sitesi", names: ["https://devastroterm.github.io/astroterm.github.io-/"], isLink: true)
            creditSection(title: "Geliştirme", names: ["AstroTerm Geliştirme Ekibi", "dev.astroterm@gmail.com"])
            creditSection(title: "Sanat & Tasarım", names: ["Özel Tasarım Uzay Varlıkları", "Evrensel Vektörel Grafikler"])
            creditSection(title: "Müzik & Ses", names: ["Escape from Sector Nine (Tema)", "Özel Ses Sentezleme Motoru"])
            
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

struct ShipSelectionView: View {
    @ObservedObject var viewModel: GameViewModel
    var onLaunch: () -> Void
    var onBack: () -> Void
    
    @State private var selectedIndex: Int = 0
    @State private var isAnimating: Bool = false
    
    private let ships = AstroShip.ships
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Arka Plan
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.02, blue: 0.12), Color(red: 0.10, green: 0.05, blue: 0.20)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Yıldızlar
                ForEach(0..<20) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(x: .random(in: 0...geo.size.width), y: .random(in: 0...geo.size.height))
                        .opacity(.random(in: 0.2...0.6))
                }
                
                VStack(spacing: 0) {
                    // Üst Başlık (Daha yukarı taşındı)
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("FILO SEÇIMI")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .italic()
                                .foregroundColor(.white)
                            
                            Text("GÖREV İÇİN GEMİSİNİ BELİRLE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.cyan.opacity(0.8))
                        }
                    }
                    .padding(.leading, max(30, geo.safeAreaInsets.leading))
                    .padding(.trailing, max(60, geo.safeAreaInsets.trailing + 30))
                    .padding(.top, max(12, geo.safeAreaInsets.top))
                    
                    Spacer()
                    
                    // Ana Seçim Alanı (Yatay Kaydırılabilir Gemi Görüntüleyici)
                    ZStack {
                        // İç Alan (Gemi | İstatistik)
                        HStack(spacing: 40) {
                            // SOL: Gemi Önizleme
                            ZStack {
                                Circle()
                                    .fill(ships[selectedIndex].difficultyColor.opacity(0.15))
                                    .frame(width: 200, height: 200)
                                    .blur(radius: 40)
                                    .scaleEffect(isAnimating ? 1.2 : 0.9)
                                
                                Image(ships[selectedIndex].imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 220, height: 160)
                                    .offset(y: isAnimating ? -10 : 10)
                                    .shadow(color: ships[selectedIndex].difficultyColor.opacity(0.5), radius: 20)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // SAĞ: İstatistikler ve Yetenekler
                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(ships[selectedIndex].name)
                                        .font(.system(size: 26, weight: .black, design: .monospaced))
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 12) {
                                        difficultyBadge(
                                            title: ships[selectedIndex].difficultyTitle,
                                            color: ships[selectedIndex].difficultyColor
                                        )
                                        
                                        hpIndicator(lives: ships[selectedIndex].maxLives)
                                    }
                                }
                                
                                Text(ships[selectedIndex].description)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(width: 320, alignment: .leading)
                                
                                // Yetenek Barları
                                VStack(spacing: 12) {
                                    abilityBar(label: "ATEŞ GÜCÜ", value: ships[selectedIndex].abilities.fireRate, color: .red)
                                    abilityBar(label: "MANEVRA", value: ships[selectedIndex].abilities.agility, color: .blue)
                                    abilityBar(label: "ZIRH", value: ships[selectedIndex].abilities.armor, color: .green)
                                }
                                .padding(.top, 5)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, max(40, geo.safeAreaInsets.leading))
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                if value.translation.width > threshold {
                                    // Swipe Right (Previous Ship)
                                    withAnimation(.spring()) {
                                        selectedIndex = (selectedIndex - 1 + ships.count) % ships.count
                                    }
                                } else if value.translation.width < -threshold {
                                    // Swipe Left (Next Ship)
                                    withAnimation(.spring()) {
                                        selectedIndex = (selectedIndex + 1) % ships.count
                                    }
                                }
                            }
                    )
                    
                    // Page Indicators (Slot points)
                    pageIndicator(count: ships.count, current: selectedIndex)
                    .padding(.top, 5)
                    
                    Spacer()
                    
                    // Launch Butonu (En altta)
                    Button(action: {
                        viewModel.selectedShip = ships[selectedIndex]
                        viewModel.reset() // Oyunu sıfırla ve canları ayarla
                        onLaunch()
                    }) {
                        Text("SISTEMI BASLAT VE OYNA")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.white)
                            .frame(width: 320, height: 55)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(
                                        LinearGradient(
                                            colors: [ships[selectedIndex].difficultyColor, ships[selectedIndex].difficultyColor.opacity(0.6)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .shadow(color: ships[selectedIndex].difficultyColor.opacity(0.4), radius: 15, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.bottom, 12)
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Yardımcı Görünümler
    
    private func abilityBar(label: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color.opacity(0.8))
            }
            .frame(width: 250)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 250, height: 6)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 250 * CGFloat(value), height: 6)
                    .shadow(color: color.opacity(0.5), radius: 4)
            }
        }
    }
    
    private func difficultyBadge(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .cornerRadius(5)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(color.opacity(0.3), lineWidth: 1))
    }
    
    private func hpIndicator(lives: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { i in
                Image(systemName: "heart.fill")
                    .font(.system(size: 10))
                    .foregroundColor(i < lives ? .red : .white.opacity(0.1))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.black.opacity(0.3))
        .cornerRadius(5)
    }
    
    // Page indicator (dots)
    private func pageIndicator(count: Int, current: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == current ? ships[index].difficultyColor : Color.white.opacity(0.2))
                    .frame(width: index == current ? 10 : 7, height: index == current ? 10 : 7)
                    .shadow(color: index == current ? ships[index].difficultyColor.opacity(0.6) : .clear, radius: 4)
                    .animation(.spring(), value: current)
            }
        }
    }
}

// MARK: - MenuTutorialView (Scope sorununu çözmek için ana dosyaya taşındı)
struct MenuTutorialView: View {
    @ObservedObject var viewModel: GameViewModel
    var onComplete: () -> Void
    
    @State private var currentStep: TutorialStep = .welcome
    @State private var bubbleOpacity: Double = 0
    @State private var spotlightScale: CGFloat = 0.8
    
    enum TutorialStep: Int, CaseIterable {
        case welcome = 0
        case playButton = 1
        case stats = 2
        case settings = 3
        case finish = 4
        
        var title: String {
            switch self {
            case .welcome: return "Hoş Geldin, Kaptan!"
            case .playButton: return "Maceraya Başla"
            case .stats: return "Gelişimini İzle"
            case .settings: return "Uzay Akustiği"
            case .finish: return "Her Şey Hazır!"
            }
        }
        
        var description: String {
            switch self {
            case .welcome: return "AstroTerm evrenine hoş geldin! Kelimelerin gücüyle galaksiyi kurtarmaya hazır mısın?"
            case .playButton: return "OYNA tuşuna basarak istediğin gemiyi seçebilir ve ilk görevine atılabilirsin."
            case .stats: return "Buradan en yüksek skorunu ve A1'den C2'ye kadar olan dil ilerlemeni görebilirsin."
            case .settings: return "Müzik ve ses efektlerini buradan kontrol ederek oyun keyfini artırabilirsin."
            case .finish: return "Artık hazırsın! İlk kelimeni vurmak için sabırsızlanıyoruz. İyi şanslar!"
            }
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Dimmed Background
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .mask(
                        TutorialMask(step: currentStep, screenSize: geo.size)
                    )
                
                // Content Layer
                VStack {
                    if currentStep == .welcome || currentStep == .finish {
                        Spacer()
                        tutorialBubble(step: currentStep)
                            .padding(.horizontal, 40)
                            .transition(.scale.combined(with: .opacity))
                        Spacer()
                    } else {
                        // Positioned bubbles based on step
                        contentForStep(currentStep, in: geo.size)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                bubbleOpacity = 1
                spotlightScale = 1.0
            }
        }
    }
    
    @ViewBuilder
    private func contentForStep(_ step: TutorialStep, in size: CGSize) -> some View {
        ZStack {
            switch step {
            case .playButton:
                tutorialBubble(step: step)
                    .position(x: size.width / 2, y: size.height - 240)
            case .stats:
                tutorialBubble(step: step)
                    .position(x: 160, y: size.height - 180)
            case .settings:
                tutorialBubble(step: step)
                    .position(x: size.width - 200, y: 180)
            default:
                EmptyView()
            }
        }
    }
    
    private func tutorialBubble(step: TutorialStep) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(step.title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.cyan)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Text("\(step.rawValue + 1)/\(TutorialStep.allCases.count)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Text(step.description)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: nextStep) {
                HStack {
                    Text(step == .finish ? "BAŞLAYALIM!" : "DEVAM")
                        .font(.system(size: 14, weight: .bold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(step == .finish ? Color.orange : Color.blue)
                )
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .frame(width: 280)
        .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
    }
    
    private func nextStep() {
        if currentStep.rawValue < TutorialStep.allCases.count - 1 {
            withAnimation(.spring()) {
                currentStep = TutorialStep(rawValue: currentStep.rawValue + 1)!
            }
        } else {
            viewModel.menuTutorialShown = true
            onComplete()
        }
    }
}

// MARK: - TutorialMask
struct TutorialMask: View {
    var step: MenuTutorialView.TutorialStep
    var screenSize: CGSize
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
            
            Group {
                switch step {
                case .playButton:
                    RoundedRectangle(cornerRadius: 22)
                        .frame(width: 250, height: 80)
                        .position(x: screenSize.width / 2, y: screenSize.height - 110)
                case .stats:
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 180, height: 60)
                        .position(x: 110, y: screenSize.height - 45)
                case .settings:
                    Circle()
                        .frame(width: 60, height: 60)
                        .position(x: screenSize.width - 42, y: 78)
                default:
                    Circle().frame(width: 0, height: 0)
                }
            }
            .blendMode(.destinationOut)
        }
        .compositingGroup()
    }
}
