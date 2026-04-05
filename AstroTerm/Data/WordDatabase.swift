// WordDatabase.swift
// AstroTerm - İngilizce-Türkçe kelime veritabanı (Zenginleştirilmiş Yedek Liste + Filtreleme Fix)

import Foundation

/// Tüm kelime çiftlerini ve kelime seçim mantığını içerir
final class WordDatabase {

    // MARK: - Tekil Örnek (Singleton)
    static let shared = WordDatabase()
    
    // MARK: - Kelime Deposu
    private var allLoadedWords: [WordPair] = []
    
    // MARK: - Zenginleştirilmiş Yedek Kelimeler (JSON yükleme başarısız olursa tam deneyim için)
    private let fallbackWords: [WordPair] = [
        // A1 (Temel)
        WordPair(turkish: "elma", english: "apple", category: "yiyecek", cefrLevel: "A1"),
        WordPair(turkish: "kedi", english: "cat", category: "hayvan", cefrLevel: "A1"),
        WordPair(turkish: "köpek", english: "dog", category: "hayvan", cefrLevel: "A1"),
        WordPair(turkish: "ev", english: "house", category: "yer", cefrLevel: "A1"),
        WordPair(turkish: "araba", english: "car", category: "ulaşım", cefrLevel: "A1"),
        WordPair(turkish: "su", english: "water", category: "yiyecek", cefrLevel: "A1"),
        WordPair(turkish: "kitap", english: "book", category: "eşya", cefrLevel: "A1"),
        WordPair(turkish: "okul", english: "school", category: "yer", cefrLevel: "A1"),
        WordPair(turkish: "anne", english: "mother", category: "aile", cefrLevel: "A1"),
        WordPair(turkish: "baba", english: "father", category: "aile", cefrLevel: "A1"),
        WordPair(turkish: "kırmızı", english: "red", category: "renk", cefrLevel: "A1"),
        WordPair(turkish: "mavi", english: "blue", category: "renk", cefrLevel: "A1"),
        WordPair(turkish: "yeşil", english: "green", category: "renk", cefrLevel: "A1"),
        WordPair(turkish: "güneş", english: "sun", category: "doğa", cefrLevel: "A1"),
        WordPair(turkish: "ay", english: "moon", category: "doğa", cefrLevel: "A1"),
        WordPair(turkish: "balık", english: "fish", category: "hayvan", cefrLevel: "A1"),
        WordPair(turkish: "kuş", english: "bird", category: "hayvan", cefrLevel: "A1"),
        WordPair(turkish: "el", english: "hand", category: "vücut", cefrLevel: "A1"),
        WordPair(turkish: "göz", english: "eye", category: "vücut", cefrLevel: "A1"),
        WordPair(turkish: "bir", english: "one", category: "sayı", cefrLevel: "A1"),
        WordPair(turkish: "iki", english: "two", category: "sayı", cefrLevel: "A1"),
        WordPair(turkish: "üç", english: "three", category: "sayı", cefrLevel: "A1"),
        WordPair(turkish: "süt", english: "milk", category: "yiyecek", cefrLevel: "A1"),
        WordPair(turkish: "ekmek", english: "bread", category: "yiyecek", cefrLevel: "A1"),
        WordPair(turkish: "kapı", english: "door", category: "ev", cefrLevel: "A1"),

        // A2 (Günlük)
        WordPair(turkish: "arkadaş", english: "friend", category: "kişi", cefrLevel: "A2"),
        WordPair(turkish: "mutlu", english: "happy", category: "duygu", cefrLevel: "A2"),
        WordPair(turkish: "büyük", english: "big", category: "sıfat", cefrLevel: "A2"),
        WordPair(turkish: "küçük", english: "small", category: "sıfat", cefrLevel: "A2"),
        WordPair(turkish: "hızlı", english: "fast", category: "sıfat", cefrLevel: "A2"),
        WordPair(turkish: "yavaş", english: "slow", category: "sıfat", cefrLevel: "A2"),
        WordPair(turkish: "şehir", english: "city", category: "yer", cefrLevel: "A2"),
        WordPair(turkish: "para", english: "money", category: "eşya", cefrLevel: "A2"),
        WordPair(turkish: "gece", english: "night", category: "zaman", cefrLevel: "A2"),
        WordPair(turkish: "sabah", english: "morning", category: "zaman", cefrLevel: "A2"),
        WordPair(turkish: "sıcak", english: "hot", category: "sıfat", cefrLevel: "A2"),
        WordPair(turkish: "soğuk", english: "cold", category: "sıfat", cefrLevel: "A2"),
        WordPair(turkish: "meyve", english: "fruit", category: "yemek", cefrLevel: "A2"),
        WordPair(turkish: "sebze", english: "vegetable", category: "yemek", cefrLevel: "A2"),
        WordPair(turkish: "tren", english: "train", category: "ulaşım", cefrLevel: "A2"),
        WordPair(turkish: "uçak", english: "plane", category: "ulaşım", cefrLevel: "A2"),
        WordPair(turkish: "telefon", english: "phone", category: "eşya", cefrLevel: "A2"),
        WordPair(turkish: "masa", english: "table", category: "eşya", cefrLevel: "A2"),
        WordPair(turkish: "yaz", english: "summer", category: "zaman", cefrLevel: "A2"),
        WordPair(turkish: "kış", english: "winter", category: "zaman", cefrLevel: "A2"),

        // B1 (Orta)
        WordPair(turkish: "deneyim", english: "experience", category: "soyut", cefrLevel: "B1"),
        WordPair(turkish: "önemli", english: "important", category: "sıfat", cefrLevel: "B1"),
        WordPair(turkish: "başarı", english: "success", category: "soyut", cefrLevel: "B1"),
        WordPair(turkish: "gelecek", english: "future", category: "zaman", cefrLevel: "B1"),
        WordPair(turkish: "değişim", english: "change", category: "soyut", cefrLevel: "B1"),
        WordPair(turkish: "problem", english: "issue", category: "soyut", cefrLevel: "B1"),
        WordPair(turkish: "karar", english: "decision", category: "soyut", cefrLevel: "B1"),
        WordPair(turkish: "fırsat", english: "opportunity", category: "soyut", cefrLevel: "B1"),
        WordPair(turkish: "toplum", english: "society", category: "soyut", cefrLevel: "B1"),
        WordPair(turkish: "güzel", english: "beautiful", category: "sıfat", cefrLevel: "B1"),
        WordPair(turkish: "çevre", english: "environment", category: "doğa", cefrLevel: "B1"),
        WordPair(turkish: "yetenek", english: "talent", category: "soyut", cefrLevel: "B1"),
        WordPair(turkish: "bilgi", english: "knowledge", category: "soyut", cefrLevel: "B1"),
        WordPair(turkish: "öğrenmek", english: "learn", category: "eylem", cefrLevel: "B1"),
        WordPair(turkish: "seyahat", english: "travel", category: "eylem", cefrLevel: "B1"),

        // B2 (Üst-Orta)
        WordPair(turkish: "strateji", english: "strategy", category: "soyut", cefrLevel: "B2"),
        WordPair(turkish: "karmaşık", english: "complex", category: "sıfat", cefrLevel: "B2"),
        WordPair(turkish: "analiz", english: "analysis", category: "akademik", cefrLevel: "B2"),
        WordPair(turkish: "küresel", english: "global", category: "sıfat", cefrLevel: "B2"),
        WordPair(turkish: "etki", english: "impact", category: "soyut", cefrLevel: "B2"),
        WordPair(turkish: "çözüm", english: "solution", category: "soyut", cefrLevel: "B2"),
        WordPair(turkish: "kaynak", english: "resource", category: "soyut", cefrLevel: "B2"),
        WordPair(turkish: "verimli", english: "efficient", category: "sıfat", cefrLevel: "B2"),
        WordPair(turkish: "mantıklı", english: "logical", category: "sıfat", cefrLevel: "B2"),
        WordPair(turkish: "meydan okuma", english: "challenge", category: "soyut", cefrLevel: "B2"),

        // C1 (İleri)
        WordPair(turkish: "kavram", english: "concept", category: "akademik", cefrLevel: "C1"),
        WordPair(turkish: "bağlam", english: "context", category: "akademik", cefrLevel: "C1"),
        WordPair(turkish: "soyut", english: "abstract", category: "sıfat", cefrLevel: "C1"),
        WordPair(turkish: "meşru", english: "legitimate", category: "sıfat", cefrLevel: "C1"),
        WordPair(turkish: "tutarlı", english: "coherent", category: "sıfat", cefrLevel: "C1"),
        WordPair(turkish: "titiz", english: "meticulous", category: "sıfat", cefrLevel: "C1"),
        WordPair(turkish: "öngörü", english: "foresight", category: "soyut", cefrLevel: "C1"),

        // C2 (Ustalık)
        WordPair(turkish: "paradigma", english: "paradigm", category: "akademik", cefrLevel: "C2"),
        WordPair(turkish: "derin", english: "profound", category: "sıfat", cefrLevel: "C2"),
        WordPair(turkish: "eskimiş", english: "obsolete", category: "sıfat", cefrLevel: "C2"),
        WordPair(turkish: "geçici", english: "ephemeral", category: "sıfat", cefrLevel: "C2"),
        WordPair(turkish: "incelikli", english: "nuanced", category: "sıfat", cefrLevel: "C2")
    ]
    
