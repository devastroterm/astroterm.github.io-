// GameViewModel.swift
// AstroTerm - SwiftUI ve SpriteKit arasında köprü görevi gören ViewModel

import SwiftUI
import Combine
import SpriteKit
import AVFoundation

// MARK: - AudioManager (Merkezi Ses Yönetimi)
/// Uygulama genelinde arka plan müziğini yöneten sınıf.
final class AudioManager {
    static let shared = AudioManager()
    
    private var musicPlayer: AVAudioPlayer?
    private(set) var isMusicPlaying: Bool = false
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            // .playback: Sessiz modda bile müzik çalar (Arka plan müziği için ideal)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ AudioSession başarıyla başlatıldı (.playback)")
        } catch {
            print("❌ AudioSession hatası: \(error.localizedDescription)")
        }
    }
    
    func playBackgroundMusic(fileName: String, type: String = "mp3") {
        // Eğer zaten aynı dosya çalıyorsa dokunma
        if let currentURL = musicPlayer?.url, currentURL.lastPathComponent == "\(fileName).\(type)" {
            if !isMusicPlaying { resumeMusic() }
            return
        }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: type) else {
            print("⚠️ HATA: Müzik dosyası BUNDLE içinde bulunamadı: \(fileName).\(type)")
            return
        }

        let shouldPlay = UserDefaults.standard.object(forKey: "astroterm_isMusicEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "astroterm_isMusicEnabled")
        let savedVolume = UserDefaults.standard.object(forKey: "astroterm_musicVolume") == nil
            ? Float(0.5)
            : UserDefaults.standard.float(forKey: "astroterm_musicVolume")

        // AVAudioPlayer yükleme ve prepareToPlay main thread'i bloklamaması için
        // background thread'de yapılır, play() main thread'e geri döner.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = -1
                player.volume = savedVolume
                player.prepareToPlay() // Disk I/O burada biter

                DispatchQueue.main.async {
                    self.musicPlayer = player
                    if shouldPlay {
                        player.play()
                        self.isMusicPlaying = true
                    }
                }
            } catch {
                print("❌ Müzik yükleme hatası: \(error.localizedDescription)")
            }
        }
    }
    
    func resumeMusic() {
        guard let player = musicPlayer, !player.isPlaying else { return }
        player.play()
        isMusicPlaying = true
    }
    
    func pauseMusic() {
        musicPlayer?.pause()
        isMusicPlaying = false
    }
    
    func setVolume(_ volume: Float) {
        musicPlayer?.volume = volume
        UserDefaults.standard.set(volume, forKey: "astroterm_musicVolume")
    }
    
    func toggleMusic(enabled: Bool) {
        if enabled {
            if let player = musicPlayer {
                player.play()
            } else {
                // Eğer player hiç oluşmamışsa tekrar dene
                playBackgroundMusic(fileName: "Escape_from_Sector_Nine")
            }
            isMusicPlaying = true
        } else {
            musicPlayer?.pause()
            isMusicPlaying = false
        }
        UserDefaults.standard.set(enabled, forKey: "astroterm_isMusicEnabled")
    }
}

/// SwiftUI HUD ile SpriteKit sahnesi arasındaki iletişimi yönetir
final class GameViewModel: ObservableObject {

    // MARK: - HUD'da Gösterilen Yayınlanmış Değerler
    @Published var score: Int = 0
    @Published var lives: Int = 3
    @Published var hp: Double = 1.0                     // 0.0 - 1.0
    @Published var currentLevel: CEFRLevel = .a1
    @Published var currentTurkishWord: String = ""      // Ekranda gösterilen Türkçe kelime
    @Published var currentCategory: String = ""         // İpucu kategorisi
    @Published var isComboActive: Bool = false
    @Published var comboMultiplier: Double = 1.0
    @Published var comboTimeRemaining: Double = 0
    @Published var specialAbilityUses: Int = 3
    @Published var totalWordsLearned: Int = 0           // İstatistik: Öğrenilen kelime sayısı
    @Published var enemiesDestroyed: Int = 0            // İstatistik: Yok edilen düşman
    @Published var wrongAnswers: Int = 0                // İstatistik: Yanlış cevaplar
    @Published var isGamePaused: Bool = false
    @Published var isGameOver: Bool = false
    @Published var showHint: Bool = false               // İpucu ikonu göster/gizle
    @Published var lastScoreGain: Int = 0               // Puan animasyonu için
    @Published var showScorePopup: Bool = false
    @Published var restartTrigger: Int = 0      // Her reset'te artar → sahneyi yeniden başlatır
    @Published var reviveTrigger: Int = 0       // Reklam izleyince sahneyi canlandırır
    @Published var revivesUsed: Int = 0         // Aynı oturumda kazanılan can sayısı
    @Published var isLevelUp: Bool = false       // Seviye atlama pop-up'ı yayını
    @Published var activeDialogue: DialogueEntry? = nil // Şu an gösterilen diyalog
    
