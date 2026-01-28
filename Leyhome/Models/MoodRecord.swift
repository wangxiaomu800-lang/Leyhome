//
//  MoodRecord.swift
//  Leyhome - 地脉归途
//
//  心绪记录数据模型
//
//  Created on 2026/01/28.
//

import Foundation
import SwiftData
import CoreLocation

/// 心绪类型
enum MoodType: String, Codable, CaseIterable {
    case calm = "calm"              // 平静
    case joy = "joy"                // 愉悦
    case anxiety = "anxiety"        // 焦虑
    case relief = "relief"          // 释然
    case inspiration = "inspiration" // 灵感
    case nostalgia = "nostalgia"    // 怀旧
    case gratitude = "gratitude"    // 感恩

    /// 心绪名称
    var displayName: String {
        switch self {
        case .calm: return "平静"
        case .joy: return "愉悦"
        case .anxiety: return "焦虑"
        case .relief: return "释然"
        case .inspiration: return "灵感"
        case .nostalgia: return "怀旧"
        case .gratitude: return "感恩"
        }
    }
}

/// 心绪记录模型
@Model
class MoodRecord {
    /// 唯一标识
    @Attribute(.unique) var id: UUID

    /// 所属用户 ID
    var userID: String

    /// 心绪类型
    var moodType: MoodType

    /// 心绪强度 (1-5)
    var intensity: Int

    /// 文字记录
    var note: String?

    /// 记录时间
    var recordTime: Date

    /// 地点坐标（JSON 存储）
    var locationData: Data?

    /// 地点名称
    var locationName: String?

    /// 关联的轨迹 ID
    var journeyID: UUID?

    /// 图片路径集合（JSON 存储）
    var imagePathsData: Data?

    /// 创建时间
    var createdAt: Date

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

    /// 图片路径集合
    var imagePaths: [String] {
        get {
            guard let data = imagePathsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            imagePathsData = try? JSONEncoder().encode(newValue)
        }
    }

    // MARK: - 初始化

    init(
        id: UUID = UUID(),
        userID: String,
        moodType: MoodType,
        intensity: Int = 3,
        note: String? = nil,
        recordTime: Date = Date(),
        journeyID: UUID? = nil,
        locationName: String? = nil
    ) {
        self.id = id
        self.userID = userID
        self.moodType = moodType
        self.intensity = min(max(intensity, 1), 5) // 限制在 1-5 范围
        self.note = note
        self.recordTime = recordTime
        self.journeyID = journeyID
        self.locationName = locationName
        self.createdAt = Date()
    }
}
