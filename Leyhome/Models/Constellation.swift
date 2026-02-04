//
//  Constellation.swift
//  Leyhome - 地脉归途
//
//  星图 + 星图节点数据模型
//
//  Created on 2026/02/04.
//

import Foundation
import SwiftData
import CoreLocation

/// 星图模型 - 先行者创建的行走路线
@Model
class Constellation: Identifiable {
    @Attribute(.unique) var id: UUID

    /// 关联的先行者 ID
    var guideId: UUID

    /// 名称（双语）
    var nameZh: String
    var nameEn: String

    /// 描述（双语）
    var descriptionZh: String
    var descriptionEn: String

    /// 封面图 URL
    var coverImageUrl: String?

    /// 难度 (1-5)
    var difficulty: Int = 1

    /// 预计时长（小时）
    var estimatedHours: Double = 0

    /// 总距离（公里）
    var totalDistance: Double = 0

    /// 共鸣行走次数
    var resonanceCount: Int = 0

    /// 是否为订阅专属
    var isPremium: Bool = false

    /// 创建时间
    var createdAt: Date

    // MARK: - Init

    init(guideId: UUID, nameZh: String, nameEn: String) {
        self.id = UUID()
        self.guideId = guideId
        self.nameZh = nameZh
        self.nameEn = nameEn
        self.descriptionZh = ""
        self.descriptionEn = ""
        self.createdAt = Date()
    }

    // MARK: - Computed Properties

    var name: String {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? nameZh : nameEn
    }

    var constellationDescription: String {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? descriptionZh : descriptionEn
    }
}

/// 星图节点 - 先行者在路线中的心绪记录点
@Model
class ConstellationNode: Identifiable {
    @Attribute(.unique) var id: UUID

    /// 关联的星图 ID
    var constellationId: UUID

    /// 节点顺序
    var order: Int

    /// 坐标
    var latitude: Double
    var longitude: Double

    /// 节点标题（双语）
    var titleZh: String?
    var titleEn: String?

    /// 先行者在此处的感悟（双语）
    var contentZh: String
    var contentEn: String

    /// 语音引导 URL
    var audioUrl: String?

    /// 创建时间
    var createdAt: Date

    // MARK: - Init

    init(constellationId: UUID, order: Int) {
        self.id = UUID()
        self.constellationId = constellationId
        self.order = order
        self.latitude = 0
        self.longitude = 0
        self.contentZh = ""
        self.contentEn = ""
        self.createdAt = Date()
    }

    // MARK: - Computed Properties

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var nodeTitle: String? {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? titleZh : titleEn
    }

    var content: String {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? contentZh : contentEn
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension Constellation {
    static var preview: Constellation {
        let c = Constellation(
            guideId: UUID(),
            nameZh: "城市边缘的呼吸",
            nameEn: "Breathing at the City's Edge"
        )
        c.descriptionZh = "在城市与自然的交界处，找到内心的宁静。"
        c.descriptionEn = "Find inner peace at the boundary between city and nature."
        c.difficulty = 2
        c.estimatedHours = 3
        c.totalDistance = 8.5
        return c
    }
}

extension ConstellationNode {
    static var preview: ConstellationNode {
        let n = ConstellationNode(constellationId: UUID(), order: 1)
        n.latitude = 39.9042
        n.longitude = 116.4074
        n.titleZh = "起点 · 城市的边界"
        n.titleEn = "Starting Point · City's Edge"
        n.contentZh = "站在这里，回望身后的城市。"
        n.contentEn = "Stand here, look back at the city behind you."
        return n
    }
}
#endif
