//
//  PlaceholderView.swift
//  Leyhome
//
//  Created by Claude on 2026/1/26.
//

import SwiftUI

struct PlaceholderView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            LeyhomeTheme.background
                .ignoresSafeArea()

            VStack(spacing: LeyhomeTheme.Spacing.lg) {
                // Icon with subtle glow
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    LeyhomeTheme.accent.opacity(0.2),
                                    LeyhomeTheme.accent.opacity(0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: icon)
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(LeyhomeTheme.accent)
                }

                VStack(spacing: LeyhomeTheme.Spacing.sm) {
                    Text(title)
                        .font(LeyhomeTheme.Fonts.title)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    Text(subtitle)
                        .font(LeyhomeTheme.Fonts.callout)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, LeyhomeTheme.Spacing.xl)
                }
            }
        }
    }
}

#Preview {
    PlaceholderView(
        icon: "map.fill",
        title: "Soul Map",
        subtitle: "Every step you take paints a unique map of your heart"
    )
}
