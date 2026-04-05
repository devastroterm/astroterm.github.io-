// WordPair.swift
// AstroTerm - İngilizce-Türkçe kelime çifti modeli

import Foundation

/// İngilizce ve Türkçe kelime çiftini temsil eden model
struct WordPair: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let turkish: String      // Türkçe kelime (HUD'da gösterilir)
    let english: String      // İngilizce kelime (düşman gemide gösterilir)
    let category: String     // Kelime kategorisi (hayvanlar, renkler vb.)
    let cefrLevel: String    // CEFR seviyesi (A1, A2, B1 vb.)

    init(id: UUID = UUID(),
         turkish: String,
         english: String,
         category: String,
         cefrLevel: String) {
        self.id = id
        self.turkish = turkish
        self.english = english
        self.category = category
        self.cefrLevel = cefrLevel
    }

    /// Hashable uyumu için sadece id kullan
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: WordPair, rhs: WordPair) -> Bool {
        lhs.id == rhs.id
    }
}
