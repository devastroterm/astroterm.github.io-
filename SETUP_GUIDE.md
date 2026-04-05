# GalaxyWords — Xcode Kurulum Rehberi

## 📱 Proje Bilgileri
- **Bundle ID:** com.galaxywords.app
- **Minimum iOS:** 16.0
- **Mimari:** Swift 5.9 + SwiftUI + SpriteKit
- **Yön:** Yalnızca Yatay (Landscape)

---

## 🛠 Xcode Kurulum Adımları

### 1. Yeni Xcode Projesi Oluştur
1. Xcode'u aç → **File → New → Project**
2. **iOS → App** şablonunu seç
3. Aşağıdaki bilgileri gir:
   - **Product Name:** GalaxyWords
   - **Team:** Kendi Apple geliştirici hesabın
   - **Organization Identifier:** com.galaxywords
   - **Bundle Identifier:** com.galaxywords.app
   - **Interface:** SwiftUI
   - **Language:** Swift
4. Kaydet

### 2. Dosya Yapısını Kur
Xcode'da oluşturulan varsayılan `ContentView.swift` ve `GalaxyWordsApp.swift` dosyalarını **sil** (trash'e taşı).

Ardından şu klasör yapısını oluştur:
- **GalaxyWords/** (mevcut)
  - Views/
  - Game/
  - Models/
  - Data/

### 3. Swift Dosyalarını Ekle
Bu paketteki tüm `.swift` dosyalarını Xcode projesine sürükle-bırak:

```
GalaxyWords/
├── GalaxyWordsApp.swift          ← Kök
├── ContentView.swift             ← Kök
├── Views/
│   ├── MainMenuView.swift
│   ├── OnboardingView.swift
│   ├── GameContainerView.swift
│   ├── HUDOverlayView.swift
│   ├── GameOverView.swift
│   └── LevelUpView.swift
├── Game/
│   ├── GameScene.swift
│   ├── GameViewModel.swift
│   ├── PlayerShipNode.swift
│   ├── EnemyShipNode.swift
│   ├── PlanetNode.swift
│   ├── StarfieldNode.swift
│   ├── BulletNode.swift
│   ├── ExplosionNode.swift
│   └── JoystickView.swift
├── Models/
│   ├── WordPair.swift
│   ├── CEFRLevel.swift
│   └── GameState.swift
└── Data/
    └── WordDatabase.swift
```

### 4. SpriteKit Framework Ekle
1. **Project Navigator** → Proje adına tıkla
2. **Targets → GalaxyWords → General → Frameworks, Libraries, and Embedded Content**
3. `+` → **SpriteKit.framework** ekle
4. `+` → **AVFoundation.framework** ekle (ses için)

### 5. Info.plist Ayarları
**Info.plist** dosyasına şu anahtarları ekle:

```xml
<!-- Yatay mod zorlaması -->
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>

<!-- iPhone yatay mod -->
<key>UISupportedInterfaceOrientations~iphone</key>
<array>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>

<!-- Durum çubuğunu gizle -->
<key>UIStatusBarHidden</key>
<true/>

<!-- Tam ekran -->
<key>UIRequiresFullScreen</key>
<true/>
```

### 6. AppDelegate Bağlantısı
`GalaxyWordsApp.swift` içindeki `AppDelegate` sınıfını uygulamaya bağlamak için `@UIApplicationDelegateAdaptor` kullan:

Dosyanın `@main struct GalaxyWordsApp` kısmını şöyle güncelle:

```swift
@main
struct GalaxyWordsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea()
                .preferredColorScheme(.dark)
        }
    }
}
```

### 7. Deployment Target
- **Project Navigator → GalaxyWords → Build Settings**
- `iOS Deployment Target` → **16.0** olarak ayarla

---

## 🎮 Oynanış Özeti

| Kontrol | İşlev |
|---------|-------|
| **Sol joystick** | Gemi yukarı/aşağı/sol/sağ hareket |
| **🔥 Ateş butonu** | Lazer ateşle |
| **⚡ Yetenek butonu** | 3 saniyelik yavaşlatma (3 kullanım) |
| **Düşmana dokun** | Otomatik hedefle + ateşle |
| **💡 İpucu butonu** | Kategori ikonunu göster |
| **⏸ Duraklat** | Oyunu duraklat |

---

## 📊 CEFR Seviyeleri

| Seviye | Puan | Düşman | Hız | Özellik |
|--------|------|--------|-----|---------|
| A1 | 0-30 | 1 | Yavaş | Temel kelimeler |
| A2 | 31-70 | 2 | Orta | Günlük yaşam |
| B1 | 71-120 | 3 | Orta+ | V formasyonu |
| B2 | 121-200 | 4 | Hızlı | Zigzag formasyon |
| C1 | 201-300 | 5 | Çok hızlı | Karmaşık kelimeler |
| C2 | 301+ | 6 | Max hız | Düşmanlar ateş ediyor! |

---

## 🗂 Dosya Yapısı Açıklaması

### Models/
- **WordPair.swift** — İngilizce-Türkçe kelime çifti modeli
- **CEFRLevel.swift** — CEFR seviyeleri, oyun özellikleri, renk temaları
- **GameState.swift** — Puan, can, kombo durumu

### Data/
- **WordDatabase.swift** — 200+ kelime, dalga oluşturma mantığı

### Game/ (SpriteKit)
- **GameScene.swift** — Ana oyun mantığı, fizik, çarpışma tespiti
- **GameViewModel.swift** — SwiftUI↔SpriteKit köprüsü
- **PlayerShipNode.swift** — Oyuncu gemisi (programatik çizim)
- **EnemyShipNode.swift** — Düşman gemileri (6 farklı stil)
- **PlanetNode.swift** — Prosedürel gezegen oluşturma
- **StarfieldNode.swift** — Titreyen yıldız arka planı
- **BulletNode.swift** — Lazer mermileri ve iz efektleri
- **ExplosionNode.swift** — SKEmitterNode patlama efektleri
- **JoystickView.swift** — SwiftUI sanal joystick + aksiyon butonları

### Views/ (SwiftUI)
- **ContentView.swift** — Ekran navigasyonu
- **MainMenuView.swift** — Animasyonlu ana menü
- **OnboardingView.swift** — 3 ekranlı Türkçe rehber
- **GameContainerView.swift** — SpriteView + HUD sarmalayıcı
- **HUDOverlayView.swift** — Avatar, HP çubuğu, kelime paneli, joystick
- **GameOverView.swift** — İstatistikler ve yeniden başlatma
- **LevelUpView.swift** — Seviye atlama kutlaması

---

## 🔧 Olası Sorunlar ve Çözümler

**"Cannot find type 'SKScene'"**
→ SpriteKit.framework projeye eklenmemiş. Adım 4'ü tekrar yap.

**"AppDelegate not connected"**
→ GalaxyWordsApp.swift'e `@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate` ekle.

**Oyun portre modda açılıyor**
→ Info.plist'e yatay yön ayarlarını ekle (Adım 5).

**Ses çalışmıyor (Simulator)**
→ Ses simülatörde çalışmayabilir. Gerçek cihazda test et.

---

*Geliştirilen: GalaxyWords v1.0 — İngilizce-Türkçe Uzay Macerası*
