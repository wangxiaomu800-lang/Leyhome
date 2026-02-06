//
//  ProfileView.swift
//  Leyhome - 地脉归途
//
//  个人中心视图 - 展示用户信息和设置
//
//  Created on 2026/01/26.
//

import SwiftUI
import Supabase
import SwiftData

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showSettings = false
    @State private var showMoodHistory = false
    @State private var showSubscription = false

    @Query(sort: \Journey.startTime, order: .reverse) private var journeys: [Journey]
    @Query(sort: \MoodRecord.recordTime, order: .reverse) private var moodRecords: [MoodRecord]

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景色
                LeyhomeTheme.Background.primary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    // 头像区域
                    VStack(spacing: LeyhomeTheme.Spacing.md) {
                        // 默认头像
                        ZStack {
                            Circle()
                                .fill(LeyhomeTheme.primary.opacity(0.1))
                                .frame(width: 100, height: 100)

                            Image(systemName: "person.fill")
                                .font(.system(size: 48))
                                .foregroundColor(LeyhomeTheme.primary.opacity(0.5))
                        }

                        // 用户名
                        Text(authManager.currentUser?.email ?? "profile.placeholder".localized)
                            .font(LeyhomeTheme.Fonts.body)
                            .foregroundColor(LeyhomeTheme.primary.opacity(0.8))

                        // 用户 ID (开发测试)
                        if let userId = authManager.currentUser?.id {
                            Text(userId.uuidString.prefix(8) + "...")
                                .font(LeyhomeTheme.Fonts.caption)
                                .foregroundColor(LeyhomeTheme.primary.opacity(0.5))
                        }
                    }
                    .padding(.top, LeyhomeTheme.Spacing.xl)

                    // 统计卡片
                    HStack(spacing: LeyhomeTheme.Spacing.md) {
                        ProfileStatCard(title: "轨迹", value: "\(journeys.count)", icon: "map")

                        Button {
                            showMoodHistory = true
                        } label: {
                            ProfileStatCard(title: "心绪", value: "\(moodRecords.count)", icon: "heart")
                        }
                        .buttonStyle(.plain)

                        ProfileStatCard(title: "圣迹", value: "0", icon: "star")
                    }
                    .padding(.horizontal, LeyhomeTheme.Spacing.lg)

                    // 功能列表
                    VStack(spacing: 0) {
                        ProfileMenuItem(
                            icon: "gear",
                            title: "设置",
                            subtitle: "账号与偏好设置",
                            action: { showSettings = true }
                        )

                        Divider()
                            .padding(.leading, 60)

                        ProfileMenuItem(
                            icon: "heart.text.square",
                            title: "mood.history.title".localized,
                            subtitle: "mood.history.subtitle".localized,
                            action: { showMoodHistory = true }
                        )

                        Divider()
                            .padding(.leading, 60)

                        ProfileMenuItem(
                            icon: "clock.arrow.circlepath",
                            title: "历史记录",
                            subtitle: "查看我的足迹",
                            action: { /* TODO */ }
                        )

                        Divider()
                            .padding(.leading, 60)

                        ProfileMenuItem(
                            icon: "trophy",
                            title: "成就",
                            subtitle: "我的旅程成就",
                            action: { /* TODO */ }
                        )

                        Divider()
                            .padding(.leading, 60)

                        ProfileMenuItem(
                            icon: "sparkles",
                            title: "subscription.menu_title".localized,
                            subtitle: "subscription.menu_subtitle".localized,
                            action: { showSubscription = true }
                        )

                        Divider()
                            .padding(.leading, 60)

                        NavigationLink {
                            InsightsView()
                        } label: {
                            ProfileMenuRow(
                                icon: "chart.bar.xaxis",
                                title: "insights.menu_title".localized,
                                subtitle: "insights.menu_subtitle".localized
                            )
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
                    .padding(.horizontal, LeyhomeTheme.Spacing.lg)
                    .shadow(
                        color: LeyhomeTheme.Shadow.light.color,
                        radius: LeyhomeTheme.Shadow.light.radius,
                        x: LeyhomeTheme.Shadow.light.x,
                        y: LeyhomeTheme.Shadow.light.y
                    )

                    // 登出按钮
                    Button(action: {
                        Task {
                            await authManager.signOut()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("button.sign_out".localized)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LeyhomeTheme.Spacing.md)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(LeyhomeTheme.CornerRadius.md)
                    }
                    .padding(.horizontal, LeyhomeTheme.Spacing.lg)
                    .padding(.top, LeyhomeTheme.Spacing.xl)

                    // 版本信息
                    Text("Leyhome v1.0.0")
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.primary.opacity(0.5))
                        .padding(.bottom, LeyhomeTheme.Spacing.xl)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(authManager)
            }
            .navigationDestination(isPresented: $showMoodHistory) {
                MoodHistoryView()
            }
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
        }
    }
}

// MARK: - 菜单行组件（用于 NavigationLink）
struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            // 图标
            ZStack {
                Circle()
                    .fill(LeyhomeTheme.accent.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(LeyhomeTheme.accent)
            }

            // 文字
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LeyhomeTheme.Fonts.body)
                    .foregroundColor(LeyhomeTheme.textPrimary)

                Text(subtitle)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(LeyhomeTheme.textSecondary)
            }

            Spacer()

            // 箭头
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(LeyhomeTheme.textMuted)
        }
        .padding(LeyhomeTheme.Spacing.md)
    }
}

// MARK: - 功能菜单项组件
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: LeyhomeTheme.Spacing.md) {
                // 图标
                ZStack {
                    Circle()
                        .fill(LeyhomeTheme.accent.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(LeyhomeTheme.accent)
                }

                // 文字
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(LeyhomeTheme.Fonts.body)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    Text(subtitle)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                }

                Spacer()

                // 箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(LeyhomeTheme.textMuted)
            }
            .padding(LeyhomeTheme.Spacing.md)
        }
    }
}

// MARK: - 统计卡片组件
struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(LeyhomeTheme.accent)

            Text(value)
                .font(LeyhomeTheme.Fonts.titleSmall)
                .foregroundColor(LeyhomeTheme.primary)

            Text(title)
                .font(LeyhomeTheme.Fonts.caption)
                .foregroundColor(LeyhomeTheme.primary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LeyhomeTheme.Spacing.md)
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
    ProfileView()
}
