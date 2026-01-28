//
//  SettingsView.swift
//  Leyhome - 地脉归途
//
//  设置页面
//
//  Created on 2026/01/28.
//

import SwiftUI
import Auth

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LeyhomeTheme.Background.primary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LeyhomeTheme.Spacing.lg) {
                        // 账号设置
                        SettingsSection(title: "账号") {
                            SettingsRow(
                                icon: "person.circle",
                                title: "账号信息",
                                value: authManager.currentUser?.email ?? "未登录"
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "lock",
                                title: "修改密码",
                                showChevron: true
                            )
                        }

                        // 通用设置
                        SettingsSection(title: "通用") {
                            // 语言选择
                            HStack(spacing: LeyhomeTheme.Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(LeyhomeTheme.accent.opacity(0.1))
                                        .frame(width: 44, height: 44)

                                    Image(systemName: "globe")
                                        .font(.system(size: 18))
                                        .foregroundColor(LeyhomeTheme.accent)
                                }

                                Text("语言")
                                    .font(LeyhomeTheme.Fonts.body)
                                    .foregroundColor(LeyhomeTheme.textPrimary)

                                Spacer()

                                Picker("", selection: $languageManager.currentLanguage) {
                                    ForEach(AppLanguage.allCases, id: \.self) { language in
                                        Text(language.displayName).tag(language)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(LeyhomeTheme.accent)
                            }
                            .padding(LeyhomeTheme.Spacing.md)

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "bell",
                                title: "通知",
                                subtitle: "推送通知设置",
                                showChevron: true
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "location",
                                title: "定位服务",
                                subtitle: "位置权限管理",
                                showChevron: true
                            )
                        }

                        // 隐私与安全
                        SettingsSection(title: "隐私与安全") {
                            SettingsRow(
                                icon: "hand.raised",
                                title: "隐私政策",
                                showChevron: true
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "doc.text",
                                title: "服务条款",
                                showChevron: true
                            )
                        }

                        // 关于
                        SettingsSection(title: "关于") {
                            SettingsRow(
                                icon: "info.circle",
                                title: "版本",
                                value: "1.0.0"
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "questionmark.circle",
                                title: "帮助与反馈",
                                showChevron: true
                            )
                        }

                        // 底部间距
                        Color.clear.frame(height: LeyhomeTheme.Spacing.xl)
                    }
                    .padding(.top, LeyhomeTheme.Spacing.md)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(LeyhomeTheme.accent)
                }
            }
        }
    }
}

// MARK: - 设置区块组件
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            Text(title)
                .font(LeyhomeTheme.Fonts.caption)
                .foregroundColor(LeyhomeTheme.textSecondary)
                .padding(.horizontal, LeyhomeTheme.Spacing.lg)

            VStack(spacing: 0) {
                content
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
        }
    }
}

// MARK: - 设置行组件
struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    var showChevron: Bool = false

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

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                }
            }

            Spacer()

            // 右侧内容
            if let value = value {
                Text(value)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(LeyhomeTheme.textSecondary)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(LeyhomeTheme.textMuted)
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
    }
}

#Preview {
    SettingsView()
}
