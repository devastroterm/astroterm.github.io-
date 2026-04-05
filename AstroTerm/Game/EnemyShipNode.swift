// EnemyShipNode.swift
// AstroTerm - Düşman uzay gemisi: kelime etiketi ve seviye bazlı görünüm

import SpriteKit

/// Düşman gemi tipi — her CEFR seviyesi için ayrı görünüm
enum EnemyShipType {
    case a1Round        // Küçük yuvarlak mor gemi
    case a2Gear         // Vites süslü yeşil gemi
    case b1SharkFin     // Köpekbalığı yüzgeci mavi gemi
    case b2Mechanical   // Mekanik turuncu gemi
    case c1Boss         // Büyük kırmızı patron gemi
    case c2Flagship     // Koyu mor amiral gemisi

    static func type(for level: CEFRLevel) -> EnemyShipType {
        switch level {
        case .a1: return .a1Round
        case .a2: return .a2Gear
        case .b1: return .b1SharkFin
        case .b2: return .b2Mechanical
        case .c1: return .c1Boss
        case .c2: return .c2Flagship
        }
    }
}

/// Bir İngilizce kelime taşıyan düşman gemi düğümü
final class EnemyShipNode: SKNode {

    // MARK: - Fizik Kategorisi
    static let physicsCategory: UInt32 = 0x1 << 1

    // MARK: - Özellikler
    let wordPair: WordPair
    let isCorrectTarget: Bool      // Bu gemi doğru cevabı taşıyor mu?
    let shipType: EnemyShipType
    private(set) var level: CEFRLevel

    private var shipBody: SKNode!
    private var wordLabel: SKLabelNode!
    private var wordBubble: SKShapeNode!
    private var selectionGlow: SKShapeNode!
    private var oscilationOffset: CGFloat = 0  // Salınım faz farkı

    // MARK: - Başlatma
    init(wordPair: WordPair, isCorrectTarget: Bool, level: CEFRLevel, oscOffset: CGFloat = 0) {
        self.wordPair = wordPair
        self.isCorrectTarget = isCorrectTarget
        self.level = level
        self.shipType = EnemyShipType.type(for: level)
        self.oscilationOffset = oscOffset
        super.init()
        buildShip()
        buildWordBubble()
        buildSelectionGlow()
        setupPhysics()
        startOscillation()
    }

    required init?(coder aDecoder: NSCoder) {
        self.wordPair = WordPair(turkish: "", english: "", category: "", cefrLevel: "A1")
        self.isCorrectTarget = false
        self.level = .a1
        self.shipType = .a1Round
        super.init(coder: aDecoder)
    }

    // MARK: - Gemi İnşası (Seviyeye Göre)
    private func buildShip() {
        let colors = level.enemyColorComponents
        let primaryColor = UIColor(red: colors.r, green: colors.g, blue: colors.b, alpha: 1.0)
        let darkColor = UIColor(red: colors.r * 0.5, green: colors.g * 0.5, blue: colors.b * 0.5, alpha: 1.0)
        let lightColor = UIColor(red: min(colors.r + 0.3, 1), green: min(colors.g + 0.3, 1), blue: min(colors.b + 0.3, 1), alpha: 1.0)

        switch shipType {
        case .a1Round:      buildRoundShip(primary: primaryColor, dark: darkColor, light: lightColor)
        case .a2Gear:       buildGearShip(primary: primaryColor, dark: darkColor, light: lightColor)
        case .b1SharkFin:   buildSharkFinShip(primary: primaryColor, dark: darkColor, light: lightColor)
        case .b2Mechanical: buildMechanicalShip(primary: primaryColor, dark: darkColor, light: lightColor)
        case .c1Boss:       buildBossShip(primary: primaryColor, dark: darkColor, light: lightColor)
        case .c2Flagship:   buildFlagshipShip(primary: primaryColor, dark: darkColor, light: lightColor)
        }
    }

