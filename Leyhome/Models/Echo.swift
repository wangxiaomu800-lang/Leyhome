//
//  Echo.swift
//  Leyhome - 地脉归途
//
//  回响数据模型 - 用户在圣迹留下的文字和照片回响
//
//  Created on 2026/02/03.
//

import Foundation
import SwiftData

/// 回响模型 - 用户在圣迹详情页留下的回响
@Model
class Echo: Identifiable {
    @Attribute(.unique) var id: UUID

    /// 关联的圣迹 ID
    var siteId: UUID

    /// 发布者用户 ID (来自 AuthManager.currentUser?.id，String 类型)
    var userId: String

    /// 用户昵称（发布时快照）
    var userNickname: String?

    /// 用户头像 URL（发布时快照）
    var userAvatarUrl: String?

    /// 回响文字内容
    var content: String

    /// 媒体 URL 列表（JSON 编码存储）
    var mediaUrlsData: Data?

    /// 是否公开可见（默认仅自己可见）
    var isPublic: Bool

    /// 是否匿名发布
    var isAnonymous: Bool

    /// 创建时间
    var createdAt: Date

    /// 更新时间
    var updatedAt: Date

    // MARK: - Init

    init(
        siteId: UUID,
        userId: String,
        content: String,
        isPublic: Bool = false,
        isAnonymous: Bool = false
    ) {
        self.id = UUID()
        self.siteId = siteId
        self.userId = userId
        self.content = content
        self.isPublic = isPublic
        self.isAnonymous = isAnonymous
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// 媒体 URL 列表
    var mediaUrls: [String] {
        get {
            guard let data = mediaUrlsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            mediaUrlsData = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    /// 显示名称（匿名时返回本地化的匿名行者）
    var displayName: String {
        if isAnonymous {
            return "echo.anonymous".localized
        }
        return userNickname ?? "echo.anonymous".localized
    }

    /// 格式化的创建时间
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - Preview Helper

#if DEBUG
extension Echo {
    static var preview: Echo {
        let echo = Echo(
            siteId: UUID(),
            userId: "preview-user-id",
            content: "这里的风景真的很美，让我想起了家乡的山水。每次来到这里，心情都会变得平静。",
            isPublic: true,
            isAnonymous: false
        )
        echo.userNickname = "行者小明"
        return echo
    }

    static var previewAnonymous: Echo {
        let echo = Echo(
            siteId: UUID(),
            userId: "preview-user-id-2",
            content: "第一次来这里，感受到了大自然的力量。",
            isPublic: true,
            isAnonymous: true
        )
        return echo
    }
}
#endif
