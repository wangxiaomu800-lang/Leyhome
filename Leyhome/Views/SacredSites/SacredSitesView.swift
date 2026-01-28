//
//  SacredSitesView.swift
//  Leyhome - 地脉归途
//
//  圣迹视图 - 展示三层地脉节点体系（源点圣迹、地脉节点、心绪锚点）
//
//  Created on 2026/01/26.
//

import SwiftUI

struct SacredSitesView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景色
                LeyhomeTheme.Background.primary
                    .ignoresSafeArea()

                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    Spacer()

                    // 星脉图占位图标
                    ZStack {
                        // 外圈光晕
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        LeyhomeTheme.starlight.opacity(0.3),
                                        LeyhomeTheme.starlight.opacity(0)
                                    ],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)

                        // 中心星辰
                        Image(systemName: "star.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [LeyhomeTheme.accent, LeyhomeTheme.SacredSite.tier1],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    // 提示文字
                    Text("sacred_sites.placeholder".localized)
                        .font(LeyhomeTheme.Fonts.body)
                        .foregroundColor(LeyhomeTheme.primary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, LeyhomeTheme.Spacing.xl)

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    SacredSitesView()
}
