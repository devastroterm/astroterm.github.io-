// ExplosionNode.swift
// AstroTerm - Patlama ve yok oluş efektleri

import SpriteKit

/// Düşman gemisi patlaması için parçacık ve şekil animasyonları
final class ExplosionNode: SKNode {

    // MARK: - Başlatma
    /// Patlama efektini oluştur ve otomatik kaldır
    init(color: UIColor, size: CGFloat = 40, isCorrect: Bool = true) {
        super.init()
        if isCorrect {
            playCorrectExplosion(color: color, size: size)
        } else {
            playWrongExplosion(size: size)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Doğru Cevap Patlaması (Renkli, Parlak)
    private func playCorrectExplosion(color: UIColor, size: CGFloat) {
        // Ana patlama dairesi
        let flash = SKShapeNode(circleOfRadius: size * 0.5)
        flash.fillColor = UIColor(white: 1.0, alpha: 0.90)
        flash.strokeColor = .clear
        flash.zPosition = 5
        addChild(flash)

        // Ana parçacık emitter
        addMainExplosionEmitter(color: color, size: size)

        // Gemi parçaları
        addDebrisFragments(count: 4, color: color, spread: size * 1.2)

        // Puan artı efekti (görsel geri bildirim)
        addScoreRing(color: color, radius: size * 0.8)

        // Flash animasyonu
        let flashAnim = SKAction.sequence([
            SKAction.scale(to: size * 0.06, duration: 0.08),
            SKAction.group([
                SKAction.scale(to: size * 0.10, duration: 0.15),
                SKAction.fadeAlpha(to: 0.0, duration: 0.15),
            ])
        ])
        flash.run(flashAnim)

        // Kendini kaldır
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.2),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Yanlış Cevap Patlaması (Kırmızı, Küçük)
    private func playWrongExplosion(size: CGFloat) {
        // Kırmızı X işareti
        let xMark = SKNode()
        let wrongColor = UIColor(red: 1.0, green: 0.15, blue: 0.15, alpha: 1.0)

        for angle in [CGFloat.pi / 4, -.pi / 4] {
            let bar = SKShapeNode(rectOf: CGSize(width: size * 0.8, height: 5), cornerRadius: 2.5)
            bar.fillColor = wrongColor
            bar.strokeColor = .clear
            bar.zRotation = angle
            xMark.addChild(bar)
        }
        xMark.zPosition = 5
        addChild(xMark)

        // Kırmızı patlama emitter
        addMainExplosionEmitter(color: wrongColor, size: size * 0.6)

        // X animasyonu
        xMark.setScale(0.1)
        let appear = SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.15),
            SKAction.fadeIn(withDuration: 0.15),
        ])
        let hold = SKAction.wait(forDuration: 0.4)
        let disappear = SKAction.group([
            SKAction.scale(to: 1.4, duration: 0.20),
            SKAction.fadeOut(withDuration: 0.20),
        ])
        xMark.run(SKAction.sequence([appear, hold, disappear]))

