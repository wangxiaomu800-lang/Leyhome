//
//  SacredSite.swift
//  Leyhome - 地脉归途
//
//  圣迹数据模型
//
//  Created on 2026/01/28.
//

import Foundation
import SwiftData
import CoreLocation

/// 圣迹层级
enum SacredSiteTier: String, Codable {
    case tier1 = "tier1"  // 源点圣迹（金色）
    case tier2 = "tier2"  // 地脉节点（琥珀）
    case tier3 = "tier3"  // 心绪锚点（淡蓝）

    /// 层级名称
    var displayName: String {
        switch self {
        case .tier1: return "源点圣迹"
        case .tier2: return "地脉节点"
        case .tier3: return "心绪锚点"
        }
    }
}

/// 圣迹模型
@Model
class SacredSite {
    /// 唯一标识
    @Attribute(.unique) var id: UUID

    /// 圣迹名称
    var name: String

    /// 圣迹描述
    var siteDescription: String?

    /// 圣迹层级
    var tier: SacredSiteTier

    /// 地点坐标（JSON 存储）
    var locationData: Data?

    /// 地址
    var address: String?

    /// 封面图片路径
    var coverImagePath: String?

    /// 是否已收藏
    var isFavorite: Bool

    /// 收藏的用户 ID 列表（JSON 存储）
    var favoriteUserIDsData: Data?

    /// 访问次数
    var visitCount: Int

    /// 创建时间
    var createdAt: Date

    /// 最后更新时间
    var updatedAt: Date

    // MARK: - 计算属性

    /// 地点坐标
    var location: CLLocationCoordinate2D? {
        get {
            guard let data = locationData,
                  let codable = try? JSONDecoder().decode(CodableCoordinate.self, from: data) else {
                return nil
            }
            return codable.coordinate
        }
        set {
            if let newValue = newValue {
                locationData = try? JSONEncoder().encode(CodableCoordinate(from: newValue))
            } else {
                locationData = nil
            }
        }
    }

    /// 收藏的用户 ID 列表
    var favoriteUserIDs: [String] {
        get {
            guard let data = favoriteUserIDsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            favoriteUserIDsData = try? JSONEncoder().encode(newValue)
        }
    }

    // MARK: - 初始化

    init(
        id: UUID = UUID(),
        name: String,
        siteDescription: String? = nil,
        tier: SacredSiteTier = .tier3,
        address: String? = nil,
        coverImagePath: String? = nil,
        isFavorite: Bool = false,
        visitCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.siteDescription = siteDescription
        self.tier = tier
        self.address = address
        self.coverImagePath = coverImagePath
        self.isFavorite = isFavorite
        self.visitCount = visitCount
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - 方法

    /// 切换收藏状态
    func toggleFavorite(for userID: String) {
        var ids = favoriteUserIDs
        if let index = ids.firstIndex(of: userID) {
            ids.remove(at: index)
            isFavorite = false
        } else {
            ids.append(userID)
            isFavorite = true
        }
        favoriteUserIDs = ids
        updatedAt = Date()
    }

    /// 增加访问次数
    func incrementVisitCount() {
        visitCount += 1
        updatedAt = Date()
    }
}
