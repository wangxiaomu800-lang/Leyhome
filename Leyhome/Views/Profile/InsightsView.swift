//
//  InsightsView.swift
//  Leyhome - 地脉归途
//
//  数据洞察视图 - 展示用户行走与心绪统计图表
//
//  Created on 2026/02/05.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - 统计数据结构

struct UserStats {
    var totalJourneys: Int = 0
    var totalDistance: Double = 0      // 米
    var totalDuration: TimeInterval = 0 // 秒
    var totalMoodRecords: Int = 0
    var transportModeCount: [TransportMode: Int] = [:]
    var moodTypeCount: [MoodType: Int] = [:]
    var weeklyActivity: [WeekdayActivity] = []
    var consecutiveDays: Int = 0
}

struct WeekdayActivity: Identifiable {
    let id = UUID()
    let weekday: String
    let count: Int
}

// MARK: - InsightsView

struct InsightsView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Query(sort: \Journey.startTime, order: .reverse) private var journeys: [Journey]
    @Query(sort: \MoodRecord.recordTime, order: .reverse) private var moodRecords: [MoodRecord]

    @State private var stats = UserStats()

    var body: some View {
        ZStack {
            LeyhomeTheme.Background.primary
                .ignoresSafeArea()

            if subscriptionManager.isPremium {
                // 已订阅：显示完整图表
                premiumContent
            } else {
                // 未订阅：显示锁定状态
                lockedContent
            }
        }
        .navigationTitle("insights.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { computeStats() }
    }

    // MARK: - 已订阅内容

    private var premiumContent: some View {
        ScrollView {
            VStack(spacing: LeyhomeTheme.Spacing.lg) {
                // 概览卡片
                OverviewCard(stats: stats)

                // 出行方式饼图
                TravelModeChart(data: stats.transportModeCount)

                // 心绪分布柱形图
                MoodDistributionChart(data: stats.moodTypeCount)

                // 每周活跃度
                WeeklyActivityChart(data: stats.weeklyActivity)

                // 成长报告
                GrowthReportSection(consecutiveDays: stats.consecutiveDays)
            }
            .padding(LeyhomeTheme.Spacing.lg)
        }
    }

    // MARK: - 锁定内容

    private var lockedContent: some View {
        VStack(spacing: LeyhomeTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 56))
                .foregroundColor(LeyhomeTheme.textMuted)

            Text("insights.locked_title".localized)
                .font(LeyhomeTheme.Fonts.title)
                .foregroundColor(LeyhomeTheme.primary)

            Text("insights.locked_desc".localized)
                .font(LeyhomeTheme.Fonts.body)
                .foregroundColor(LeyhomeTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LeyhomeTheme.Spacing.xl)

            Spacer()
        }
    }

    // MARK: - 计算统计数据

    private func computeStats() {
        var s = UserStats()
        s.totalJourneys = journeys.count
        s.totalDistance = journeys.reduce(0) { $0 + $1.distance }
        s.totalDuration = journeys.reduce(0) { $0 + $1.duration }
        s.totalMoodRecords = moodRecords.count

        // 出行方式统计
        for j in journeys {
            s.transportModeCount[j.transportMode, default: 0] += 1
        }

        // 心绪分布
        for m in moodRecords {
            s.moodTypeCount[m.moodType, default: 0] += 1
        }

        // 每周活跃度
        let calendar = Calendar.current
        let weekdaySymbols = calendar.shortWeekdaySymbols
        var weekdayCounts = [Int: Int]()
        for j in journeys {
            let wd = calendar.component(.weekday, from: j.startTime)
            weekdayCounts[wd, default: 0] += 1
        }
        s.weeklyActivity = (1...7).map { wd in
            WeekdayActivity(
                weekday: weekdaySymbols[wd - 1],
                count: weekdayCounts[wd] ?? 0
            )
        }

        // 连续天数
        s.consecutiveDays = computeConsecutiveDays()

        stats = s
    }

    private func computeConsecutiveDays() -> Int {
        let calendar = Calendar.current
        var dates = Set<DateComponents>()

        for j in journeys {
            let comps = calendar.dateComponents([.year, .month, .day], from: j.startTime)
            dates.insert(comps)
        }
        for m in moodRecords {
            let comps = calendar.dateComponents([.year, .month, .day], from: m.recordTime)
            dates.insert(comps)
        }

        guard !dates.isEmpty else { return 0 }

        let sortedDates = dates.compactMap { calendar.date(from: $0) }.sorted(by: >)
        guard let latest = sortedDates.first else { return 0 }

        // 检查最近日期是否为今天或昨天
        let today = calendar.startOfDay(for: Date())
        let latestDay = calendar.startOfDay(for: latest)
        let dayDiff = calendar.dateComponents([.day], from: latestDay, to: today).day ?? 0
        guard dayDiff <= 1 else { return 0 }

        var count = 1
        for i in 1..<sortedDates.count {
            let prev = calendar.startOfDay(for: sortedDates[i - 1])
            let curr = calendar.startOfDay(for: sortedDates[i])
            let diff = calendar.dateComponents([.day], from: curr, to: prev).day ?? 0
            if diff == 1 {
                count += 1
            } else {
                break
            }
        }
        return count
    }
}

// MARK: - OverviewCard

struct OverviewCard: View {
    let stats: UserStats

    private var distanceKm: String {
        String(format: "%.1f", stats.totalDistance / 1000)
    }

