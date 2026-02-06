//
//  GuideApplication.swift
//  Leyhome - 地脉归途
//
//  先行者申请模型
//
//  Created on 2026/02/06.
//

import Foundation
import SwiftData

/// 申请状态
enum ApplicationStatus: String, Codable {
    case pending = "pending"       // 待审核
    case approved = "approved"     // 已通过
    case rejected = "rejected"     // 已拒绝
}

/// 先行者申请模型
@Model
class GuideApplication: Identifiable {
    @Attribute(.unique) var id: UUID

    /// 申请人用户 ID
    var userId: String

    /// 申请人姓名
    var name: String

    /// 头像 URL（可选）
    var avatarUrl: String?

    /// 中文标题
    var titleZh: String

    /// 英文标题
    var titleEn: String

    /// 中文简介
    var bioZh: String

    /// 英文简介
    var bioEn: String

    /// 擅长标签（JSON 存储）
    var tagsData: Data?

    /// 申请状态
    var status: ApplicationStatus

    /// 创建时间
    var createdAt: Date

    /// 更新时间
    var updatedAt: Date

    // MARK: - Computed

    /// 标签列表
    var tags: [String] {
        get {
            guard let data = tagsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            tagsData = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    /// 语言相关的标题
    var title: String {
        LocalizationManager.shared.currentLanguage.hasPrefix("zh") ? titleZh : titleEn
    }

    /// 语言相关的简介
    var bio: String {
        LocalizationManager.shared.currentLanguage.hasPrefix("zh") ? bioZh : bioEn
    }

    /// 状态本地化名称
    var statusText: String {
        switch status {
        case .pending:
            return "guide.application.status.pending".localized
        case .approved:
            return "guide.application.status.approved".localized
        case .rejected:
            return "guide.application.status.rejected".localized
        }
    }

    // MARK: - Init

    init(
        userId: String,
        name: String,
        titleZh: String,
        titleEn: String,
        bioZh: String,
        bioEn: String,
        tags: [String] = []
    ) {
        self.id = UUID()
        self.userId = userId
        self.name = name
        self.titleZh = titleZh
        self.titleEn = titleEn
        self.bioZh = bioZh
        self.bioEn = bioEn
        self.tagsData = try? JSONEncoder().encode(tags)
        self.status = .pending
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
