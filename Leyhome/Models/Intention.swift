//
//  Intention.swift
//  Leyhome - 地脉归途
//
//  意向数据模型 - 用户标记「我亦向往」时选择的计划到达年月
//
//  Created on 2026/02/03.
//

import Foundation
import SwiftData

/// 意向模型 - 用户对圣迹的「我亦向往」标记及计划到达时间
@Model
class Intention: Identifiable {
    @Attribute(.unique) var id: UUID

    /// 关联的圣迹 ID
    var siteId: UUID

    /// 用户 ID (来自 AuthManager.currentUser?.id，String 类型)
    var userId: String

    /// 计划到达年份
    var targetYear: Int

    /// 计划到达月份 (1-12)
    var targetMonth: Int

    /// 创建时间
    var createdAt: Date

    // MARK: - Init

    init(
        siteId: UUID,
        userId: String,
        targetYear: Int,
        targetMonth: Int
    ) {
        self.id = UUID()
        self.siteId = siteId
        self.userId = userId
        self.targetYear = targetYear
        self.targetMonth = targetMonth
        self.createdAt = Date()
    }

    // MARK: - Computed Properties

    /// 格式化的目标日期字符串 (如 "2026年7月" 或 "July 2026")
    var formattedTargetDate: String {
        let lang = LocalizationManager.shared.currentLanguage
        if lang.hasPrefix("zh") {
            return "\(targetYear)年\(targetMonth)月"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            var components = DateComponents()
            components.year = targetYear
            components.month = targetMonth
            if let date = Calendar.current.date(from: components) {
                return formatter.string(from: date)
            }
            return "\(targetMonth)/\(targetYear)"
        }
    }

    /// 目标年月的键值 (用于统计，格式为 "2026-07")
    var targetKey: String {
        String(format: "%04d-%02d", targetYear, targetMonth)
    }
}

// MARK: - IntentionStats

/// 意向统计数据
struct IntentionStats {
    /// 圣迹 ID
    let siteId: UUID

    /// 总意向人数
    let totalCount: Int

    /// 按月份分组的意向人数 (键格式 "2026-07": 42)
    let monthlyBreakdown: [String: Int]

    /// 获取指定年月的意向人数
    func count(for year: Int, month: Int) -> Int {
        let key = String(format: "%04d-%02d", year, month)
        return monthlyBreakdown[key] ?? 0
    }
}

// MARK: - Preview Helper

#if DEBUG
extension Intention {
    static var preview: Intention {
        Intention(
            siteId: UUID(),
            userId: "preview-user-id",
            targetYear: 2026,
            targetMonth: 7
        )
    }
}

extension IntentionStats {
    static var preview: IntentionStats {
        IntentionStats(
            siteId: UUID(),
            totalCount: 142,
            monthlyBreakdown: [
                "2026-07": 42,
                "2026-08": 35,
                "2026-09": 28,
                "2026-10": 22,
                "2026-11": 15
            ]
        )
    }
}
#endif
