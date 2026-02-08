//
//  StarFieldView.swift
//  Leyhome - 地脉归途
//
//  星空粒子背景组件 - 增强版闪烁星光
//
//  Created on 2026/02/06.
//

import SwiftUI

/// 增强版星空背景视图
/// 80颗星，随机位置/大小/亮度，独立闪烁动画，~10%亮星带光晕
struct StarFieldView: View {
    /// 星星数据（仅初始化一次）
    private let stars: [StarParticle] = (0..<80).map { _ in StarParticle() }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(stars) { star in
                    StarParticleView(star: star, containerSize: geometry.size)
                }
            }
        }
    }
}

// MARK: - StarParticle Model

/// 单颗星数据
private struct StarParticle: Identifiable {
    let id = UUID()
    let relativeX: CGFloat = CGFloat.random(in: 0...1)
    let relativeY: CGFloat = CGFloat.random(in: 0...1)
    let size: CGFloat = CGFloat.random(in: 1...3.5)
    let baseOpacity: Double = Double.random(in: 0.2...0.8)
    let animationDuration: Double = Double.random(in: 1.5...4.0)
    let animationDelay: Double = Double.random(in: 0...3.0)
    let isBright: Bool = Double.random(in: 0...1) < 0.1  // ~10% 亮星
}

// MARK: - StarParticleView

/// 单颗星视图（带独立闪烁动画）
private struct StarParticleView: View {
    let star: StarParticle
    let containerSize: CGSize
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: star.isBright ? star.size * 1.5 : star.size,
                   height: star.isBright ? star.size * 1.5 : star.size)
            .opacity(isAnimating ? star.baseOpacity * 0.3 : star.baseOpacity)
            .shadow(
                color: star.isBright ? Color.white.opacity(0.6) : Color.clear,
                radius: star.isBright ? 4 : 0
            )
            .position(
                x: star.relativeX * containerSize.width,
                y: star.relativeY * containerSize.height
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: star.animationDuration)
                    .repeatForever(autoreverses: true)
                    .delay(star.animationDelay)
                ) {
                    isAnimating = true
                }
            }
    }
}
