//
//  Journey.swift
//  Leyhome - 地脉归途
//
//  轨迹记录数据模型
//
//  Created on 2026/01/28.
//

import Foundation
import SwiftData
import CoreLocation

/// 轨迹记录模型
@Model
class Journey {
    /// 唯一标识
    @Attribute(.unique) var id: UUID

    /// 所属用户 ID
    var userID: String

    /// 轨迹名称
    var name: String

    /// 开始时间
    var startTime: Date

    /// 结束时间
    var endTime: Date?

    /// 交通方式
    var transportMode: TransportMode

    /// 总距离（米）
    var distance: Double

    /// 总时长（秒）
    var duration: TimeInterval

    /// 起点坐标（使用 CodableCoordinate 存储）
    var startLocationData: Data?

    /// 终点坐标（使用 CodableCoordinate 存储）
    var endLocationData: Data?

    /// 路径点集合（使用 CodableCoordinate 数组存储）
    var pathPointsData: Data?

    /// 关联的心绪记录 ID 列表
    var moodRecordIDs: [UUID]

    /// 创建时间
    var createdAt: Date

    // MARK: - 计算属性

    /// 起点坐标
    var startLocation: CLLocationCoordinate2D? {
        get {
            guard let data = startLocationData,
                  let codable = try? JSONDecoder().decode(CodableCoordinate.self, from: data) else {
                return nil
            }
            return codable.coordinate
        }
        set {
            if let newValue = newValue {
                startLocationData = try? JSONEncoder().encode(CodableCoordinate(from: newValue))
            } else {
                startLocationData = nil
            }
        }
    }

    /// 终点坐标
    var endLocation: CLLocationCoordinate2D? {
        get {
            guard let data = endLocationData,
                  let codable = try? JSONDecoder().decode(CodableCoordinate.self, from: data) else {
                return nil
            }
            return codable.coordinate
        }
        set {
            if let newValue = newValue {
                endLocationData = try? JSONEncoder().encode(CodableCoordinate(from: newValue))
            } else {
                endLocationData = nil
            }
        }
    }

    /// 路径点集合
    var pathPoints: [CLLocationCoordinate2D] {
        get {
            guard let data = pathPointsData else { return [] }
            let codableCoordinates = (try? JSONDecoder().decode([CodableCoordinate].self, from: data)) ?? []
            return codableCoordinates.coordinates
        }
        set {
            pathPointsData = try? JSONEncoder().encode(newValue.codable)
        }
    }

    // MARK: - 初始化

    init(
        id: UUID = UUID(),
        userID: String,
        name: String,
        startTime: Date,
        endTime: Date? = nil,
        transportMode: TransportMode = .walking,
        distance: Double = 0,
        duration: TimeInterval = 0,
        moodRecordIDs: [UUID] = []
    ) {
        self.id = id
        self.userID = userID
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.transportMode = transportMode
        self.distance = distance
        self.duration = duration
        self.moodRecordIDs = moodRecordIDs
        self.createdAt = Date()
    }
}

