// GameContainerView.swift
// AstroTerm - SpriteKit sahnesi + SwiftUI HUD'un ZStack sarmalayıcısı

import SwiftUI
import SpriteKit

/// SpriteKit oyun sahnesi ile SwiftUI HUD'u bir araya getirir
struct GameContainerView: View {

    @ObservedObject var viewModel: GameViewModel
    var onGameOver: () -> Void

    // MARK: - Sahne Referansı
    @State private var scene: GameScene?
    @State private var showPauseMenu: Bool = false

    // Reklam gösterimi sırasında iOS scenePhase'i .inactive'e alır;
    // reklam kapandıktan sonra .active'e dönünce sahneyi güvenle unpause et.
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: - SpriteKit Sahnesi (Arka Plan)
                if let gameScene = scene {
                    ZStack {
                        // Tüm Seviyeler için Dinamik Renkli Lottie Arka Planı
                        LottieView(filename: "Space", color: UIColor(viewModel.currentLevel.themeColor))
                            .overlay(viewModel.currentLevel.themeColor.opacity(0.2)) // Tüm atmosferi boyamak için overlay ekle
                            .ignoresSafeArea()
                        
                        SpriteView(
                            scene: gameScene,
                            preferredFramesPerSecond: 60, // Batarya dostu 60 FPS (120Hz ekrana gerek yok)
                            options: [.allowsTransparency, .ignoresSiblingOrder, .shouldCullNonVisibleNodes]
                        )
                            .ignoresSafeArea()
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                }

                // MARK: - SwiftUI HUD (Ön Plan)
                if !showPauseMenu {
                    HUDOverlayView(
                        viewModel: viewModel,
                        onFireButtonTap: {
                            scene?.firePlayerBullet(isSpecial: false)
                        },
                        onSpecialButtonTap: {
                            guard viewModel.specialAbilityUses > 0 else { return }
                            scene?.activateSlowMotion()
                        },
                        onPauseTap: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showPauseMenu = true
                                viewModel.isGamePaused = true
                                scene?.setPaused(true)
                            }
                        }
                    )
                }

                // MARK: - Duraklat Menüsü
                if showPauseMenu {
                    PauseMenuView(
                        onResume: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showPauseMenu = false
                                viewModel.isGamePaused = false
                                scene?.setPaused(false)
                            }
                        },
                        onQuit: {
                            showPauseMenu = false
                            viewModel.isGamePaused = false
                            scene?.setPaused(false)
                            onGameOver()
                        }
                    )
                    .transition(.opacity)
                    .zIndex(100)
                }

                // MARK: - Seviye Atlama Efekti
                if viewModel.isLevelUp {
                    LevelUpView(newLevel: viewModel.currentLevel)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(90)
                        .onAppear {
                            scene?.performLevelTransition(to: viewModel.currentLevel)
                        }
                }

                // MARK: - Hikaye Diyaloğu
                if let dialogue = viewModel.activeDialogue {
                    DialogueOverlayView(
                        dialogue: dialogue,
                        onDismiss: {
                            viewModel.activeDialogue = nil
                            // Eğer diyalog "Final" ise, diyalog bitince GameOver ekranına geç
                            if dialogue.transition == "Final" {
                                viewModel.isGameOver = true
                            } else {
                                // Diğer durumlarda normal seviye geçiş efektini göster
                                viewModel.isLevelUp = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                    viewModel.isLevelUp = false
                                }
                            }
                        }
                    )
                    .zIndex(110)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }


            }
        }
        .ignoresSafeArea()
        .onAppear {
            setupScene()
        }
        .onChange(of: viewModel.isGameOver) { isOver in
            if isOver {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onGameOver()
                }
            }
        }
        .onChange(of: viewModel.restartTrigger) { _ in
            // viewModel.reset() çağrıldığında sahneyi sıfırla ve yeni kelime sırası oluştur
            scene?.resetScene()
        }
        .onChange(of: viewModel.reviveTrigger) { _ in
            scene?.revivePlayer()
        }
        .onChange(of: scenePhase) { newPhase in
            // Reklam UIViewController'ı kapandığında iOS scenePhase'i .inactive →
            // .active sırasına geçirir. SpriteView bu geçişte SKView'ı önceki manuel
            // duraklatma durumuna (true) geri yükleyebilir. Uygulama .active'e döndüğünde
            // ve ne pause menüsü açıksa sahneyi garantili olarak
            // unpause ediyoruz.
            if newPhase == .active, !viewModel.isUIBlocking {
                scene?.setPaused(false)
            }
        }
        .onChange(of: viewModel.isUIBlocking) { isBlocking in
            // Herhangi bir UI blokajında oyunu duraklat
            scene?.setPaused(isBlocking)
        }
    }

    // MARK: - Sahne Kurulumu
    private func setupScene() {
        // resizeFill ensures no cropping occurs; elements will be dynamically adjusted in GameScene
        let newScene = GameScene()
        newScene.viewModel = viewModel
        newScene.scaleMode = .resizeFill
        newScene.backgroundColor = .clear
        scene = newScene
    }
}

