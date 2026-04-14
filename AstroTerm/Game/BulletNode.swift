// BulletNode.swift
// AstroTerm - Oyuncu ve düşman mermileri

import SpriteKit

/// Mermi türleri
enum BulletType {
    case playerLaser      // Oyuncu lazeri (mavi-beyaz)
    case enemyShot        // Düşman ateşi (kırmızı-turuncu)
    case specialLaser     // Özel yetenek lazeri (altın)
}

/// Mermi düğümü — hızlı yatay hareket ve hareket bulanıklığı izi
final class BulletNode: SKNode {

    // MARK: - Fizik Kategorileri
    static let playerBulletCategory: UInt32 = 0x1 << 2
    static let enemyBulletCategory:  UInt32 = 0x1 << 3

    // MARK: - Özellikler
    let bulletType: BulletType
    private var bulletShape: SKShapeNode!
    private var trailEmitter: SKEmitterNode?

    // MARK: - Başlatma
    init(type: BulletType) {
        self.bulletType = type
        super.init()
        buildBullet()
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        self.bulletType = .playerLaser
        super.init(coder: aDecoder)
    }

    // MARK: - Mermi İnşası
    private func buildBullet() {
        switch bulletType {
        case .playerLaser:
            buildPlayerLaser()
        case .enemyShot:
            buildEnemyShot()
        case .specialLaser:
            buildSpecialLaser()
        }
    }

    // MARK: - Oyuncu Lazeri (Mavi-Beyaz)
    private func buildPlayerLaser() {
        // Ana lazer gövdesi
        bulletShape = SKShapeNode(rectOf: CGSize(width: 30, height: 5), cornerRadius: 2.5)
        bulletShape.fillColor = UIColor(red: 0.60, green: 0.90, blue: 1.0, alpha: 1.0)
        bulletShape.strokeColor = UIColor(red: 0.80, green: 1.0, blue: 1.0, alpha: 0.90)
        bulletShape.lineWidth = 1
        bulletShape.zPosition = 1
        addChild(bulletShape)

        // Parlama hale
        let glow = SKShapeNode(rectOf: CGSize(width: 34, height: 9), cornerRadius: 4.5)
        glow.fillColor = UIColor(red: 0.30, green: 0.70, blue: 1.0, alpha: 0.25)
        glow.strokeColor = .clear
        glow.zPosition = 0
        addChild(glow)

        // Parlak nokta (ön)
        let tip = SKShapeNode(circleOfRadius: 4)
        tip.position = CGPoint(x: 15, y: 0)
        tip.fillColor = UIColor(white: 1.0, alpha: 0.90)
        tip.strokeColor = .clear
        tip.zPosition = 2
        addChild(tip)

        // Hareket izi emitter
        setupTrailEmitter(
            color: UIColor(red: 0.30, green: 0.70, blue: 1.0, alpha: 0.80),
            direction: -.pi  // sola doğru iz bırak
        )
    }

