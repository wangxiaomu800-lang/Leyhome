//
//  MapViewRepresentable.swift
//  Leyhome - 地脉归途
//
//  UIKit MapKit 包装器 - 渲染能量线轨迹、历史轨迹和用户位置
//
//  Created on 2026/01/28.
//  Updated on 2026/01/29: 能量线渲染器、动画、历史轨迹、主题系统
//

import SwiftUI
import MapKit

/// UIKit MapView 的 SwiftUI 包装器
struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var trackingManager: TrackingManager
    @Binding var region: MKCoordinateRegion

    /// 历史旅程列表（从 SwiftData 查询）
    var journeys: [Journey]

    /// 当前地图主题
    var mapTheme: MapTheme

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        // 应用主题
        applyTheme(to: mapView)

        // 如果已经有位置信息，立即居中
        if let location = trackingManager.currentLocation {
            let region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            mapView.setRegion(region, animated: false)
        }

        // 启动动画
        context.coordinator.startAnimation()

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 更新 coordinator 的 parent 引用
        context.coordinator.parent = self

        // 应用主题变化
        applyTheme(to: mapView)

        // 重建轨迹覆盖层
        mapView.removeOverlays(mapView.overlays)

        // 添加历史轨迹（限制数量防止性能问题）
        let maxHistoricalJourneys = 50
        let historicalJourneys = Array(journeys.prefix(maxHistoricalJourneys))

        for journey in historicalJourneys {
            let points = journey.pathPoints
            guard points.count >= 2 else { continue }

            let convertedCoordinates = CoordinateConverter.wgs84ToGcj02(points)
            let polyline = TransportModePolyline.create(
                coordinates: convertedCoordinates,
                transportMode: journey.transportMode,
                isHistorical: true
            )
            mapView.addOverlay(polyline, level: .aboveRoads)
        }

        // 添加当前轨迹（在最上层）
        if !trackingManager.currentTrack.isEmpty {
            let convertedCoordinates = CoordinateConverter.wgs84ToGcj02(trackingManager.currentTrack)
            let polyline = TransportModePolyline.create(
                coordinates: convertedCoordinates,
                transportMode: trackingManager.currentTransportMode,
                isHistorical: false
            )
            mapView.addOverlay(polyline, level: .aboveLabels)
        }

        // 更新 coordinator 的渲染器引用
        context.coordinator.updateRenderers(on: mapView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - Theme Application

    /// 应用地图主题
    private func applyTheme(to mapView: MKMapView) {
        mapView.mapType = mapTheme.mapType

        // 配置 POI 过滤
        if !mapTheme.showsPOI {
            mapView.pointOfInterestFilter = .excludingAll
        } else {
            mapView.pointOfInterestFilter = .includingAll
        }

        // 3D 视角
        if mapTheme.is3D {
            mapView.isPitchEnabled = true
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        private var hasInitiallyZoomedToUser = false
        /// 防止 region 回调触发 updateUIView 循环
        private var isUpdatingRegion = false

        /// 动画控制器
        private let animator = EnergyLineAnimator()

        /// 当前活跃的能量线渲染器
        private var activeRenderers: [EnergyLineRenderer] = []

        init(parent: MapViewRepresentable) {
            self.parent = parent
            super.init()

            // 设置动画回调
            animator.onPhaseUpdate = { [weak self] phase in
                self?.updateAnimationPhase(phase)
            }
        }

        deinit {
            animator.stopAnimation()
        }

        // MARK: - Animation

        /// 启动动画
        func startAnimation() {
            animator.startAnimation()
        }

        /// 停止动画
        func stopAnimation() {
            animator.stopAnimation()
        }

        /// 更新所有活跃渲染器的动画相位
        private func updateAnimationPhase(_ phase: CGFloat) {
            for renderer in activeRenderers where !renderer.isHistorical {
                renderer.animationPhase = phase
                renderer.setNeedsDisplay()
            }
        }

        /// 更新渲染器引用列表
        func updateRenderers(on mapView: MKMapView) {
            activeRenderers = mapView.overlays.compactMap { overlay in
                mapView.renderer(for: overlay) as? EnergyLineRenderer
            }
        }

        // MARK: - MKMapViewDelegate

        /// 渲染轨迹线
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? TransportModePolyline {
                let renderer = EnergyLineRenderer(polyline: polyline)
                renderer.transportMode = polyline.transportMode
                renderer.isHistorical = polyline.isHistorical

                // 应用主题颜色覆盖
                let themeManager = ThemeManager.shared
                renderer.colorOverride = themeManager.currentTheme.energyLineColorOverride(for: polyline.transportMode)

                // 基础样式
                renderer.strokeColor = UIColor(polyline.transportMode.lineColor)
                renderer.lineWidth = polyline.transportMode.lineWidth
                renderer.lineCap = .round
                renderer.lineJoin = .round

                return renderer
            }

            // 兼容普通 MKPolyline（防御性）
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
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
            if annotation is MKUserLocation {
                return nil
            }
            return nil
        }

        /// 地图区域改变时更新绑定（不回传以避免循环）
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // 不再回写 region binding，避免 updateUIView 循环干扰 userTrackingMode
        }

        /// 用户位置更新时，确保地图居中（首次获取位置时）
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            guard !hasInitiallyZoomedToUser else { return }
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
            center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )),
        journeys: [],
        mapTheme: .starDust
    )
    .ignoresSafeArea()
}
