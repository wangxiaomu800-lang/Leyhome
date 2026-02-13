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
    @Binding var selectedTab: Int
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var languageManager = LanguageManager.shared
    @State private var showSettings = false
    @State private var showSubscription = false
    @State private var showMoodHistory = false
    @State private var showSignOutConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var deleteConfirmText = ""
    @State private var isDeleting = false
    @State private var showDeleteError = false
    @State private var deleteErrorMessage = ""

    @Query(sort: \Journey.startTime, order: .reverse) private var allJourneys: [Journey]
    @Query(sort: \MoodRecord.recordTime, order: .reverse) private var allMoodRecords: [MoodRecord]

    private var journeys: [Journey] {
        guard let uid = authManager.currentUser?.id.uuidString.lowercased() else { return [] }
        return allJourneys.filter { $0.userID.lowercased() == uid }
    }
    private var moodRecords: [MoodRecord] {
        guard let uid = authManager.currentUser?.id.uuidString.lowercased() else { return [] }
        return allMoodRecords.filter { $0.userID.lowercased() == uid }
    }

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
                        Button {
                            selectedTab = 1
                        } label: {
                            ProfileStatCard(title: "profile.stat.tracks".localized, value: "\(journeys.count)", icon: "map")
                        }
                        .buttonStyle(.plain)

                        Button {
                            showMoodHistory = true
                        } label: {
                            ProfileStatCard(title: "profile.stat.moods".localized, value: "\(moodRecords.count)", icon: "heart")
                        }
                        .buttonStyle(.plain)

                        ProfileStatCard(title: "profile.stat.sacred_sites".localized, value: "0", icon: "star")
                    }
                    .padding(.horizontal, LeyhomeTheme.Spacing.lg)

                    // 功能列表
                    VStack(spacing: 0) {
                        ProfileMenuItem(
                            icon: "gear",
                            title: "profile.menu.settings".localized,
                            subtitle: "profile.menu.settings_subtitle".localized,
                            action: { showSettings = true }
                        )

                        Divider()
                            .padding(.leading, 60)

                        ProfileMenuItem(
                            icon: "trophy",
                            title: "profile.menu.achievements".localized,
                            subtitle: "profile.menu.achievements_subtitle".localized,
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
                        showSignOutConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("button.sign_out".localized)
                        }
                        .font(LeyhomeTheme.Fonts.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LeyhomeTheme.Spacing.md)
                        .background(Color.red.opacity(0.12))
                        .foregroundColor(.red)
                        .cornerRadius(LeyhomeTheme.CornerRadius.md)
                    }
                    .padding(.horizontal, LeyhomeTheme.Spacing.lg)
                    .padding(.top, LeyhomeTheme.Spacing.lg)

                    // 删除账户按钮
                    Button {
                        deleteConfirmText = ""
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            if isDeleting {
                                ProgressView()
                                    .tint(.red.opacity(0.4))
                            } else {
                                Image(systemName: "trash")
                            }
                            Text("settings.delete_account".localized)
                        }
                        .font(LeyhomeTheme.Fonts.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LeyhomeTheme.Spacing.md)
                        .foregroundColor(.red.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.md)
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .disabled(isDeleting)
                    .padding(.horizontal, LeyhomeTheme.Spacing.lg)
                    .padding(.top, LeyhomeTheme.Spacing.sm)

                    // 版本信息
                    Text("Leyhome v1.0.0")
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.primary.opacity(0.5))
                        .padding(.vertical, LeyhomeTheme.Spacing.md)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
            .navigationDestination(isPresented: $showMoodHistory) {
                MoodHistoryView()
            }
            .alert("sign_out.confirm_title".localized, isPresented: $showSignOutConfirmation) {
                Button("button.sign_out".localized, role: .destructive) {
                    Task {
                        await authManager.signOut()
                    }
                }
                Button("common.cancel".localized, role: .cancel) {}
            } message: {
                Text("sign_out.confirm_message".localized)
            }
            .alert("settings.delete_confirm_title".localized, isPresented: $showDeleteConfirmation) {
                TextField("settings.delete_confirm_placeholder".localized, text: $deleteConfirmText)
                Button("settings.delete_confirm_button".localized, role: .destructive) {
                    Task {
                        await performDeleteAccount()
                    }
                }
                .disabled(deleteConfirmText != "settings.delete_confirm_keyword".localized)
                Button("common.cancel".localized, role: .cancel) {}
            } message: {
                Text("settings.delete_confirm_message".localized)
            }
            .alert("settings.delete_error_title".localized, isPresented: $showDeleteError) {
                Button("common.ok".localized, role: .cancel) {}
            } message: {
                Text(deleteErrorMessage)
            }
        }
        .id(languageManager.currentLanguage)
    }

    private func performDeleteAccount() async {
        isDeleting = true
        do {
            try await authManager.deleteAccount()
        } catch {
            deleteErrorMessage = error.localizedDescription
            showDeleteError = true
        }
        isDeleting = false
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
    ProfileView(selectedTab: .constant(4))
}
