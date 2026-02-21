import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel

    init(onGetStarted: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(onGetStarted: onGetStarted))
    }

    @State private var floating = false

    private let olive = Color("GreenLight")

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            glassesAndCoinAnimation
                .offset(y: floating ? -8 : 8)
            
            Spacer()
            
            titleText
            
            actionButtons
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear {
            floating = false
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                floating = true
            }
        }
    }
    
    // Constants for precise geometry matching a glass tumbler
    private let glassW: CGFloat = 85
    private let glassH: CGFloat = 135
    private let rimW: CGFloat = 85
    private let rimH: CGFloat = 28 // Slightly flatter ellipse for a more natural perspective
    private let rimY: CGFloat = -135 / 2
    
    // MARK: - Subviews
    
    private var glassesAndCoinAnimation: some View {
        ZStack {
            // Back of Jars
            HStack(spacing: 40) {
                ForEach(glassThemes) { theme in
                    glassBack(theme: theme)
                        .frame(width: glassW, height: glassH)
                        .rotationEffect(.degrees(theme.tilt))
                }
            }
            
            // The animating jumping coin
            leapingCoin

            // Front of Jars (Glass & Lid)
            HStack(spacing: 40) {
                ForEach(glassThemes) { theme in
                    glassFront(theme: theme)
                        .frame(width: glassW, height: glassH)
                        .rotationEffect(.degrees(theme.tilt))
                }
            }
        }
    }
    
    private var titleText: some View {
        Text("160 COUNTRIES, 40\nCURRENCIES. ONE\nACCOUNT")
            .font(.system(size: 30, weight: .black, design: .rounded))
            .multilineTextAlignment(.center)
            .lineSpacing(2)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 0) {
            Button(action: {
                viewModel.checkRatesTapped()
            }) {
                Text("Check our rates")
                    .font(.system(size: 17, weight: .semibold))
                    .underline()
                    .foregroundStyle(.black.opacity(0.84))
                    .padding(.top, 18)
            }

            Button(action: {
                viewModel.getStartedTapped()
            }) {
                Text("Get started")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(olive)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 26)
        }
    }

    // Positions for the 3 bottles (approximate centers of the bottle openings)
    // Bottle 1 (left): offset approx -120 to -110 from center
    // Bottle 2 (center): offset approx 0 from center
    // Bottle 3 (right): offset approx +110 to +120 from center
    // Top opening Y is roughly -75 from the bottle center.
    private var leapingCoin: some View {
        KeyframeAnimator(initialValue: CoinAnimationValues(), repeating: true) { values in
            coin3D()
                .rotation3DEffect(.degrees(values.rotation), axis: (x: 1, y: 0.4, z: 0.2))
                .offset(x: values.xOffset, y: values.yOffset)
                // Shadow for 3D jump effect
                .shadow(color: .black.opacity(0.15), radius: 6, y: 8)
        } keyframes: { _ in
            KeyframeTrack(\.xOffset) {
                // Start J1 inside
                LinearKeyframe(-125, duration: 0.1)
                // Jump to J2
                CubicKeyframe(-155, duration: 0.1) // slide out (was 0.2)
                CubicKeyframe(8.5, duration: 0.6)  // hop
                CubicKeyframe(-5, duration: 0.2)   // slide in
                LinearKeyframe(-5, duration: 0.3)  // wait in J2
                // Jump to J3
                CubicKeyframe(8.5, duration: 0.2)
                CubicKeyframe(146, duration: 0.6)
                CubicKeyframe(129, duration: 0.2)
                LinearKeyframe(129, duration: 0.3)
                // Jump to J1
                CubicKeyframe(146, duration: 0.2)
                CubicKeyframe(-155, duration: 0.8) // longer hop
                CubicKeyframe(-125, duration: 0.2)
                LinearKeyframe(-125, duration: 0.3)
            }
            
            KeyframeTrack(\.yOffset) {
                // Start J1 inside
                LinearKeyframe(39, duration: 0.1)
                // Jump to J2
                CubicKeyframe(-68, duration: 0.1)  // slide out
                CubicKeyframe(-200, duration: 0.3) // hop peak
                CubicKeyframe(-69, duration: 0.3)  // hop end
                CubicKeyframe(40, duration: 0.2)   // slide in
                LinearKeyframe(40, duration: 0.3)  // wait
                // Jump to J3
                CubicKeyframe(-69, duration: 0.2)
                CubicKeyframe(-200, duration: 0.3) // hop peak
                CubicKeyframe(-69, duration: 0.3)
                CubicKeyframe(39, duration: 0.2)
                LinearKeyframe(39, duration: 0.3)
                // Jump to J1
                CubicKeyframe(-69, duration: 0.2)
                CubicKeyframe(-250, duration: 0.4) // higher peak for long hop
                CubicKeyframe(-68, duration: 0.4)
                CubicKeyframe(39, duration: 0.2)
                LinearKeyframe(39, duration: 0.3)
            }
            
            KeyframeTrack(\.rotation) {
                // Realistic spin during jumps, static inside
                LinearKeyframe(0, duration: 0.1)
                // Jump 1
                CubicKeyframe(0, duration: 0.1)
                CubicKeyframe(360, duration: 0.6)
                CubicKeyframe(360, duration: 0.2)
                LinearKeyframe(360, duration: 0.3)
                // Jump 2
                CubicKeyframe(360, duration: 0.2)
                CubicKeyframe(720, duration: 0.6)
                CubicKeyframe(720, duration: 0.2)
                LinearKeyframe(720, duration: 0.3)
                // Jump 3
                CubicKeyframe(720, duration: 0.2)
                CubicKeyframe(1260, duration: 0.8) // more spin for long hop
                CubicKeyframe(1260, duration: 0.2)
                LinearKeyframe(1260, duration: 0.3)
            }
        }
    }
    
    private func coin3D() -> some View {
        let coinSize: CGFloat = 28 // Constant size, no zoom
        return ZStack {
            // "Thickness" of the coin (a few layers behind the front face)
            ForEach(1...4, id: \.self) { i in
                Circle()
                    .fill(Color(red: 0.75, green: 0.65, blue: 0.25))
                    .frame(width: coinSize, height: coinSize)
                    .offset(y: CGFloat(i) * 1.5) // Offset Y for a cheap 3D edge when flipping
            }

            // Coin face
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.95, green: 0.85, blue: 0.5), Color(red: 0.8, green: 0.7, blue: 0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: coinSize, height: coinSize)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                }
        }
    }



    private func glassBack(theme: GlassTheme) -> some View {
        ZStack {
            // Dark interior liquid/texture
            GlassShape()
                .fill(Color.black.opacity(0.6))
                
            // Top opening interior hole (The deep bottom of the glass)
            Ellipse()
                .fill(Color.black.opacity(0.75))
                .frame(width: rimW, height: rimH)
                .offset(y: rimY)
                
            // Inner layer of thick glass rim (back glossy edge)
            Ellipse()
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.8), .white.opacity(0.2), .white.opacity(0.6)].reversed(),
                        startPoint: .leading, endPoint: .trailing
                    ),
                    lineWidth: 4
                )
                .frame(width: rimW, height: rimH)
                .offset(y: rimY)
        }
    }

    private func glassFront(theme: GlassTheme) -> some View {
        ZStack {
            // Solid Glass Base (Thick bottom)
            ZStack {
                // Bottom curve
                Ellipse()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: glassW * 0.82, height: 20)
                    .offset(y: glassH / 2)
                    .shadow(color: theme.colorB.opacity(0.5), radius: 10, y: 15)
                
                // Floor of the glass inside
                Ellipse()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: glassW * 0.82, height: 18)
                    .offset(y: glassH / 2 - 12)
                
                // Base thickness walls
                GlassShape()
                    // mask it to only show the bottom 12pts
                    .fill(Color.white.opacity(0.2))
                    .mask(
                        Rectangle()
                            .frame(height: 24)
                            .offset(y: glassH / 2 - 12)
                    )
            }
            
            // The colorful texture (representing liquid/smoke inside the glass)
            GlassFrontShape(rimH: rimH)
                .fill(
                    LinearGradient(
                        colors: [theme.colorA.opacity(0.9), theme.colorC.opacity(0.7), theme.colorA.opacity(0.8), theme.colorB.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                // Leave room for the solid glass base at the bottom
                .padding(.bottom, 12)
            
            // Glass Reflection Overlay
            GlassFrontShape(rimH: rimH)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .clear, .clear, .white.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.horizontal, 2)
                
            // Glossy highlight lines
            GlassFrontShape(rimH: rimH)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.9), .clear, .white.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
            
            // Front half of the glass top rim
            ZStack {
                Ellipse()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.9), .white.opacity(0.3), .white.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 6
                    )
                    .frame(width: rimW, height: rimH)
                
                Ellipse()
                    .stroke(Color.white, lineWidth: 1.5)
                    .frame(width: rimW - 2, height: rimH - 2)
            }
            .offset(y: rimY)
            // Clip perfectly along the equator of the rim mask
            .mask(
                Rectangle()
                    .frame(height: glassH * 2) // Large enough to not cut off anything else
                    .offset(y: glassH + rimY)
            )
        }
    }

}

#Preview {
    OnboardingView()
}
