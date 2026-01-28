//
//  MapViewRepresentable.swift
//  Leyhome - 地脉归途
//
//  UIKit MapKit 包装器 - 渲染轨迹和用户位置
//
//  Created on 2026/01/28.
//

import SwiftUI
import MapKit

/// UIKit MapView 的 SwiftUI 包装器
struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var trackingManager: TrackingManager
    @Binding var region: MKCoordinateRegion

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.mapType = .standard

        // 如果已经有位置信息，立即居中
        if let location = trackingManager.currentLocation {
            let region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            mapView.setRegion(region, animated: false)
        }

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 更新地图区域（仅在不追踪时）
        if mapView.userTrackingMode == .none {
            mapView.setRegion(region, animated: true)
        }

        // 移除旧的轨迹覆盖层
        mapView.removeOverlays(mapView.overlays)

        // 添加当前轨迹
        if !trackingManager.currentTrack.isEmpty {
            // 转换坐标（WGS-84 → GCJ-02）
            let convertedCoordinates = CoordinateConverter.wgs84ToGcj02(trackingManager.currentTrack)

            // 创建折线
            let polyline = MKPolyline(coordinates: convertedCoordinates, count: convertedCoordinates.count)
            mapView.addOverlay(polyline)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: MapViewRepresentable
        private var hasInitiallyZoomedToUser = false

        init(parent: MapViewRepresentable) {
            self.parent = parent
        }

        // MARK: - MKMapViewDelegate

        /// 渲染轨迹线
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)

                // 根据出行方式设置线条样式
                let mode = parent.trackingManager.currentTransportMode
                renderer.strokeColor = UIColor(mode.lineColor)
                renderer.lineWidth = mode.lineWidth
                renderer.lineCap = .round
                renderer.lineJoin = .round

                return renderer
            }

            return MKOverlayRenderer(overlay: overlay)
        }

        /// 自定义用户位置标注
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // 保持系统默认的用户位置样式
            if annotation is MKUserLocation {
                return nil
            }

            return nil
        }

        /// 地图区域改变时更新绑定
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.parent.region = mapView.region
            }
        }

        /// 用户位置更新时，确保地图居中（首次获取位置时）
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            // 只在第一次获取到有效位置时居中一次
            guard !hasInitiallyZoomedToUser else { return }

            // 检查坐标是否有效
            guard CLLocationCoordinate2DIsValid(userLocation.coordinate) else { return }
            guard userLocation.coordinate.latitude != 0 || userLocation.coordinate.longitude != 0 else { return }

            hasInitiallyZoomedToUser = true

            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            mapView.setRegion(region, animated: true)

            #if DEBUG
            print("🗺️ 地图首次居中到用户位置: (\(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude))")
            #endif
        }
    }
}

// MARK: - Preview

#Preview {
    MapViewRepresentable(
        trackingManager: TrackingManager.shared,
        region: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074), // 北京
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    )
    .ignoresSafeArea()
}
