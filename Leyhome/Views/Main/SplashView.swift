//
//  SplashView.swift
//  Leyhome
//
//  Created by Claude on 2026/1/26.
//

import SwiftUI

struct SplashView: View {
    @State private var hasStartedAnimation = false
    @State private var hasFinishedLoading = false
    @State private var breathingScale: CGFloat = 1.0

    var onFinished: () -> Void

    var body: some View {
        ZStack {
            // Background
            LeyhomeTheme.background
                .ignoresSafeArea()

            VStack {
                Spacer()

                // Core Energy Point
                ZStack {
                    // Breathing Glow
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    LeyhomeTheme.accent.opacity(0.3),
                                    LeyhomeTheme.accent.opacity(0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 64
                            )
                        )
                        .frame(width: 128, height: 128)
                        .scaleEffect(breathingScale)
                        .opacity(hasStartedAnimation ? 1 : 0)

                    // Central Point
                    Circle()
                        .fill(LeyhomeTheme.accent)
                        .frame(width: 8, height: 8)
                        .shadow(color: LeyhomeTheme.accent, radius: 15)
                        .scaleEffect(hasStartedAnimation ? 1 : 0)
                        .opacity(hasStartedAnimation ? 1 : 0)
                }
                .frame(width: 160, height: 160)
                .padding(.bottom, 48)

                // Titles
                VStack(spacing: 16) {
                    Text("app.name".localized)
                        .font(LeyhomeTheme.Fonts.largeTitle)
                        .tracking(8)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    Text("Leyhome")
                        .font(.system(size: 12, weight: .light))
                        .tracking(12)
                        .textCase(.uppercase)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                }
                .offset(y: hasStartedAnimation ? 0 : 20)
                .opacity(hasStartedAnimation ? 1 : 0)

                Spacer()

                // Loading Hint
                Text(hasFinishedLoading ? "splash.entering".localized : "splash.loading".localized)
                    .font(.system(size: 12, weight: .light))
                    .tracking(4)
                    .italic()
                    .foregroundColor(LeyhomeTheme.textMuted)
                    .opacity(hasStartedAnimation ? 1 : 0)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Start entry animations
        withAnimation(.easeOut(duration: 1.0).delay(0.1)) {
            hasStartedAnimation = true
        }

        // Start breathing animation
        withAnimation(LeyhomeTheme.Animation.breathing.delay(0.5)) {
            breathingScale = 1.2
        }

        // Simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                hasFinishedLoading = true
            }
        }

        // Transition to main screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            onFinished()
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