    private var durationHours: String {
        String(format: "%.1f", stats.totalDuration / 3600)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            Text("insights.overview".localized)
                .font(LeyhomeTheme.Fonts.headline)
                .foregroundColor(LeyhomeTheme.primary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: LeyhomeTheme.Spacing.md) {
                StatCell(value: "\(stats.totalJourneys)", label: "insights.journeys".localized, icon: "map")
                StatCell(value: "\(stats.totalMoodRecords)", label: "insights.moods".localized, icon: "heart")
                StatCell(value: distanceKm, label: "insights.distance_km".localized, icon: "figure.walk")
                StatCell(value: durationHours, label: "insights.duration_hours".localized, icon: "clock")
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(
            color: LeyhomeTheme.Shadow.light.color,
            radius: LeyhomeTheme.Shadow.light.radius,
            x: LeyhomeTheme.Shadow.light.x,
            y: LeyhomeTheme.Shadow.light.y
        )
    }
}

struct StatCell: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(LeyhomeTheme.accent)
            Text(value)
                .font(LeyhomeTheme.Fonts.titleSmall)
                .foregroundColor(LeyhomeTheme.primary)
            Text(label)
                .font(LeyhomeTheme.Fonts.caption)
                .foregroundColor(LeyhomeTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LeyhomeTheme.Spacing.sm)
    }
}

// MARK: - TravelModeChart (饼图)

struct TravelModeChart: View {
    let data: [TransportMode: Int]

    private var chartData: [(mode: TransportMode, count: Int)] {
        data.map { (mode: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            Text("insights.travel_mode".localized)
                .font(LeyhomeTheme.Fonts.headline)
                .foregroundColor(LeyhomeTheme.primary)

            if chartData.isEmpty {
                emptyState
            } else {
                Chart(chartData, id: \.mode) { item in
                    SectorMark(
                        angle: .value("count", item.count),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(item.mode.lineColor)
                    .annotation(position: .overlay) {
                        Text(item.mode.localizedName)
                            .font(LeyhomeTheme.Fonts.caption)
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 200)

                // 图例
                HStack(spacing: LeyhomeTheme.Spacing.md) {
                    ForEach(chartData, id: \.mode) { item in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(item.mode.lineColor)
                                .frame(width: 8, height: 8)
                            Text("\(item.mode.localizedName) \(item.count)")
                                .font(LeyhomeTheme.Fonts.caption)
                                .foregroundColor(LeyhomeTheme.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(
            color: LeyhomeTheme.Shadow.light.color,
            radius: LeyhomeTheme.Shadow.light.radius,
            x: LeyhomeTheme.Shadow.light.x,
            y: LeyhomeTheme.Shadow.light.y
        )
    }

    private var emptyState: some View {
        Text("insights.no_data".localized)
            .font(LeyhomeTheme.Fonts.body)
            .foregroundColor(LeyhomeTheme.textMuted)
            .frame(maxWidth: .infinity, minHeight: 100)
    }
}

// MARK: - MoodDistributionChart (条形图)

struct MoodDistributionChart: View {
    let data: [MoodType: Int]

    private var chartData: [(mood: MoodType, count: Int)] {
        data.map { (mood: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            Text("insights.mood_distribution".localized)
                .font(LeyhomeTheme.Fonts.headline)
                .foregroundColor(LeyhomeTheme.primary)

            if chartData.isEmpty {
                Text("insights.no_data".localized)
                    .font(LeyhomeTheme.Fonts.body)
                    .foregroundColor(LeyhomeTheme.textMuted)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                Chart(chartData, id: \.mood) { item in
                    BarMark(
                        x: .value("mood", item.mood.localizedName),
                        y: .value("count", item.count)
                    )
                    .foregroundStyle(item.mood.color)
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(LeyhomeTheme.Fonts.caption)
                    }
                }
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(
            color: LeyhomeTheme.Shadow.light.color,
            radius: LeyhomeTheme.Shadow.light.radius,
            x: LeyhomeTheme.Shadow.light.x,
            y: LeyhomeTheme.Shadow.light.y
        )
    }
}

// MARK: - WeeklyActivityChart (柱形图)

struct WeeklyActivityChart: View {
    let data: [WeekdayActivity]

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            Text("insights.weekly_activity".localized)
                .font(LeyhomeTheme.Fonts.headline)
                .foregroundColor(LeyhomeTheme.primary)

            if data.isEmpty {
                Text("insights.no_data".localized)
                    .font(LeyhomeTheme.Fonts.body)
                    .foregroundColor(LeyhomeTheme.textMuted)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                Chart(data) { item in
                    BarMark(
                        x: .value("weekday", item.weekday),
                        y: .value("count", item.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [LeyhomeTheme.primary, LeyhomeTheme.accent],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                }
                .frame(height: 180)
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(
            color: LeyhomeTheme.Shadow.light.color,
            radius: LeyhomeTheme.Shadow.light.radius,
            x: LeyhomeTheme.Shadow.light.x,
            y: LeyhomeTheme.Shadow.light.y
        )
    }
}

// MARK: - GrowthReportSection

struct GrowthReportSection: View {
    let consecutiveDays: Int

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            Text("insights.growth_report".localized)
                .font(LeyhomeTheme.Fonts.headline)
                .foregroundColor(LeyhomeTheme.primary)

            HStack(spacing: LeyhomeTheme.Spacing.md) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 32))
                    .foregroundColor(consecutiveDays > 0 ? LeyhomeTheme.accent : LeyhomeTheme.textMuted)

                VStack(alignment: .leading, spacing: 4) {
                    Text("insights.consecutive_days".localized(with: consecutiveDays))
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    Text(consecutiveDays > 0
                         ? "insights.keep_going".localized
                         : "insights.start_today".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                }

                Spacer()
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(
            color: LeyhomeTheme.Shadow.light.color,
            radius: LeyhomeTheme.Shadow.light.radius,
            x: LeyhomeTheme.Shadow.light.x,
            y: LeyhomeTheme.Shadow.light.y
        )
    }
}

#Preview {
    NavigationStack {
        InsightsView()
    }
}