    // MARK: - A1: Yuvarlak Gemi (Sprite tabanlı)
    private func buildRoundShip(primary: UIColor, dark: UIColor, light: UIColor) {
        let sprite = SKSpriteNode(imageNamed: "enemy_a1")
        // Görselde motor aşağı bakıyor; oyunda düşman sola baktığından 90° saat yönünde döndür
        sprite.zRotation = -.pi / 2
        sprite.size = CGSize(width: 72, height: 72)
        sprite.zPosition = 2
        addChild(sprite)

        // Motor alevi (görselin orijinal alt kısmı artık sol taraf = oyuncuya zıt yön)
        addEngineGlow(positions: [CGPoint(x: 32, y: 0)],
                      color: UIColor(red: 1.0, green: 0.55, blue: 0.10, alpha: 0.85))
    }

    // MARK: - A2: Dişli Gemi (Sprite tabanlı)
    private func buildGearShip(primary: UIColor, dark: UIColor, light: UIColor) {
        let sprite = SKSpriteNode(imageNamed: "enemy_a2")
        // Görselde burun yukarı, motor aşağı — oyunda sola baktığından 90° saat yönünde döndür
        sprite.zRotation = -.pi / 2
        sprite.size = CGSize(width: 80, height: 80)
        sprite.zPosition = 2
        addChild(sprite)

        // Motor alevi (görselin alt kısmı = oyunda sağ taraf = geminin arkası)
        addEngineGlow(positions: [CGPoint(x: 36, y: 0)],
                      color: UIColor(red: 1.0, green: 0.55, blue: 0.10, alpha: 0.85))
    }

    // MARK: - B1: Köpekbalığı Kanat Gemi (Sprite tabanlı)
    private func buildSharkFinShip(primary: UIColor, dark: UIColor, light: UIColor) {
        let sprite = SKSpriteNode(imageNamed: "enemy_b1")
        // Görselde burun sağ-üst (~45°), motor sol-alt.
        // Oyunda sola bakması için 135° CCW (= 3π/4 rad) döndür.
        sprite.zRotation = .pi * 3.0 / 4.0
        sprite.size = CGSize(width: 85, height: 85)
        sprite.zPosition = 2
        addChild(sprite)

        // Motor alevi: 135° döndükten sonra motorlar sağ tarafa gelir
        addEngineGlow(positions: [CGPoint(x: 36, y: 6), CGPoint(x: 36, y: -6)],
                      color: UIColor(red: 0.30, green: 0.80, blue: 1.0, alpha: 0.85))
    }

