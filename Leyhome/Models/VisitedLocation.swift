//
//  VisitedLocation.swift
//  Leyhome - 地脉归途
//
//  到访记录模型 - 记录用户到访过的圣迹
//
//  Created on 2026/02/03.
//

import Foundation
import SwiftData

/// 到访记录 - 记录用户曾到访过的圣迹
/// 用于回响定位限制：用户必须到过圣迹才能写回响
@Model
class VisitedLocation: Identifiable {
    @Attribute(.unique) var id: UUID
    var siteId: UUID           // 圣迹 ID
    var userId: String         // 用户 ID
    var visitedAt: Date        // 首次到访时间
    var distance: Double       // 到访时的距离（米）

    init(siteId: UUID, userId: String, distance: Double) {
        self.id = UUID()
        self.siteId = siteId
        self.userId = userId
        self.visitedAt = Date()
        self.distance = distance
    }
}

// MARK: - EchoDistanceThreshold

/// 回响定位阈值常量
/// 定义不同层级圣迹的到访判定距离
struct EchoDistanceThreshold {
    /// 地脉节点 (Tier 2): 2km 范围内
    static let leyNode: Double = 2_000

    /// 源点圣迹 (Tier 1): 10km 范围内
    static let primal: Double = 10_000

    /// 极地特殊区域: 100km 范围内（考虑极地环境特殊性）
    static let polar: Double = 100_000

    /// 极地纬度阈值（北纬/南纬 66.5° 以上视为极地）
    static let polarLatitudeThreshold: Double = 66.5

    /// 获取指定圣迹的到访判定阈值
    /// - Parameter site: 圣迹对象
    /// - Returns: 距离阈值（米）
    static func threshold(for site: SacredSite) -> Double {
        // 检测是否为极地（纬度 > 66.5° 或 < -66.5°）
        if abs(site.latitude) > polarLatitudeThreshold {
            return polar
        }

        switch site.siteTier {
        case .primal:
            return primal
        case .leyNode:
            return leyNode
        case .anchor:
            return leyNode  // 锚点同节点
        }
    }

    /// 格式化距离显示
    /// - Parameter meters: 距离（米）
    /// - Returns: 格式化的距离字符串
    static func formatDistance(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", meters / 1000)
        } else {
            return String(format: "%.0f m", meters)
        }
    }
}
