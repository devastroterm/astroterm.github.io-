// CEFRLevel.swift
// AstroTerm - CEFR dil seviyeleri ve oyun zorlukları

import SwiftUI

/// CEFR seviyelerini ve her seviyenin oyun özelliklerini tanımlar
enum CEFRLevel: String, CaseIterable, Codable, Identifiable {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"
    case b2 = "B2"
    case c1 = "C1"
    case c2 = "C2"

    var id: String { rawValue }

    // MARK: - Doğru Cevap Eşikleri

    /// Bu seviyeye ulaşmak için gereken toplam doğru cevap sayısı (kümülatif)
    var correctAnswersThreshold: Int {
        switch self {
        case .a1: return 0
        case .a2: return 20
        case .b1: return 40
        case .b2: return 60
        case .c1: return 80
        case .c2: return 100
        }
    }

    // MARK: - Düşman Özellikleri

    /// Bu seviyede aynı anda ekrandaki düşman sayısı
    var enemyCount: Int {
        switch self {
        case .a1: return 1
        case .a2: return 2
        case .b1: return 3
        case .b2: return 4
        case .c1: return 5
        case .c2: return 6
        }
    }

    /// Düşman gemi hızı (nokta/saniye)
    var enemySpeed: CGFloat {
        switch self {
        case .a1: return 62.5
        case .a2: return 81.25
        case .b1: return 100
        case .b2: return 118.75
        case .c1: return 137.5
        case .c2: return 156.25
        }
    }

    /// C2 seviyesinde düşmanlar karşılık ateşleme yapabilir
    var enemiesShootBack: Bool { self == .c2 }

    /// Dalgalar arası bekleme süresi (saniye) — üst seviyelerde daha uzun nefes payı
    var waveTransitionDelay: TimeInterval {
        switch self {
        case .a1: return 0.9
        case .a2: return 0.8
        case .b1: return 0.8
        case .b2: return 0.9
        case .c1: return 1.0
        case .c2: return 1.1
        }
    }

    /// Dalga başına dikkat dağıtıcı kelime sayısı (yanlış cevap seçenekleri)
    /// Toplam ekranda 3 kelime (1 Hedef + 2 Dikkat Dağıtıcı) gösterilir.
    var distractorCount: Int {
        return 2
    }

    // MARK: - Görsel Tema

    /// Gezegen renk teması
    var planetColors: (primary: Color, secondary: Color, crater: Color) {
        switch self {
        case .a1: return (.init(red: 0.95, green: 0.92, blue: 0.98),
                          .init(red: 0.88, green: 0.82, blue: 0.92),
                          .init(red: 0.82, green: 0.75, blue: 0.88))
        case .a2: return (.init(red: 0.80, green: 0.35, blue: 0.15),
                          .init(red: 0.65, green: 0.25, blue: 0.10),
                          .init(red: 0.55, green: 0.20, blue: 0.08))
        case .b1: return (.init(red: 0.20, green: 0.60, blue: 0.55),
                          .init(red: 0.15, green: 0.48, blue: 0.44),
                          .init(red: 0.12, green: 0.38, blue: 0.36))
        case .b2: return (.init(red: 0.55, green: 0.20, blue: 0.70),
                          .init(red: 0.45, green: 0.15, blue: 0.58),
                          .init(red: 0.35, green: 0.10, blue: 0.48))
        case .c1: return (.init(red: 0.25, green: 0.05, blue: 0.05),
                          .init(red: 0.40, green: 0.08, blue: 0.08),
                          .init(red: 0.60, green: 0.15, blue: 0.10))
        case .c2: return (.init(red: 0.15, green: 0.70, blue: 0.65),
                          .init(red: 0.10, green: 0.55, blue: 0.52),
                          .init(red: 0.20, green: 0.80, blue: 0.75))
        }
    }

    /// Düşman gemi rengi (SpriteKit UIColor uyumlu değerler)
    var enemyColorComponents: (r: CGFloat, g: CGFloat, b: CGFloat) {
        switch self {
        case .a1: return (0.60, 0.20, 0.80)   // Mor
        case .a2: return (0.10, 0.75, 0.60)   // Camgöbeği
        case .b1: return (0.15, 0.45, 0.90)   // Mavi
        case .b2: return (0.95, 0.55, 0.10)   // Turuncu
        case .c1: return (0.90, 0.15, 0.15)   // Kırmızı
        case .c2: return (0.30, 0.10, 0.50)   // Koyu Mor
        }
    }

    /// Seviye teması için ana renk (Lottie arka planı vb. için)
    var themeColor: Color {
        let components = enemyColorComponents
        return Color(red: components.r, green: components.g, blue: components.b)
    }

    // MARK: - Gezegen Adı
    var planetName: String {
        switch self {
        case .a1: return "Rüya Gökyüzü"
        case .a2: return "Mars"
        case .b1: return "Yeşil Asteroit"
        case .b2: return "Mor Gaz Devi"
        case .c1: return "Volkanik Gezegen"
        case .c2: return "Kristal Dünya"
        }
    }

    // MARK: - Dalga Formasyon Türü
    enum WaveFormation { case line, vShape, zigzag }

    var waveFormation: WaveFormation {
        switch self {
        case .a1, .a2: return .line
        case .b1, .b2: return .vShape
        case .c1, .c2: return .zigzag
        }
    }

    // MARK: - Sonraki Seviye
    var nextLevel: CEFRLevel? {
        switch self {
        case .a1: return .a2
        case .a2: return .b1
        case .b1: return .b2
        case .b2: return .c1
        case .c1: return .c2
        case .c2: return nil
        }
    }

    /// Verilen doğru cevap sayısına göre uygun seviyeyi döndür
    static func level(forCorrectAnswers count: Int) -> CEFRLevel {
        if count >= 100 { return .c2 }
        if count >= 80  { return .c1 }
        if count >= 60  { return .b2 }
        if count >= 40  { return .b1 }
        if count >= 20  { return .a2 }
        return .a1
    }
}