    // MARK: - B2: Mekanik Gemi (Sprite tabanlı)
    private func buildMechanicalShip(primary: UIColor, dark: UIColor, light: UIColor) {
        let sprite = SKSpriteNode(imageNamed: "enemy_b2")
        // Gemi tamamen simetrik — rotasyon gerekmez, doğrudan kullan
        sprite.zRotation = 0
        sprite.size = CGSize(width: 85, height: 85)
        sprite.zPosition = 2
        addChild(sprite)

        // Merkez çekirdek nabzı (sprite üstüne overlay)
        let core = SKShapeNode(circleOfRadius: 8)
        core.fillColor = UIColor(red: 1.0, green: 0.60, blue: 0.10, alpha: 0.6)
        core.strokeColor = .clear
        core.zPosition = 3
        addChild(core)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.9),
            SKAction.scale(to: 0.85, duration: 0.9),
        ])
        core.run(SKAction.repeatForever(pulse))

        // Motor alevi sağ taraftan (oyuncuya zıt yön)
        addEngineGlow(positions: [CGPoint(x: 38, y: 0)],
                      color: UIColor(red: 1.0, green: 0.55, blue: 0.10, alpha: 0.80))
    }

    // MARK: - C1: Boss Gemi (Sprite tabanlı)
    private func buildBossShip(primary: UIColor, dark: UIColor, light: UIColor) {
        let sprite = SKSpriteNode(imageNamed: "enemy_c1")
        // Görselde cannons yukarıda (kuzey), oyunda sola bakması için 90° CW (-π/2)
        sprite.zRotation = -.pi / 2
        sprite.size = CGSize(width: 100, height: 100)
        sprite.zPosition = 2
        addChild(sprite)

        // Kırmızı orb nabız efekti (sprite üstüne overlay)
        for xOff in [-12, 12] as [CGFloat] {
            let orb = SKShapeNode(circleOfRadius: 6)
            orb.position = CGPoint(x: 0, y: xOff)  // döndükten sonra y ekseninde
            orb.fillColor = UIColor(red: 1.0, green: 0.10, blue: 0.10, alpha: 0.5)
            orb.strokeColor = .clear
            orb.zPosition = 3
            addChild(orb)
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.4, duration: 0.8),
                SKAction.scale(to: 0.75, duration: 0.8),
            ])
            orb.run(SKAction.repeatForever(pulse))
        }

        // Motor alevi: 90° CW döndükten sonra motorlar (görselin alt kısmı) sağa gelir
        addEngineGlow(positions: [CGPoint(x: 42, y: 8), CGPoint(x: 42, y: -8), CGPoint(x: 42, y: 0)],
                      color: UIColor(red: 1.0, green: 0.20, blue: 0.10, alpha: 0.85))
    }

    // MARK: - C2: Amiral Gemisi (Sprite tabanlı)
    private func buildFlagshipShip(primary: UIColor, dark: UIColor, light: UIColor) {
        let sprite = SKSpriteNode(imageNamed: "enemy_c2")
        // Gemi tamamen simetrik — rotasyon gerekmez
        sprite.zRotation = 0
        sprite.size = CGSize(width: 110, height: 110)
        sprite.zPosition = 2
        addChild(sprite)

        // Mor kalkan nabzı (sprite üstüne, C2'nin en belirgin özelliği)
        let shield = SKShapeNode(circleOfRadius: 52)
        shield.fillColor = UIColor(red: 0.30, green: 0.10, blue: 0.55, alpha: 0.15)
        shield.strokeColor = UIColor(red: 0.70, green: 0.30, blue: 1.0, alpha: 0.70)
        shield.lineWidth = 2
        shield.zPosition = 1
        addChild(shield)

        let shieldPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.15, duration: 1.4),
            SKAction.fadeAlpha(to: 0.85, duration: 1.4),
        ])
        shield.run(SKAction.repeatForever(shieldPulse))

        // Motor alevi — simetrik olduğundan sağ tarafa ekliyoruz (oyuncuya zıt yön)
        addEngineGlow(positions: [
            CGPoint(x: 48, y: 10),
            CGPoint(x: 48, y: -10),
            CGPoint(x: 48, y: 0)
        ], color: UIColor(red: 0.60, green: 0.15, blue: 1.0, alpha: 0.85))
    }

    // MARK: - Motor Işıltısı
    // Performans: flicker adım süresi 0.1s → 0.25s (GPU güncelleme sıklığı %60 azaldı)
    private func addEngineGlow(positions: [CGPoint], color: UIColor) {
        for pos in positions {
            let glow = SKShapeNode(ellipseOf: CGSize(width: 16, height: 10))
            glow.position = pos
            glow.fillColor = color
            glow.strokeColor = color.withAlphaComponent(0.5)
            glow.lineWidth = 1
            glow.zPosition = -1
            addChild(glow)

            let flicker = SKAction.sequence([
                SKAction.scaleX(to: 1.3, y: 0.7, duration: 0.25),
                SKAction.scaleX(to: 0.8, y: 1.2, duration: 0.25),
                SKAction.scaleX(to: 1.0, y: 1.0, duration: 0.25),
            ])
            glow.run(SKAction.repeatForever(flicker))
        }
    }

    // MARK: - Kelime Baloncuğu
    private func buildWordBubble() {
        // Kelime etiketi
        wordLabel = SKLabelNode(text: wordPair.english)
        wordLabel.fontName = "AvenirNext-Bold"
        wordLabel.fontSize = 12
        wordLabel.fontColor = .white
        wordLabel.horizontalAlignmentMode = .center
        wordLabel.verticalAlignmentMode = .center
        wordLabel.zPosition = 12

        // Baloncuk arka planı — daha dar ve kompakt
        let textWidth = CGFloat(wordPair.english.count) * 7.0 + 12
        wordBubble = SKShapeNode(rectOf: CGSize(width: max(textWidth, 44), height: 20), cornerRadius: 6)
        wordBubble.fillColor = UIColor(red: 0.05, green: 0.05, blue: 0.20, alpha: 0.88)
        wordBubble.strokeColor = UIColor(red: 0.60, green: 0.60, blue: 0.90, alpha: 0.70)
        wordBubble.lineWidth = 1.0
        wordBubble.position = CGPoint(x: 0, y: 44)
        wordBubble.zPosition = 11
        addChild(wordBubble)
        wordBubble.addChild(wordLabel)

        // Baloncuk oku (aşağı üçgen)
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: -5, y: 0))
        arrowPath.addLine(to: CGPoint(x: 5, y: 0))
        arrowPath.addLine(to: CGPoint(x: 0, y: -6))
        arrowPath.closeSubpath()
        let arrow = SKShapeNode(path: arrowPath)
        arrow.fillColor = UIColor(red: 0.05, green: 0.05, blue: 0.20, alpha: 0.88)
        arrow.strokeColor = .clear
        arrow.position = CGPoint(x: 0, y: 34)
        arrow.zPosition = 11
        addChild(arrow)
    }

    // MARK: - Seçim Işıltısı
    private func buildSelectionGlow() {
        selectionGlow = SKShapeNode(circleOfRadius: 50)
        selectionGlow.fillColor = UIColor(red: 0.30, green: 1.0, blue: 0.50, alpha: 0.12)
        selectionGlow.strokeColor = UIColor(red: 0.30, green: 1.0, blue: 0.50, alpha: 0.70)
        selectionGlow.lineWidth = 2
        selectionGlow.zPosition = 8
        selectionGlow.alpha = 0
        addChild(selectionGlow)
    }

    // MARK: - Fizik
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 35)
        physicsBody?.categoryBitMask = EnemyShipNode.physicsCategory
        physicsBody?.contactTestBitMask = BulletNode.playerBulletCategory
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
    }

    // MARK: - Salınım Animasyonu (Y ekseninde)
    private func startOscillation() {
        let amplitude = CGFloat.random(in: 12...20)
        let duration  = Double.random(in: 1.6...2.8)

        let bobUp = SKAction.moveBy(x: 0, y: amplitude, duration: duration / 2)
        bobUp.timingMode = .easeInEaseOut
        let bobDown = SKAction.moveBy(x: 0, y: -amplitude, duration: duration / 2)
        bobDown.timingMode = .easeInEaseOut

        let delay = SKAction.wait(forDuration: oscilationOffset * 0.5)
        run(SKAction.sequence([
            delay,
            SKAction.repeatForever(SKAction.sequence([bobUp, bobDown]))
        ]))
    }

    // MARK: - Seçim Vurgusu (Joystick ile hedefleme)
    func setHighlighted(_ highlighted: Bool) {
        let alpha: CGFloat = highlighted ? 1.0 : 0.0
        selectionGlow.run(SKAction.fadeAlpha(to: alpha, duration: 0.2))

        if highlighted {
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
            selectionGlow.run(SKAction.repeatForever(rotate))
        } else {
            selectionGlow.removeAllActions()
        }
    }

    // MARK: - Özel Yetenek Efekti (Yavaşlatma)
    func applySlowEffect(_ active: Bool) {
        let color: UIColor = active
            ? UIColor(red: 0.30, green: 0.70, blue: 1.0, alpha: 0.60)
            : .clear
        let overlay = SKShapeNode(circleOfRadius: 45)
        overlay.fillColor = color
        overlay.strokeColor = .clear
        overlay.zPosition = 9
        overlay.alpha = active ? 0.40 : 0.0
        overlay.name = "slowOverlay"

        // Mevcut yavaşlatma efektini kaldır
        childNode(withName: "slowOverlay")?.removeFromParent()
        if active { addChild(overlay) }
    }

    // MARK: - Vurulma Animasyonu
    func playHitAnimation(completion: @escaping () -> Void) {
        // Parlama efekti
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.9, duration: 0.06),
            SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0.06),
        ])
        let scaleDown = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.06),
            SKAction.scale(to: 0.0, duration: 0.15),
        ])
        let fadeOut = SKAction.fadeOut(withDuration: 0.20)

        run(SKAction.group([flash]))
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.group([scaleDown, fadeOut]),
            SKAction.run { completion() }
        ]))
    }
}
