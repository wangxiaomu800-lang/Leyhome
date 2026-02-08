//
//  MountainSilhouetteView.swift
//  Leyhome - 地脉归途
//
//  山脉剪影组件 - 两层山脉，用于登录页底部装饰
//
//  Created on 2026/02/06.
//

import SwiftUI

/// 两层山脉剪影视图
/// 远山：较高，浅色，40% 不透明度
/// 近山：较矮，深色，60% 不透明度
struct MountainSilhouetteView: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack(alignment: .bottom) {
                // 远山（较高，浅色）
                FarMountainShape()
                    .fill(Color(hex: "1A2340").opacity(0.4))
                    .frame(width: width, height: 200)

                // 近山（较矮，深色）
                NearMountainShape()
                    .fill(Color(hex: "0D1520").opacity(0.6))
                    .frame(width: width, height: 150)
            }
            .frame(width: width, height: height, alignment: .bottom)
        }
    }
}

// MARK: - 远山形状

private struct FarMountainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: 0, y: h))

        // 从左到右绘制山脉轮廓
        path.addLine(to: CGPoint(x: 0, y: h * 0.65))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.15, y: h * 0.35),
            control: CGPoint(x: w * 0.08, y: h * 0.45)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.28, y: h * 0.55),
            control: CGPoint(x: w * 0.22, y: h * 0.30)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.45, y: h * 0.20),
            control: CGPoint(x: w * 0.35, y: h * 0.50)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.60, y: h * 0.45),
            control: CGPoint(x: w * 0.52, y: h * 0.15)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.78, y: h * 0.25),
            control: CGPoint(x: w * 0.68, y: h * 0.50)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.92, y: h * 0.50),
            control: CGPoint(x: w * 0.85, y: h * 0.20)
        )
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.40),
            control: CGPoint(x: w * 0.96, y: h * 0.48)
        )

        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()

        return path
    }
}

// MARK: - 近山形状

private struct NearMountainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: 0, y: h))

        // 从左到右绘制较矮的前景山脉
        path.addLine(to: CGPoint(x: 0, y: h * 0.55))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.20, y: h * 0.40),
            control: CGPoint(x: w * 0.10, y: h * 0.60)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.38, y: h * 0.60),
            control: CGPoint(x: w * 0.30, y: h * 0.32)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.55, y: h * 0.35),
            control: CGPoint(x: w * 0.45, y: h * 0.65)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.72, y: h * 0.55),
            control: CGPoint(x: w * 0.62, y: h * 0.30)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.38),
            control: CGPoint(x: w * 0.80, y: h * 0.60)
        )
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.50),
            control: CGPoint(x: w * 0.95, y: h * 0.30)
        )

        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()

        return path
    }
}
