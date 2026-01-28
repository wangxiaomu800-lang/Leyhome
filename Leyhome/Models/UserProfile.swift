//
//  UserProfile.swift
//  Leyhome - 地脉归途
//
//  用户资料数据模型
//
//  Created on 2026/01/28.
//

import Foundation
import SwiftData

/// 用户资料模型
@Model
class UserProfile {
    /// 唯一标识（使用 Supabase User ID）
    @Attribute(.unique) var id: String

    /// 用户昵称
    var nickname: String

    /// 用户邮箱
    var email: String?

    /// 头像 URL
    var avatarURL: String?

    /// 注册时间
    var createdAt: Date

    /// 最后更新时间
    var updatedAt: Date

    // MARK: - 统计数据

    /// 轨迹总数
    var journeyCount: Int

    /// 心绪记录总数
    var moodCount: Int

    /// 收藏的圣迹总数
    var sacredSiteCount: Int

    /// 总里程（米）
    var totalDistance: Double

    /// 累计时长（秒）
    var totalDuration: TimeInterval

    // MARK: - 初始化

    init(
        id: String,
        nickname: String,
        email: String? = nil,
        avatarURL: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.nickname = nickname
        self.email = email
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        // 初始化统计数据
        self.journeyCount = 0
        self.moodCount = 0
        self.sacredSiteCount = 0
        self.totalDistance = 0
        self.totalDuration = 0
    }
}
