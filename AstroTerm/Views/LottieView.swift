// LottieView.swift
// AstroTerm - Lottie animasyonlarını SwiftUI içinde oynatmak ve renklendirmek için wrapper

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .loop
    var contentMode: UIView.ContentMode = .scaleAspectFill
    var color: UIColor? = nil // Yeni: Dinamik renklendirme desteği

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        let animationView = LottieAnimationView()
        
        // Çok katmanlı yükleme stratejisi
        if let animation = LottieAnimation.named(filename, bundle: .main) {
            animationView.animation = animation
        } else if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            animationView.animation = LottieAnimation.filepath(path)
        } else if let path = Bundle.main.path(forResource: filename, ofType: "json", inDirectory: "Resources") {
            animationView.animation = LottieAnimation.filepath(path)
        }
        
        animationView.configuration = LottieConfiguration(renderingEngine: .automatic)
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.backgroundColor = .clear
        
        if let color = color {
            applyColor(color, to: animationView)
        }
        
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let animationView = uiView.subviews.first as? LottieAnimationView {
            animationView.backgroundColor = .clear
            if let color = color {
                applyColor(color, to: animationView)
            }
        }
    }
    
    // MARK: - Renklendirme Mantığı
    private func applyColor(_ color: UIColor, to animationView: LottieAnimationView) {
        animationView.backgroundColor = .clear
        let colorProvider = ColorValueProvider(color.lottieColorValue)
        
        // Sadece arka plan olabilecek katmanları hedefle (Stars/Yıldızlar dokunulmaz kalsın)
        let keypaths = [
            "**.bg.**.Color",
            "**.background.**.Color",
            "**.Fill 1.Color" // Bu bazen riskli olabilir ama şimdilik kalsın
        ]
        
        // Eğer yıldızlar kaybolursa "**.Fill 1.Color" yolunu listeden çıkaracağız.
        for path in keypaths {
            animationView.setValueProvider(colorProvider, keypath: AnimationKeypath(keypath: path))
        }
    }
}