    // MARK: - Gemi Seçimi
    @Published var selectedShip: AstroShip = AstroShip.ships[0]

    /// Herhangi bir UI elemanının (Diyalog, Seviye Atlama, Duraklatma) oyunu bloklayıp bloklamadığı
    var isUIBlocking: Bool {
        isGamePaused || isLevelUp || activeDialogue != nil || isGameOver
    }

    /// Menü eğitimi şu an aktif mi?
    @Published var isMenuTutorialActive: Bool = false


    // MARK: - Ses Ayarları
    @Published var isMusicEnabled: Bool = true {
        didSet { 
            UserDefaults.standard.set(isMusicEnabled, forKey: "astroterm_isMusicEnabled")
            AudioManager.shared.toggleMusic(enabled: isMusicEnabled)
        }
    }
    @Published var isSfxEnabled: Bool = true {
        didSet { UserDefaults.standard.set(isSfxEnabled, forKey: "astroterm_sfxEnabled") }
    }
    @Published var musicVolume: Float = 0.5 {
        didSet {
            AudioManager.shared.setVolume(musicVolume)
        }
    }

    // MARK: - İç Oyun Durumu
    private(set) var gameState = GameState()
    private var previousLevel: CEFRLevel = .a1
    private var lastComboUIUpdateTime: TimeInterval = 0   // Combo UI throttle

    // MARK: - Joystick Girişi
    var joystickDelta: CGVector = .zero  // SpriteKit sahnesinin okuduğu joystick vektörü

    // MARK: - Sahne Geri Çağrımları (GameScene → ViewModel)
    var onEnemyReachedBase: (() -> Void)?
    var onCorrectAnswer: ((Int) -> Void)?
    var onWrongAnswer: (() -> Void)?
    var onShieldPickup: (() -> Void)?
    var triggerGameOver: (() -> Void)?

    // MARK: - Kullanıcı Tercihleri
    @AppStorage("astroterm_highScore")        var storedHighScore: Int = 0
    @AppStorage("astroterm_lastLevel")        var storedLastLevel: String = "A1"
    @AppStorage("astroterm_onboardingShown")  var onboardingShown: Bool = false
    @AppStorage("astroterm_menuTutorialShown") var menuTutorialShown: Bool = false

    // MARK: - Başlatma
    init() {
        // Ses ayarlarını yükle
        self.isMusicEnabled = UserDefaults.standard.bool(forKey: "astroterm_isMusicEnabled")
        if UserDefaults.standard.object(forKey: "astroterm_isMusicEnabled") == nil { self.isMusicEnabled = true }

        self.isSfxEnabled = UserDefaults.standard.bool(forKey: "astroterm_sfxEnabled")
        if UserDefaults.standard.object(forKey: "astroterm_sfxEnabled") == nil { self.isSfxEnabled = true }

        let savedVolume = UserDefaults.standard.float(forKey: "astroterm_musicVolume")
        self.musicVolume = (UserDefaults.standard.object(forKey: "astroterm_musicVolume") == nil) ? 0.5 : savedVolume

        gameState.highScore = storedHighScore
        setupCallbacks()

        // WordDatabase'i arka planda önceden yükle — oyun başlayınca main thread bloklanmasın
        DispatchQueue.global(qos: .userInitiated).async {
            _ = WordDatabase.shared
        }
    }

    // MARK: - Geri Çağrımları Kur
    private func setupCallbacks() {
        onEnemyReachedBase = { [weak self] in
            self?.enemyReachedBase()
        }
        triggerGameOver = { [weak self] in
            self?.forceGameOver()
        }
        onCorrectAnswer = { [weak self] points in
            self?.correctAnswer(points: points)
        }
        onWrongAnswer = { [weak self] in
            self?.wrongAnswer()
        }
        onShieldPickup = { [weak self] in
            self?.pickupShield()
        }
    }

    // MARK: - Oyun Eylemleri

