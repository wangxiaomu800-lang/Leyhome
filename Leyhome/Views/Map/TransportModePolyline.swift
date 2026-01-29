//
//  TransportModePolyline.swift
//  Leyhome - 地脉归途
//
//  自定义 MKPolyline 子类，携带出行方式和历史轨迹标记
//
//  Created on 2026/01/29.
//

import MapKit

/// 携带出行方式信息的自定义折线
class TransportModePolyline: MKPolyline {
    /// 出行方式
    var transportMode: TransportMode = .walking

    /// 是否为历史轨迹（用于降低不透明度）
    var isHistorical: Bool = false

    /// 便捷工厂方法
    static func create(
        coordinates: [CLLocationCoordinate2D],
        transportMode: TransportMode,
        isHistorical: Bool = false
    ) -> TransportModePolyline {
        var coords = coordinates
        let polyline = TransportModePolyline(coordinates: &coords, count: coords.count)
        polyline.transportMode = transportMode
        polyline.isHistorical = isHistorical
        return polyline
    }
}
