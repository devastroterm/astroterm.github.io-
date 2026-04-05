import SpriteKit

final class PlanetNode: SKNode {

    let level: CEFRLevel
    let radius: CGFloat
    
    private let cropNode = SKCropNode()
    private let surfaceLayer = SKNode()

    init(level: CEFRLevel, radius: CGFloat = 200) {
        self.level = level
        self.radius = radius
        super.init()
        buildPlanet()
    }

    required init?(coder aDecoder: NSCoder) {
        self.level = .a1
        self.radius = 200
        super.init(coder: aDecoder)
    }

    private func buildPlanet() {
        // Mask layer ensures details don't spill (using SKSpriteNode to fix iOS SKShapeNode mask bug)
        let mask = generateCircleMask(radius: radius)
        cropNode.maskNode = mask
        cropNode.zPosition = 1
        addChild(cropNode)
        
        cropNode.addChild(surfaceLayer)
        
        // Slow rotation for premium feel (gas giant needs faster surface flow)
        let rotationDuration: TimeInterval = level == .b2 ? 45.0 : 120.0
        surfaceLayer.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: rotationDuration)))
        
        switch level {
        case .a1: buildMoon()
        case .a2: buildMars()
        case .b1: buildOceanWorld()
        case .b2: buildGasGiant()
        case .c1: buildVolcanicPlanet()
        case .c2: buildCrystalWorld()
        }
    }

    // MARK: - A1: Gri Ay — Stilize, Büyük Kraterler
    private func buildMoon() {
        addAtmosphereGlow(color: UIColor(white: 0.9, alpha: 1.0), spread: 8)

        let base = circle(radius: radius, fill: UIColor(white: 0.45, alpha: 1.0))
        surfaceLayer.addChild(base)

        // Yüzey açık bölgeleri
        surfaceLayer.addChild(circle(radius: radius * 0.4, fill: UIColor(white: 0.55, alpha: 0.4), pos: CGPoint(x: -radius * 0.2, y: radius * 0.15)))
        surfaceLayer.addChild(circle(radius: radius * 0.3, fill: UIColor(white: 0.52, alpha: 0.3), pos: CGPoint(x: radius * 0.3, y: -radius * 0.25)))

        let craters: [(CGPoint, CGFloat)] = [
            (CGPoint(x: -radius*0.35, y:  radius*0.30), radius*0.18),
            (CGPoint(x:  radius*0.45, y: -radius*0.35), radius*0.12),
            (CGPoint(x: -radius*0.15, y: -radius*0.45), radius*0.22),
            (CGPoint(x:  radius*0.50, y:  radius*0.45), radius*0.08),
            (CGPoint(x: -radius*0.55, y: -radius*0.15), radius*0.13),
        ]
        for (pos, r) in craters {
            let outer = circle(radius: r, fill: UIColor(white: 0.35, alpha: 0.6), pos: pos)
            let inner = circle(radius: r * 0.6, fill: UIColor(white: 0.25, alpha: 0.8), pos: pos)
            surfaceLayer.addChild(outer)
            surfaceLayer.addChild(inner)
        }

        addFlatCrescentShadow()
    }

    // MARK: - A2: Mars — Stilize Pas Rengi, Geometrik Buzul
    private func buildMars() {
        addAtmosphereGlow(color: UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0), spread: 10)

        surfaceLayer.addChild(circle(radius: radius, fill: UIColor(red: 0.75, green: 0.32, blue: 0.15, alpha: 1.0)))

        // Stilize bantlar (Capsules)
        let bands: [(CGFloat, CGFloat)] = [
            (radius * 0.2, radius * 1.2),
            (-radius * 0.3, radius * 0.9),
            (radius * 0.55, radius * 0.6)
        ]
        for (y, w) in bands {
            let band = SKShapeNode(rectOf: CGSize(width: w, height: radius * 0.15), cornerRadius: radius * 0.075)
            band.fillColor = UIColor(red: 0.6, green: 0.2, blue: 0.1, alpha: 0.6)
            band.strokeColor = .clear
            band.position = CGPoint(x: 0, y: y)
            surfaceLayer.addChild(band)
        }

        // Kuzey Kutbu (Geometric)
        let iceCap = SKShapeNode(circleOfRadius: radius * 0.35)
        iceCap.position = CGPoint(x: 0, y: radius * 0.85)
        iceCap.fillColor = .white
        iceCap.strokeColor = .clear
        surfaceLayer.addChild(iceCap)

        addFlatCrescentShadow()
    }

    // MARK: - B1: Okyanus Dünyası — Stilize Mavi, Geometrik Adalar
    private func buildOceanWorld() {
        addAtmosphereGlow(color: UIColor(red: 0.3, green: 0.9, blue: 1.0, alpha: 1.0), spread: 12)

        let oceanColor = UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1.0)
        surfaceLayer.addChild(circle(radius: radius, fill: oceanColor))

        let islands: [(CGPoint, CGFloat)] = [
            (CGPoint(x: -radius*0.3, y:  radius*0.2), radius*0.35),
            (CGPoint(x:  radius*0.4, y: -radius*0.1), radius*0.25),
            (CGPoint(x: -radius*0.1, y: -radius*0.4), radius*0.28),
            (CGPoint(x:  radius*0.2, y:  radius*0.5), radius*0.18),
        ]
        
        for (pos, r) in islands {
            let land = circle(radius: r, fill: UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0), pos: pos)
            surfaceLayer.addChild(land)
            
            // Stilize sahil çizgisi (Inner ring)
            let shore = SKShapeNode(circleOfRadius: r * 0.8)
            shore.position = pos
            shore.fillColor = UIColor.white.withAlphaComponent(0.2)
            shore.strokeColor = .clear
            surfaceLayer.addChild(shore)
        }

        addFlatCrescentShadow()
    }

    // MARK: - B2: Gaz Devi — Stilize Bantlar, Spot
    private func buildGasGiant() {
        addAtmosphereGlow(color: UIColor(red: 0.8, green: 0.4, blue: 1.0, alpha: 1.0), spread: 15)

        surfaceLayer.addChild(circle(radius: radius, fill: UIColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 1.0)))

        let bands: [(CGFloat, CGFloat, UIColor)] = [
            ( radius*0.7,  radius*1.8, UIColor(red: 0.7, green: 0.3, blue: 0.9, alpha: 0.6)),
            ( radius*0.3,  radius*2.1, UIColor(red: 0.5, green: 0.2, blue: 0.7, alpha: 0.5)),
            ( 0,           radius*2.0, UIColor(red: 0.8, green: 0.4, blue: 1.0, alpha: 0.6)),
            (-radius*0.4,  radius*1.9, UIColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 0.5)),
            (-radius*0.7,  radius*1.7, UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 0.6)),
        ]
        for (y, w, color) in bands {
            let band = SKShapeNode(rectOf: CGSize(width: w, height: radius * 0.12), cornerRadius: radius * 0.06)
            band.fillColor = color
            band.strokeColor = .clear
            band.position = CGPoint(x: 0, y: y)
            surfaceLayer.addChild(band)
        }

        // Büyük Spot (Stilize)
        let spot = circle(radius: radius * 0.2, fill: UIColor(red: 0.9, green: 0.2, blue: 0.5, alpha: 0.8), pos: CGPoint(x: radius * 0.35, y: -radius * 0.2))
        surfaceLayer.addChild(spot)
        let spotInner = circle(radius: radius * 0.1, fill: UIColor.white.withAlphaComponent(0.3), pos: CGPoint(x: radius * 0.35, y: -radius * 0.2))
        surfaceLayer.addChild(spotInner)

        addGasGiantRings()
        addFlatCrescentShadow()
    }

    private func addGasGiantRings() {
        let ringColors = [
            UIColor(red: 0.8, green: 0.4, blue: 1.0, alpha: 0.6),
            UIColor(red: 0.9, green: 0.6, blue: 1.0, alpha: 0.4),
            UIColor(red: 0.7, green: 0.3, blue: 0.9, alpha: 0.5)
        ]
        
        for (idx, color) in ringColors.enumerated() {
            let ringW = radius * (1.8 + CGFloat(idx) * 0.4)
            let ringH = ringW * 0.25
            let ring = SKShapeNode(ellipseOf: CGSize(width: ringW, height: ringH))
            ring.fillColor = .clear
            ring.strokeColor = color
            ring.lineWidth = 10 - CGFloat(idx) * 2
            ring.zPosition = idx == 0 ? 50 : -5 // Mix front and back for effect
            addChild(ring)
        }
    }

    // MARK: - C1: Volkanik Gezegen — Stilize Lav Yarıkları
    private func buildVolcanicPlanet() {
        addAtmosphereGlow(color: UIColor.red, spread: 10)

        surfaceLayer.addChild(circle(radius: radius, fill: UIColor(red: 0.2, green: 0.05, blue: 0.05, alpha: 1.0)))

        // Stilize Lav Yarıkları (Angle lines)
        for i in 0..<12 {
            let angle = CGFloat(i) * .pi * 2 / 12
            let line = SKShapeNode(rectOf: CGSize(width: radius * 1.2, height: radius * 0.08), cornerRadius: radius * 0.04)
            line.fillColor = UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.7)
            line.strokeColor = .clear
            line.zRotation = angle
            surfaceLayer.addChild(line)
        }
        
        surfaceLayer.addChild(circle(radius: radius * 0.3, fill: .orange, pos: .zero))
        surfaceLayer.addChild(circle(radius: radius * 0.15, fill: .yellow, pos: .zero))

        addFlatCrescentShadow()
    }

    // MARK: - C2: Kristal Dünya — Stilize Facetler
    private func buildCrystalWorld() {
        addAtmosphereGlow(color: .cyan, spread: 15)

        surfaceLayer.addChild(circle(radius: radius, fill: UIColor(red: 0.1, green: 0.5, blue: 0.7, alpha: 1.0)))

        let facetCount = 12
        for i in 0..<facetCount {
            let angle = CGFloat(i) * .pi * 2 / CGFloat(facetCount)
            let facet = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: cos(angle) * radius, y: sin(angle) * radius))
            path.addLine(to: CGPoint(x: cos(angle + 0.5) * radius * 0.8, y: sin(angle + 0.5) * radius * 0.8))
            path.closeSubpath()
            facet.path = path
            facet.fillColor = UIColor.white.withAlphaComponent(0.2)
            facet.strokeColor = .white.withAlphaComponent(0.4)
            facet.lineWidth = 1.0
            surfaceLayer.addChild(facet)
        }

        addFlatCrescentShadow()
    }

    // MARK: - Ortak Yardımcılar
    
    private func addAtmosphereGlow(color: UIColor, spread: CGFloat) {
        let glow = SKShapeNode(circleOfRadius: radius + spread)
        glow.fillColor = .clear
        glow.strokeColor = color.withAlphaComponent(0.4)
        glow.lineWidth = spread
        glow.zPosition = -1
        addChild(glow)
        
        // Breathing effect
        glow.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 2.0),
            SKAction.fadeAlpha(to: 0.5, duration: 2.0)
        ])))
    }

    private func addFlatCrescentShadow() {
        let shadowColor = UIColor.black.withAlphaComponent(0.35)
        
        // Ana gölge (Crescent shape via Clipping)
        let mask = SKShapeNode(circleOfRadius: radius)
        let crop = SKCropNode()
        crop.maskNode = mask
        crop.zPosition = 10
        addChild(crop)
        
        let shadow = SKShapeNode(circleOfRadius: radius)
        shadow.fillColor = shadowColor
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: radius * 0.4, y: -radius * 0.4) // Sağ alt gölge
        crop.addChild(shadow)
    }

    // MARK: - Şekil Yardımcıları
    
    private func generateCircleMask(radius: CGFloat) -> SKSpriteNode {
        let size = CGSize(width: radius * 2, height: radius * 2)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKSpriteNode(texture: SKTexture(image: image ?? UIImage()))
    }

    private func circle(radius r: CGFloat, fill: UIColor, pos: CGPoint = .zero) -> SKShapeNode {
        let n = SKShapeNode(circleOfRadius: r)
        n.fillColor  = fill
        n.strokeColor = .clear
        n.position = pos
        return n
    }

    private func ellipse(w: CGFloat, h: CGFloat, fill: UIColor, pos: CGPoint) -> SKShapeNode {
        let n = SKShapeNode(ellipseOf: CGSize(width: w, height: h))
        n.position   = pos
        n.fillColor  = fill
        n.strokeColor = .clear
        return n
    }

    private func makeLineShape(from: CGPoint, to: CGPoint, color: UIColor, width: CGFloat) -> SKShapeNode {
        let n    = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        n.path        = path
        n.strokeColor = color
        n.lineWidth   = width
        n.lineCap     = .round
        return n
    }

    private func makeAngleLine(angle: CGFloat, innerR: CGFloat, outerR: CGFloat, color: UIColor, width: CGFloat) -> SKShapeNode {
        return makeLineShape(
            from: CGPoint(x: cos(angle) * innerR, y: sin(angle) * innerR),
            to:   CGPoint(x: cos(angle) * outerR, y: sin(angle) * outerR),
            color: color, width: width
        )
    }

    // MARK: - Seviye Geçiş Animasyonu
    func animateTransition(to newLevel: CEFRLevel, completion: @escaping () -> Void) {
        let fadeOut   = SKAction.fadeOut(withDuration: 0.5)
        let rebuild   = SKAction.run { [weak self] in self?.removeAllChildren() }
        let fadeIn    = SKAction.fadeIn(withDuration: 0.8)
        let scaleUp   = SKAction.scale(by: 1.1, duration: 0.4)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.4)

        run(SKAction.sequence([
            fadeOut,
            rebuild,
            SKAction.group([fadeIn, SKAction.sequence([scaleUp, scaleDown])]),
            SKAction.run { completion() }
        ]))
    }
}
