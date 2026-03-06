// MARK: - スプラッシュ画面
import SwiftUI

struct SplashView: View {
    @State private var pulse = false
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0

    private let orbs: [(color: Color, size: CGFloat, relX: CGFloat, relY: CGFloat)] = [
        (Color(hex: "#FF6B6B"), 80, 0.12, 0.08),
        (Color(hex: "#4A90D9"), 60, 0.82, 0.16),
        (Color(hex: "#27AE60"), 50, 0.18, 0.72),
        (Color(hex: "#F1C40F"), 70, 0.80, 0.68),
        (Color(hex: "#9B59B6"), 40, 0.05, 0.40),
        (Color(hex: "#E67E22"), 45, 0.90, 0.45),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 背景オーブ
                ForEach(orbs.indices, id: \.self) { i in
                    let orb = orbs[i]
                    Circle()
                        .fill(RadialGradient(
                            colors: [orb.color.opacity(0.4), orb.color.opacity(0.0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: orb.size / 2
                        ))
                        .frame(width: orb.size, height: orb.size)
                        .blur(radius: 10)
                        .position(x: geo.size.width * orb.relX, y: geo.size.height * orb.relY)
                        .opacity(pulse ? 0.8 : 0.35)
                        .animation(
                            .easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.2),
                            value: pulse
                        )
                }

                // メインコンテンツ
                VStack(spacing: 20) {
                    Spacer()

                    AppLogoView(size: 120)
                        .shadow(
                            color: Color(hex: "#4A90D9").opacity(pulse ? 0.5 : 0.2),
                            radius: pulse ? 32 : 16,
                            x: 0, y: 12
                        )
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .animation(
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                            value: pulse
                        )

                    // タイトル
                    HStack(spacing: 0) {
                        Text("Iro")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "#FF6B6B"), Color(hex: "#4A90D9"), Color(hex: "#27AE60")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                        Text("Pre")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    .opacity(titleOpacity)

                    Text("色で解く、新しい数独体験")
                        .font(FontManager.body())
                        .foregroundStyle(.secondary)
                        .opacity(subtitleOpacity)

                    Spacer()

                    // インジケータードット
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(
                                    i == (pulse ? 1 : 0)
                                        ? ColorPalette.puzzleColors[i].light
                                        : ColorPalette.puzzleColors[i].light.opacity(0.25)
                                )
                                .frame(width: 8, height: 8)
                                .animation(
                                    .easeInOut(duration: 0.6).delay(Double(i) * 0.15),
                                    value: pulse
                                )
                        }
                    }
                    .padding(.bottom, 48)
                    .opacity(subtitleOpacity)
                }
                .frame(width: geo.size.width)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.4)) { titleOpacity = 1 }
            withAnimation(.easeOut(duration: 0.4).delay(0.6)) { subtitleOpacity = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { pulse = true }
        }
    }
}

#Preview {
    SplashView()
}
