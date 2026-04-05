// StarfieldNode.swift
// AstroTerm - Seviye bazlı uzay / gökyüzü arka planı

import SpriteKit
import UIKit

final class StarfieldNode: SKNode {

    // MARK: - Seviye Teması
    private struct LevelTheme {
        let bgTop:        UIColor   // Arka plan üst rengi
        let bgMid:        UIColor   // Arka plan orta rengi
        let bgBottom:     UIColor   // Arka plan alt rengi
        let nebula1:      UIColor   // Birinci nebula rengi
        let nebula2:      UIColor   // İkinci nebula rengi
        let starTint:     UIColor   // Yıldız renk tonu
        let starCount:    Int
        let hasStreaks:   Bool      // Enerji çizgileri
        let streakColor:  UIColor
        let isDaytimeStyle: Bool    // Gündüz/Günbatımı teması için (bulutlar, az yıldız)
    }

    private static func theme(for level: CEFRLevel) -> LevelTheme {
        switch level {
        case .a1:
            return LevelTheme(
                bgTop:       UIColor(red: 0.22, green: 0.12, blue: 0.38, alpha: 1), // Deep Purple
                bgMid:       UIColor(red: 0.17, green: 0.10, blue: 0.32, alpha: 1), // Dark Purple
                bgBottom:    UIColor(red: 0.12, green: 0.08, blue: 0.25, alpha: 1), // Very Dark Purple
                nebula1:     UIColor(red: 0.94, green: 0.11, blue: 0.42, alpha: 0.25), // Hot Pink
                nebula2:     UIColor(red: 0.18, green: 0.85, blue: 0.76, alpha: 0.20), // Vibrant Cyan
                starTint:    UIColor.white,
                starCount:   45,
                hasStreaks:  true,
                streakColor: UIColor(red: 0.18, green: 0.85, blue: 0.76, alpha: 0.8), // Cyan streaks
                isDaytimeStyle: false
            )
        case .a2:
            return LevelTheme(
                bgTop:       UIColor(red: 0.10, green: 0.05, blue: 0.25, alpha: 1),
                bgMid:       UIColor(red: 0.15, green: 0.08, blue: 0.35, alpha: 1),
                bgBottom:    UIColor(red: 0.20, green: 0.10, blue: 0.45, alpha: 1),
                nebula1:     UIColor(red: 0.0,  green: 0.5,  blue: 1.0,  alpha: 0.25), // Blue
                nebula2:     UIColor(red: 0.5,  green: 0.0,  blue: 1.0,  alpha: 0.20), // Purple
                starTint:    UIColor(red: 0.95, green: 0.95, blue: 1.0,  alpha: 1),
                starCount:   50,
                hasStreaks:  true,
                streakColor: .white,
                isDaytimeStyle: false
            )
        case .b1:
            return LevelTheme(
                bgTop:       UIColor(red: 0.02, green: 0.15, blue: 0.20, alpha: 1),
                bgMid:       UIColor(red: 0.01, green: 0.10, blue: 0.15, alpha: 1),
                bgBottom:    UIColor(red: 0.02, green: 0.15, blue: 0.20, alpha: 1),
                nebula1:     UIColor(red: 0.18, green: 0.85, blue: 0.76, alpha: 0.22),
                nebula2:     UIColor(red: 0.1,  green: 0.4,  blue: 0.8,  alpha: 0.18),
                starTint:    UIColor.white,
                starCount:   55,
                hasStreaks:  true,
                streakColor: UIColor(red: 0.18, green: 0.85, blue: 0.76, alpha: 0.6),
                isDaytimeStyle: false
            )
        case .b2:
            return LevelTheme(
                bgTop:       UIColor(red: 0.18, green: 0.05, blue: 0.25, alpha: 1),
                bgMid:       UIColor(red: 0.12, green: 0.02, blue: 0.18, alpha: 1),
                bgBottom:    UIColor(red: 0.18, green: 0.05, blue: 0.25, alpha: 1),
                nebula1:     UIColor(red: 1.00, green: 0.20, blue: 0.60, alpha: 0.22),
                nebula2:     UIColor(red: 0.60, green: 0.10, blue: 0.90, alpha: 0.18),
                starTint:    UIColor.white,
                starCount:   60,
                hasStreaks:  true,
                streakColor: UIColor(red: 1.00, green: 0.40, blue: 0.80, alpha: 0.6),
                isDaytimeStyle: false
            )
        case .c1:
            return LevelTheme(
                bgTop:       UIColor(red: 0.15, green: 0.02, blue: 0.05, alpha: 1),
                bgMid:       UIColor(red: 0.25, green: 0.04, blue: 0.08, alpha: 1),
                bgBottom:    UIColor(red: 0.15, green: 0.02, blue: 0.05, alpha: 1),
                nebula1:     UIColor(red: 1.00, green: 0.20, blue: 0.10, alpha: 0.25),
                nebula2:     UIColor(red: 1.00, green: 0.50, blue: 0.00, alpha: 0.18),
                starTint:    UIColor.white,
                starCount:   60,
                hasStreaks:  true,
                streakColor: UIColor(red: 1.00, green: 0.20, blue: 0.00, alpha: 0.7),
                isDaytimeStyle: false
            )
        case .c2:
            return LevelTheme(
                bgTop:       UIColor(red: 0.05, green: 0.02, blue: 0.12, alpha: 1),
                bgMid:       UIColor(red: 0.12, green: 0.04, blue: 0.20, alpha: 1),
                bgBottom:    UIColor(red: 0.05, green: 0.02, blue: 0.12, alpha: 1),
                nebula1:     UIColor(red: 0.50, green: 0.20, blue: 1.00, alpha: 0.25),
                nebula2:     UIColor(red: 0.00, green: 0.80, blue: 1.00, alpha: 0.18),
                starTint:    UIColor.white,
                starCount:   65,
                hasStreaks:  true,
                streakColor: UIColor(red: 0.60, green: 0.30, blue: 1.00, alpha: 0.7),
                isDaytimeStyle: false
            )
        }
    }

