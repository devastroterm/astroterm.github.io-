// JoystickView.swift
// AstroTerm - Sanal joystick kontrol bileşeni

import SwiftUI

/// D-Pad tarzı sanal joystick — oyuncu gemisini kontrol eder
struct JoystickView: View {

    // MARK: - Callback
    var onDeltaChanged: (CGVector) -> Void
    var onRelease: () -> Void

    // MARK: - Sabitler
    private let outerRadius: CGFloat = 60   // Dış halka yarıçapı
    private let innerRadius: CGFloat = 20   // İç nokta yarıçapı
    private let maxOffset: CGFloat = 38     // Maksimum yön ofseti

    // MARK: - Durum
    @State private var stickOffset: CGSize = .zero
    @State private var isDragging: Bool = false

    var body: some View {
        ZStack {
            // MARK: - Dış Halka
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: outerRadius * 2, height: outerRadius * 2)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.20), lineWidth: 1.5)
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        .frame(width: outerRadius * 1.2, height: outerRadius * 1.2)
                )

            // MARK: - Yön Okları
            directionalArrows

            // MARK: - İç Merkez Nokta (Hareketli)
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.20))
                    .frame(width: innerRadius * 2, height: innerRadius * 2)
                
                Circle()
                    .strokeBorder(Color.white.opacity(0.40), lineWidth: 1.5)
                    .frame(width: innerRadius * 2, height: innerRadius * 2)
                
                Circle()
                    .fill(Color.white.opacity(0.10))
                    .frame(width: innerRadius * 1.2, height: innerRadius * 1.2)
            }
            .shadow(color: Color.black.opacity(0.20), radius: 4, x: 0, y: 2)
            .offset(stickOffset)
            .scaleEffect(isDragging ? 0.90 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isDragging)
        }
        .frame(width: outerRadius * 2, height: outerRadius * 2)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    handleDrag(value.translation)
                }
                .onEnded { _ in
                    handleRelease()
                }
        )
    }

    // MARK: - Yön Okları
    private var directionalArrows: some View {
        ZStack {
            // Yukarı
            arrowShape(rotation: 0)
                .offset(y: -(outerRadius * 0.60))
                .opacity(upArrowOpacity)
            // Aşağı
            arrowShape(rotation: 180)
                .offset(y: outerRadius * 0.60)
                .opacity(downArrowOpacity)
            // Sol
            arrowShape(rotation: 270)
                .offset(x: -(outerRadius * 0.60))
                .opacity(leftArrowOpacity)
            // Sağ
            arrowShape(rotation: 90)
                .offset(x: outerRadius * 0.60)
                .opacity(rightArrowOpacity)
        }
    }

    private func arrowShape(rotation: Double) -> some View {
        Image(systemName: "arrowtriangle.up.fill")
            .resizable()
            .frame(width: 10, height: 12)
            .foregroundColor(Color.white.opacity(0.60))
            .rotationEffect(.degrees(rotation))
    }

    // MARK: - Ok Opaklıkları (Aktif yöne göre)
    private var upArrowOpacity: Double {
        stickOffset.height < -5 ? 0.90 : 0.15
    }
    private var downArrowOpacity: Double {
        stickOffset.height > 5 ? 0.90 : 0.15
    }
    private var leftArrowOpacity: Double {
        stickOffset.width < -5 ? 0.90 : 0.15
    }
    private var rightArrowOpacity: Double {
        stickOffset.width > 5 ? 0.90 : 0.15
    }

    // MARK: - Sürükleme İşleme
    private func handleDrag(_ translation: CGSize) {
        isDragging = true

        // Dairesel sınır içinde tut
        let dx = translation.width
        let dy = translation.height
        let distance = sqrt(dx * dx + dy * dy)

        let clampedDistance = min(distance, maxOffset)
        let angle = atan2(dy, dx)

        let clampedX = cos(angle) * clampedDistance
        let clampedY = sin(angle) * clampedDistance

        stickOffset = CGSize(width: clampedX, height: clampedY)

        // Normalize edilmiş vektör (-1...1)
        let normalizedX = clampedDistance > 3 ? clampedX / maxOffset : 0
        let normalizedY = clampedDistance > 3 ? -(clampedY / maxOffset) : 0  // Y eksenini ters çevir (yukarı = pozitif)

        onDeltaChanged(CGVector(dx: normalizedX, dy: normalizedY))
    }

    private func handleRelease() {
        isDragging = false
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            stickOffset = .zero
        }
        onDeltaChanged(.zero)
        onRelease()
    }
}

// MARK: - Aksiyon Butonu Bileşeni
struct ActionButton: View {

    let icon: String           // SF Symbol adı
    let badgeCount: Int        // Kırmızı rozet sayısı
    let color: Color           // Buton rengi
    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // MARK: - Ana Buton
            Button(action: {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isPressed = false
                }
                action()
            }) {
                ZStack {
                    // Dış daire
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.85),
                                    color.opacity(0.50),
                                ]),
                                center: .center,
                                startRadius: 5,
                                endRadius: 40
                            )
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(color.opacity(0.90), lineWidth: 2)
                        )
                        .shadow(color: color.opacity(0.55), radius: 8, x: 0, y: 0)

                    // İkon
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.white)
                        .shadow(color: color, radius: 4)
                }
                .frame(width: 68, height: 68)
                .scaleEffect(isPressed ? 0.88 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())

            // MARK: - Rozet (Kırmızı Sayı)
            if badgeCount > 0 {
                Text("\(badgeCount)")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.90, green: 0.15, blue: 0.15))
                    )
                    .offset(x: 4, y: -4)
            }
        }
    }
}

// MARK: - Önizleme
#if DEBUG
struct JoystickView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.18)
                .ignoresSafeArea()
            JoystickView(
                onDeltaChanged: { _ in },
                onRelease: { }
            )
        }
    }
}
#endif
