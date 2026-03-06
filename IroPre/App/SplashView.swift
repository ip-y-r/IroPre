// MARK: - スプラッシュ画面
import SwiftUI

struct SplashView: View {
    private let colors: [Color] = [
        Color(hex: "#FF6B6B"), Color(hex: "#4A90D9"), Color(hex: "#27AE60"),
        Color(hex: "#F1C40F"), Color(hex: "#9B59B6"), Color(hex: "#E67E22"),
        Color(hex: "#FF9FF3"), Color(hex: "#00CEC9"), Color(hex: "#BADC58")
    ]

    @State private var cellScales: [CGFloat] = Array(repeating: 0, count: 9)
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // 3×3 カラーグリッド
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(72), spacing: 8), count: 3),
                spacing: 8
            ) {
                ForEach(0..<9, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colors[index])
                        .frame(width: 72, height: 72)
                        .shadow(color: colors[index].opacity(0.5), radius: 8, x: 0, y: 4)
                        .scaleEffect(cellScales[index])
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))

            // アプリ名
            VStack(spacing: 6) {
                Text("IroPre")
                    .font(FontManager.title())
                    .opacity(titleOpacity)

                Text("色で解くパズル")
                    .font(FontManager.body())
                    .foregroundStyle(.secondary)
                    .opacity(subtitleOpacity)
            }

            Spacer()
        }
        .padding(.horizontal, 48)
        .onAppear { startAnimation() }
    }

    private func startAnimation() {
        // セルをスタッガードで出現
        for index in 0..<9 {
            let delay = Double(index) * 0.07
            withAnimation(.spring(response: 0.45, dampingFraction: 0.65).delay(delay)) {
                cellScales[index] = 1.0
            }
        }
        // タイトルはグリッド出現後にフェードイン
        withAnimation(.easeOut(duration: 0.4).delay(0.7)) {
            titleOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.9)) {
            subtitleOpacity = 1.0
        }
    }
}

#Preview {
    SplashView()
}