    private init() {
        loadWords()
    }

    // MARK: - Yükleme Mantığı
    private func loadWords() {
        let fileVariants = ["words", "Words"]
        let subDirectories = [nil, "Data", "Data/"]
        
        // 1. Yol: Bundle'da her ihtimali ara
        for fileName in fileVariants {
            for subDir in subDirectories {
                if let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: subDir) {
                    if let data = try? Data(contentsOf: url),
                       let decoded = try? JSONDecoder().decode([WordPair].self, from: data) {
                        self.allLoadedWords = decoded
                        self.allLoadedWords.shuffle() // Her seans farklı gelsin
                        print("DEBUG: ✅ JSON Bundle'dan yüklendi (\(url.lastPathComponent)) - \(allLoadedWords.count) kelime karıştırıldı.")
                        return
                    }
                }
            }
        }
        
        // 2. Yol: Hiçbiri olmazsa kod içindeki yedekleri kullan
        self.allLoadedWords = fallbackWords
        self.allLoadedWords.shuffle()
        print("DEBUG: ❌ JSON Bundle'da bulunamadı. Yedek kelimeler karıştırıldı.")
    }

    // MARK: - Seviye Bazlı Kelime Getirme
    func words(for level: CEFRLevel) -> [WordPair] {
        let filtered = allLoadedWords.filter { $0.cefrLevel.uppercased() == level.rawValue.uppercased() }
        // Eğer o seviyede hiç kelime bulunamazsa yedek listeden getir
        return filtered.isEmpty ? fallbackWords.filter { $0.cefrLevel.uppercased() == level.rawValue.uppercased() } : filtered
    }

    // MARK: - Dalga Oluşturma

    /// Bir dalga için hedef kelime ve dikkat dağıtıcı kelimeleri seç
    func generateWave(for level: CEFRLevel, excluding usedPairs: [WordPair] = []) -> (target: WordPair, distractors: [WordPair]) {
        // 1. O seviyeye ait tüm kelimeleri al
        let levelWords = words(for: level)
        
        // 2. Bu oyun seansında daha önce doğru cevaplanmış tüm kelimeleri hariç tut
        let learnedIds = Set(usedPairs.map { $0.id })
        var availableTargetPool = levelWords.filter { !learnedIds.contains($0.id) }
        
        // Eğer havuz bittiyse (tüm kelimeler öğrenildiyse), o seviyeyi sıfırla
        if availableTargetPool.isEmpty {
            print("DEBUG: \(level.rawValue) havuzu tükendi, tekrar karıştırılıyor.")
            availableTargetPool = levelWords
        }

        // 3. Hedef kelimeyi rastgele seç
        let target = availableTargetPool.randomElement()!

        // 4. Dikkat dağıtıcıları seç (Yanlış cevap seçenekleri)
        // Kritik Fix: Dikkat dağıtıcılar ARASINDA da daha önce bilinmiş kelimeler OLMAMALI (fresh hissettirmesi için)
        var distractorPool = allLoadedWords.filter { 
            $0.id != target.id && !learnedIds.contains($0.id)
        }
        
        // Eğer çok fazla kelime bilindiyse ve distractor havuzu boşaldıysa, tüm listeden al (ama hedefi hariç tut)
        if distractorPool.count < 2 {
            distractorPool = allLoadedWords.filter { $0.id != target.id }
        }

        let shuffledDistractors = distractorPool.shuffled()
        var distractors: [WordPair] = []
        for i in 0..<min(2, shuffledDistractors.count) {
            distractors.append(shuffledDistractors[i])
        }

        print("DEBUG: Yeni dalga oluşturuldu - Hedef: \(target.english), Bilinen Kelime Sayısı: \(usedPairs.count)")
        return (target: target, distractors: distractors)
    }

    // MARK: - İpucu Kategorisi İkonu
    func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "hayvan":    return "🐾"
        case "yiyecek", "yemek": return "🍎"
        case "renk":      return "🎨"
        case "sayı":      return "🔢"
        case "vücut":     return "🫁"
        case "aile":      return "👨‍👩‍👧"
        case "eşya":      return "📦"
        case "yer":       return "📍"
        case "doğa":      return "🌿"
        case "ulaşım":    return "🚗"
        case "zaman":     return "⏰"
        case "sıfat":     return "✨"
        case "duygu":     return "💖"
        case "soyut":     return "💭"
        case "akademik":  return "🎓"
        case "edebi":     return "📚"
        case "eylem":     return "⚡"
        default:          return "🌟" // Genel kategori simgesi
        }
    }
}
