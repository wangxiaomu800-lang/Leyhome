//
//  EnergyLineAnimator.swift
//  Leyhome - 地脉归途
//
//  能量线动画控制器 - 使用 CADisplayLink 驱动能量线动画
//
//  Created on 2026/01/29.
//

import Foundation
import QuartzCore
import Combine

/// 能量线动画控制器
/// 使用 CADisplayLink 驱动 0.0~1.0 的动画相位循环
class EnergyLineAnimator: ObservableObject {

    // MARK: - Published Properties

    /// 动画相位（0.0 ~ 1.0 循环）
    @Published var phase: CGFloat = 0.0

    // MARK: - Private Properties

    /// CADisplayLink 实例
    private var displayLink: CADisplayLink?

    /// 动画周期（秒）
    private let cycleDuration: TimeInterval = 3.0

    /// 上一帧时间戳
    private var lastTimestamp: CFTimeInterval = 0

    /// 渲染器更新回调
    var onPhaseUpdate: ((CGFloat) -> Void)?

    // MARK: - Lifecycle

    deinit {
        stopAnimation()
    }

    // MARK: - Public Methods

    /// 开始动画
    func startAnimation() {
        guard displayLink == nil else { return }

        lastTimestamp = 0
        let link = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 60)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /// 停止动画
    func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = 0
    }

    /// 动画是否正在运行
    var isAnimating: Bool {
        displayLink != nil
    }

    // MARK: - Private Methods

    @objc private func handleDisplayLink(_ link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        let elapsed = link.timestamp - lastTimestamp
        lastTimestamp = link.timestamp

        // 更新相位
        let delta = CGFloat(elapsed / cycleDuration)
        phase += delta
        if phase >= 1.0 {
            phase -= 1.0
        }

        // 通知回调
        onPhaseUpdate?(phase)
    }
}