    // MARK: - State
    private var stars: [SKSpriteNode] = []
    private var clouds: [SKSpriteNode] = []
    private var starTextures: [SKTexture] = []
    private let theme: LevelTheme
    private let sceneSize: CGSize
    private let level: CEFRLevel

    // MARK: - Başlatma
    init(size: CGSize, level: CEFRLevel) {
        self.sceneSize = size
        self.level = level
        self.theme = StarfieldNode.theme(for: level)
        super.init()
        buildGradientBackground(size: size)
        
        // buildNebulae(size: size)
        
        // buildStarTextures()
        // buildStars(size: size, seed: level.hashValue)
        // buildTwinkles()
        
        // if theme.hasStreaks {
        //     buildStylizedComets(size: size)
        // }
    }

    required init?(coder aDecoder: NSCoder) {
        self.level = .a1
        self.theme = StarfieldNode.theme(for: .a1)
        self.sceneSize = .zero
        super.init(coder: aDecoder)
    }

    // MARK: - Degrade Arka Plan (GPU texture — SKShapeNode yok)
    private func buildGradientBackground(size: CGSize) {
        if level == .a1 || level == .a2 || level == .b1 || level == .b2 || level == .c1 || level == .c2 {
            let imageName = level.rawValue.lowercased() + "_background"
            let bg = SKSpriteNode(imageNamed: imageName)
            
            // Aspect Fill Mantığı (Yayılmayı Önle)
            let aspectRatio = bg.size.width / bg.size.height
            let screenAspectRatio = size.width / size.height
            
            if aspectRatio > screenAspectRatio {
                // Görsel ekrandan daha geniş (kenarlardan kırp)
                bg.size = CGSize(width: size.height * aspectRatio, height: size.height)
            } else {
                // Görsel ekrandan daha dar/dikey (üst/alttan kırp)
                bg.size = CGSize(width: size.width, height: size.width / aspectRatio)
            }
            
            bg.zPosition = -20
            addChild(bg)
            return
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            // Üstten alta 3 renkli degrade
            let colors = [theme.bgTop.cgColor, theme.bgMid.cgColor, theme.bgBottom.cgColor] as CFArray
            let space  = CGColorSpaceCreateDeviceRGB()
            guard let gradient = CGGradient(colorsSpace: space,
                                            colors: colors,
                                            locations: [0, 0.45, 1.0]) else { return }
            ctx.cgContext.drawLinearGradient(gradient,
                                             start: CGPoint(x: 0, y: 0),
                                             end:   CGPoint(x: 0, y: size.height),
                                             options: [])
        }
        let tex = SKTexture(image: img)
        let bg  = SKSpriteNode(texture: tex, size: size)
        bg.zPosition = -20
        addChild(bg)
    }

