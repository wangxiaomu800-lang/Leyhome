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
import SafariServices

// MARK: - App 内 Safari 浏览器
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var safariURL: URL?
    @State private var showVersionSheet = false
    @State private var showHelpActionSheet = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

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

                            // 定位服务 → 跳转系统设置
                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                SettingsRow(
                                    icon: "location",
                                    title: "settings.location_services".localized,
                                    subtitle: "settings.location_subtitle".localized,
                                    showChevron: true
                                )
                            }
                        }

                        // 隐私与安全
                        SettingsSection(title: "settings.privacy_security".localized) {
                            Button {
                                safariURL = URL(string: "https://wangxiaomu800-lang.github.io/Leyhome-support/privacy.html")
                            } label: {
                                SettingsRow(
                                    icon: "hand.raised",
                                    title: "settings.privacy_policy".localized,
                                    showChevron: true
                                )
                            }

                            Divider()
                                .padding(.leading, 60)

                            Button {
                                safariURL = URL(string: "https://wangxiaomu800-lang.github.io/Leyhome-support/")
                            } label: {
                                SettingsRow(
                                    icon: "wrench.and.screwdriver",
                                    title: "settings.tech_support".localized,
                                    showChevron: true
                                )
                            }
                        }

                        // 关于
                        SettingsSection(title: "settings.about".localized) {
                            // 版本 → 弹出版本详情 Sheet
                            Button {
                                showVersionSheet = true
                            } label: {
                                SettingsRow(
                                    icon: "info.circle",
                                    title: "settings.version".localized,
                                    value: appVersion
                                )
                            }

                            Divider()
                                .padding(.leading, 60)

                            // 帮助与反馈 → 弹出选择菜单
                            Button {
                                showHelpActionSheet = true
                            } label: {
                                SettingsRow(
                                    icon: "questionmark.circle",
                                    title: "settings.help_feedback".localized,
                                    showChevron: true
                                )
                            }
                            .confirmationDialog(
                                "settings.help_feedback".localized,
                                isPresented: $showHelpActionSheet,
                                titleVisibility: .visible
                            ) {
                                Button("settings.help_docs".localized) {
                                    safariURL = URL(string: "https://wangxiaomu800-lang.github.io/Leyhome-support/")
                                }
                                Button("settings.send_feedback".localized) {
                                    let subject = "Leyhome Feedback v\(appVersion)"
                                    if let encoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                       let url = URL(string: "mailto:wangxiaomu800@gmail.com?subject=\(encoded)") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                Button("settings.cancel".localized, role: .cancel) {}
                            }
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
            .sheet(item: $safariURL) { url in
                SafariView(url: url)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showVersionSheet) {
                VersionSheetView(appVersion: appVersion, buildNumber: buildNumber)
            }
        }
    }
}

// MARK: - 版本详情 Sheet
struct VersionSheetView: View {
    let appVersion: String
    let buildNumber: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LeyhomeTheme.Background.primary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LeyhomeTheme.Spacing.xl) {
                        Spacer().frame(height: LeyhomeTheme.Spacing.lg)

                        // App 图标
                        if let uiImage = UIImage(named: "AppIcon") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(
                                    color: LeyhomeTheme.Shadow.light.color,
                                    radius: LeyhomeTheme.Shadow.light.radius,
                                    x: LeyhomeTheme.Shadow.light.x,
                                    y: LeyhomeTheme.Shadow.light.y
                                )
                        } else {
                            Image(systemName: "app.fill")
                                .font(.system(size: 60))
                                .foregroundColor(LeyhomeTheme.accent)
                        }

                        // App 名称
                        Text("Leyhome")
                            .font(LeyhomeTheme.Fonts.title)
                            .foregroundColor(LeyhomeTheme.textPrimary)

                        // 版本号 + Build
                        VStack(spacing: LeyhomeTheme.Spacing.sm) {
                            HStack {
                                Text("settings.version_current".localized)
                                    .font(LeyhomeTheme.Fonts.body)
                                    .foregroundColor(LeyhomeTheme.textSecondary)
                                Spacer()
                                Text(appVersion)
                                    .font(LeyhomeTheme.Fonts.body)
                                    .foregroundColor(LeyhomeTheme.textPrimary)
                            }

                            Divider()

                            HStack {
                                Text("settings.version_build".localized)
                                    .font(LeyhomeTheme.Fonts.body)
                                    .foregroundColor(LeyhomeTheme.textSecondary)
                                Spacer()
                                Text(buildNumber)
                                    .font(LeyhomeTheme.Fonts.body)
                                    .foregroundColor(LeyhomeTheme.textPrimary)
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

                        // 更新日志
                        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                            Text("settings.version_changelog".localized)
                                .font(LeyhomeTheme.Fonts.headline)
                                .foregroundColor(LeyhomeTheme.textPrimary)

                            Text("settings.version_changelog_content".localized)
                                .font(LeyhomeTheme.Fonts.body)
                                .foregroundColor(LeyhomeTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
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
                    .padding(.horizontal, LeyhomeTheme.Spacing.lg)
                }
            }
            .navigationTitle("settings.version_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("settings.done".localized) {
                        dismiss()
                    }
                    .foregroundColor(LeyhomeTheme.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - URL Identifiable 扩展
extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
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
