// ContentView.swift
// AstroTerm - Kök görünüm ve uygulama durum yönetimi

import SwiftUI

/// Uygulama ekranları arasındaki geçişleri yöneten kök görünüm
struct ContentView: View {

    // MARK: - Uygulama Durumu
    enum AppScreen {
        case mainMenu
        case onboarding
        case playing
        case gameOver
    }

    @State private var currentScreen: AppScreen = .mainMenu
    @StateObject private var viewModel = GameViewModel()

    // MARK: - Onboarding Durumu
    @AppStorage("astroterm_onboardingShown") private var onboardingShown: Bool = false

    var body: some View {
        ZStack {
            switch currentScreen {

            // MARK: - Ana Menü
            case .mainMenu:
                MainMenuView(viewModel: viewModel, onPlay: {
                    if onboardingShown {
                        // Onboarding daha önce gösterildiyse direkt oyuna geç
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .playing
                        }
                    } else {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .onboarding
                        }
                    }
                })
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            // MARK: - Tanıtım
            case .onboarding:
                OnboardingView(onComplete: {
                    onboardingShown = true
                    viewModel.reset()
                    withAnimation(.easeInOut(duration: 0.4)) {
                        currentScreen = .playing
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            // MARK: - Oyun
            case .playing:
                GameContainerView(
                    viewModel: viewModel,
                    onGameOver: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentScreen = .gameOver
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))

            // MARK: - Oyun Bitti
            case .gameOver:
                GameOverView(
                    viewModel: viewModel,
                    onRestart: {
                        viewModel.reset()
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .playing
                        }
                    },
                    onMenu: {
                        viewModel.reset()
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .mainMenu
                        }
                    },
                    onRevive: {
                        viewModel.acceptRevive()
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .playing
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: currentScreen)
        .onAppear {
            // İlk açılışta müziği başlat
            if currentScreen == .mainMenu {
                viewModel.startMusic()
            }
        }
        .onChange(of: currentScreen) { screen in
            // Ekranlar arası geçişlerde müziği yönet
            if screen == .mainMenu {
                viewModel.startMusic()
            } else {
                // Oyun sırasında, onboarding'de veya game over'da müziği durdur
                viewModel.stopMusic()
            }
        }
    }
}