    // MARK: - Stilize Nebulalar (Overlap eden daire grupları)
    private func buildNebulae(size: CGSize) {
        let positions: [(CGFloat, CGFloat)] = [
            (0.15, 0.20), (0.85, 0.15), (0.10, 0.80), (0.90, 0.85), (0.50, 0.50)
        ]
        
        for (idx, pos) in positions.enumerated() {
            let color = idx % 2 == 0 ? theme.nebula1 : theme.nebula2
            let center = CGPoint(x: size.width * pos.0 - size.width / 2,
                                 y: size.height * pos.1 - size.height / 2)
            
            let nebulaGroup = SKNode()
            nebulaGroup.position = center
            nebulaGroup.zPosition = -10
            nebulaGroup.alpha = 0.6
            addChild(nebulaGroup)
            
            // 3-5 tane içiçe geçmiş daire ile stilize bulut
            for _ in 0..<Int.random(in: 3...6) {
                let r = CGFloat.random(in: 40...120)
                let offset = CGPoint(x: CGFloat.random(in: -r...r), y: CGFloat.random(in: -r...r))
                let circle = SKShapeNode(circleOfRadius: r)
                circle.fillColor = color.withAlphaComponent(0.15)
                circle.strokeColor = .clear
                circle.position = offset
                nebulaGroup.addChild(circle)
            }
            
            // Yavaş hareket animasyonu
            let move = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: -20...20), duration: 10.0)
            nebulaGroup.run(SKAction.repeatForever(SKAction.sequence([move, move.reversed()])))
        }
    }

    // MARK: - Yıldız Texture'ları (Seviye tintli, tek seferlik)
    private func buildStarTextures() {
        let tint = theme.starTint
        
        // 1. Nokta Yıldızlar
        for radius in [1.0, 1.8] as [CGFloat] {
            let d = radius * 2 + 2
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: d, height: d))
            let img = renderer.image { ctx in
                tint.setFill()
                UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: radius * 2, height: radius * 2)).fill()
            }
            starTextures.append(SKTexture(image: img))
        }
        
        // 2. 4 Köşeli Yıldızlar (Cross)
        let crossSize: CGFloat = 12
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: crossSize, height: crossSize))
        let crossImg = renderer.image { ctx in
            tint.setStroke()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: crossSize/2, y: 0))
            path.addLine(to: CGPoint(x: crossSize/2, y: crossSize))
            path.move(to: CGPoint(x: 0, y: crossSize/2))
            path.addLine(to: CGPoint(x: crossSize, y: crossSize/2))
            path.lineWidth = 2
            path.lineCapStyle = .round
            path.stroke()
        }
        starTextures.append(SKTexture(image: crossImg))
        
        // 3. Küçük Swirl Galaxy (S şekli)
        let swirlSize: CGFloat = 16
        let swirlImg = renderer.image { ctx in
            tint.withAlphaComponent(0.6).setStroke()
            let path = UIBezierPath()
            path.addArc(withCenter: CGPoint(x: swirlSize/2 - 4, y: swirlSize/2), radius: 4, startAngle: .pi, endAngle: 0, clockwise: true)
            path.addArc(withCenter: CGPoint(x: swirlSize/2 + 4, y: swirlSize/2), radius: 4, startAngle: .pi, endAngle: 0, clockwise: false)
            path.lineWidth = 1.5
            path.stroke()
        }
        starTextures.append(SKTexture(image: swirlImg))
    }

    // MARK: - Yıldızlar (Deterministik LCG seed)
    private func buildStars(size: CGSize, seed: Int) {
        guard starTextures.count >= 4 else { return }
        var s = UInt64(bitPattern: Int64(seed &+ 0xDEAD_BEEF))

        func lcg() -> CGFloat {
            s = s &* 6364136223846793005 &+ 1442695040888963407
            return CGFloat(s >> 33) / CGFloat(UInt32.max)
        }

        for _ in 0..<theme.starCount {
            let x = lcg() * size.width  - size.width  / 2
            let y = lcg() * size.height - size.height / 2

            let roll = lcg()
            let texIdx: Int
            if      roll < 0.70 { texIdx = 0 } // Küçük nokta
            else if roll < 0.85 { texIdx = 1 } // Orta nokta
            else if roll < 0.95 { texIdx = 2 } // 4 Köşeli
            else                 { texIdx = 3 } // Swirl

            let star          = SKSpriteNode(texture: starTextures[texIdx])
            star.position     = CGPoint(x: x, y: y)
            star.alpha        = lcg() * 0.5 + 0.4
            star.zPosition    = -15
            star.blendMode    = .alpha
            
            if texIdx == 2 {
                star.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: Double.random(in: 4...8))))
            }
            
            stars.append(star)
            addChild(star)
        }
    }

    // MARK: - Twinkle (Her 5. yıldız)
    private func buildTwinkles() {
        for (i, star) in stars.enumerated() where i % 5 == 0 {
            let dur     = Double.random(in: 1.2...3.0)
            let minA    = CGFloat.random(in: 0.12...0.38)
            let baseA   = star.alpha
            let delay   = SKAction.wait(forDuration: Double.random(in: 0...2.5))
            let out     = SKAction.fadeAlpha(to: minA,   duration: dur)
            let inn     = SKAction.fadeAlpha(to: baseA,  duration: dur)
            star.run(SKAction.sequence([delay,
                                        SKAction.repeatForever(SKAction.sequence([out, inn]))]))
        }
    }

    // MARK: - Stilize Kuyruklu Yıldızlar (Shooting Stars / Comets)
    private func buildStylizedComets(size: CGSize) {
        let cometColor = theme.streakColor
        
        for _ in 0..<3 {
            let cometNode = SKNode()
            let length: CGFloat = CGFloat.random(in: 150...250)
            
            // 1. Kuyruk (Capsule Lines)
            for i in 0..<3 {
                let segmentLen = length * CGFloat.random(in: 0.6...0.9)
                let segment = SKShapeNode(rectOf: CGSize(width: segmentLen, height: 6 - CGFloat(i)*2), cornerRadius: 3)
                segment.fillColor = cometColor.withAlphaComponent(0.6 - CGFloat(i)*0.2)
                segment.strokeColor = .clear
                segment.position = CGPoint(x: -segmentLen/2, y: CGFloat(i-1)*6)
                cometNode.addChild(segment)
            }
            
            // 2. Baş (Glow Circle)
            let head = SKShapeNode(circleOfRadius: 6)
            head.fillColor = .white
            head.strokeColor = cometColor
            head.lineWidth = 2
            cometNode.addChild(head)
            
            let xStart = size.width / 2 + 100
            let xEnd = -size.width / 2 - 300
            let y = CGFloat.random(in: -size.height/2 ... size.height/2)
            
            cometNode.position = CGPoint(x: xStart, y: y)
            cometNode.zPosition = -5
            cometNode.zRotation = .pi * 0.15 // Hafif eğik gitsin
            addChild(cometNode)
            
            let move = SKAction.moveTo(x: xEnd, duration: Double.random(in: 15...25))
            let reset = SKAction.moveTo(x: xStart, duration: 0)
            let wait = SKAction.wait(forDuration: Double.random(in: 5...15))
            
            cometNode.run(SKAction.repeatForever(SKAction.sequence([move, reset, wait])))
        }
    }

    // MARK: - Paralaks Kaydırma
    func scroll(by delta: CGFloat) {
        // Yıldızlar en yavaş kayar
        for star in stars {
            star.position.x -= delta * 0.08
            let halfW = sceneSize.width / 2
            if star.position.x < -halfW - 20 {
                star.position.x += sceneSize.width + 40
            }
        }
        
        // Bulutlar biraz daha hızlı kayar
        for cloud in clouds {
            cloud.position.x -= delta * 0.15
            let halfW = sceneSize.width / 2
            if cloud.position.x < -halfW - cloud.size.width/2 {
                cloud.position.x += sceneSize.width + cloud.size.width
                cloud.position.y = -sceneSize.height/2 + CGFloat.random(in: 0...sceneSize.height * 0.3)
            }
        }
    }
}
