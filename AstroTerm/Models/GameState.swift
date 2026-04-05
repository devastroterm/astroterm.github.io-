// GameState.swift
// AstroTerm - Oyun durumu ve puan yönetimi

import Foundation

/// Oyunun anlık durumunu tutan model
struct GameState: Codable {

    // MARK: - Temel Değerler
    var score: Int = 0
    var lives: Int = 3
    var maxLives: Int = 3
    var currentLevel: CEFRLevel = .a1
    var highScore: Int = 0
    var totalWordsLearned: Int = 0

    // MARK: - Kombo Sistemi
    var correctStreak: Int = 0          // Ardışık doğru cevap sayısı
    var comboMultiplier: Double = 1.0   // Puan çarpanı (max 2x)
    var isComboActive: Bool = false     // 5 ardışık doğru → kombo aktif
    var comboTimeRemaining: Double = 0  // Kombo kalan süre (saniye)

    // MARK: - Özel Yetenek
    var specialAbilityUses: Int = 3     // Yavaşlatma yeteneği kullanım hakkı

    // MARK: - Can Barı (HP)
    var hp: Double = 1.0  // 0.0 - 1.0 arası

    // MARK: - İstatistikler
    var correctAnswers: Int = 0
    var wrongAnswers: Int = 0
    var enemiesDestroyed: Int = 0
    var wavesCompleted: Int = 0

    // MARK: - Puan Ekleme
    mutating func addScore(_ basePoints: Int) {
        let multiplied = Int(Double(basePoints) * comboMultiplier)
        score += multiplied
        if score > highScore {
            highScore = score
        }
        // Seviyeyi güncelle (Doğru cevap sayısına göre)
        currentLevel = CEFRLevel.level(forCorrectAnswers: correctAnswers)
    }

    // MARK: - Can Yönetimi
    mutating func loseLife() {
        guard lives > 0 else { return }
        lives -= 1
        hp = lives > 0 ? Double(lives) / Double(maxLives) : 0.0
    }

    mutating func gainLife() {
        guard lives < maxLives else { return }
        lives += 1
        hp = Double(lives) / Double(maxLives)
    }

    // MARK: - Kombo Güncelleme
    mutating func updateCombo(correct: Bool) {
        if correct {
            correctAnswers += 1
            correctStreak += 1
            if correctStreak >= 5 {
                isComboActive = true
                comboMultiplier = 2.0
                comboTimeRemaining = 10.0
            }
        } else {
            wrongAnswers += 1
            correctStreak = 0
            isComboActive = false
            comboMultiplier = 1.0
            comboTimeRemaining = 0
        }
    }

    /// Kombo zamanlayıcısını güncelle (delta time)
    mutating func tickCombo(deltaTime: Double) {
        guard isComboActive else { return }
        comboTimeRemaining -= deltaTime
        if comboTimeRemaining <= 0 {
            isComboActive = false
            comboMultiplier = 1.0
            comboTimeRemaining = 0
        }
    }

    // MARK: - Oyun Bitti mi?
    var isGameOver: Bool { lives <= 0 }

    // MARK: - Doğruluk Yüzdesi
    var accuracy: Double {
        let total = correctAnswers + wrongAnswers
        guard total > 0 else { return 0 }
        return Double(correctAnswers) / Double(total) * 100
    }

    // MARK: - Canlanma (Revive)
    /// Oyuncuyu tam canla diriltir — skor ve seviye korunur.
    mutating func revive() {
        lives = maxLives
        hp = 1.0
    }

    /// Ödüllü başlangıç: 1 ekstra can bonusu ile başla.
    mutating func applyBonusLife() {
        maxLives = 4
        lives = 4
        hp = 1.0
    }

    // MARK: - Sıfırlama
    mutating func reset() {
        score = 0
        lives = 3
        maxLives = 3
        hp = 1.0
        currentLevel = .a1
        correctStreak = 0
        comboMultiplier = 1.0
        isComboActive = false
        comboTimeRemaining = 0
        specialAbilityUses = 3
        correctAnswers = 0
        wrongAnswers = 0
        enemiesDestroyed = 0
        wavesCompleted = 0
        totalWordsLearned = 0
    }
}