    /// Doğru kelime vurulduğunda
    func correctAnswer(points: Int) {
        gameState.updateCombo(correct: true)
        gameState.addScore(points)
        gameState.enemiesDestroyed += 1
        gameState.totalWordsLearned += 1
        syncPublishedValues()
        showScoreAnimation(points: Int(Double(points) * gameState.comboMultiplier))
        checkLevelUp()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Yanlış kelime vurulduğunda
    func wrongAnswer() {
        gameState.updateCombo(correct: false)
        gameState.loseLife()
        syncPublishedValues()
        checkGameOver()
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    /// Düşman üssüne ulaştığında
    func enemyReachedBase() {
        forceGameOver()
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    /// Kalkan güç-yukarı toplandığında
    func pickupShield() {
        gameState.gainLife()
        syncPublishedValues()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // MARK: - Kelime Güncelleme

    /// Yeni bir dalga başladığında Türkçe kelimeyi güncelle
    func updateCurrentWord(_ pair: WordPair) {
        gameState.wavesCompleted += 1
        DispatchQueue.main.async { [weak self] in
            self?.currentTurkishWord = pair.turkish
            self?.currentCategory = pair.category
            self?.syncPublishedValues()
        }
    }

    // MARK: - Özel Yetenek (Yavaşlatma)
    func useSpecialAbility() {
        guard specialAbilityUses > 0 else { return }
        specialAbilityUses -= 1
        gameState.specialAbilityUses -= 1
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    // MARK: - Duraklat/Devam
    func togglePause() {
        isGamePaused.toggle()
    }

    // MARK: - Kombo Zamanlayıcı Tick (Her frame çağrılır)
    func tickCombo(deltaTime: TimeInterval) {
        guard gameState.isComboActive else { return }
        gameState.tickCombo(deltaTime: deltaTime)

        // SwiftUI re-render'ı throttle et: saniyede maks 10 güncelleme
        let now = CACurrentMediaTime()
        guard now - lastComboUIUpdateTime >= 0.10 else { return }
        lastComboUIUpdateTime = now

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isComboActive = self.gameState.isComboActive
            self.comboMultiplier = self.gameState.comboMultiplier
            self.comboTimeRemaining = self.gameState.comboTimeRemaining
        }
    }

    // MARK: - Puan Animasyonu
    private func showScoreAnimation(points: Int) {
        lastScoreGain = points
        showScorePopup = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.showScorePopup = false
        }
    }

    // MARK: - Seviye Atlama Kontrolü
    private func checkLevelUp() {
        let newLevel = gameState.currentLevel
        if newLevel != previousLevel {
            let transitionKey = "\(previousLevel.rawValue) → \(newLevel.rawValue)"
            previousLevel = newLevel
            
            if let dialogue = DialogueData.transitions[transitionKey] {
                DispatchQueue.main.async { [weak self] in
                    self?.activeDialogue = dialogue
                }
            } else {
                // Eğer diyalog yoksa normal seviye atlama efektini göster
                DispatchQueue.main.async { [weak self] in
                    self?.isLevelUp = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                    self?.isLevelUp = false
                }
            }
        }
    }

    // MARK: - Oyun Bitti Kontrolü
    private func checkGameOver() {
        if gameState.isGameOver {
            DispatchQueue.main.async { [weak self] in
                self?.triggerFinalGameOver()
            }
        }
    }

    /// Dalgada hiç kill yapılmadığında anında game over tetikler
    func forceGameOver() {
        DispatchQueue.main.async { [weak self] in
            self?.triggerFinalGameOver()
        }
    }

    // MARK: - Kesin Oyun Sonu
    private func triggerFinalGameOver() {
        if gameState.score > storedHighScore {
            storedHighScore = gameState.score
        }
        storedLastLevel = currentLevel.rawValue
        
        // Eğer oyun tamamlanarak bittiyse (C2 bittiyse) Final diyaloğu göster
        if gameState.currentLevel == .c2 && gameState.hp > 0 {
             if let finalDialogue = DialogueData.transitions["Final"] {
                 DispatchQueue.main.async { [weak self] in
                     self?.activeDialogue = finalDialogue
                 }
                 return
             }
        }
        
        isGameOver = true
    }

    // MARK: - Yayınlanan Değerleri Senkronize Et
    private func syncPublishedValues() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.score = self.gameState.score
            self.lives = self.gameState.lives
            self.hp = self.gameState.hp
            self.currentLevel = self.gameState.currentLevel
            self.isComboActive = self.gameState.isComboActive
            self.comboMultiplier = self.gameState.comboMultiplier
            self.comboTimeRemaining = self.gameState.comboTimeRemaining
            
            // İstatistikleri senkronize et
            self.totalWordsLearned = self.gameState.totalWordsLearned
            self.enemiesDestroyed = self.gameState.enemiesDestroyed
            self.wrongAnswers = self.gameState.wrongAnswers
        }
    }

    // MARK: - Sıfırlama
    func reset() {
        restartTrigger += 1          // Sahneye "yeniden başlat" sinyali gönder
        gameState.reset(customMaxLives: selectedShip.maxLives)
        gameState.highScore = storedHighScore
        previousLevel = .a1
        joystickDelta = .zero
        specialAbilityUses = 3
        isGamePaused = false
        isGameOver = false
        isLevelUp = false
        showHint = false
        showScorePopup = false
        revivesUsed = 0
        syncPublishedValues()
        currentTurkishWord = ""
        currentCategory = ""
    }

    // MARK: - Dirilme (Revive)
    func acceptRevive() {
        gameState.revive() // canı full hale getirir
        isGameOver = false
        isGamePaused = false
        revivesUsed += 1
        syncPublishedValues()
        reviveTrigger += 1
    }

    // MARK: - Ses Ayarları (Toggle)
    func toggleMusic() {
        isMusicEnabled.toggle()
    }

    func toggleSfx() {
        isSfxEnabled.toggle()
    }

    // MARK: - Müzik Kontrolü
    func startMusic() {
        if isMusicEnabled {
            AudioManager.shared.playBackgroundMusic(fileName: "Escape_from_Sector_Nine")
        }
    }

    func stopMusic() {
        AudioManager.shared.pauseMusic()
    }

    // MARK: - Yüksek Puan
    var highScore: Int { storedHighScore }

    // MARK: - İstatistikler
    var accuracy: Double { gameState.accuracy }
}

// MARK: - Diyalog Modelleri ve Verisi

/// Bir diyalog girişini temsil eder
struct DialogueEntry: Identifiable, Equatable {
    let id = UUID()
    let characterName: String
    let portraitImage: String
    let text: String
    let transition: String // Örn: "1 → 2"
}

/// Tüm oyun içi diyalogları merkezi olarak tutar
struct DialogueData {
    static let transitions: [String: DialogueEntry] = [
        "A1 → A2": DialogueEntry(
            characterName: "Siber Dron",
            portraitImage: "char_drone",
            text: "Sinyal doğrulandı... Bir Astro-Dilbilimci mi? Bu meteorları geçmen sadece şanstı, gerçek sınav şimdi başlıyor!",
            transition: "A1 → A2"
        ),
        "A2 → B1": DialogueEntry(
            characterName: "Siber Dron",
            portraitImage: "char_drone_damaged",
            text: "Sistem hatası! Kelimeleri toplaman faydasız. 'Nebula' derinliklerinde Yüzbaşı Vex seni bekliyor olacak.",
            transition: "A2 → B1"
        ),
        "B1 → B2": DialogueEntry(
            characterName: "Yüzbaşı Vex",
            portraitImage: "char_vex",
            text: "Dronlarımı hurdaya çevirmişsin. Ama 'Challenge' (Meydan Okuma) asıl şimdi başlıyor. Bakalım ışık hızında düşünebiliyor musun?",
            transition: "B1 → B2"
        ),
        "B2 → C1": DialogueEntry(
            characterName: "Yüzbaşı Vex",
            portraitImage: "char_vex_damaged",
            text: "İmkansız! Dil bilgin sandığımdan daha güçlü... Ama Efendi Lexicon'un kara deliğinden kimse sağ çıkamadı!",
            transition: "B2 → C1"
        ),
        "C1 → C2": DialogueEntry(
            characterName: "Lexicon",
            portraitImage: "char_lexicon",
            text: "Vex sadece bir piyondur. Ben ise evrenin unutulmuş hafızasıyım. Son kelimeleri kurtarmak için ruhunu ortaya koymalısın!",
            transition: "C1 → C2"
        ),
        "Final": DialogueEntry(
            characterName: "Lexicon",
            portraitImage: "char_lexicon_damaged",
            text: "Babil Ağı yeniden parlıyor... Kelimeler artık senin ellerinde Astro-Dilbilimci. Galaksiyi sessizlikten kurtardın.",
            transition: "Final"
        )
    ]
}
