//
//  GuidesView.swift
//  Leyhome - 地脉归途
//
//  引路视图 - 展示先行者和星图合集
//
//  Created on 2026/01/26.
//

import SwiftUI

struct GuidesView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // 深色背景（星空主题）
                LeyhomeTheme.Background.dark
                    .ignoresSafeArea()

                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    Spacer()

                    // 星图占位
                    ZStack {
                        // 星星装饰
                        ForEach(0..<12, id: \.self) { index in
                            Circle()
                                .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                                .frame(width: CGFloat.random(in: 2...6))
                                .offset(
                                    x: CGFloat.random(in: -80...80),
                                    y: CGFloat.random(in: -80...80)
                                )
                        }

                        // 中心图标
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [LeyhomeTheme.starlight, LeyhomeTheme.accent],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .frame(width: 200, height: 200)

                    // 提示文字
                    Text("guides.placeholder".localized)
                        .font(LeyhomeTheme.Fonts.body)
                        .foregroundColor(.white.opacity(0.8))
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
    GuidesView()
}
