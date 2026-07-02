import SwiftUI

struct BreakOverlayView: View {
    @ObservedObject var timerManager: TimerManager

    @State private var carOffset: CGFloat = -9999   // off-screen until onAppear
    @State private var carBounce: CGFloat = 0
    @State private var appear = false

    private let stars: [(x: CGFloat, y: CGFloat, r: CGFloat, a: Double)] = [
        (0.05,0.04,1.2,0.9),(0.12,0.09,0.8,0.7),(0.20,0.03,1.1,0.8),(0.28,0.07,0.5,0.6),
        (0.37,0.05,1.3,0.9),(0.45,0.10,0.8,0.7),(0.53,0.04,1.1,0.8),(0.62,0.08,0.5,0.6),
        (0.70,0.03,1.3,0.9),(0.79,0.07,0.8,0.7),(0.87,0.05,1.1,0.8),(0.94,0.09,0.5,0.6),
        (0.08,0.16,0.8,0.6),(0.17,0.21,1.1,0.8),(0.26,0.14,0.5,0.5),(0.34,0.19,1.3,0.9),
        (0.43,0.13,0.8,0.7),(0.51,0.20,1.1,0.8),(0.60,0.15,0.5,0.5),(0.68,0.22,1.3,0.9),
        (0.76,0.17,0.8,0.7),(0.84,0.12,1.1,0.8),(0.92,0.18,0.5,0.6),(0.04,0.28,1.1,0.7),
        (0.15,0.32,0.8,0.6),(0.25,0.27,1.3,0.9),(0.38,0.30,0.5,0.5),(0.50,0.26,1.1,0.8),
        (0.63,0.31,0.8,0.7),(0.75,0.28,1.3,0.9),(0.88,0.33,0.5,0.5),(0.02,0.40,0.8,0.6),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                nightSky
                starsView(geo: geo)
                messageView(geo: geo)
                roadView(geo: geo)
                carView(geo: geo)
                buttonsView
            }
            .onAppear {
                // Snap car to start position (no animation — outside withAnimation block)
                carOffset = startX(geo)
                withAnimation(.easeIn(duration: 0.4)) { appear = true }
                withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                    carBounce = -6
                }
            }
            // .task is auto-cancelled when the view disappears — safe from use-after-free
            .task {
                try? await Task.sleep(nanoseconds: 60_000_000)  // one frame after onAppear
                guard !Task.isCancelled else { return }
                withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) {
                    carOffset = endX(geo)
                }
            }
        }
        .opacity(appear ? 1 : 0)
    }

    // MARK: - Helpers

    private func startX(_ geo: GeometryProxy) -> CGFloat { -(geo.size.width * 0.5 + geo.size.width * 0.18) }
    private func endX(_ geo: GeometryProxy)   -> CGFloat {   geo.size.width * 0.5 + geo.size.width * 0.18  }

    // MARK: - Layers

    private var nightSky: some View {
        LinearGradient(
            colors: [
                Color(red:0.03,green:0.02,blue:0.12),
                Color(red:0.06,green:0.04,blue:0.20),
                Color(red:0.10,green:0.07,blue:0.28),
                Color(red:0.14,green:0.10,blue:0.22),
            ],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private func starsView(geo: GeometryProxy) -> some View {
        ForEach(0..<stars.count, id: \.self) { i in
            Circle()
                .fill(Color.white.opacity(stars[i].a))
                .frame(width: stars[i].r * 2, height: stars[i].r * 2)
                .position(x: geo.size.width  * stars[i].x,
                          y: geo.size.height * stars[i].y * 0.65)
        }
    }

    private func messageView(geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: geo.size.height * 0.07)

            Text("Time to Look Away!")
                .font(.system(size: min(geo.size.width * 0.042, 58), weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Focus on something 20 feet away")
                .font(.system(size: min(geo.size.width * 0.017, 22), weight: .light))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 10)

            Spacer(minLength: 24)
            countdownRing
            Spacer()
        }
        .padding(.horizontal, 40)
    }

    private var countdownRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 5)
                .frame(width: 120, height: 120)
            Circle()
                .trim(from: 0, to: timerManager.breakDuration > 0
                      ? CGFloat(timerManager.breakProgress) : 0)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timerManager.breakTimeRemaining)
            Text("\(Int(timerManager.breakTimeRemaining))")
                .font(.system(size: 44, weight: .thin, design: .monospaced))
                .foregroundColor(.white)
        }
    }

    private func roadView(geo: GeometryProxy) -> some View {
        let rh = geo.size.height * 0.28
        return VStack(spacing: 0) {
            Spacer()
            ZStack {
                Rectangle().fill(Color(white: 0.10)).frame(height: rh)
                VStack {
                    Rectangle().fill(Color.yellow.opacity(0.55)).frame(height: 3)
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.35)).frame(height: 2)
                }
                .frame(height: rh)
                // Center dashes
                VStack {
                    Spacer()
                    HStack(spacing: 32) {
                        ForEach(0..<Int(geo.size.width / 80) + 2, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.white.opacity(0.45))
                                .frame(width: 48, height: 4)
                        }
                    }
                    .padding(.bottom, rh * 0.47)
                }
                .frame(height: rh)
            }
            .frame(height: rh)
        }
    }

    private func carView(geo: GeometryProxy) -> some View {
        let rh  = geo.size.height * 0.28
        let carW = min(geo.size.width * 0.25, 360)
        return VStack(spacing: 0) {
            Spacer()
            Image(systemName: "car.fill")
                .resizable()
                .scaledToFit()
                .frame(width: carW)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red:0.95,green:0.12,blue:0.12),
                                 Color(red:0.70,green:0.05,blue:0.05)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .shadow(color: .red.opacity(0.45),    radius: 24, x: 0, y: 8)
                .shadow(color: .orange.opacity(0.25), radius: 40, x: 0, y: 4)
                .offset(x: carOffset, y: carBounce - rh * 0.42)
        }
        .frame(height: geo.size.height)
    }

    private var buttonsView: some View {
        VStack {
            Spacer()
            HStack(spacing: 16) {
                actionButton("Snooze 5 min", primary: false) { timerManager.snooze(minutes: 5) }
                actionButton("Skip Break",   primary: true)  { timerManager.skip() }
            }
            .padding(.bottom, 28)
        }
    }

    @ViewBuilder
    private func actionButton(_ label: String, primary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(primary ? .black : .white)
                .padding(.horizontal, 26)
                .padding(.vertical, 11)
                .background(Capsule().fill(primary ? Color.white : Color.white.opacity(0.18)))
        }
        .buttonStyle(.plain)
    }
}