// MARK: - Diyalog Görünümü

struct DialogueOverlayView: View {
    let dialogue: DialogueEntry
    var onDismiss: () -> Void

    @State private var displayedText: String = ""
    @State private var alpha: Double = 0
    @State private var barOffset: CGFloat = 100
    @State private var textTimer: Timer?

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Arka Plan Karartma (Tıklanabilir)
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        handleDismiss()
                    }

                // MARK: - Diyalog Barı
                HStack(alignment: .bottom, spacing: 0) {
                    // SOL: Karakter Portresi
                    ZStack {
                        // Portre Çerçevesi (Futuristic)
                        Rectangle()
                            .fill(Color.black.opacity(0.8))
                            .frame(width: 110, height: 110)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.cyan.opacity(0.5), lineWidth: 2)
                            )
                        
                        Image(dialogue.portraitImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .overlay(
                                // Portre üzerine hafif cyan tarama çizgileri efekti
                                VStack(spacing: 2) {
                                    ForEach(0..<20) { _ in
                                        Rectangle()
                                            .fill(Color.cyan.opacity(0.05))
                                            .frame(height: 1)
                                    }
                                }
                            )
                    }
                    .padding(.leading, max(16, geo.safeAreaInsets.leading))
                    .padding(.bottom, max(16, geo.safeAreaInsets.bottom))
                    .shadow(color: .cyan.opacity(0.3), radius: 8)

                    // SAĞ: Metin Alanı
                    VStack(alignment: .leading, spacing: 6) {
                        // Karakter Adı
                        Text(dialogue.characterName.uppercased())
                            .font(.system(size: 13, weight: .black, design: .monospaced))
                            .foregroundColor(.cyan)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.cyan.opacity(0.2))
                        
                        // Diyalog Metni (Glowing Cyan)
                        ScrollView {
                            Text(displayedText)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .cyan.opacity(0.7), radius: 4)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxHeight: 70)

                        // "Devam etmek için dokun" ipucu
                        HStack {
                            Spacer()
                            Text("DEVAM >>")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(.cyan.opacity(0.6))
                                .opacity(alpha)
                                .animation(.easeInOut(duration: 0.8).repeatForever(), value: alpha)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, max(24, geo.safeAreaInsets.trailing))
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        // Yarı saydam koyu bar
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.black.opacity(0.95),
                                        Color.black.opacity(0.8)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                // Üst ve Alt Cyber Sınırlar
                                VStack {
                                    Rectangle().fill(Color.cyan.opacity(0.4)).frame(height: 1)
                                    Spacer()
                                    Rectangle().fill(Color.cyan.opacity(0.2)).frame(height: 1)
                                }
                            )
                    )
                }
                .frame(height: 140 + geo.safeAreaInsets.bottom / 2)
                .offset(y: barOffset)
                .opacity(alpha)
            }
        }
        .onAppear {
            startDialogue()
        }
    }

    private func startDialogue() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            alpha = 1.0
            barOffset = 0
        }
        
        // Typing Effect
        let characters = Array(dialogue.text)
        var index = 0
        textTimer = Timer.scheduledTimer(withTimeInterval: 0.035, repeats: true) { timer in
            if index < characters.count {
                displayedText.append(characters[index])
                index += 1
            } else {
                timer.invalidate()
            }
        }
    }

    private func handleDismiss() {
        // Eğer yazı hala yazılıyorsa hemen hepsini bitir
        if displayedText.count < dialogue.text.count {
            textTimer?.invalidate()
            displayedText = dialogue.text
            return
        }
        
        // Kapat
        withAnimation(.easeIn(duration: 0.25)) {
            alpha = 0
            barOffset = 100
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
}

// MARK: - Önizleme
#if DEBUG
struct GameContainerView_Previews: PreviewProvider {
    static var previews: some View {
        GameContainerView(
            viewModel: GameViewModel(),
            onGameOver: {}
        )
        .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
        .previewDisplayName("iPhone 15 Pro")
    }
}
#endif
