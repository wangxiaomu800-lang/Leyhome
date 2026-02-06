//
//  JourneyRowView.swift
//  Leyhome - 地脉归途
//
//  旅程列表行视图 - 单条旅程摘要
//
//  Created on 2026/01/29.
//

import SwiftUI

struct JourneyRowView: View {
    let journey: Journey

    var body: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            // 左侧：出行方式图标
            Image(systemName: journey.transportMode.icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(journey.transportMode.lineColor)
                .cornerRadius(LeyhomeTheme.CornerRadius.sm)

            // 中间：名称、距离、时长
            VStack(alignment: .leading, spacing: 4) {
                // 旅程名称
                Text(displayName)
                    .font(LeyhomeTheme.Fonts.body)
                    .foregroundColor(LeyhomeTheme.textPrimary)
                    .lineLimit(1)

                // 距离 + 时长
                HStack(spacing: LeyhomeTheme.Spacing.md) {
                    Label(formattedDistance, systemImage: "arrow.triangle.swap")
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)

                    Label(formattedDuration, systemImage: "clock")
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)

                    // 轨迹点数
                    Label("\(journey.pathPoints.count)", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textMuted)
                }
            }

            Spacer()

            // 右侧：心绪数量（预留）
            if !journey.moodRecordIDs.isEmpty {
                HStack(spacing: 2) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(LeyhomeTheme.Mood.calm)
                    Text("\(journey.moodRecordIDs.count)")
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(LeyhomeTheme.textMuted)
        }
        .padding(.vertical, LeyhomeTheme.Spacing.xs)
    }

    // MARK: - Formatted Strings

    /// 旅程名称（使用自定义名称或默认年月日时分格式）
    private var displayName: String {
        // 如果有自定义名称（非默认生成的），使用自定义名称
        if !journey.name.isEmpty && !journey.name.hasPrefix("Journey ") {
            return journey.name
        }

        // 否则使用年月日时分格式
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter.string(from: journey.startTime)
    }

    /// 格式化距离
    private var formattedDistance: String {
        if journey.distance >= 1000 {
            return String(format: "%.2f km", journey.distance / 1000)
        }
        return String(format: "%.0f m", journey.distance)
    }

    /// 格式化时长
    private var formattedDuration: String {
        let totalSeconds = Int(journey.duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Preview

#Preview {
    List {
        JourneyRowView(journey: Journey(
            userID: "preview",
            name: "Morning Walk",
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date(),
            transportMode: .walking,
            distance: 2500,
            duration: 3600
        ))
    }
    .listStyle(.insetGrouped)
}
