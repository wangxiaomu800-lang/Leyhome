//
//  CodableCoordinate.swift
//  Leyhome - 地脉归途
//
//  可编码的坐标结构体
//  避免直接扩展 CLLocationCoordinate2D 导致的并发和冲突问题
//
//  Created on 2026/01/28.
//

import Foundation
import CoreLocation

/// 可编码的坐标包装器
@preconcurrency
struct CodableCoordinate: Hashable, Sendable {
    let latitude: Double
    let longitude: Double

    // MARK: - 初始化

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    init(from coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    // MARK: - 转换

    /// 转换为 CLLocationCoordinate2D
    nonisolated var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// 是否为有效坐标
    nonisolated var isValid: Bool {
        CLLocationCoordinate2DIsValid(coordinate)
    }
}

// MARK: - Codable (nonisolated)

extension CodableCoordinate: Codable {
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
}

// MARK: - 便利扩展

extension CLLocationCoordinate2D {
    /// 转换为可编码坐标
    var codable: CodableCoordinate {
        CodableCoordinate(from: self)
    }
}

extension Array where Element == CLLocationCoordinate2D {
    /// 转换为可编码坐标数组
    var codable: [CodableCoordinate] {
        map { $0.codable }
    }
}

extension Array where Element == CodableCoordinate {
    /// 转换为 CLLocationCoordinate2D 数组
    var coordinates: [CLLocationCoordinate2D] {
        map { $0.coordinate }
    }
}
