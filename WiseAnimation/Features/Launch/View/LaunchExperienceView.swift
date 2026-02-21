import SwiftUI

struct LaunchExperienceView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: LaunchViewModel
    var debug: Bool = false

    init(onComplete: @escaping () -> Void, debug: Bool = false) {
        _viewModel = StateObject(wrappedValue: LaunchViewModel(onComplete: onComplete))
        self.debug = debug
    }

    // MARK: - Animation State
    
    @State private var hasStarted = false
    @State private var backgroundProgress: CGFloat = 0
    @State private var textureVerticalProgress: CGFloat = 0
    @State private var textureWidthProgress: CGFloat = 0
    @State private var textureFullScreenProgress: CGFloat = 0

    // MARK: - Constants
    
    private let pillWidth: CGFloat = 120
    private let pillCornerRadius: CGFloat = 60
    private let backgroundPillHeightRatio: CGFloat = 0.35
    private let textureOvershootRatio: CGFloat = 0.5
    private let arrowOverlaySize: CGFloat = 104 // pillWidth - 16

    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            let animationValues = computeAnimationValues(screenSize: geometry.size)
            
            ZStack(alignment: .bottom) {
                // Base Background
                Color("GreenLight")
                    .ignoresSafeArea()

                // Center Logo
                Image("WiseLogo")
                    .scaledToFit()
                    .frame(maxHeight: .infinity, alignment: .center)

                // Layer 1: Background Pill
                backgroundPill(screenHeight: screenHeight)
                
                // Layer 2: Texture (Static, Masked)
                // The image stays static fullscreen, but handled by the mask which moves.
                // We only show it after start/calculations roughly to avoid glitches if necessary,
                // but checking hasStarted might just be an optimization.
                Image("SwipeTexture")
                    .resizable()
                    .ignoresSafeArea()
                    .mask(alignment: .bottom) {
                        textureMask(values: animationValues)
                    }
                
                // Layer 3: Arrow Overlay
                arrowOverlay(values: animationValues)
            }
            .frame(width: screenWidth, height: screenHeight)
        }
        .ignoresSafeArea()
        .task {
            await runAnimationSequence()
        }
    }
    
    // MARK: - Component Views
    
    @ViewBuilder
    private func backgroundPill(screenHeight: CGFloat) -> some View {
        let height = screenHeight * backgroundPillHeightRatio
        let offset = height * (1 - backgroundProgress)
        
        UnevenRoundedRectangle(
            topLeadingRadius: pillCornerRadius,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: pillCornerRadius
        )
        .fill(Color("GreenDark"))
        .frame(width: pillWidth, height: height)
        .offset(y: offset)
    }
    
    private struct AnimationValues {
        let verticalOffset: CGFloat
        let currentWidth: CGFloat
        let currentCornerRadius: CGFloat
        let height: CGFloat
        let currentArrowScale: CGFloat
    }
    
    private func computeAnimationValues(screenSize: CGSize) -> AnimationValues {
        let screenHeight = screenSize.height
        let screenWidth = screenSize.width
        let overshoot = screenHeight * textureOvershootRatio
        
        // 1. Vertical Offset
        let verticalOffset = (screenHeight + overshoot) * (1 - textureVerticalProgress)
        
        // 2. Width Expansion
        let stage1TargetWidth = pillWidth * 2
        let currentWidth = pillWidth 
            + (stage1TargetWidth - pillWidth) * textureWidthProgress 
            + (screenWidth - stage1TargetWidth) * textureFullScreenProgress
            
        // 3. Corner Radius
        // Stage 3: Radius grows with width (maintaining pill shape: radius = width / 2)
        // Stage 4: Radius decays to 0 as it fills the screen (controlled by textureFullScreenProgress)
        let currentCornerRadius = (currentWidth / 2) * (1 - textureFullScreenProgress)
        
        // 4. Arrow Scale
        // Increases to 2x during Stage 3 (Width Expansion)
        let currentArrowScale = 1 + textureWidthProgress / 2.0
        
        return AnimationValues(
            verticalOffset: verticalOffset,
            currentWidth: currentWidth,
            currentCornerRadius: currentCornerRadius,
            height: screenHeight + overshoot,
            currentArrowScale: currentArrowScale
        )
    }
    
    @ViewBuilder
    private func textureMask(values: AnimationValues) -> some View {
        UnevenRoundedRectangle(
            topLeadingRadius: values.currentCornerRadius,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: values.currentCornerRadius
        )
        .frame(width: values.currentWidth, height: values.height)
        .offset(y: values.verticalOffset)
    }
    
    @ViewBuilder
    private func arrowOverlay(values: AnimationValues) -> some View {
        VStack {
            Spacer().frame(height: 16)
            
            ZStack {
                Color("GreenLight")
                Image(systemName: "arrow.up")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(Color("GreenDark"))
            }
            .frame(width: arrowOverlaySize, height: arrowOverlaySize)
            .clipShape(Circle())
            .scaleEffect(values.currentArrowScale) // Scale 1x -> 2x
            
            Spacer()
        }
        .frame(width: values.currentWidth, height: values.height)
        .offset(y: values.verticalOffset)
    }

    // MARK: - Animation Sequence
    
    @MainActor
    private func runAnimationSequence() async {
        guard !hasStarted else { return }
        hasStarted = true

        repeat {
            // Reset State (for loop or first run)
            if debug {
                backgroundProgress = 0
                textureVerticalProgress = 0
                textureWidthProgress = 0
                textureFullScreenProgress = 0
            }

        // Initial Delay before start
        try? await Task.sleep(for: .seconds(0.5))

        // 1. Background Pill Up
        withAnimation(.spring(response: 0.8, dampingFraction: 1.0)) {
            backgroundProgress = 1.9 // Overshoot slighty as per user tweak
        }
        
        // Wait for impact
        try? await Task.sleep(for: .seconds(0.2))
        
        // 2. Texture Up (Vertical - Intermediate Step)
        withAnimation(.spring(response: 0.45, dampingFraction: 1.0)) {
            textureVerticalProgress = 0.45
        }
        
        // 3. Texture Up (Full) + Width Expansion (Stage 1)
        try? await Task.sleep(for: .seconds(0.35))
        
        withAnimation(.spring(response: 1.0, dampingFraction: 1.0)) {
            textureVerticalProgress = 1.0
            textureWidthProgress = 1.0
        }
        
        // 4. Width Expansion (Stage 2 - Full Screen)
        try? await Task.sleep(for: .seconds(0.4))
        
        withAnimation(.spring(response: 0.4, dampingFraction: 1.0)) {
            textureFullScreenProgress = 1.0
        }

            // Completion / Loop Wait
            if debug {
                try? await Task.sleep(for: .seconds(2.0))
            } else {
                try? await Task.sleep(for: .seconds(0.5))
            }
            
        } while debug
        
        viewModel.animationDidComplete()
    }
}

#Preview {
    LaunchExperienceView(onComplete: {}, debug: true)
}
