//
//  JourneyDetailView.swift
//  Leyhome - 地脉归途
//
//  旅程详情视图 - 地图预览、统计数据、删除
//
//  Created on 2026/01/29.
//

import SwiftUI
import MapKit
import SwiftData

struct JourneyDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let journey: Journey

    @State private var showDeleteConfirmation = false
    @State private var mapRegion: MKCoordinateRegion

    init(journey: Journey) {
        self.journey = journey

        // 用 GCJ-02 转换后的坐标计算地图区域（与渲染一致）
        let convertedPoints = CoordinateConverter.wgs84ToGcj02(journey.pathPoints)
        if let first = convertedPoints.first {
            var minLat = first.latitude
            var maxLat = first.latitude
            var minLon = first.longitude
            var maxLon = first.longitude

            for point in convertedPoints {
                minLat = min(minLat, point.latitude)
                maxLat = max(maxLat, point.latitude)
                minLon = min(minLon, point.longitude)
                maxLon = max(maxLon, point.longitude)
            }

            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            )
            let span = MKCoordinateSpan(
                latitudeDelta: max((maxLat - minLat) * 1.5, 0.005),
                longitudeDelta: max((maxLon - minLon) * 1.5, 0.005)
            )
            _mapRegion = State(initialValue: MKCoordinateRegion(center: center, span: span))
        } else {
            _mapRegion = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    // 地图预览
                    mapPreview

                    // 统计数据
                    statsSection

                    // 删除按钮
                    deleteButton
                }
                .padding(LeyhomeTheme.Spacing.md)
            }
            .navigationTitle("journey.detail".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .alert("journey.delete.confirm".localized, isPresented: $showDeleteConfirmation) {
                Button("button.cancel".localized, role: .cancel) {}
                Button("journey.delete".localized, role: .destructive) {
                    deleteJourney()
                }
            }
        }
    }

    // MARK: - Map Preview

    private var mapPreview: some View {
        JourneyMapOverlay(journey: journey, region: mapRegion)
            .frame(height: 220)
            .cornerRadius(LeyhomeTheme.CornerRadius.lg)
            .allowsHitTesting(false)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            // 出行方式
            HStack {
                Image(systemName: journey.transportMode.icon)
                    .foregroundColor(journey.transportMode.lineColor)
                Text(journey.transportMode.localizedName)
                    .font(LeyhomeTheme.Fonts.headline)
                    .foregroundColor(LeyhomeTheme.textPrimary)
                Spacer()
            }

            Divider()

            // 统计网格
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: LeyhomeTheme.Spacing.md) {
                statItem(
                    icon: "arrow.triangle.swap",
                    title: "recording.distance".localized,
                    value: formattedDistance
                )
                statItem(
                    icon: "clock",
                    title: "journey.duration".localized,
                    value: formattedDuration
                )
                statItem(
                    icon: "point.topleft.down.to.point.bottomright.curvepath",
                    title: "recording.points".localized,
                    value: "\(journey.pathPoints.count)"
                )
                statItem(
                    icon: "calendar",
                    title: "journey.date".localized,
                    value: formattedDate
                )
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(LeyhomeTheme.Background.card)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(
            color: LeyhomeTheme.Shadow.light.color,
            radius: LeyhomeTheme.Shadow.light.radius
        )
    }

    private func statItem(icon: String, title: String, value: String) -> some View {
        VStack(spacing: LeyhomeTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(LeyhomeTheme.primary)

            Text(title)
                .font(LeyhomeTheme.Fonts.caption)
                .foregroundColor(LeyhomeTheme.textSecondary)

            Text(value)
                .font(LeyhomeTheme.Fonts.headline)
                .foregroundColor(LeyhomeTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LeyhomeTheme.Spacing.sm)
    }

    // MARK: - Delete Button

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("journey.delete".localized)
            }
            .font(LeyhomeTheme.Fonts.button)
            .foregroundColor(LeyhomeTheme.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, LeyhomeTheme.Spacing.md)
            .background(LeyhomeTheme.danger.opacity(0.1))
            .cornerRadius(LeyhomeTheme.CornerRadius.md)
        }
    }

    // MARK: - Formatted Strings

    private var formattedDistance: String {
        if journey.distance >= 1000 {
            return String(format: "%.2f km", journey.distance / 1000)
        }
        return String(format: "%.0f m", journey.distance)
    }

    private var formattedDuration: String {
        let totalSeconds = Int(journey.duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: journey.startTime)
    }

    // MARK: - Actions

    private func deleteJourney() {
        modelContext.delete(journey)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Journey Map Overlay

/// 在详情页地图上绘制旅程轨迹的辅助视图
struct JourneyMapOverlay: UIViewRepresentable {
    let journey: Journey
    let region: MKCoordinateRegion

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isUserInteractionEnabled = false
        mapView.mapType = .standard
        mapView.pointOfInterestFilter = .excludingAll
        mapView.setRegion(region, animated: false)

        // 添加轨迹
        let points = journey.pathPoints
        guard points.count >= 2 else { return mapView }

        let convertedCoordinates = CoordinateConverter.wgs84ToGcj02(points)
        let polyline = TransportModePolyline.create(
            coordinates: convertedCoordinates,
            transportMode: journey.transportMode,
            isHistorical: false
        )
        mapView.addOverlay(polyline)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(journey: journey)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        let journey: Journey

        init(journey: Journey) {
            self.journey = journey
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? TransportModePolyline {
                let renderer = EnergyLineRenderer(polyline: polyline)
                renderer.transportMode = polyline.transportMode
                renderer.isHistorical = false
                renderer.strokeColor = UIColor(polyline.transportMode.lineColor)
                renderer.lineWidth = polyline.transportMode.lineWidth
                renderer.lineCap = .round
                renderer.lineJoin = .round
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// MARK: - Preview

#Preview {
    JourneyDetailView(journey: Journey(
        userID: "preview",
        name: "Morning Walk",
        startTime: Date().addingTimeInterval(-3600),
        endTime: Date(),
        transportMode: .walking,
        distance: 2500,
        duration: 3600
    ))
}
