// GameScene.swift
// AstroTerm - Ana SpriteKit oyun sahnesi

import SpriteKit
import AVFoundation
import Combine

/// Oyunun tüm mantığını yöneten SpriteKit sahnesi
final class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - ViewModel Referansı
    weak var viewModel: GameViewModel?

    // MARK: - Sahne Düğümleri
    private var starfield: StarfieldNode?
    private var planet: PlanetNode?
    private var playerShip: PlayerShipNode!
    private var activeEnemies: [EnemyShipNode] = []
    private var activeBullets: [BulletNode] = []
    private var shieldPowerups: [SKShapeNode] = []

    // MARK: - Oyun Durumu
    private var currentWave: (target: WordPair, distractors: [WordPair])?
    private var waveInProgress = false
    private var targetEnemy: EnemyShipNode?
    private var isSlowMoActive = false
    private var gameLevel: CEFRLevel = .a1
    private var sessionWordPool: [WordPair] = []
    private var sessionShownTargets: Set<UUID> = []   // Session içinde hedef olarak gösterilen kelimeler
    private var retryQueue: [WordPair] = []
    private var waveHadAnyKill = false   // Mevcut dalgada en az 1 düşman vuruldu mu?

    // MARK: - Zamanlayıcılar
    private var enemySpawnTimer: TimeInterval = 0
    private var enemySpawnInterval: TimeInterval = 3.5
    private var lastUpdateTime: TimeInterval = 0
    private var waveCount = 0
    private var enemyShootTimer: TimeInterval = 0
    private var lastFireTime: TimeInterval = 0          // Ateş hızı sınırlayıcı

    // MARK: - Ses (AVAudioEngine)
    // Sadece düşük gecikmeli SFX (lazer, patlama vb.) için kullanılır.
    // Arka plan müziği global AudioManager tarafından yönetilir.
    private var gameAudioEngine: AVAudioEngine!
    private var mainMixer: AVAudioMixerNode!

    // Ses efekti türleri
    private enum SFX {
        case laser, specialLaser1, specialLaser2
        case correct1, correct2
        case wrong
        case levelUp0, levelUp1, levelUp2, levelUp3
    }

    // Önceden üretilmiş buffer'lar (bir kez oluşturulur, tekrar kullanılır)
    private var sfxBuffers: [SFX: AVAudioPCMBuffer] = [:]

    // Sabit node havuzu — attach/detach yok, glitch yok
    private var sfxNodes: [AVAudioPlayerNode] = []
    private var sfxNodeIndex = 0
    private let sfxPoolSize = 8

    private var audioSubscriptions = Set<AnyCancellable>()

    // MARK: - Fizik Kategorileri
    private let playerCategory:      UInt32 = 0x1 << 0
    private let enemyCategory:       UInt32 = 0x1 << 1
    private let playerBulletCategory:UInt32 = 0x1 << 2
    private let enemyBulletCategory: UInt32 = 0x1 << 3
    private let powerupCategory:     UInt32 = 0x1 << 4

    // MARK: - Sahne Hazırlama
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5) // Ekranın ortasını (0,0) noktası yap
        setupPhysics()
        setupBackground()
        setupPlanet()
        setupPlayerShip()
        setupAudio()
        setupAudioObservers()
        startNextWave()
    }

    // MARK: - Fizik
    private func setupPhysics() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        backgroundColor = UIColor(red: 0.05, green: 0.07, blue: 0.18, alpha: 1.0)
    }

    // MARK: - Arka Plan
    private func setupBackground() {
        let sf = StarfieldNode(size: size, level: gameLevel)
        sf.zPosition = -20
        addChild(sf)
        starfield = sf
    }

    private func transitionBackground(to level: CEFRLevel) {
        let newStarfield = StarfieldNode(size: size, level: level)
        newStarfield.zPosition = -20
        newStarfield.alpha = 0
        addChild(newStarfield)
        newStarfield.run(SKAction.fadeIn(withDuration: 1.2)) { [weak self] in
            self?.starfield?.removeFromParent()
            self?.starfield = newStarfield
        }
    }

    // MARK: - Gezegen
    private func setupPlanet() {
        guard gameLevel != .a1 && gameLevel != .a2 && gameLevel != .b1 && gameLevel != .b2 && gameLevel != .c1 else { return }
        
        let p = PlanetNode(level: gameLevel, radius: 170)
        // Sol alt köşeye yerleştir (kısmen görünür)
        p.position = CGPoint(x: -size.width * 0.38, y: -size.height * 0.35)
        p.zPosition = -5
        addChild(p)
        planet = p
    }

    // MARK: - Oyuncu Gemisi
    private func setupPlayerShip() {
        playerShip = PlayerShipNode()
        playerShip.position = CGPoint(x: -size.width * 0.32, y: size.height * 0.05)
        playerShip.zPosition = 10
        addChild(playerShip)
    }

    // MARK: - Dalga Başlatma
    private func startNextWave() {
        guard let viewModel = viewModel else { return }
        
        // --- DEFENSIVE CHECK ---
        // Eğer herhangi bir UI blokajı (Diyalog, Seviye Atlama, Pause) varsa,
        // dalgayı başlatma ve 0.5 saniye sonra tekrar dene.
        if viewModel.isUIBlocking {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.startNextWave()
            }
            return
        }

        // isGameOver burada kontrol edilmez — revive sonrası
        // acceptRevive() zaten false'a çekmiştir. Sahneyi her ihtimale
        // karşı unpause et (hem SKScene hem SKView katmanı).
        isPaused = false
        view?.isPaused = false

        waveInProgress = true   // Yeni dalga başladı
        waveHadAnyKill = false  // Bu dalgadaki kill sayacını sıfırla

        // Havuz boşsa sıfırdan oluştur (level geçişi performLevelTransition'da temizler)
        if sessionWordPool.isEmpty {
            let rawWords = WordDatabase.shared.words(for: gameLevel)

            // Aynı kelimeyi (duplicate) havuza girmeden temizle
            var uniqueWords: [WordPair] = []
            var seenTexts = Set<String>()

            for w in rawWords {
                let textLower = w.english.lowercased()
                if !seenTexts.contains(textLower) {
                    seenTexts.insert(textLower)
                    uniqueWords.append(w)
                }
            }

            sessionWordPool = uniqueWords.shuffled()
            sessionShownTargets.removeAll() // Havuz yenilendi → gösterim geçmişini sıfırla
        }

        // Güvenlik: Eğer veritabanından hiç kelime gelmediyse dur
        guard !sessionWordPool.isEmpty else { return }

        // Retry queue karıştır (spam hissini azaltır)
        retryQueue.shuffle()

        // --- Target (Hedef) Seçimi ---
        let target: WordPair
        if !retryQueue.isEmpty && Bool.random() {
            // Yanlış cevaplanmış kelimeyi tekrar sor
            target = retryQueue.removeFirst()
        } else {
            // Bu session'da henüz hedef olarak gösterilmemiş kelimeleri filtrele
            var availablePool = sessionWordPool.filter { !sessionShownTargets.contains($0.id) }

            // Tüm kelimeler bir tur gösterildiyse geçmişi sıfırla ve baştan başla
            if availablePool.isEmpty {
                sessionShownTargets.removeAll()
                availablePool = sessionWordPool
            }

            target = availablePool.randomElement()!
        }

        // Hedefi "gösterildi" olarak işaretle
        sessionShownTargets.insert(target.id)

        // --- Çeldirici Seçimi (sadece mevcut level havuzundan) ---
        // Her kelime sadece kendi levelinde çeldirici olarak da görünmeli
        var distractors: [WordPair] = []
        var usedTexts = Set<String>([target.english.lowercased()])

        for word in sessionWordPool.shuffled() {
            if distractors.count >= 3 { break }
            let text = word.english.lowercased()
            if !usedTexts.contains(text) {
                usedTexts.insert(text)
                distractors.append(word)
            }
        }

        let wave = (target: target, distractors: distractors)
        currentWave = wave

        viewModel.updateCurrentWord(target)
        waveCount += 1
        enemySpawnTimer = 0

        spawnEnemyWave(wave: wave)
    }
    
    // MARK: - Düşman Dalgası Oluştur
    private func spawnEnemyWave(wave: (target: WordPair, distractors: [WordPair])) {
        let allWords = ([wave.target] + wave.distractors).shuffled()
        let count = allWords.count

        // Spacing'i ekran yüksekliğine göre dinamik hesapla:
        let usableHeight = size.height - 140
        let dynamicSpacing = count > 1
            ? min(110, usableHeight / CGFloat(count))
            : 110
        let spacing: CGFloat = max(75, dynamicSpacing)

        for (i, pair) in allWords.enumerated() {
            let isTarget = pair.id == wave.target.id

            let yOffset = (CGFloat(i) - CGFloat(count - 1) / 2.0) * spacing

            let enemy = EnemyShipNode(
                wordPair: pair,
                isCorrectTarget: isTarget,
                level: gameLevel,
                oscOffset: CGFloat(i)
            )

            let startX = size.width / 2 + 80
            enemy.position = CGPoint(x: startX, y: yOffset)
            enemy.zPosition = 5
            enemy.alpha = 0
            addChild(enemy)
            activeEnemies.append(enemy)

            // Fizik kontağı spawn anında kapalı — update() döngüsündeki
            // activatePhysicsForVisibleEnemies() düşman ekrana girince açar.
            // Bu sayede ekran dışındaki düşmanlara mermi isabetiyle kelime
            // tekrarı yaşanmaz.
            enemy.physicsBody?.contactTestBitMask = 0

            let fadeDelay = Double(i) * 0.10
            enemy.run(SKAction.sequence([
                SKAction.wait(forDuration: fadeDelay),
                SKAction.fadeIn(withDuration: 0.25)
            ]))
        }

        // Fade-in tamamlandıktan hemen sonra ilerlemeye başlar
        let approachDelay = Double(count) * 0.10 + 0.30
        DispatchQueue.main.asyncAfter(deadline: .now() + approachDelay) { [weak self] in
            self?.startEnemyApproach()
        }
    }

    // MARK: - Pozisyon Tabanlı Fizik Aktivasyonu
    // Mermi isyanını önler: düşman görünür alana GİRDİKTEN sonra çarpışmayı aç
    private func activatePhysicsForVisibleEnemies() {
        let screenRightEdge = size.width / 2
        for enemy in activeEnemies {
            // Sadece hâlâ devre dışı olan fizikleri kontrol et
            guard enemy.physicsBody?.contactTestBitMask == 0 else { continue }
            // Düşman ekranın sağ kenarından içeri girdi mi?
            if enemy.position.x < screenRightEdge - 20 {
                enemy.physicsBody?.contactTestBitMask = BulletNode.playerBulletCategory
            }
        }
    }

    // MARK: - Düşman İlerlemesi
    private func startEnemyApproach() {
        for enemy in activeEnemies {
            let moveLeft = SKAction.moveBy(x: -size.width * 1.8, y: 0, duration: TimeInterval(size.width * 1.8 / gameLevel.enemySpeed))
            let reachBase = SKAction.run { [weak self] in
                self?.enemyReachedBase(enemy: enemy)
            }
            enemy.run(SKAction.sequence([moveLeft, reachBase]), withKey: "approach")
        }
    }

    // MARK: - Düşman Üsse Ulaştı
    private func enemyReachedBase(enemy: EnemyShipNode) {
        if let idx = activeEnemies.firstIndex(where: { $0 === enemy }) {
            activeEnemies.remove(at: idx)
        }
        
        if enemy.isCorrectTarget, let current = currentWave?.target {
            if !retryQueue.contains(where: { $0.id == current.id }) {
                retryQueue.append(current)
            }
        }
        
        enemy.removeFromParent()

        viewModel?.onEnemyReachedBase?()
        playHaptic(.warning)

        // Düşman üsse ulaştığında dalga bitti mi diye merkezi fonksiyona sor
        checkWaveComplete()
    }

    // MARK: - Dalga Tamamlandı mı? (Merkezi Kontrol)
    private func checkWaveComplete() {
        // Sahnede hiç aktif düşman kalmadıysa dalga bitmiştir
        guard activeEnemies.isEmpty else { return }

        // Dalganın çift tetiklenmesini engelle
        guard waveInProgress else { return }

        // --- DEFENSIVE CHECK ---
        // Eğer herhangi bir UI blokajı (Diyalog, Seviye Atlama, Pause) varsa,
        // bitene kadar dalga bitirme işlemini ertele. 
        // Bunu waveInProgress = false yapmadan önce yapmalıyız!
        if let vm = viewModel, vm.isUIBlocking {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.checkWaveComplete()
            }
            return
        }

        waveInProgress = false

        // Hiç kill yoksa → tüm dalga geçti → anında game over
        if !waveHadAnyKill {
            viewModel?.onEnemyReachedBase?()   // Can düşür
            viewModel?.triggerGameOver?()      // Game over tetikle
            return
        }

        let delay = gameLevel.waveTransitionDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self, let vm = self.viewModel, !vm.isGameOver else { return }
            
            self.gameLevel = vm.currentLevel
            self.startNextWave()
        }
    }

    // MARK: - Kalan Düşmanları Temizle
    private func clearRemainingEnemiesAndStartNextWave() {
        for distractor in activeEnemies {
            distractor.removeAction(forKey: "approach")
            distractor.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.15),
                SKAction.removeFromParent()
            ]))
        }
        activeEnemies.removeAll()
        targetEnemy = nil
        
        checkWaveComplete() // Temizlik bitince dalgayı güvenle kapatır
    }

    // MARK: - Joystick ile Oyuncu Hareketi
    private func updatePlayerMovement(deltaTime: TimeInterval) {
        guard let vm = viewModel else { return }

        let joystick = vm.joystickDelta
        guard vm.joystickDelta != .zero else {
            playerShip.stopMoving()
            return
        }

        let speed: CGFloat = 200
        let dx = joystick.dx * speed * CGFloat(deltaTime)
        let dy = joystick.dy * speed * CGFloat(deltaTime)

        var newX = playerShip.position.x + dx
        var newY = playerShip.position.y + dy

        let minX = -size.width / 2 + 40
        let maxX = -size.width * 0.05
        let minY = -size.height / 2 + 60
        let maxY = size.height / 2 - 60

        newX = max(minX, min(maxX, newX))
        newY = max(minY, min(maxY, newY))

        playerShip.position = CGPoint(x: newX, y: newY)
        playerShip.move(direction: CGVector(dx: joystick.dx, dy: joystick.dy), speed: speed)
    }

    // MARK: - Hedefleme
    private func updateTargeting() {
        let playerY = playerShip.position.y
        var closestEnemy: EnemyShipNode?
        var closestDist = CGFloat.greatestFiniteMagnitude

        for enemy in activeEnemies {
            let dist = abs(enemy.position.y - playerY)
            if dist < closestDist {
                closestDist = dist
                closestEnemy = enemy
            }
        }

        if let prev = targetEnemy, prev !== closestEnemy {
            prev.setHighlighted(false)
        }
        targetEnemy = closestEnemy
        closestEnemy?.setHighlighted(true)
        playerShip.showTargetingReticle(visible: closestEnemy != nil && closestDist < 120)
    }

    // MARK: - Ateşleme (Oyuncu)
    func firePlayerBullet(isSpecial: Bool = false) {
        guard !(viewModel?.isGamePaused ?? true) else { return }
        guard let ship = playerShip else { return }   // Sahne henüz hazır değilse çık

        // Ateş hızı sınırlayıcı: çok hızlı ateşleme bug'larını önler
        let fireCooldown: TimeInterval = isSpecial ? 0.08 : 0.12
        let now = CACurrentMediaTime()
        guard now - lastFireTime >= fireCooldown else { return }
        lastFireTime = now

        let bulletType: BulletType = isSpecial ? .specialLaser : .playerLaser
        let bullet = BulletNode(type: bulletType)
        bullet.position = CGPoint(x: ship.position.x + 60, y: ship.position.y)
        bullet.zPosition = 8
        addChild(bullet)
        activeBullets.append(bullet)

        let speed: CGFloat = isSpecial ? 600 : 500
        bullet.physicsBody?.velocity = CGVector(dx: speed, dy: 0)

        ship.playFireAnimation()
        playLaserSound(special: isSpecial)
        playHaptic(.light)
    }

    // MARK: - Düşman Ateşi
    private func updateEnemyShooting(deltaTime: TimeInterval) {
        guard gameLevel.enemiesShootBack else { return }
        enemyShootTimer += deltaTime
        if enemyShootTimer >= 2.5 {
            enemyShootTimer = 0
            if let shooter = activeEnemies.randomElement() {
                spawnEnemyBullet(from: shooter)
            }
        }
    }

    private func spawnEnemyBullet(from enemy: EnemyShipNode) {
        let bullet = BulletNode(type: .enemyShot)
        bullet.position = CGPoint(x: enemy.position.x - 30, y: enemy.position.y)
        bullet.zPosition = 8
        addChild(bullet)
        activeBullets.append(bullet)
        bullet.physicsBody?.velocity = CGVector(dx: -280, dy: 0)
    }

    // MARK: - Özel Yetenek (Yavaşlatma)
    func activateSlowMotion() {
        guard !isSlowMoActive else { return }
        guard let ship = playerShip else { return }
        isSlowMoActive = true
        viewModel?.useSpecialAbility()
        ship.playSpecialAbilityAnimation()

        for enemy in activeEnemies {
            enemy.speed = 0.25
            enemy.applySlowEffect(true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.deactivateSlowMotion()
        }

        let overlay = SKShapeNode(rect: CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size))
        overlay.fillColor = UIColor(red: 0.10, green: 0.40, blue: 0.80, alpha: 0.15)
        overlay.strokeColor = .clear
        overlay.zPosition = 50
        overlay.name = "slowOverlay"
        addChild(overlay)
    }

    private func deactivateSlowMotion() {
        isSlowMoActive = false
        for enemy in activeEnemies {
            enemy.speed = 1.0
            enemy.applySlowEffect(false)
        }
        childNode(withName: "slowOverlay")?.removeFromParent()
    }

    // MARK: - Dokunma ile Hedefleme
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for enemy in activeEnemies {
            let enemyFrame = CGRect(
                x: enemy.position.x - 55, y: enemy.position.y - 55,
                width: 110, height: 110
            )
            if enemyFrame.contains(location) {
                targetEnemy = enemy
                firePlayerBullet()
                return
            }
        }
    }

    // MARK: - Fizik Teması (Mermi - Düşman)
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        let isPlayerBulletHit =
            (bodyA.categoryBitMask == playerBulletCategory && bodyB.categoryBitMask == enemyCategory) ||
            (bodyB.categoryBitMask == playerBulletCategory && bodyA.categoryBitMask == enemyCategory)

        let isEnemyBulletHit =
            (bodyA.categoryBitMask == enemyBulletCategory && bodyB.categoryBitMask == playerCategory) ||
            (bodyB.categoryBitMask == enemyBulletCategory && bodyA.categoryBitMask == playerCategory)

        if isPlayerBulletHit {
            let bulletNode = bodyA.categoryBitMask == playerBulletCategory ? bodyA.node : bodyB.node
            let enemyNode  = bodyA.categoryBitMask == enemyCategory ? bodyA.node : bodyB.node

            if let bullet = bulletNode as? BulletNode,
               let enemy = enemyNode as? EnemyShipNode {
                handleBulletHitEnemy(bullet: bullet, enemy: enemy)
            }
        }

        if isEnemyBulletHit {
            let bulletNode = bodyA.categoryBitMask == enemyBulletCategory ? bodyA.node : bodyB.node
            if let bullet = bulletNode as? BulletNode {
                bullet.removeFromParent()
                activeBullets.removeAll { $0 === bullet }
                viewModel?.onWrongAnswer?()
                playerShip.playHitAnimation()
            }
        }
    }

    // MARK: - Mermi - Düşman Çarpışması
    private func handleBulletHitEnemy(bullet: BulletNode, enemy: EnemyShipNode) {
        // Merminin sahnede hâlâ olup olmadığını kontrol et (çift tetiklenmeyi önler)
        guard bullet.parent != nil else { return }
        bullet.removeFromParent()
        activeBullets.removeAll { $0 === bullet }

        // Düşman zaten işlendi mi? (hızlı ateşte iki mermi aynı düşmana ulaşabilir)
        guard activeEnemies.contains(where: { $0 === enemy }) else { return }

        if enemy.isCorrectTarget {
            handleCorrectHit(enemy: enemy)
        } else {
            handleWrongHit(enemy: enemy)
        }
    }

    // MARK: - Doğru Cevap
    private func handleCorrectHit(enemy: EnemyShipNode) {
        let colors = gameLevel.enemyColorComponents
        let color = UIColor(red: colors.r, green: colors.g, blue: colors.b, alpha: 1.0)
        let baseScore = 10 + (gameLevel.correctAnswersThreshold / 2)

        enemy.removeAction(forKey: "approach")
        activeEnemies.removeAll { $0 === enemy }

        enemy.playHitAnimation { [weak self, weak enemy] in
            guard let self, let enemy else { return }

            let explosion = ExplosionNode(color: color, size: 50, isCorrect: true)
            explosion.position = enemy.position
            explosion.zPosition = 15
            self.addChild(explosion)

            self.showScorePopup(at: enemy.position, points: baseScore)
            enemy.removeFromParent()
        }

        waveHadAnyKill = true   // Bu dalgada en az 1 doğru vurma yapıldı
        viewModel?.onCorrectAnswer?(baseScore)
        playCorrectSound()
        playHaptic(.medium)

        if Double.random(in: 0...1) < 0.15 {
            spawnShieldPowerup(at: enemy.position)
        }

        clearRemainingEnemiesAndStartNextWave()
    }

    // MARK: - Yanlış Cevap
    private func handleWrongHit(enemy: EnemyShipNode) {
        let explosion = ExplosionNode(color: .red, size: 30, isCorrect: false)
        explosion.position = enemy.position
        explosion.zPosition = 15
        addChild(explosion)

        enemy.removeAction(forKey: "approach")
        activeEnemies.removeAll { $0 === enemy }
        enemy.removeFromParent()

        viewModel?.onWrongAnswer?()
        playerShip.playHitAnimation()
        playWrongSound()
        playHaptic(.heavy)

        if let current = currentWave?.target {
            if !retryQueue.contains(where: { $0.id == current.id }) {
                retryQueue.append(current)
            }
        }
        
        checkWaveComplete()
    }

    // MARK: - Kalkan Güç-Yukarı
    private func spawnShieldPowerup(at position: CGPoint) {
        let shield = SKShapeNode(circleOfRadius: 14)
        shield.position = position
        shield.fillColor = UIColor(red: 0.20, green: 0.80, blue: 0.35, alpha: 0.90)
        shield.strokeColor = UIColor(red: 0.40, green: 1.0, blue: 0.60, alpha: 1.0)
        shield.lineWidth = 2
        shield.zPosition = 12

        let icon = SKLabelNode(text: "🛡")
        icon.fontSize = 18
        icon.verticalAlignmentMode = .center
        shield.addChild(icon)

        shield.physicsBody = SKPhysicsBody(circleOfRadius: 14)
        shield.physicsBody?.categoryBitMask = powerupCategory
        shield.physicsBody?.isDynamic = true
        shield.physicsBody?.affectedByGravity = false
        shield.physicsBody?.velocity = CGVector(dx: -60, dy: 0)

        addChild(shield)
        shieldPowerups.append(shield)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 0.9, duration: 0.5),
        ])
        shield.run(SKAction.repeatForever(pulse))

        shield.run(SKAction.sequence([
            SKAction.wait(forDuration: 8.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Güç-Yukarı Toplama
    private func checkPowerupCollection() {
        for powerup in shieldPowerups {
            let dist = CGPoint(x: powerup.position.x - playerShip.position.x,
                               y: powerup.position.y - playerShip.position.y)
            let distance = sqrt(dist.x * dist.x + dist.y * dist.y)

            if distance < 55 {
                powerup.removeFromParent()
                shieldPowerups.removeAll { $0 === powerup }
                viewModel?.onShieldPickup?()

                let collect = ExplosionNode(color: UIColor(red: 0.20, green: 0.80, blue: 0.35, alpha: 1.0),
                                            size: 20, isCorrect: true)
                collect.position = powerup.position
                addChild(collect)

                playHaptic(.medium)
                break
            }
        }
    }

    // MARK: - Ekran Dışı Mermi Temizleme
    private func cleanupBullets() {
        for bullet in activeBullets {
            if bullet.isOffScreen(in: size) {
                bullet.removeFromParent()
            }
        }
        activeBullets.removeAll { $0.parent == nil }
    }

    // MARK: - Puan Animasyonu
    private func showScorePopup(at position: CGPoint, points: Int) {
        let label = SKLabelNode(text: "+\(points)")
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 22
        label.fontColor = UIColor(red: 0.30, green: 1.0, blue: 0.55, alpha: 1.0)
        label.position = position
        label.zPosition = 20
        addChild(label)

        let moveUp = SKAction.moveBy(x: 0, y: 60, duration: 1.0)
        moveUp.timingMode = .easeOut
        let fade = SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.fadeOut(withDuration: 0.6)
        ])
        let remove = SKAction.removeFromParent()
        label.run(SKAction.sequence([SKAction.group([moveUp, fade]), remove]))
    }

    // MARK: - Seviye Geçiş Efekti
    func performLevelTransition(to newLevel: CEFRLevel) {
        for enemy in activeEnemies {
            enemy.removeAllActions()
            enemy.removeFromParent()
        }
        activeEnemies.removeAll()
        targetEnemy = nil

        planet?.removeFromParent()
        planet = nil
        
        if newLevel != .a1 && newLevel != .a2 && newLevel != .b1 && newLevel != .b2 && newLevel != .c1 {
            let p = PlanetNode(level: newLevel, radius: 170)
            p.position = CGPoint(x: -size.width * 0.38, y: -size.height * 0.35)
            p.zPosition = -5
            p.alpha = 0
            addChild(p)
            p.run(SKAction.fadeIn(withDuration: 1.0))
            planet = p
        }

        let flashOverlay = SKShapeNode(
            rect: CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size)
        )
        flashOverlay.fillColor = UIColor(white: 1.0, alpha: 0.90)
        flashOverlay.strokeColor = .clear
        flashOverlay.zPosition = 100
        addChild(flashOverlay)
        flashOverlay.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.fadeOut(withDuration: 0.6),
            SKAction.removeFromParent()
        ]))

        gameLevel = newLevel

        // Yeni seviyeye geçerken eski kelime havuzunu ve gösterim geçmişini sıfırla
        sessionWordPool.removeAll()
        sessionShownTargets.removeAll()
        retryQueue.removeAll()

        // Starfield geçişi (flash bittikten sonra)
        transitionBackground(to: newLevel)

        playLevelUpSound()
    }

    // MARK: - Ekran Boyutu Değişimi
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if let planet = planet {
            planet.position = CGPoint(x: -size.width * 0.38, y: -size.height * 0.35)
        }
        if let ship = playerShip {
            ship.position.x = -size.width * 0.32
        }
    }

    // MARK: - Düşmanların Gemiyi Geçme Kontrolü
    private func checkEnemiesPassingPlayer() {
        guard let ship = playerShip else { return }
        // Geminin x pozisyonundan geriye geçerlerse
        let passThreshold = ship.position.x - 40
        
        let passedEnemies = activeEnemies.filter { $0.position.x < passThreshold }
        for enemy in passedEnemies {
            enemyReachedBase(enemy: enemy)
        }
    }

    // MARK: - Update Döngüsü
    override func update(_ currentTime: TimeInterval) {
        guard let vm = viewModel, !vm.isUIBlocking else { return }

        let deltaTime = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 0.05)
        lastUpdateTime = currentTime

        updatePlayerMovement(deltaTime: deltaTime)
        updateTargeting()
        updateEnemyShooting(deltaTime: deltaTime)
        activatePhysicsForVisibleEnemies()
        checkEnemiesPassingPlayer()
        checkPowerupCollection()
        cleanupBullets()
        vm.tickCombo(deltaTime: deltaTime)

        starfield?.scroll(by: 0.5)
    }

    // MARK: - Duraklatma / Sıfırlama
    func setPaused(_ paused: Bool) {
        isPaused = paused
        // SKView.isPaused ve SKScene.isPaused bağımsız çalışır.
        view?.isPaused = paused
    }

    func revivePlayer() {
        // Ekrandaki tüm düşmanları ve mermileri temizle
        for enemy in activeEnemies { enemy.removeFromParent() }
        activeEnemies.removeAll()
        for bullet in activeBullets { bullet.removeFromParent() }
        activeBullets.removeAll()
        
        targetEnemy = nil
        waveInProgress = false
        
        // Gemiyi hafifçe parlatarak (yenilmezlik hissi) oyuna başlat
        playerShip?.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1),
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ]))
        
        // Hızla bir sonraki dalgayı başlat
        startNextWave()
    }

    func resetScene() {
        sessionWordPool.removeAll()
        sessionShownTargets.removeAll()
        retryQueue.removeAll()
        for enemy in activeEnemies { enemy.removeFromParent() }
        activeEnemies.removeAll()
        for bullet in activeBullets { bullet.removeFromParent() }
        activeBullets.removeAll()
        for powerup in shieldPowerups { powerup.removeFromParent() }
        shieldPowerups.removeAll()
        targetEnemy = nil
        waveInProgress = false
        gameLevel = .a1
        lastUpdateTime = 0
        waveCount = 0
        enemyShootTimer = 0

        planet?.removeFromParent()
        setupPlanet()

        // Starfield'ı A1'er sıfırla
        starfield?.removeFromParent()
        let resetSf = StarfieldNode(size: size, level: .a1)
        resetSf.zPosition = -20
        addChild(resetSf)
        starfield = resetSf

        playerShip?.position = CGPoint(x: -size.width * 0.32, y: size.height * 0.05)
        startNextWave()
    }

    // MARK: - Ses Efektleri (AVAudioEngine)
    private func setupAudio() {
        gameAudioEngine = AVAudioEngine()
        mainMixer = gameAudioEngine.mainMixerNode
        
        // Başlangıç ses ayarları
        updateVolumes()

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        buildSFXBuffers(format: format)

        for _ in 0..<sfxPoolSize {
            let node = AVAudioPlayerNode()
            gameAudioEngine.attach(node)
            gameAudioEngine.connect(node, to: mainMixer, format: format)
            sfxNodes.append(node)
        }

        do {
            try gameAudioEngine.start()
        } catch {
            return
        }

        for node in sfxNodes {
            node.play()
        }
    }

    private func setupAudioObservers() {
        viewModel?.$isSfxEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateVolumes() }
            .store(in: &audioSubscriptions)
    }

    private func updateVolumes() {
        guard let vm = viewModel else { return }
        
        // SFX Control
        for node in sfxNodes {
            node.volume = vm.isSfxEnabled ? 1.0 : 0.0
        }
    }

    private func buildSFXBuffers(format: AVAudioFormat) {
        let specs: [(SFX, Float, Float, Float)] = [
            (.laser,         880, 0.08, 0.20),
            (.specialLaser1, 660, 0.15, 0.25),
            (.specialLaser2, 880, 0.12, 0.20),
            (.correct1,      660, 0.12, 0.30),
            (.correct2,      880, 0.18, 0.25),
            (.wrong,         180, 0.25, 0.35),
            (.levelUp0,      262, 0.20, 0.30),
            (.levelUp1,      330, 0.20, 0.30),
            (.levelUp2,      392, 0.20, 0.30),
            (.levelUp3,      523, 0.20, 0.30),
        ]
        for (sfx, freq, dur, amp) in specs {
            sfxBuffers[sfx] = makeToneBuffer(format: format, frequency: freq, duration: dur, amplitude: amp)
        }
    }

    private func makeToneBuffer(format: AVAudioFormat, frequency: Float, duration: Float, amplitude: Float) -> AVAudioPCMBuffer? {
        let sampleRate = Float(format.sampleRate)
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        let data = buffer.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Float(i) / sampleRate
            let env = t < 0.01 ? t / 0.01 : max(0, 1.0 - (t - 0.01) / (duration - 0.01))
            data[i] = amplitude * env * sin(2.0 * .pi * frequency * t)
        }
        return buffer
    }

    private func playSFX(_ sfx: SFX) {
        guard let vm = viewModel, vm.isSfxEnabled else { return }
        guard let buffer = sfxBuffers[sfx], !sfxNodes.isEmpty else { return }
        let node = sfxNodes[sfxNodeIndex % sfxPoolSize]
        sfxNodeIndex = (sfxNodeIndex + 1) % sfxPoolSize
        node.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }

    private func playLaserSound(special: Bool) {
        if special {
            playSFX(.specialLaser1)
            playSFX(.specialLaser2)
        } else {
            playSFX(.laser)
        }
    }

    private func playCorrectSound() {
        playSFX(.correct1)
        playSFX(.correct2)
    }

    private func playWrongSound() {
        playSFX(.wrong)
    }

    private func playLevelUpSound() {
        guard let n0 = sfxBuffers[.levelUp0],
              let n1 = sfxBuffers[.levelUp1],
              let n2 = sfxBuffers[.levelUp2],
              let n3 = sfxBuffers[.levelUp3],
              !sfxNodes.isEmpty else { return }
        let node = sfxNodes[sfxNodeIndex % sfxPoolSize]
        sfxNodeIndex = (sfxNodeIndex + 1) % sfxPoolSize
        node.scheduleBuffer(n0, at: nil, options: [], completionHandler: nil)
        node.scheduleBuffer(n1, at: nil, options: [], completionHandler: nil)
        node.scheduleBuffer(n2, at: nil, options: [], completionHandler: nil)
        node.scheduleBuffer(n3, at: nil, options: [], completionHandler: nil)
    }

    // MARK: - Haptic Geri Bildirim
    private func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard viewModel?.isSfxEnabled == true else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    private func playHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard viewModel?.isSfxEnabled == true else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
