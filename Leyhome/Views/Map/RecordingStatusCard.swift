//
//  RecordingStatusCard.swift
//  Leyhome - 地脉归途
//
//  录制状态卡片 - 显示实时统计数据
//
//  Created on 2026/01/28.
//

import SwiftUI

/// 录制状态卡片
struct RecordingStatusCard: View {
    @ObservedObject var trackingManager: TrackingManager

    var body: some View {
        VStack {
            HStack(spacing: LeyhomeTheme.Spacing.md) {
                // 录制指示器
                recordingIndicator

                // 出行方式图标
                transportModeIcon

                // 统计数据
                statisticsView

                Spacer()
            }
            .padding(LeyhomeTheme.Spacing.md)
            .background(LeyhomeTheme.Background.card)
            .cornerRadius(LeyhomeTheme.CornerRadius.md)
            .shadow(
                color: LeyhomeTheme.Shadow.light.color,
                radius: LeyhomeTheme.Shadow.light.radius,
                x: LeyhomeTheme.Shadow.light.x,
                y: LeyhomeTheme.Shadow.light.y
            )
            .padding(.horizontal, LeyhomeTheme.Spacing.md)
            .padding(.top, LeyhomeTheme.Spacing.md)

            Spacer()
        }
    }

    // MARK: - Components

    /// 录制指示器（脉动的红点）
    private var recordingIndicator: some View {
        Circle()
            .fill(LeyhomeTheme.danger)
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(LeyhomeTheme.danger.opacity(0.3), lineWidth: 4)
                    .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                    .opacity(pulseAnimation ? 0.0 : 1.0)
            )
            .animation(LeyhomeTheme.Animation.breathing, value: pulseAnimation)
            .onAppear {
                pulseAnimation = true
            }
    }

    /// 出行方式图标
    private var transportModeIcon: some View {
        ZStack {
            Circle()
                .fill(trackingManager.currentTransportMode.lineColor.opacity(0.15))
                .frame(width: 36, height: 36)

            Image(systemName: trackingManager.currentTransportMode.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(trackingManager.currentTransportMode.lineColor)
        }
    }

    /// 统计数据视图
    private var statisticsView: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.xs) {
            // 时长
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(LeyhomeTheme.textSecondary)

                Text(formattedDuration)
                    .font(LeyhomeTheme.Fonts.headline)
                    .foregroundColor(LeyhomeTheme.textPrimary)
                    .monospacedDigit()
            }

            // 距离和轨迹点
            HStack(spacing: LeyhomeTheme.Spacing.md) {
                // 距离
                HStack(spacing: 4) {
                    Image(systemName: "map")
                        .font(.caption2)
                        .foregroundColor(LeyhomeTheme.textMuted)

                    Text(formattedDistance)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                }

                // 轨迹点数
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundColor(LeyhomeTheme.textMuted)

                    Text("\(trackingManager.currentTrack.count)")
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                        .monospacedDigit()
                }

                // 出行方式名称
                Text(trackingManager.currentTransportMode.localizedName)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(trackingManager.currentTransportMode.lineColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(trackingManager.currentTransportMode.lineColor.opacity(0.1))
                    .cornerRadius(4)
            }
        }
    }

    // MARK: - State

    @State private var pulseAnimation = false

    // MARK: - Computed Properties

    /// 格式化的时长（HH:MM:SS 或 MM:SS）
    private var formattedDuration: String {
        let duration = trackingManager.duration
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    /// 格式化的距离
    private var formattedDistance: String {
        let distance = trackingManager.totalDistance
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.2f km", distance / 1000)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()

        RecordingStatusCard(trackingManager: TrackingManager.shared)
    }
    .onAppear {
        TrackingManager.shared.startTracking()
    }
}