        // Titreme
        addShakeEffect(amplitude: 8, duration: 0.3)

        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.9),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Ana Patlama Parçacıkları
    private func addMainExplosionEmitter(color: UIColor, size: CGFloat) {
        // Birleşik ana patlama emitter'ı (eskiden 3 ayrı emitter vardı)
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 80
        emitter.numParticlesToEmit = 25
        emitter.particleLifetime = 0.45
        emitter.particleLifetimeRange = 0.15
        emitter.particlePositionRange = CGVector(dx: size * 0.3, dy: size * 0.3)
        emitter.particleSpeed = size * 3.0
        emitter.particleSpeedRange = size * 1.5
        emitter.particleAlpha = 0.85
        emitter.particleAlphaSpeed = -1.8
        emitter.particleScale = 0.12
        emitter.particleScaleRange = 0.06
        emitter.particleScaleSpeed = -0.20
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        emitter.zPosition = 4
        addChild(emitter)

        // Ateş parçacıkları (azaltıldı)
        let fireEmitter = SKEmitterNode()
        fireEmitter.particleBirthRate = 45
        fireEmitter.numParticlesToEmit = 15
        fireEmitter.particleLifetime = 0.30
        fireEmitter.particleLifetimeRange = 0.10
        fireEmitter.particlePositionRange = CGVector(dx: size * 0.2, dy: size * 0.2)
        fireEmitter.particleSpeed = size * 1.5
        fireEmitter.particleSpeedRange = size
        fireEmitter.particleAlpha = 0.7
        fireEmitter.particleAlphaSpeed = -2.2
        fireEmitter.particleScale = 0.09
        fireEmitter.particleScaleRange = 0.04
        fireEmitter.particleScaleSpeed = -0.25
        fireEmitter.particleColor = UIColor(red: 1.0, green: 0.60, blue: 0.10, alpha: 1.0)
        fireEmitter.particleColorBlendFactor = 1.0
        fireEmitter.particleBlendMode = .add
        fireEmitter.emissionAngle = 0
        fireEmitter.emissionAngleRange = .pi * 2
        fireEmitter.zPosition = 3
        addChild(fireEmitter)
        // Duman emitter kaldırıldı (performans)
    }

    // MARK: - Gemi Enkazı Parçaları
    private func addDebrisFragments(count: Int, color: UIColor, spread: CGFloat) {
        for i in 0..<count {
            let angle = CGFloat(i) * .pi * 2 / CGFloat(count) + CGFloat.random(in: -0.3...0.3)
            let distance = CGFloat.random(in: spread * 0.5...spread)
            let fragmentSize = CGFloat.random(in: 4...10)

            let fragment: SKShapeNode
            let shapeType = Int.random(in: 0...2)
            switch shapeType {
            case 0:
                fragment = SKShapeNode(rectOf: CGSize(width: fragmentSize, height: fragmentSize * 0.4))
            case 1:
                fragment = SKShapeNode(circleOfRadius: fragmentSize * 0.5)
            default:
                let triPath = CGMutablePath()
                triPath.move(to: CGPoint(x: 0, y: fragmentSize))
                triPath.addLine(to: CGPoint(x: fragmentSize * 0.7, y: -fragmentSize * 0.5))
                triPath.addLine(to: CGPoint(x: -fragmentSize * 0.7, y: -fragmentSize * 0.5))
                triPath.closeSubpath()
                fragment = SKShapeNode(path: triPath)
            }

            fragment.fillColor = color.withAlphaComponent(0.90)
            fragment.strokeColor = UIColor(white: 1.0, alpha: 0.40)
            fragment.lineWidth = 0.5
            fragment.zPosition = 6

            addChild(fragment)

            // Parça uçma animasyonu
            let targetX = cos(angle) * distance
            let targetY = sin(angle) * distance
            let move = SKAction.moveBy(x: targetX, y: targetY, duration: 0.6)
            move.timingMode = .easeOut
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -.pi * 2...(.pi * 2)), duration: 0.6)
            let fade = SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                SKAction.fadeOut(withDuration: 0.4)
            ])
            fragment.run(SKAction.group([move, rotate, fade]))
        }
    }

    // MARK: - Puan Halkası (Doğru cevap görsel geri bildirimi)
    private func addScoreRing(color: UIColor, radius: CGFloat) {
        let ring = SKShapeNode(circleOfRadius: radius)
        ring.fillColor = .clear
        ring.strokeColor = color.withAlphaComponent(0.70)
        ring.lineWidth = 3
        ring.zPosition = 7

        addChild(ring)

        let expand = SKAction.scale(to: 2.5, duration: 0.5)
        expand.timingMode = .easeOut
        let fade = SKAction.fadeOut(withDuration: 0.5)
        ring.run(SKAction.group([expand, fade]))
    }

    // MARK: - Titreme (Yanlış Cevap)
    private func addShakeEffect(amplitude: CGFloat, duration: TimeInterval) {
        let steps = 6
        var actions: [SKAction] = []
        for i in 0..<steps {
            let dx = i % 2 == 0 ? amplitude : -amplitude
            let stepDuration = duration / Double(steps)
            actions.append(SKAction.moveBy(x: dx, y: 0, duration: stepDuration))
        }
        actions.append(SKAction.moveBy(x: 0, y: 0, duration: 0))
        run(SKAction.sequence(actions))
    }
}
