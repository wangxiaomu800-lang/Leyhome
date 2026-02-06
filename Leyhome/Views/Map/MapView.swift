//
//  MapView.swift
//  Leyhome - 地脉归途
//
//  心灵地图视图 - 展示用户的行走轨迹和心绪节点
//
//  Created on 2026/01/26.
//  Refactored on 2026/01/28: Full GPS tracking integration
//  Updated on 2026/01/29: 历史轨迹、能量线、地图主题、心绪旅程绑定
//

import SwiftUI
import MapKit
import SwiftData
import CoreLocation
import Supabase

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var trackingManager = TrackingManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    /// 从 SwiftData 查询所有已保存的旅程（按开始时间降序）
    @Query(sort: \Journey.startTime, order: .reverse) private var journeys: [Journey]

    /// 从 SwiftData 查询所有心绪记录（按记录时间降序）
    @Query(sort: \MoodRecord.recordTime, order: .reverse) private var moodRecords: [MoodRecord]

    /// 从 SwiftData 查询所有已到访记录
    @Query private var visitedLocations: [VisitedLocation]

    /// 预置圣迹数据
    private let allSites = SacredSiteData.loadAllSites()

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074), // 默认北京
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showStopConfirmation = false
    @State private var showPermissionAlert = false
    @State private var showThemePicker = false
    @State private var showMoodCreationSheet = false
    @State private var longPressCoordinate: CLLocationCoordinate2D?
    @State private var selectedMoodRecord: MoodRecord?

    /// 当前追踪期间创建的心绪 ID 列表
    @State private var trackingMoodRecordIDs: [UUID] = []

    /// 未追踪时长按提示
    @State private var showTrackingHint = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 地图背景（使用 UIKit MapView）
                MapViewRepresentable(
                    trackingManager: trackingManager,
                    region: $region,
                    journeys: journeys,
                    moodRecords: moodRecords,
                    mapTheme: themeManager.currentTheme,
                    onLongPress: { coordinate in
                        handleLongPress(coordinate)
                    },
                    onMoodAnnotationTapped: { record in
                        selectedMoodRecord = record
                    }
                )
                .ignoresSafeArea()

                // 录制状态卡片 / 占位提示（顶部）
                VStack {
                    if trackingManager.isTracking {
                        RecordingStatusCard(trackingManager: trackingManager)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        // 占位提示 - 顶部安全区下方
                        VStack(spacing: LeyhomeTheme.Spacing.md) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 36))
                                .foregroundColor(LeyhomeTheme.primary.opacity(0.6))

                            Text("map.recording.placeholder".localized)
                                .font(LeyhomeTheme.Fonts.body)
                                .foregroundColor(LeyhomeTheme.primary.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(LeyhomeTheme.Spacing.md)
                        .background(.ultraThinMaterial)
                        .cornerRadius(LeyhomeTheme.CornerRadius.lg)
                        .padding(.horizontal, LeyhomeTheme.Spacing.lg)
                        .padding(.top, LeyhomeTheme.Spacing.xxl + 20)
                        .transition(.opacity)
                    }

                    Spacer()
                }

                // 长按提示 Toast
                if showTrackingHint {
                    VStack {
                        Spacer()

                        Text("node.hint.start_journey".localized)
                            .font(LeyhomeTheme.Fonts.bodySmall)
                            .foregroundColor(.white)
                            .padding(.horizontal, LeyhomeTheme.Spacing.lg)
                            .padding(.vertical, LeyhomeTheme.Spacing.md)
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(LeyhomeTheme.CornerRadius.lg)
                            .padding(.bottom, 120)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
                }

                // 主题切换按钮（右上角）
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            showThemePicker = true
                        } label: {
                            Image(systemName: themeManager.currentTheme.icon)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(LeyhomeTheme.primary)
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        }
                        .padding(.trailing, LeyhomeTheme.Spacing.md)
                        .padding(.top, LeyhomeTheme.Spacing.xxl)
                    }
                    Spacer()
                }

                // 录制控制按钮
                RecordingControlView(
                    trackingManager: trackingManager,
                    showStopConfirmation: $showStopConfirmation
                )
            }
            .navigationBarHidden(true)
            .animation(.easeInOut(duration: 0.3), value: trackingManager.isTracking)
            .animation(.easeInOut(duration: 0.3), value: showTrackingHint)
            .alert("recording.stop.confirm.title".localized, isPresented: $showStopConfirmation) {
                Button("button.cancel".localized, role: .cancel) {}
                Button("recording.stop.confirm".localized, role: .destructive) {
                    stopAndSaveTracking()
                }
            } message: {
                Text("recording.stop.confirm.message".localized)
            }
            .alert("定位权限", isPresented: $showPermissionAlert) {
                Button("好的", role: .cancel) {}
            } message: {
                Text("地脉归途需要访问您的位置来记录轨迹，请前往设置开启定位权限。")
            }
            .sheet(isPresented: $showThemePicker) {
                ThemePickerView(themeManager: themeManager)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showMoodCreationSheet) {
                if let coordinate = longPressCoordinate {
                    NodeCreatorSheet(
                        coordinate: coordinate,
                        journeyID: nil, // journeyID 在停止追踪后回写
                        onSave: { recordID in
                            trackingMoodRecordIDs.append(recordID)
                        }
                    )
                    .presentationDetents([.large])
                }
            }
            .sheet(item: $selectedMoodRecord) { record in
                NodeDetailView(moodRecord: record)
                    .presentationDetents([.large])
            }
            .onAppear {
                checkLocationPermission()

                // 开始更新位置（不开始追踪）
                trackingManager.startLocationUpdates()

                // 如果有当前位置，更新地图区域
                if let location = trackingManager.currentLocation {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                    #if DEBUG
                    print("🗺️ MapView 加载，设置区域到当前位置")
                    #endif
                } else {
                    #if DEBUG
                    print("⚠️ MapView 加载时暂无位置信息，等待位置更新")
                    #endif
                }
            }
            .onChange(of: trackingManager.currentLocation) { _, newLocation in
                // 检测是否进入圣迹范围
                if let location = newLocation {
                    checkProximityToSites(currentLocation: location)
                }
            }
            .onDisappear {
                // 离开地图页面时停止位置更新（如果没在追踪）
                if !trackingManager.isTracking {
                    trackingManager.stopLocationUpdates()
                }
            }
            .onChange(of: trackingManager.isTracking) { _, isTracking in
                if isTracking {
                    // 开始追踪时清空心绪 ID 列表
                    trackingMoodRecordIDs = []
                }
            }
        }
    }

    // MARK: - Actions

    /// 处理长按地图
    private func handleLongPress(_ coordinate: CLLocationCoordinate2D) {
        if trackingManager.isTracking {
            longPressCoordinate = coordinate
            showMoodCreationSheet = true
        } else {
            // 未追踪时显示提示
            showTrackingHint = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showTrackingHint = false
                }
            }
        }
    }

    /// 检查定位权限
    private func checkLocationPermission() {
        switch trackingManager.authorizationStatus {
        case .notDetermined:
            trackingManager.requestAuthorization()
        case .denied, .restricted:
            showPermissionAlert = true
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            break
        }
    }

    // MARK: - 到访检测

    /// 检测用户是否进入圣迹范围，自动记录到访
    private func checkProximityToSites(currentLocation: CLLocation) {
        guard let userId = authManager.currentUser?.id.uuidString else { return }

        for site in allSites {
            let siteLocation = CLLocation(latitude: site.latitude, longitude: site.longitude)
            let distance = currentLocation.distance(from: siteLocation)
            let threshold = EchoDistanceThreshold.threshold(for: site)

            if distance <= threshold {
                // 检查是否已经记录过
                let alreadyVisited = visitedLocations.contains { visited in
                    visited.siteId == site.id && visited.userId == userId
                }

                if !alreadyVisited {
                    // 记录到访
                    let visitedLocation = VisitedLocation(
                        siteId: site.id,
                        userId: userId,
                        distance: distance
                    )
                    modelContext.insert(visitedLocation)

                    #if DEBUG
                    print("📍 记录到访: \(site.name) (距离: \(EchoDistanceThreshold.formatDistance(distance)))")
                    #endif
                }
            }
        }

        // 保存更改
        try? modelContext.save()
    }

    /// 停止追踪并保存到 SwiftData
    private func stopAndSaveTracking() {
        guard let journey = trackingManager.stopTracking() else {
            print("⚠️ 停止追踪失败：无法创建 Journey 对象")
            return
        }

        // 将追踪期间的心绪 IDs 写入 Journey
        journey.moodRecordIDs = trackingMoodRecordIDs

        modelContext.insert(journey)

        do {
            try modelContext.save()
            print("✅ Journey 保存成功：\(journey.name)，关联心绪 \(trackingMoodRecordIDs.count) 条")

            // 回写 journeyID 到关联的 MoodRecord
            let journeyID = journey.id
            let moodIDs = trackingMoodRecordIDs
            for record in moodRecords where moodIDs.contains(record.id) {
                record.journeyID = journeyID
            }
            try modelContext.save()
        } catch {
            print("❌ Journey 保存失败：\(error.localizedDescription)")
        }

        // 清空追踪期间的心绪 IDs
        trackingMoodRecordIDs = []
    }
}

