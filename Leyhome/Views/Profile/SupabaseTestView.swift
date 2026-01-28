//
//  SupabaseTestView.swift
//  Leyhome
//
//  Created by Claude on 2026/1/26.
//

import SwiftUI
import Supabase

// MARK: - Supabase Client
let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://ovhzthwqsgmattginbet.supabase.co")!,
    supabaseKey: "sb_publishable_5Ir5dM1goNcVFBihT4mhww_BXhhfHG5"
)

// MARK: - Connection Status
enum ConnectionStatus {
    case idle
    case testing
    case success
    case failure
}

// MARK: - Supabase Test View
struct SupabaseTestView: View {
    @State private var status: ConnectionStatus = .idle
    @State private var logText: String = "点击「测试连接」按钮开始测试..."

    var body: some View {
        ZStack {
            LeyhomeTheme.background
                .ignoresSafeArea()

            VStack(spacing: LeyhomeTheme.Spacing.md) {
                // Status Icon (smaller)
                statusIcon
                    .padding(.top, LeyhomeTheme.Spacing.md)

                // Log Text Box (smaller height)
                ScrollView {
                    Text(logText)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(LeyhomeTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(LeyhomeTheme.Spacing.sm)
                }
                .frame(maxHeight: 180)
                .background(Color.white.opacity(0.6))
                .cornerRadius(LeyhomeTheme.CornerRadius.md)
                .padding(.horizontal, LeyhomeTheme.Spacing.lg)

                // Test Button
                Button(action: testConnection) {
                    HStack(spacing: LeyhomeTheme.Spacing.sm) {
                        if status == .testing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(status == .testing ? "测试中..." : "测试连接")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(status == .testing ? Color.gray : LeyhomeTheme.accent)
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
                }
                .disabled(status == .testing)
                .padding(.horizontal, LeyhomeTheme.Spacing.lg)
                .padding(.bottom, 100) // Extra padding for TabBar
            }
        }
        .navigationTitle("Supabase 测试")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Status Icon
    @ViewBuilder
    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(statusBackgroundColor.opacity(0.2))
                .frame(width: 80, height: 80)

            Circle()
                .fill(statusBackgroundColor.opacity(0.4))
                .frame(width: 50, height: 50)

            Image(systemName: statusIconName)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(statusIconColor)
        }
    }

    private var statusIconName: String {
        switch status {
        case .idle:
            return "questionmark.circle"
        case .testing:
            return "arrow.triangle.2.circlepath"
        case .success:
            return "checkmark.circle.fill"
        case .failure:
            return "exclamationmark.circle.fill"
        }
    }

    private var statusIconColor: Color {
        switch status {
        case .idle:
            return LeyhomeTheme.textSecondary
        case .testing:
            return LeyhomeTheme.accent
        case .success:
            return LeyhomeTheme.success
        case .failure:
            return LeyhomeTheme.danger
        }
    }

    private var statusBackgroundColor: Color {
        switch status {
        case .idle:
            return LeyhomeTheme.textSecondary
        case .testing:
            return LeyhomeTheme.accent
        case .success:
            return LeyhomeTheme.success
        case .failure:
            return LeyhomeTheme.danger
        }
    }

    // MARK: - Test Connection
    private func testConnection() {
        status = .testing
        logText = "[\(timestamp)] 开始测试 Supabase 连接...\n"
        logText += "[\(timestamp)] URL: https://ovhzthwqsgmattginbet.supabase.co\n"
        logText += "[\(timestamp)] 正在查询测试表...\n"

        Task {
            do {
                // 故意查询一个不存在的表来测试连接
                let _ = try await supabase
                    .from("non_existent_table")
                    .select()
                    .execute()

                // 如果没有抛出错误（不太可能），也算成功
                await MainActor.run {
                    status = .success
                    logText += "[\(timestamp)] ✅ 连接成功！\n"
                }
            } catch {
                await MainActor.run {
                    handleError(error)
                }
            }
        }
    }

    // MARK: - Handle Error
    private func handleError(_ error: Error) {
        let errorString = String(describing: error)
        logText += "[\(timestamp)] 收到服务器响应\n"
        logText += "[\(timestamp)] 错误详情: \(errorString)\n"

        // 检查错误类型来判断连接状态
        if errorString.contains("PGRST") ||
           errorString.contains("Could not find") ||
           errorString.contains("relation") && errorString.contains("does not exist") ||
           errorString.contains("404") ||
           errorString.contains("not found") {
            // 这些错误说明服务器已响应，连接成功
            status = .success
            logText += "[\(timestamp)] ✅ 连接成功（服务器已响应）\n"
            logText += "[\(timestamp)] 说明：表不存在是预期行为，这证明了与 Supabase 的连接正常\n"
        } else if errorString.contains("hostname") ||
                  errorString.contains("URL") ||
                  errorString.contains("NSURLErrorDomain") ||
                  errorString.contains("network") ||
                  errorString.contains("Internet") ||
                  errorString.contains("offline") {
            // 网络或 URL 错误
            status = .failure
            logText += "[\(timestamp)] ❌ 连接失败：URL 错误或无网络\n"
            logText += "[\(timestamp)] 请检查网络连接和 Supabase URL 配置\n"
        } else if errorString.contains("Invalid API key") ||
                  errorString.contains("apikey") ||
                  errorString.contains("unauthorized") ||
                  errorString.contains("401") {
            // API Key 错误
            status = .failure
            logText += "[\(timestamp)] ❌ 连接失败：API Key 无效\n"
            logText += "[\(timestamp)] 请检查 Supabase anon key 配置\n"
        } else {
            // 其他错误
            status = .failure
            logText += "[\(timestamp)] ❌ 未知错误\n"
            logText += "[\(timestamp)] 完整错误: \(error.localizedDescription)\n"
        }
    }

    // MARK: - Timestamp
    private var timestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}

#Preview {
    NavigationStack {
        SupabaseTestView()
    }
}
