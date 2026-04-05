// HUDOverlayView.swift
// AstroTerm - SwiftUI HUD katmanı (SpriteKit sahnesinin üstünde)

import SwiftUI

/// Oyun sırasında SpriteKit sahnesinin üzerinde gösterilen HUD
struct HUDOverlayView: View {

    @ObservedObject var viewModel: GameViewModel

    // Ateşleme ve yetenek kullanımı için geri çağrımlar
    var onFireButtonTap: () -> Void
    var onSpecialButtonTap: () -> Void
    var onPauseTap: () -> Void

    var body: some View {
        ZStack {
            // MARK: - SOL ÜST: Avatar + HP + Skor
            VStack(alignment: .leading, spacing: 4) {
                topLeftHUD
                Spacer()

                // MARK: - SOL ALT: Joystick
                HStack {
                    joystickControl
                    Spacer()
                }
                .padding(.bottom, 4)
                .padding(.leading, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 16)
            .padding(.leading, 16)

            // MARK: - SAĞ ÜST/ALT: Ses Ayarları + Duraklat + Aksiyon Butonları
            VStack {
                HStack(spacing: 12) {
                    Spacer()
                    
                    // Ses Kontrolleri
                    audioToggles
                    
                    pauseButton
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
                
                Spacer()

                // MARK: - SAĞ ALT: Aksiyon Butonları
                HStack {
                    Spacer()
                    actionButtons
                        .padding(.bottom, 24)
                        .padding(.trailing, 16)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            // MARK: - ORTA ÜST: Türkçe Kelime Paneli
            VStack {
                turkishWordPanel
                    .padding(.top, 20)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // MARK: - KOMBO İndikatörü
            if viewModel.isComboActive {
                VStack {
                    comboIndicator
                        .padding(.top, 95)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }

            // MARK: - Puan Popup
            if viewModel.showScorePopup {
                scorePopupView
            }
        }
    }

    // MARK: - Sol Üst HUD (Avatar + HP + Skor)
    private var topLeftHUD: some View {
        HStack(alignment: .center, spacing: 14) {
            // Astronot Avatar
            ZStack {
                // Dış halka — level rengine göre parlıyor
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                levelBadgeColor.opacity(0.95),
                                levelBadgeColor.opacity(0.40),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 58, height: 58)

                // İç dolgu — cam efekti
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 52, height: 52)
                    .shadow(color: levelBadgeColor.opacity(0.30), radius: 10)

                // Astronot emoji
                Text("👨‍🚀")
                    .font(.system(size: 32))
            }
            .shadow(color: levelBadgeColor.opacity(0.40), radius: 12, x: 0, y: 0)

            // HP Barı + Skor Katmanı
            VStack(alignment: .leading, spacing: 6) {
                // HP çubuğu
                ZStack(alignment: .leading) {
                    // Arka plan
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 140, height: 14)
                    
                    // Dolgu
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: hpBarColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(4, 140 * viewModel.hp), height: 14)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.hp)
                        
                    // Parlama efekti
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: max(4, 140 * viewModel.hp), height: 7)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.white.opacity(0.20), lineWidth: 1.5)
                )
                .shadow(color: (hpBarColors.first ?? .green).opacity(0.3), radius: 5)

                // SKOR
                HStack(spacing: 5) {
                    Text("SCORE:")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.60))
                        
                    Text("\(viewModel.score)")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(Color(red: 0.95, green: 0.90, blue: 0.20))
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: viewModel.score)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.40))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.15), lineWidth: 0.8))
                )
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.25))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
        )
    }

    // HP çubuğu rengi (yüksek: yeşil → düşük: kırmızı)
    private var hpBarColors: [Color] {
        if viewModel.hp > 0.6 {
            return [Color(red: 0.15, green: 0.85, blue: 0.35), Color(red: 0.30, green: 1.0, blue: 0.50)]
        } else if viewModel.hp > 0.3 {
            return [Color(red: 0.90, green: 0.70, blue: 0.10), Color(red: 1.0, green: 0.85, blue: 0.20)]
        } else {
            return [Color(red: 0.90, green: 0.15, blue: 0.10), Color(red: 1.0, green: 0.30, blue: 0.20)]
        }
    }

    // MARK: - Ses Kontrolleri (Sadece SFX)
    private var audioToggles: some View {
        HStack(spacing: 8) {
            // SFX Toggle
            Button(action: { viewModel.toggleSfx() }) {
                Image(systemName: viewModel.isSfxEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(viewModel.isSfxEnabled ? .white : .white.opacity(0.40))
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(viewModel.isSfxEnabled ? 0.12 : 0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
                            )
                    )
            }
            .animation(.spring(), value: viewModel.isSfxEnabled)
        }
    }

    // MARK: - Duraklat Butonu (Sağ Üst)
    private var pauseButton: some View {
        Button(action: onPauseTap) {
            HStack(spacing: 3) {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 4, height: 16)
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 4, height: 16)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Türkçe Kelime Paneli (Ortada)
    private var turkishWordPanel: some View {
        HStack(spacing: 10) {
            // İpucu Butonu
            if !viewModel.currentCategory.isEmpty {
                Button(action: { viewModel.showHint.toggle() }) {
                    Text(viewModel.showHint
                         ? WordDatabase.shared.categoryIcon(for: viewModel.currentCategory)
                         : "💡")
                        .font(.system(size: 18))
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.50))
                        )
                }
            }

            // Türkçe Kelime
            VStack(spacing: 2) {
                Text("Türkçe → İngilizce")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(red: 0.60, green: 0.80, blue: 1.0).opacity(0.80))

                Text(viewModel.currentTurkishWord.isEmpty ? "..." : viewModel.currentTurkishWord)
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: Color(red: 0.30, green: 0.70, blue: 1.0).opacity(0.80), radius: 8)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4), value: viewModel.currentTurkishWord)
            }

            // Seviye Rozeti
            Text(viewModel.currentLevel.rawValue)
                .font(.system(size: 13, weight: .black))
                .foregroundColor(levelBadgeColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(levelBadgeColor.opacity(0.20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(levelBadgeColor.opacity(0.70), lineWidth: 1.5)
                        )
                )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.08, blue: 0.25).opacity(0.25),
                            Color(red: 0.08, green: 0.12, blue: 0.35).opacity(0.25),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.30, green: 0.60, blue: 1.0).opacity(0.40),
                                    Color(red: 0.60, green: 0.30, blue: 1.0).opacity(0.30),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                )
        )
        .shadow(color: Color(red: 0.20, green: 0.40, blue: 0.80).opacity(0.40), radius: 12, x: 0, y: 4)
    }

    private var levelBadgeColor: Color {
        switch viewModel.currentLevel {
        case .a1: return Color(red: 0.30, green: 0.85, blue: 0.40)
        case .a2: return Color(red: 0.40, green: 0.90, blue: 0.55)
        case .b1: return Color(red: 0.20, green: 0.60, blue: 1.0)
        case .b2: return Color(red: 0.50, green: 0.25, blue: 1.0)
        case .c1: return Color(red: 1.0, green: 0.40, blue: 0.20)
        case .c2: return Color(red: 1.0, green: 0.80, blue: 0.10)
        }
    }

    // MARK: - Joystick Kontrolü (Sol Alt)
    private var joystickControl: some View {
        ZStack {
            JoystickView(
                onDeltaChanged: { vector in
                    viewModel.joystickDelta = vector
                },
                onRelease: {
                    viewModel.joystickDelta = .zero
                }
            )
        }
    }

    // MARK: - Aksiyon Butonları (Sağ Alt)
    private var actionButtons: some View {
        HStack(spacing: 14) {
            // Özel Yetenek Butonu (Yavaşlatma)
            ActionButton(
                icon: "bolt.fill",
                badgeCount: viewModel.specialAbilityUses,
                color: Color(red: 0.20, green: 0.50, blue: 1.0)
            ) {
                onSpecialButtonTap()
            }

            // Ana Ateş Butonu
            ActionButton(
                icon: "flame.fill",
                badgeCount: 0,
                color: Color(red: 1.0, green: 0.45, blue: 0.10)
            ) {
                onFireButtonTap()
            }
        }
    }

    // MARK: - Kombo Göstergesi
    private var comboIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.10))
                .font(.system(size: 16, weight: .bold))

            Text("COMBO x\(Int(viewModel.comboMultiplier))")
                .font(.system(size: 15, weight: .black))
                .foregroundColor(Color(red: 1.0, green: 0.90, blue: 0.10))

            // Kombo zamanlayıcı çubuğu
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.black.opacity(0.50))
                    .frame(width: 70, height: 8)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 1.0, green: 0.80, blue: 0.10))
                    .frame(width: 70 * max(0, viewModel.comboTimeRemaining / 10.0), height: 8)
                    .animation(.linear, value: viewModel.comboTimeRemaining)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color(red: 0.30, green: 0.15, blue: 0.05).opacity(0.88))
                .overlay(
                    Capsule()
                        .strokeBorder(Color(red: 1.0, green: 0.80, blue: 0.10).opacity(0.70), lineWidth: 1.5)
                )
        )
        .shadow(color: Color(red: 1.0, green: 0.70, blue: 0.05).opacity(0.50), radius: 8)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Puan Popup
    private var scorePopupView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("+\(viewModel.lastScoreGain)")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(Color(red: 0.30, green: 1.0, blue: 0.50))
                    .shadow(color: Color(red: 0.15, green: 0.70, blue: 0.30).opacity(0.80), radius: 8)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        )
                    )
                Spacer()
            }
            Spacer()
                .frame(height: 100)
        }
    }
}

// MARK: - Duraklat Menüsü
struct PauseMenuView: View {
    var onResume: () -> Void
    var onQuit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.70)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("⏸")
                    .font(.system(size: 50))

                Text("OYUN DURAKLATILDI")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.white)
                    .tracking(2)

                Divider()
                    .background(Color.white.opacity(0.30))

                Button(action: onResume) {
                    Text("DEVAM ET")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(red: 0.15, green: 0.55, blue: 0.25))
                        )
                }

                Button(action: onQuit) {
                    Text("ANA MENÜ")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.40, blue: 0.40))
                        .frame(width: 200)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(red: 0.25, green: 0.08, blue: 0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color.red.opacity(0.40), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.06, green: 0.08, blue: 0.20).opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.50), radius: 30)
        }
    }
}
