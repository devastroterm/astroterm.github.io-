// PlayerShipNode.swift
// AstroTerm - Oyuncunun uzay gemisi (sprite tabanlı)

import SpriteKit

/// Oyuncunun kontrol ettiği uzay gemisi düğümü
final class PlayerShipNode: SKNode {

    // MARK: - Alt Düğümler
    private var shipSprite: SKSpriteNode!
    private var engineGlowLeft: SKShapeNode!
    private var engineGlowRight: SKShapeNode!
    private var engineEmitter: SKEmitterNode?
    private var targetingReticle: SKShapeNode!

    // MARK: - Hareket Durumu
    private(set) var isMovingUp = false
    private(set) var isMovingDown = false
    private let bobAmplitude: CGFloat = 5.0

    // MARK: - Fizik Kategorileri (GameScene ile paylaşılır)
    static let physicsCategory: UInt32 = 0x1 << 0

    // MARK: - Gemi boyutu (orijinal SKShapeNode ile uyumlu)
    private let shipSize = CGSize(width: 120, height: 90)

    // MARK: - Başlatma
    override init() {
        super.init()
        buildShip()
        buildEngineGlow()
        buildTargetingReticle()
        setupPhysics()
        startIdleAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Sprite Gemi
    private func buildShip() {
        shipSprite = SKSpriteNode(imageNamed: "player_ship")
        shipSprite.size = shipSize
        // Yeni görsel: burun sağa, motorlar sola — flip gerekmez.
        shipSprite.zPosition = 2
        addChild(shipSprite)
    }

    // MARK: - Motor Işıltısı (sprite'ın sağ kenarına yerleştir)
    private func buildEngineGlow() {
        // Görseldeki motorlar sağ tarafta — xScale = -1 ile gemi döndüğünde
        // Gemi sağa baktığından motor arkada = negatif x tarafı
        let glowOffset: CGFloat = -52
        let positions: [(CGFloat, CGFloat)] = [(glowOffset, 10), (glowOffset, -10)]

        for (i, pos) in positions.enumerated() {
            let glow = SKShapeNode(ellipseOf: CGSize(width: 18, height: 10))
            glow.position = CGPoint(x: pos.0, y: pos.1)
            glow.fillColor = UIColor(red: 0.30, green: 0.60, blue: 1.0, alpha: 0.90)
            glow.strokeColor = UIColor(red: 0.60, green: 0.80, blue: 1.0, alpha: 0.60)
            glow.lineWidth = 2
            glow.zPosition = 0

            let outerGlow = SKShapeNode(ellipseOf: CGSize(width: 26, height: 16))
            outerGlow.position = CGPoint(x: pos.0 - 4, y: pos.1)
            outerGlow.fillColor = UIColor(red: 0.20, green: 0.40, blue: 1.0, alpha: 0.20)
            outerGlow.strokeColor = .clear
            outerGlow.zPosition = -1
            addChild(outerGlow)

            let flicker = SKAction.sequence([
                SKAction.scaleX(to: 1.2, y: 0.8, duration: 0.20),
                SKAction.scaleX(to: 0.85, y: 1.15, duration: 0.15),
                SKAction.scaleX(to: 1.0, y: 1.0, duration: 0.15),
            ])
            glow.run(SKAction.repeatForever(flicker))

            addChild(glow)
            if i == 0 { engineGlowLeft = glow } else { engineGlowRight = glow }
        }

        setupEngineEmitter()
    }

    private func setupEngineEmitter() {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 60
        emitter.particleLifetime = 0.5
        emitter.particleLifetimeRange = 0.2
        emitter.particlePositionRange = CGVector(dx: 0, dy: 14)
        emitter.particleSpeed = 80
        emitter.particleSpeedRange = 30
        emitter.particleAlpha = 0.8
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -1.6
        emitter.particleScale = 0.08
        emitter.particleScaleRange = 0.04
        emitter.particleScaleSpeed = -0.12
        emitter.particleColor = UIColor(red: 0.50, green: 0.75, blue: 1.0, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        // Motor arkada (-x), parçacıklar sola doğru fırlar (angle = π)
        emitter.emissionAngle = .pi
        emitter.emissionAngleRange = 0.3
        emitter.position = CGPoint(x: -55, y: 0)
        emitter.zPosition = -2
        engineEmitter = emitter
        addChild(emitter)
    }

    // MARK: - Nişan Alma Retiküle
    private func buildTargetingReticle() {
        targetingReticle = SKShapeNode(circleOfRadius: 18)
        targetingReticle.strokeColor = UIColor(red: 0.30, green: 1.0, blue: 0.50, alpha: 0.80)
        targetingReticle.fillColor = .clear
        targetingReticle.lineWidth = 1.5
        targetingReticle.zPosition = 10
        targetingReticle.alpha = 0

        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
        targetingReticle.run(SKAction.repeatForever(rotate))

        for i in 0..<4 {
            let angle = CGFloat(i) * .pi / 2
            let path = CGMutablePath()
            path.move(to: CGPoint(x: cos(angle) * 20, y: sin(angle) * 20))
            path.addLine(to: CGPoint(x: cos(angle) * 28, y: sin(angle) * 28))
            let dash = SKShapeNode(path: path)
            dash.strokeColor = UIColor(red: 0.30, green: 1.0, blue: 0.50, alpha: 0.80)
            dash.lineWidth = 1.5
            targetingReticle.addChild(dash)
        }
        addChild(targetingReticle)
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
