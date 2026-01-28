//
//  TransportMode.swift
//  Leyhome - 地脉归途
//
//  统一的出行方式枚举
//
//  Created on 2026/01/28.
//

import Foundation
import SwiftUI

/// 出行方式枚举
enum TransportMode: String, Codable, CaseIterable, Identifiable {
    case walking = "walking"   // 步行
    case cycling = "cycling"   // 骑行
    case driving = "driving"   // 驾车
    case flying = "flying"     // 飞行（高铁/飞机）

    var id: String { rawValue }

    // MARK: - 速度区间（km/h）

    var speedRange: ClosedRange<Double> {
        switch self {
        case .walking: return 0...10
        case .cycling: return 10...30
        case .driving: return 30...120
        case .flying: return 120...1000
        }
    }

    // MARK: - 视觉样式

    /// 能量线颜色
    var lineColor: Color {
        switch self {
        case .walking: return LeyhomeTheme.EnergyLine.walking
        case .cycling: return LeyhomeTheme.EnergyLine.cycling
        case .driving: return LeyhomeTheme.EnergyLine.driving
        case .flying: return LeyhomeTheme.EnergyLine.flying
        }
    }

    /// 线条宽度
    var lineWidth: CGFloat {
        switch self {
        case .walking: return LeyhomeTheme.LineWidth.walking
        case .cycling: return LeyhomeTheme.LineWidth.cycling
        case .driving: return LeyhomeTheme.LineWidth.driving
        case .flying: return LeyhomeTheme.LineWidth.flying
        }
    }

    /// SF Symbol 图标
    var icon: String {
        switch self {
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .driving: return "car.fill"
        case .flying: return "airplane"
        }
    }

    // MARK: - 国际化

    /// 本地化名称
    var localizedName: String {
        "travel_mode.\(rawValue)".localized
    }

    // MARK: - 智能识别

    /// 根据速度检测出行方式
    /// - Parameter speedKmh: 速度（千米/小时）
    /// - Returns: 推断的出行方式
    static func detect(speedKmh: Double) -> TransportMode {
        // 异常值处理
        if speedKmh < 0 { return .walking }
        if speedKmh > 1000 { return .flying }

        // 从快到慢匹配
        for mode in [TransportMode.flying, .driving, .cycling, .walking] {
            if mode.speedRange.contains(speedKmh) {
                return mode
            }
        }

        // 默认步行
        return .walking
    }
}
