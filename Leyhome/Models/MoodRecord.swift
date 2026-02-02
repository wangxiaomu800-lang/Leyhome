//
//  MoodRecord.swift
//  Leyhome - 地脉归途
//
//  心绪记录数据模型
//
//  Created on 2026/01/28.
//

import Foundation
import SwiftUI
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
    case melancholy = "melancholy"  // 惆怅
    case wonder = "wonder"          // 惊奇
    case peace = "peace"            // 安宁

    /// 本地化名称
    var localizedName: String {
        "mood.\(rawValue)".localized
    }

    /// 心绪名称（兼容）
    var displayName: String {
        localizedName
    }

    /// 心绪颜色
    var color: Color {
        switch self {
        case .calm: return LeyhomeTheme.Mood.calm
        case .joy: return LeyhomeTheme.Mood.joy
        case .anxiety: return LeyhomeTheme.Mood.anxiety
        case .relief: return LeyhomeTheme.Mood.relief
        case .inspiration: return LeyhomeTheme.Mood.inspiration
        case .nostalgia: return LeyhomeTheme.Mood.nostalgia
        case .gratitude: return LeyhomeTheme.Mood.gratitude
        case .melancholy: return LeyhomeTheme.Mood.melancholy
        case .wonder: return LeyhomeTheme.Mood.wonder
        case .peace: return LeyhomeTheme.Mood.peace
        }
    }

    /// 心绪图标
    var icon: String {
        switch self {
        case .calm: return "wind"
        case .joy: return "sun.max.fill"
        case .anxiety: return "cloud.bolt.fill"
        case .relief: return "leaf.fill"
        case .inspiration: return "lightbulb.fill"
        case .nostalgia: return "clock.arrow.circlepath"
        case .gratitude: return "heart.fill"
        case .melancholy: return "cloud.rain.fill"
        case .wonder: return "sparkles"
        case .peace: return "moon.stars.fill"
        }
    }
}

/// 心绪记录模型
@Model
class MoodRecord: Identifiable {
    /// 唯一标识
    @Attribute(.unique) var id: UUID

    /// 所属用户 ID
    var userID: String

    /// 心绪类型（主要心绪，兼容旧数据）
    var moodType: MoodType

    /// 多心绪类型（JSON 存储）
    var moodTypesData: Data?

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

    /// 语音笔记（JSON 存储）
    var voiceNotesData: Data?

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

    /// 多心绪类型
    var moodTypes: [MoodType] {
        get {
            guard let data = moodTypesData,
                  let rawValues = try? JSONDecoder().decode([String].self, from: data) else {
                return [moodType]
            }
            return rawValues.compactMap { MoodType(rawValue: $0) }
        }
        set {
            moodTypesData = try? JSONEncoder().encode(newValue.map { $0.rawValue })
            if let first = newValue.first {
                moodType = first
            }
        }
    }

    /// 语音笔记集合
    var voiceNotes: [VoiceNote] {
        get {
            guard let data = voiceNotesData else { return [] }
            return (try? JSONDecoder().decode([VoiceNote].self, from: data)) ?? []
        }
        set {
            voiceNotesData = try? JSONEncoder().encode(newValue)
        }
    }

    // MARK: - 初始化

    init(
        id: UUID = UUID(),
        userID: String,
        moodType: MoodType,
        moodTypes: [MoodType]? = nil,
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

        // 存储多心绪
        if let types = moodTypes {
            self.moodTypesData = try? JSONEncoder().encode(types.map { $0.rawValue })
        }
    }
}

// MARK: - VoiceNote

/// 语音笔记
struct VoiceNote: Codable, Identifiable {
    var id: UUID
    var filePath: String
    var duration: TimeInterval
    var createdAt: Date

    init(id: UUID = UUID(), filePath: String, duration: TimeInterval, createdAt: Date = Date()) {
        self.id = id
        self.filePath = filePath
        self.duration = duration
        self.createdAt = createdAt
    }
}
