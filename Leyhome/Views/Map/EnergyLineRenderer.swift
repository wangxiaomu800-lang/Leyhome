//
//  EnergyLineRenderer.swift
//  Leyhome - 地脉归途
//
//  能量线渲染器 - 发光效果、脉动光点、流光效果
//
//  Created on 2026/01/29.
//

import MapKit
import UIKit
import SwiftUI

/// 能量线渲染器
/// 继承 MKPolylineRenderer，添加发光、脉动、流光等视觉效果
class EnergyLineRenderer: MKPolylineRenderer {

    // MARK: - Properties

    /// 出行方式
    var transportMode: TransportMode = .walking

    /// 是否为历史轨迹
    var isHistorical: Bool = false

    /// 动画相位（0.0 ~ 1.0），由 EnergyLineAnimator 驱动
    var animationPhase: CGFloat = 0.0

    /// 主题颜色覆盖（来自 ThemeManager）
    var colorOverride: UIColor?

    // MARK: - Computed Properties

    /// 当前使用的线条颜色
    private var lineColor: UIColor {
        if let override = colorOverride {
            return override
        }
        return UIColor(transportMode.lineColor)
    }

    /// 当前使用的线条宽度
    private var lineBaseWidth: CGFloat {
        transportMode.lineWidth
    }

    /// 发光半径
    private var glowRadius: CGFloat {
        lineBaseWidth * 2.5
    }

    // MARK: - Drawing

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        // 计算实际渲染宽度（考虑缩放）
        let baseWidth = self.lineBaseWidth / zoomScale

        // 获取路径
        guard let path = self.path else { return }

        // 不透明度：历史轨迹降低
        let alpha: CGFloat = isHistorical ? 0.35 : 1.0

        // 1. 绘制外发光
        drawGlow(path: path, baseWidth: baseWidth, alpha: alpha, in: context, zoomScale: zoomScale)

        // 2. 绘制主线条
        drawMainLine(path: path, baseWidth: baseWidth, alpha: alpha, in: context)

        // 3. 绘制动画效果（仅非历史轨迹）
        if !isHistorical {
            switch transportMode {
            case .walking:
                drawPulsingDot(path: path, baseWidth: baseWidth, in: context, zoomScale: zoomScale)
            case .cycling:
                drawFlowEffect(path: path, baseWidth: baseWidth, in: context, zoomScale: zoomScale)
            case .driving, .flying:
                drawBreathingGlow(path: path, baseWidth: baseWidth, alpha: alpha, in: context, zoomScale: zoomScale)
            }
        }
    }

    // MARK: - Glow Effect

    /// 绘制外发光效果
    private func drawGlow(path: CGPath, baseWidth: CGFloat, alpha: CGFloat, in context: CGContext, zoomScale: MKZoomScale) {
        context.saveGState()

        let glowRadius = self.glowRadius / zoomScale

        // 柔和外光晕
        context.setLineWidth(baseWidth + glowRadius)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setStrokeColor(lineColor.withAlphaComponent(0.2 * alpha).cgColor)
        context.setShadow(offset: .zero, blur: glowRadius, color: lineColor.withAlphaComponent(0.4 * alpha).cgColor)

        context.addPath(path)
        context.strokePath()

        context.restoreGState()
    }

    // MARK: - Main Line

    /// 绘制主线条
    private func drawMainLine(path: CGPath, baseWidth: CGFloat, alpha: CGFloat, in context: CGContext) {
        context.saveGState()

        context.setLineWidth(baseWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setStrokeColor(lineColor.withAlphaComponent(alpha).cgColor)

        context.addPath(path)
        context.strokePath()

        context.restoreGState()
    }

    // MARK: - Pulsing Dot (Walking)

    /// 步行模式：沿轨迹移动的白色脉动光点
    private func drawPulsingDot(path: CGPath, baseWidth: CGFloat, in context: CGContext, zoomScale: MKZoomScale) {
        // 获取轨迹上的点
        let polyline = self.polyline
        let pointCount = polyline.pointCount
        guard pointCount >= 2 else { return }

        // 根据动画相位计算光点位置
        let targetIndex = Int(animationPhase * CGFloat(pointCount - 1))
        let clampedIndex = min(max(targetIndex, 0), pointCount - 1)

        let mapPoint = polyline.points()[clampedIndex]
        let point = self.point(for: mapPoint)

        // 光点大小随呼吸脉动
        let breathScale = 1.0 + 0.3 * sin(animationPhase * .pi * 6)
        let dotRadius = (baseWidth * 1.5 * breathScale)

        context.saveGState()

        // 外发光
        context.setShadow(offset: .zero, blur: dotRadius * 2, color: UIColor.white.withAlphaComponent(0.6).cgColor)

        // 白色光点
        context.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
        context.fillEllipse(in: CGRect(
            x: point.x - dotRadius,
            y: point.y - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2
        ))

        context.restoreGState()
    }

    // MARK: - Flow Effect (Cycling)

    /// 骑行模式：流光效果
    private func drawFlowEffect(path: CGPath, baseWidth: CGFloat, in context: CGContext, zoomScale: MKZoomScale) {
        let polyline = self.polyline
        let pointCount = polyline.pointCount
        guard pointCount >= 2 else { return }

        // 流光段长度（占总路径的 20%）
        let segmentLength = 0.2
        let flowStart = animationPhase
        let flowEnd = flowStart + segmentLength

        // 绘制高亮流光段
        let startIdx = Int(flowStart * CGFloat(pointCount - 1)) % pointCount
        let endIdx = Int(flowEnd * CGFloat(pointCount - 1)) % pointCount

        guard startIdx != endIdx else { return }

        let actualStart = min(startIdx, pointCount - 1)
        let actualEnd = min(max(endIdx, actualStart + 1), pointCount - 1)

        guard actualEnd > actualStart else { return }

        context.saveGState()

        // 创建流光段路径
        let flowPath = CGMutablePath()
        let firstPoint = self.point(for: polyline.points()[actualStart])
        flowPath.move(to: firstPoint)

        for i in (actualStart + 1)...actualEnd {
            let pt = self.point(for: polyline.points()[i])
            flowPath.addLine(to: pt)
        }

        // 绘制高亮线段
        context.setLineWidth(baseWidth * 1.5)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
        context.setShadow(offset: .zero, blur: baseWidth * 3 / zoomScale, color: lineColor.withAlphaComponent(0.8).cgColor)

        context.addPath(flowPath)
        context.strokePath()

        context.restoreGState()
    }

    // MARK: - Breathing Glow (Driving/Flying)

    /// 驾车/飞行模式：呼吸感发光
    private func drawBreathingGlow(path: CGPath, baseWidth: CGFloat, alpha: CGFloat, in context: CGContext, zoomScale: MKZoomScale) {
        let breathAlpha = 0.15 + 0.15 * sin(animationPhase * .pi * 2)
        let breathWidth = baseWidth * (1.0 + 0.3 * sin(animationPhase * .pi * 2))

        context.saveGState()

        let glowRadius = self.glowRadius / zoomScale
        context.setLineWidth(breathWidth + glowRadius * 0.5)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setStrokeColor(lineColor.withAlphaComponent(breathAlpha * alpha).cgColor)
        context.setShadow(offset: .zero, blur: glowRadius * 0.8, color: lineColor.withAlphaComponent(breathAlpha * alpha).cgColor)

        context.addPath(path)
        context.strokePath()

        context.restoreGState()
    }
}
