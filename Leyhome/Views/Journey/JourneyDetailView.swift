//
//  JourneyDetailView.swift
//  Leyhome - 地脉归途
//
//  旅程详情视图 - 地图预览、统计数据、心绪列表、删除
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

    @Query(sort: \MoodRecord.recordTime, order: .reverse) private var allMoodRecords: [MoodRecord]

    @State private var showDeleteConfirmation = false
    @State private var showAddMoodSheet = false
    @State private var showRenameAlert = false
    @State private var newJourneyName = ""
    @State private var selectedMoodRecord: MoodRecord?
    @State private var mapRegion: MKCoordinateRegion

    /// 当前旅程关联的心绪记录
    private var journeyMoodRecords: [MoodRecord] {
        guard !journey.moodRecordIDs.isEmpty else { return [] }
        return allMoodRecords.filter { journey.moodRecordIDs.contains($0.id) }
            .sorted { $0.recordTime < $1.recordTime }
    }

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

                    // 心绪列表
                    moodSection

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
            .alert("journey.rename".localized, isPresented: $showRenameAlert) {
                TextField("journey.name.placeholder".localized, text: $newJourneyName)
                Button("button.cancel".localized, role: .cancel) {}
                Button("button.save".localized) {
                    renameJourney()
                }
            } message: {
                Text("journey.rename.message".localized)
            }
            .sheet(isPresented: $showAddMoodSheet) {
                // 补录心绪 - 使用旅程中间点坐标
                let midCoordinate = journeyMidCoordinate
                NodeCreatorSheet(
                    coordinate: midCoordinate,
                    journeyID: journey.id,
                    onSave: { recordID in
                        journey.moodRecordIDs.append(recordID)
                        try? modelContext.save()
                    }
                )
                .presentationDetents([.large])
            }
            .sheet(item: $selectedMoodRecord) { record in
                NodeDetailView(moodRecord: record)
                    .presentationDetents([.large])
            }
        }
    }

    /// 旅程路径中点坐标（补录心绪时使用）
    private var journeyMidCoordinate: CLLocationCoordinate2D {
        let points = journey.pathPoints
        if points.isEmpty {
            return CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074)
        }
        let midIndex = points.count / 2
        return points[midIndex]
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
            // 出行方式 + 重命名按钮
            HStack {
                Image(systemName: journey.transportMode.icon)
                    .foregroundColor(journey.transportMode.lineColor)
                Text(journey.transportMode.localizedName)
                    .font(LeyhomeTheme.Fonts.headline)
                    .foregroundColor(LeyhomeTheme.textPrimary)

                Spacer()

                // 重命名按钮
                Button {
                    newJourneyName = journey.name
                    showRenameAlert = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                        Text("journey.rename".localized)
                            .font(LeyhomeTheme.Fonts.caption)
                    }
                    .foregroundColor(LeyhomeTheme.accent)
                }
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

    // MARK: - Mood Section

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            HStack {
                Image(systemName: "heart.text.square")
                    .foregroundColor(LeyhomeTheme.accent)
                Text("journey.mood_records".localized)
                    .font(LeyhomeTheme.Fonts.headline)
                    .foregroundColor(LeyhomeTheme.textPrimary)

                Spacer()

                // 补录心绪按钮
                Button {
                    showAddMoodSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14))
                        Text("node.add_retroactive".localized)
                            .font(LeyhomeTheme.Fonts.caption)
                    }
                    .foregroundColor(LeyhomeTheme.accent)
                }
            }

            if journeyMoodRecords.isEmpty {
                // 空状态
                VStack(spacing: 8) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 24))
                        .foregroundColor(LeyhomeTheme.textMuted)
                    Text("journey.no_mood_records".localized)
                        .font(LeyhomeTheme.Fonts.bodySmall)
                        .foregroundColor(LeyhomeTheme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, LeyhomeTheme.Spacing.lg)
            } else {
                // 心绪列表
                ForEach(journeyMoodRecords) { record in
                    Button {
                        selectedMoodRecord = record
                    } label: {
                        MoodRecordRow(record: record)
                    }
                    .buttonStyle(.plain)
                }
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

    private func renameJourney() {
        guard !newJourneyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        journey.name = newJourneyName.trimmingCharacters(in: .whitespacesAndNewlines)
        try? modelContext.save()
    }
}

// MARK: - MoodRecordRow

/// 心绪记录行组件（共享给 JourneyDetailView 和 MoodHistoryView）
struct MoodRecordRow: View {
    let record: MoodRecord

    var body: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            // 心绪图标
            ZStack {
                Circle()
                    .fill(record.moodType.color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: record.moodType.icon)
                    .font(.system(size: 18))
                    .foregroundColor(record.moodType.color)
            }

            // 内容
            VStack(alignment: .leading, spacing: 4) {
                // 心绪名称（多心绪时显示全部）
                HStack(spacing: 4) {
                    ForEach(record.moodTypes, id: \.rawValue) { mood in
                        Text(mood.localizedName)
                            .font(LeyhomeTheme.Fonts.bodySmall)
                            .foregroundColor(mood.color)
                    }
                }

                // 时间
                Text(record.recordTime, style: .time)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(LeyhomeTheme.textMuted)

                // 文字摘要
                if let note = record.note, !note.isEmpty {
                    Text(note)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(LeyhomeTheme.textMuted)
        }
        .padding(.vertical, LeyhomeTheme.Spacing.sm)
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
