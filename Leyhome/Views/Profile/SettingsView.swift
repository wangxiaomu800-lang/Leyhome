//
//  SettingsView.swift
//  Leyhome - 地脉归途
//
//  设置页面
//
//  Created on 2026/01/28.
//

import SwiftUI
import Supabase

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirmation = false
    @State private var deleteConfirmText = ""
    @State private var isDeleting = false
    @State private var showDeleteError = false
    @State private var deleteErrorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LeyhomeTheme.Background.primary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LeyhomeTheme.Spacing.lg) {
                        // 账号设置
                        SettingsSection(title: "settings.account".localized) {
                            SettingsRow(
                                icon: "person.circle",
                                title: "settings.account_info".localized,
                                value: authManager.currentUser?.email ?? "settings.not_logged_in".localized
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "lock",
                                title: "settings.change_password".localized,
                                showChevron: true
                            )
                        }

                        // 通用设置
                        SettingsSection(title: "settings.general".localized) {
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

                                Text("settings.language".localized)
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
                                title: "settings.notifications".localized,
                                subtitle: "settings.notifications_subtitle".localized,
                                showChevron: true
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "location",
                                title: "settings.location_services".localized,
                                subtitle: "settings.location_subtitle".localized,
                                showChevron: true
                            )
                        }

                        // 隐私与安全
                        SettingsSection(title: "settings.privacy_security".localized) {
                            SettingsRow(
                                icon: "hand.raised",
                                title: "settings.privacy_policy".localized,
                                showChevron: true
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "doc.text",
                                title: "settings.terms_of_service".localized,
                                showChevron: true
                            )
                        }

                        // 关于
                        SettingsSection(title: "settings.about".localized) {
                            SettingsRow(
                                icon: "info.circle",
                                title: "settings.version".localized,
                                value: "1.0.0"
                            )

                            Divider()
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "questionmark.circle",
                                title: "settings.help_feedback".localized,
                                showChevron: true
                            )
                        }

                        // 危险区域
                        SettingsSection(title: "settings.danger_zone".localized) {
                            Button {
                                deleteConfirmText = ""
                                showDeleteConfirmation = true
                            } label: {
                                HStack(spacing: LeyhomeTheme.Spacing.md) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red.opacity(0.1))
                                            .frame(width: 44, height: 44)

                                        if isDeleting {
                                            ProgressView()
                                                .tint(.red)
                                        } else {
                                            Image(systemName: "trash")
                                                .font(.system(size: 18))
                                                .foregroundColor(.red)
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("settings.delete_account".localized)
                                            .font(LeyhomeTheme.Fonts.body)
                                            .foregroundColor(.red)

                                        Text("settings.delete_account_subtitle".localized)
                                            .font(LeyhomeTheme.Fonts.caption)
                                            .foregroundColor(LeyhomeTheme.textSecondary)
                                    }

                                    Spacer()
                                }
                                .padding(LeyhomeTheme.Spacing.md)
                            }
                            .disabled(isDeleting)
                        }

                        // 底部间距
                        Color.clear.frame(height: LeyhomeTheme.Spacing.xl)
                    }
                    .padding(.top, LeyhomeTheme.Spacing.md)
                }
            }
            .navigationTitle("settings.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("settings.done".localized) {
                        dismiss()
                    }
                    .foregroundColor(LeyhomeTheme.accent)
                }
            }
            .id(languageManager.currentLanguage)
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
