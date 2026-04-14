// PlayerShipNode.swift
// AstroTerm - Oyuncunun uzay gemisi (sprite tabanlı)

import SpriteKit

/// Oyuncunun kontrol ettiği uzay gemisi düğümü
final class PlayerShipNode: SKNode {

    // MARK: - Alt Düğümler
    private var shipSprite: SKSpriteNode!
    private var engineGlows: [SKShapeNode] = []
    private var engineEmitters: [SKEmitterNode] = []
    private var targetingReticle: SKShapeNode!

    // MARK: - Hareket Durumu
    private(set) var isMovingUp = false
    private(set) var isMovingDown = false
    private let bobAmplitude: CGFloat = 5.0

    // MARK: - Fizik Kategorileri (GameScene ile paylaşılır)
    static let physicsCategory: UInt32 = 0x1 << 0

    // MARK: - Gemi boyutu
    private var shipSize = CGSize(width: 120, height: 90)
    private var spriteName: String = "ship_beginner"

    // MARK: - Başlatma
    init(ship: AstroShip) {
        self.spriteName = ship.imageName
        self.shipSize = ship.stats.size
        super.init()
        buildShip()
        buildEngineGlow(for: ship)
        buildTargetingReticle()
        setupPhysics()
        startIdleAnimation()
    }
    
    // Eski init (Geriye dönük uyumluluk veya test için)
    override init() {
        super.init()
        buildShip()
        if let defaultShip = AstroShip.ships.first {
            buildEngineGlow(for: defaultShip)
        }
        buildTargetingReticle()
        setupPhysics()
        startIdleAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Sprite Gemi
    private func buildShip() {
        shipSprite = SKSpriteNode(imageNamed: spriteName)
        shipSprite.size = shipSize
        shipSprite.zPosition = 2
        addChild(shipSprite)
    }

    // MARK: - Motor Işıltısı (Gemiye göre yapılandır)
    private func buildEngineGlow(for ship: AstroShip) {
        let config = ship.engineConfig
        let color = UIColor(config.particleColor)
        
        for pos in config.offsets {
            // Ana ışıltı
            let glow = SKShapeNode(ellipseOf: config.glowSize)
            glow.position = pos
            glow.fillColor = color.withAlphaComponent(0.9)
            glow.strokeColor = color.withAlphaComponent(0.6)
            glow.lineWidth = 2
            glow.zPosition = 0
            
            // Dış hale
            let outerSize = CGSize(width: config.glowSize.width * 1.5, height: config.glowSize.height * 1.6)
            let outerGlow = SKShapeNode(ellipseOf: outerSize)
            outerGlow.position = CGPoint(x: pos.x - 4, y: pos.y)
            outerGlow.fillColor = color.withAlphaComponent(0.2)
            outerGlow.strokeColor = .clear
            outerGlow.zPosition = -1
            addChild(outerGlow)

            // Titreme efekti
            let flicker = SKAction.sequence([
                SKAction.scaleX(to: 1.2, y: 0.8, duration: 0.20),
                SKAction.scaleX(to: 0.85, y: 1.15, duration: 0.15),
                SKAction.scaleX(to: 1.0, y: 1.0, duration: 0.15),
            ])
            glow.run(SKAction.repeatForever(flicker))

            addChild(glow)
            engineGlows.append(glow)
            
            // Parçacık sistemi
            setupEngineEmitter(at: pos, color: color)
        }
    }

    private func setupEngineEmitter(at position: CGPoint, color: UIColor) {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 20
        emitter.particleLifetime = 0.22
        emitter.particleLifetimeRange = 0.08
        emitter.particlePositionRange = CGVector(dx: 0, dy: 5)
        emitter.particleSpeed = 90
        emitter.particleSpeedRange = 35
        emitter.particleAlpha = 0.6
        emitter.particleAlphaRange = 0.15
        emitter.particleAlphaSpeed = -2.5
        emitter.particleScale = 0.05
        emitter.particleScaleRange = 0.02
        emitter.particleScaleSpeed = -0.12
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add

        emitter.emissionAngle = .pi // Sola doğru
        emitter.emissionAngleRange = 0.2
        emitter.position = position
        emitter.zPosition = -2

        addChild(emitter)
        engineEmitters.append(emitter)
    }

    // MARK: - Nişan Alma Retiküle (Kaldırıldı)
    private func buildTargetingReticle() {
        targetingReticle = SKShapeNode(circleOfRadius: 18)
        targetingReticle.alpha = 0
        // addChild(targetingReticle) // Kullanıcı isteğiyle retikül kaldırıldı
    }

    // MARK: - Fizik
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 32)
        physicsBody?.categoryBitMask = PlayerShipNode.physicsCategory
        // C2 düşman ateşi fix: enemyBulletCategory = 0x1 << 3
        physicsBody?.contactTestBitMask = 0x1 << 3
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
    }

    // MARK: - Rölanti Animasyonu
    private func startIdleAnimation() {
        let bobUp = SKAction.moveBy(x: 0, y: bobAmplitude, duration: 1.0)
        bobUp.timingMode = .easeInEaseOut
        let bobDown = SKAction.moveBy(x: 0, y: -bobAmplitude, duration: 1.0)
        bobDown.timingMode = .easeInEaseOut
        run(SKAction.repeatForever(SKAction.sequence([bobUp, bobDown])))
    }

    // MARK: - Hareket
    func move(direction: CGVector, speed: CGFloat) {
        isMovingUp = direction.dy > 0.1
        isMovingDown = direction.dy < -0.1

        // Hareket yönüne göre sprite eğimi
        let tiltAngle = direction.dy * 0.25
        let tilt = SKAction.rotate(toAngle: tiltAngle, duration: 0.15)
        shipSprite.run(tilt)
    }

    func stopMoving() {
        isMovingUp = false
        isMovingDown = false
        let straighten = SKAction.rotate(toAngle: 0, duration: 0.3)
        shipSprite.run(straighten)
    }

    // MARK: - Nişan Alma Göstergesi
    func showTargetingReticle(visible: Bool) {
        targetingReticle.run(SKAction.fadeAlpha(to: visible ? 1.0 : 0.0, duration: 0.2))
    }

    // MARK: - Hasar Alındı Animasyonu
    func playHitAnimation() {
        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0.1),
            SKAction.colorize(with: .red, colorBlendFactor: 0.6, duration: 0.1),
            SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0.1),
        ])
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -8, y: 0, duration: 0.04),
            SKAction.moveBy(x: 8, y: 0, duration: 0.04),
            SKAction.moveBy(x: -6, y: 0, duration: 0.04),
            SKAction.moveBy(x: 6, y: 0, duration: 0.04),
            SKAction.moveBy(x: 0, y: 0, duration: 0.04),
        ])
        shipSprite.run(flash)
        run(shake)
    }

    // MARK: - Ateşleme Animasyonu
    func playFireAnimation() {
        let recoil = SKAction.sequence([
            SKAction.moveBy(x: -6, y: 0, duration: 0.06),
            SKAction.moveBy(x: 6, y: 0, duration: 0.10),
        ])
        run(recoil)
    }

    // MARK: - Özel Yetenek Aktivasyon Animasyonu
    func playSpecialAbilityAnimation() {
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.15),
            SKAction.scale(to: 0.95, duration: 0.10),
            SKAction.scale(to: 1.0, duration: 0.10),
        ])
        run(pulse)
    }
}
