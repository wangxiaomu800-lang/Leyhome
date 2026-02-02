//
//  SacredSite.swift
//  Leyhome - 地脉归途
//
//  圣迹数据模型 - 三层地脉节点体系
//
//  Created on 2026/01/28.
//  Rewritten on 2026/01/30: Day 6 完整圣迹系统
//

import Foundation
import SwiftUI
import SwiftData
import CoreLocation

// MARK: - SiteTier

/// 圣迹层级（GDD 2.2 三层地脉节点体系）
enum SiteTier: Int, Codable, CaseIterable {
    case primal = 1      // 源点圣迹 (Tier 1)
    case leyNode = 2     // 地脉节点 (Tier 2)
    case anchor = 3      // 心绪锚点 (Tier 3)

    var nameZh: String {
        switch self {
        case .primal: return "源点圣迹"
        case .leyNode: return "地脉节点"
        case .anchor: return "心绪锚点"
        }
    }

    var nameEn: String {
        switch self {
        case .primal: return "Primal Site"
        case .leyNode: return "Ley Node"
        case .anchor: return "Anchor of Serenity"
        }
    }

    var localizedName: String {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? nameZh : nameEn
    }

    /// GDD 6.3 图标设计
    var iconStyle: SiteIconStyle {
        switch self {
        case .primal: return .mandala
        case .leyNode: return .elegant
        case .anchor: return .ripple
        }
    }

    /// 层级对应颜色
    var color: Color {
        switch self {
        case .primal: return LeyhomeTheme.SacredSite.tier1
        case .leyNode: return LeyhomeTheme.SacredSite.tier2
        case .anchor: return LeyhomeTheme.SacredSite.tier3
        }
    }
}

/// 图标风格
enum SiteIconStyle {
    case mandala   // 曼陀罗（动态旋转的光构几何体）
    case elegant   // 精致线条（静态图标）
    case ripple    // 涟漪光点
}

// MARK: - SacredSite Model

/// 圣迹模型
@Model
class SacredSite: Identifiable {
    @Attribute(.unique) var id: UUID

    /// 层级（存储为 Int）
    var tier: Int

    // MARK: 双语内容
    var nameZh: String
    var nameEn: String
    var descriptionZh: String
    var descriptionEn: String
    var loreZh: String          // 地脉解读（GDD: 充满灵性的官方文字）
    var loreEn: String
    var historyZh: String?      // 历史与传说
    var historyEn: String?

    // MARK: 位置
    var latitude: Double
    var longitude: Double
    var continent: String       // 大洲分类
    var country: String
    var region: String?

    // MARK: 媒体
    var imageUrl: String?
    var videoUrl: String?

    // MARK: 统计
    var visitorCount: Int
    var echoCount: Int
    var intentionCount: Int

    // MARK: 创建者（用户提名的圣迹）
    var creatorId: UUID?
    var creatorName: String?

    // MARK: 收藏
    var isFavorite: Bool

    // MARK: 时间
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Init

    init(
        tier: SiteTier,
        nameZh: String,
        nameEn: String
    ) {
        self.id = UUID()
        self.tier = tier.rawValue
        self.nameZh = nameZh
        self.nameEn = nameEn
        self.descriptionZh = ""
        self.descriptionEn = ""
        self.loreZh = ""
        self.loreEn = ""
        self.latitude = 0
        self.longitude = 0
        self.continent = ""
        self.country = ""
        self.visitorCount = 0
        self.echoCount = 0
        self.intentionCount = 0
        self.isFavorite = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    var siteTier: SiteTier {
        SiteTier(rawValue: tier) ?? .anchor
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var name: String {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? nameZh : nameEn
    }

    var siteDescription: String {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? descriptionZh : descriptionEn
    }

    var lore: String {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? loreZh : loreEn
    }

    var history: String? {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? historyZh : historyEn
    }

    // MARK: - Methods

    func toggleFavorite() {
        isFavorite.toggle()
        updatedAt = Date()
    }

    func incrementVisitCount() {
        visitorCount += 1
        updatedAt = Date()
    }
}
