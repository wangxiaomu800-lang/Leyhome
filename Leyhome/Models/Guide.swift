//
//  Guide.swift
//  Leyhome - 地脉归途
//
//  先行者数据模型
//
//  Created on 2026/02/04.
//

import Foundation
import SwiftData

/// 先行者模型
@Model
class Guide: Identifiable {
    @Attribute(.unique) var id: UUID

    /// 先行者名称
    var name: String

    /// 身份/头衔（双语）
    var titleZh: String
    var titleEn: String

    /// 简介（双语）
    var bioZh: String
    var bioEn: String

    /// 头像 URL
    var avatarUrl: String?

    /// 封面图 URL
    var coverImageUrl: String?

    /// 是否认证
    var isVerified: Bool = true

    /// 关注者数量
    var followerCount: Int = 0

    /// 专长标签（JSON 编码存储）
    var tagsData: Data?

    /// 创建时间
    var createdAt: Date

    // MARK: - Init

    init(name: String, titleZh: String, titleEn: String) {
        self.id = UUID()
        self.name = name
        self.titleZh = titleZh
        self.titleEn = titleEn
        self.bioZh = ""
        self.bioEn = ""
        self.createdAt = Date()
    }

    // MARK: - Computed Properties

    var title: String {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? titleZh : titleEn
    }

    var bio: String {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? bioZh : bioEn
    }

    var tags: [String] {
        get {
            guard let data = tagsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            tagsData = try? JSONEncoder().encode(newValue)
        }
    }
}

// MARK: - Preview Helper

#if DEBUG
extension Guide {
    static var preview: Guide {
        let guide = Guide(
            name: "林深",
            titleZh: "正念导师 · 山野行者",
            titleEn: "Mindfulness Guide · Mountain Walker"
        )
        guide.bioZh = "二十年山野徒步经验，致力于将正念冥想与户外行走相结合。"
        guide.bioEn = "Twenty years of mountain hiking experience, dedicated to combining mindfulness meditation with outdoor walking."
        guide.tags = ["正念", "徒步", "山野"]
        return guide
    }
}
#endif