// MARK: - Theme Picker

/// 地图主题选择器
struct ThemePickerView: View {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(MapTheme.allCases) { theme in
                    Button {
                        themeManager.setTheme(theme)
                        dismiss()
                    } label: {
                        HStack(spacing: LeyhomeTheme.Spacing.md) {
                            Image(systemName: theme.icon)
                                .font(.system(size: 22))
                                .foregroundColor(themeManager.currentTheme == theme ? LeyhomeTheme.accent : LeyhomeTheme.textSecondary)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(theme.localizedName)
                                        .font(LeyhomeTheme.Fonts.body)
                                        .foregroundColor(LeyhomeTheme.textPrimary)

                                    if theme.isPremium {
                                        Text("map.theme.premium".localized)
                                            .font(LeyhomeTheme.Fonts.caption)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(LeyhomeTheme.accent)
                                            .cornerRadius(4)
                                    }
                                }
                            }

                            Spacer()

                            if themeManager.currentTheme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(LeyhomeTheme.primary)
                            }
                        }
                        .padding(.vertical, LeyhomeTheme.Spacing.xs)
                    }
                }
            }
            .navigationTitle("map.theme".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MapView()
        .environmentObject(AuthManager())
        .modelContainer(for: [Journey.self, MoodRecord.self, VisitedLocation.self], inMemory: true)
}
