import SwiftUI

// MARK: - Mugic Logo Shape
struct MugicLogo: View {
    let size: CGFloat
    var color: Color = Color.sonicPrimary

    private var unit: CGFloat { size / 10 }

    var body: some View {
        Canvas { context, canvasSize in
            let u = canvasSize.width / 10

            // Left vertical bar of "M"
            let leftBar = Path { p in
                p.move(to: CGPoint(x: 1.2 * u, y: 8.5 * u))
                p.addLine(to: CGPoint(x: 1.2 * u, y: 3.5 * u))
                p.addLine(to: CGPoint(x: 2.4 * u, y: 2.8 * u))
                p.addLine(to: CGPoint(x: 2.4 * u, y: 7.8 * u))
                p.closeSubpath()
            }

            // Left diagonal of "M"
            let leftDiag = Path { p in
                p.move(to: CGPoint(x: 1.2 * u, y: 3.5 * u))
                p.addLine(to: CGPoint(x: 3.8 * u, y: 5.0 * u))
                p.addLine(to: CGPoint(x: 5.0 * u, y: 4.3 * u))
                p.addLine(to: CGPoint(x: 2.4 * u, y: 2.8 * u))
                p.closeSubpath()
            }

            // Center V of "M"
            let centerV = Path { p in
                p.move(to: CGPoint(x: 3.8 * u, y: 5.0 * u))
                p.addLine(to: CGPoint(x: 5.0 * u, y: 5.7 * u))
                p.addLine(to: CGPoint(x: 6.2 * u, y: 5.0 * u))
                p.addLine(to: CGPoint(x: 5.0 * u, y: 4.3 * u))
                p.closeSubpath()
            }

            // Right diagonal of "M"
            let rightDiag = Path { p in
                p.move(to: CGPoint(x: 5.0 * u, y: 4.3 * u))
                p.addLine(to: CGPoint(x: 7.6 * u, y: 2.8 * u))
                p.addLine(to: CGPoint(x: 8.8 * u, y: 3.5 * u))
                p.addLine(to: CGPoint(x: 6.2 * u, y: 5.0 * u))
                p.closeSubpath()
            }

            // Right vertical bar of "M"
            let rightBar = Path { p in
                p.move(to: CGPoint(x: 7.6 * u, y: 7.8 * u))
                p.addLine(to: CGPoint(x: 7.6 * u, y: 2.8 * u))
                p.addLine(to: CGPoint(x: 8.8 * u, y: 3.5 * u))
                p.addLine(to: CGPoint(x: 8.8 * u, y: 8.5 * u))
                p.closeSubpath()
            }

            // Draw with slight color variations for depth
            let baseColor = color
            let darkShade = color.opacity(0.7)

            context.fill(leftBar, with: .color(darkShade))
            context.fill(leftDiag, with: .color(baseColor))
            context.fill(centerV, with: .color(baseColor.opacity(0.85)))
            context.fill(rightDiag, with: .color(baseColor))
            context.fill(rightBar, with: .color(darkShade))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Splash Screen
struct SplashView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var footerOpacity: Double = 0
    @State private var dotPhase: Int = 0
    @State private var isFinished = false

    var onFinished: () -> Void

    var body: some View {
        ZStack {
            // Background
            Color.sonicBackground
                .ignoresSafeArea()

            // Subtle radial glow
            RadialGradient(
                colors: [
                    Color.sonicPrimary.opacity(0.04),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                // Logo + Name
                VStack(spacing: 24) {
                    // Logo container
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.sonicOnSurface)
                        .frame(width: 130, height: 130)
                        .overlay(
                            MugicLogo(size: 70, color: Color.sonicPrimary)
                        )
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    Text("Mugic")
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .tracking(-1)
                        .foregroundStyle(.sonicOnSurface)
                        .opacity(textOpacity)
                }

                Spacer()

                // Footer
                VStack(spacing: 24) {
                    // Loading dots
                    HStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(Color.sonicOnSurfaceVariant.opacity(dotPhase == i ? 0.6 : 0.2))
                                .frame(width: 6, height: 6)
                                .animation(.easeInOut(duration: 0.4), value: dotPhase)
                        }
                    }
                    .opacity(footerOpacity)

                    // Attribution
                    VStack(spacing: 4) {
                        Text("FROM")
                            .font(.system(size: 10, weight: .medium))
                            .tracking(3)
                            .foregroundStyle(Color.sonicOnSurfaceVariant.opacity(0.6))

                        Text("Utsab")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.sonicPrimary)
                    }
                    .opacity(footerOpacity)
                }
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                textOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                footerOpacity = 1.0
            }
            // Animate dots
            Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { timer in
                if isFinished { timer.invalidate(); return }
                dotPhase = (dotPhase + 1) % 3
            }
            // Dismiss after 2.2s
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                isFinished = true
                withAnimation(.easeIn(duration: 0.3)) {
                    logoOpacity = 0
                    textOpacity = 0
                    footerOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onFinished()
                }
            }
        }
    }
}
