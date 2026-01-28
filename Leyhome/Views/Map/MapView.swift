//
//  MapView.swift
//  Leyhome - 地脉归途
//
//  心灵地图视图 - 展示用户的行走轨迹和心绪节点
//
//  Created on 2026/01/26.
//  Refactored on 2026/01/28: Full GPS tracking integration
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var trackingManager = TrackingManager.shared

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074), // 默认北京
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showStopConfirmation = false
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 地图背景（使用 UIKit MapView）
                MapViewRepresentable(
                    trackingManager: trackingManager,
                    region: $region
                )
                .ignoresSafeArea()

                // 录制状态卡片
                if trackingManager.isTracking {
                    RecordingStatusCard(trackingManager: trackingManager)
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    // 占位提示
                    VStack {
                        Spacer()

                        VStack(spacing: LeyhomeTheme.Spacing.md) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 48))
                                .foregroundColor(LeyhomeTheme.primary.opacity(0.6))

                            Text("map.recording.placeholder".localized)
                                .font(LeyhomeTheme.Fonts.body)
                                .foregroundColor(LeyhomeTheme.primary.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(LeyhomeTheme.Spacing.lg)
                        .background(.ultraThinMaterial)
                        .cornerRadius(LeyhomeTheme.CornerRadius.lg)
                        .padding(.horizontal, LeyhomeTheme.Spacing.lg)

                        Spacer()
                    }
                    .transition(.opacity)
                }

                // 录制控制按钮
                RecordingControlView(
                    trackingManager: trackingManager,
                    showStopConfirmation: $showStopConfirmation
                )
            }
            .navigationBarHidden(true)
            .animation(.easeInOut(duration: 0.3), value: trackingManager.isTracking)
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
            .onDisappear {
                // 离开地图页面时停止位置更新（如果没在追踪）
                if !trackingManager.isTracking {
                    trackingManager.stopLocationUpdates()
                }
            }
        }
    }

    // MARK: - Actions

    /// 检查定位权限
    private func checkLocationPermission() {
        switch trackingManager.authorizationStatus {
        case .notDetermined:
            trackingManager.requestAuthorization()
        case .denied, .restricted:
            showPermissionAlert = true
        case .authorizedWhenInUse, .authorizedAlways:
            // WhenInUse 权限足够用于前台录制
            break
        @unknown default:
            break
        }
    }

    /// 停止追踪并保存到 SwiftData
    private func stopAndSaveTracking() {
        guard let journey = trackingManager.stopTracking() else {
            print("⚠️ 停止追踪失败：无法创建 Journey 对象")
            return
        }

        // 保存到 SwiftData
        modelContext.insert(journey)

        do {
            try modelContext.save()
            print("✅ Journey 保存成功：\(journey.name)")
        } catch {
            print("❌ Journey 保存失败：\(error.localizedDescription)")
        }
    }
}

// MARK: - Preview

#Preview {
    MapView()
        .modelContainer(for: [Journey.self], inMemory: true)
}