    // MARK: - Düşman Ateşi (Kırmızı-Turuncu)
    private func buildEnemyShot() {
        // Düşman plazma topu
        bulletShape = SKShapeNode(circleOfRadius: 7)
        bulletShape.fillColor = UIColor(red: 1.0, green: 0.25, blue: 0.05, alpha: 1.0)
        bulletShape.strokeColor = UIColor(red: 1.0, green: 0.60, blue: 0.20, alpha: 0.90)
        bulletShape.lineWidth = 1.5
        bulletShape.zPosition = 1
        addChild(bulletShape)

        // Dış hale
        let outerGlow = SKShapeNode(circleOfRadius: 12)
        outerGlow.fillColor = UIColor(red: 1.0, green: 0.30, blue: 0.05, alpha: 0.20)
        outerGlow.strokeColor = .clear
        outerGlow.zPosition = 0
        addChild(outerGlow)

        // Titreme animasyonu (Performans: 0.12s → 0.28s)
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.28),
            SKAction.scale(to: 0.90, duration: 0.28),
        ])
        bulletShape.run(SKAction.repeatForever(pulse))

        // İz emitter
        setupTrailEmitter(
            color: UIColor(red: 1.0, green: 0.40, blue: 0.10, alpha: 0.70),
            direction: 0  // sağa doğru iz bırak
        )
    }

    // MARK: - Özel Lazer (Altın-Sarı)
    private func buildSpecialLaser() {
        // Kalın altın lazer
        bulletShape = SKShapeNode(rectOf: CGSize(width: 50, height: 8), cornerRadius: 4)
        bulletShape.fillColor = UIColor(red: 1.0, green: 0.85, blue: 0.10, alpha: 1.0)
        bulletShape.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 0.60, alpha: 0.90)
        bulletShape.lineWidth = 1.5
        bulletShape.zPosition = 1
        addChild(bulletShape)

        // Çift hale katmanı
        for (size, alpha) in [(CGSize(width: 55, height: 14), 0.20), (CGSize(width: 62, height: 20), 0.10)] as [(CGSize, CGFloat)] {
            let h = SKShapeNode(rectOf: size, cornerRadius: size.height / 2)
            h.fillColor = UIColor(red: 1.0, green: 0.90, blue: 0.30, alpha: alpha)
            h.strokeColor = .clear
            h.zPosition = 0
            addChild(h)
        }

        // Parlak ön uç
        let tip = SKShapeNode(circleOfRadius: 6)
        tip.position = CGPoint(x: 25, y: 0)
        tip.fillColor = UIColor(white: 1.0, alpha: 0.95)
        tip.strokeColor = .clear
        tip.zPosition = 2
        addChild(tip)

        setupTrailEmitter(
            color: UIColor(red: 1.0, green: 0.80, blue: 0.10, alpha: 0.80),
            direction: -.pi
        )
    }

    // MARK: - İz Parçacık Emitter
    private func setupTrailEmitter(color: UIColor, direction: CGFloat) {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 12
        emitter.particleLifetime = 0.12
        emitter.particleLifetimeRange = 0.04
        emitter.particlePositionRange = CGVector(dx: 2, dy: 3)
        emitter.particleSpeed = 18
        emitter.particleSpeedRange = 8
        emitter.particleAlpha = 0.6
        emitter.particleAlphaSpeed = -5.0
        emitter.particleScale = 0.06
        emitter.particleScaleRange = 0.02
        emitter.particleScaleSpeed = -0.25
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        emitter.emissionAngle = direction
        emitter.emissionAngleRange = 0.4
        emitter.zPosition = -1

        trailEmitter = emitter
        addChild(emitter)
    }

    // MARK: - Fizik
    private func setupPhysics() {
        let categoryMask: UInt32
        switch bulletType {
        case .playerLaser, .specialLaser:
            categoryMask = BulletNode.playerBulletCategory
        case .enemyShot:
            categoryMask = BulletNode.enemyBulletCategory
        }

        physicsBody = SKPhysicsBody(circleOfRadius: bulletType == .playerLaser ? 5 : 7)
        physicsBody?.categoryBitMask = categoryMask
        physicsBody?.contactTestBitMask = 0  // GameScene tarafından ayarlanır
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 0
    }

    // MARK: - Ekran Dışı Kontrolü
    func isOffScreen(in sceneSize: CGSize) -> Bool {
        let x = position.x
        return x > sceneSize.width / 2 + 80 || x < -sceneSize.width / 2 - 80
    }

    // MARK: - Çarışma Efekti
    func playImpactEffect(completion: @escaping () -> Void) {
        let scale = SKAction.scale(to: 1.8, duration: 0.06)
        let fade  = SKAction.fadeOut(withDuration: 0.10)
        let remove = SKAction.run { completion() }
        run(SKAction.sequence([SKAction.group([scale, fade]), remove]))
    }
}
