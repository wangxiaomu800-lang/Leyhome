//
//  RecordingControlView.swift
//  Leyhome - 地脉归途
//
//  轨迹录制控制面板
//
//  Created on 2026/01/28.
//

import SwiftUI

/// 轨迹录制控制按钮
struct RecordingControlView: View {
    @ObservedObject var trackingManager: TrackingManager
    @Binding var showStopConfirmation: Bool

    var body: some View {
        VStack {
            Spacer()

            Button {
                handleButtonTap()
            } label: {
                HStack(spacing: LeyhomeTheme.Spacing.sm) {
                    Image(systemName: trackingManager.isTracking ? "stop.fill" : "play.fill")
                        .font(.system(size: 20, weight: .semibold))

                    Text(trackingManager.isTracking ? "recording.stop".localized : "recording.start".localized)
                        .font(LeyhomeTheme.Fonts.button)
                }
                .foregroundColor(.white)
                .padding(.horizontal, LeyhomeTheme.Spacing.lg)
                .padding(.vertical, LeyhomeTheme.Spacing.md)
                .background(
                    trackingManager.isTracking
                        ? LeyhomeTheme.danger
                        : LeyhomeTheme.primary
                )
                .cornerRadius(LeyhomeTheme.CornerRadius.full)
                .shadow(
                    color: LeyhomeTheme.Shadow.medium.color,
                    radius: LeyhomeTheme.Shadow.medium.radius,
                    x: LeyhomeTheme.Shadow.medium.x,
                    y: LeyhomeTheme.Shadow.medium.y
                )
            }
            .padding(.bottom, LeyhomeTheme.Spacing.xl)
        }
    }

    // MARK: - Actions

    private func handleButtonTap() {
        // 触觉反馈
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        if trackingManager.isTracking {
            // 停止录制：显示确认弹窗
            showStopConfirmation = true
        } else {
            // 开始录制
            trackingManager.startTracking()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()

        RecordingControlView(
            trackingManager: TrackingManager.shared,
            showStopConfirmation: .constant(false)
        )
    }
}
