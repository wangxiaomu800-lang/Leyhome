//
//  GuidesView.swift
//  Leyhome - 地脉归途
//
//  引路视图 - 展示先行者列表
//
//  Created on 2026/01/26.
//  Rewritten on 2026/02/04: Day 8 完整先行者列表
//

import SwiftUI
import SwiftData

struct GuidesView: View {
    @State private var guides: [Guide] = []
    @State private var showApplicationSheet = false

    /// 查询当前用户的申请
    @Query(sort: \GuideApplication.createdAt, order: .reverse) private var applications: [GuideApplication]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    // 顶部介绍区
                    VStack(spacing: LeyhomeTheme.Spacing.sm) {
                        Text("guides.intro.title".localized)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("guides.intro.subtitle".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    // 先行者卡片列表
                    LazyVStack(spacing: LeyhomeTheme.Spacing.md) {
                        ForEach(guides) { guide in
                            NavigationLink(destination: GuideDetailView(guide: guide)) {
                                GuideCard(guide: guide)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)

                    // 申请成为先行者
                    applySection
                        .padding(.horizontal)
                        .padding(.top, LeyhomeTheme.Spacing.lg)
                        .padding(.bottom, LeyhomeTheme.Spacing.xxl)
                }
            }
            .background(LeyhomeTheme.Background.primary)
            .navigationTitle("tab.guides".localized)
            .onAppear {
                guides = GuideData.loadAllGuides()
            }
            .sheet(isPresented: $showApplicationSheet) {
                GuideApplicationView()
            }
        }
    }

    // MARK: - 申请区域

    private var applySection: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            // 分隔线
            HStack {
                Rectangle()
                    .fill(LeyhomeTheme.textMuted.opacity(0.3))
                    .frame(height: 1)
                Text("guide.apply.divider".localized)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(LeyhomeTheme.textMuted)
                Rectangle()
                    .fill(LeyhomeTheme.textMuted.opacity(0.3))
                    .frame(height: 1)
            }

            // 检查是否有待审核申请
            if let pendingApp = applications.first(where: { $0.status == .pending }) {
                // 已有申请，显示状态
                VStack(spacing: LeyhomeTheme.Spacing.sm) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 28))
                        .foregroundColor(LeyhomeTheme.accent)

                    Text("guide.apply.pending.title".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    Text("guide.apply.pending.message".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                        .multilineTextAlignment(.center)

                    Text("guide.apply.submitted_at".localized(with: formattedDate(pendingApp.createdAt)))
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textMuted)
                }
                .padding(LeyhomeTheme.Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(LeyhomeTheme.accent.opacity(0.1))
                .cornerRadius(LeyhomeTheme.CornerRadius.md)
            } else {
                // 无申请，显示申请按钮
                VStack(spacing: LeyhomeTheme.Spacing.sm) {
                    Text("guide.apply.cta.title".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    Text("guide.apply.cta.subtitle".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                        .multilineTextAlignment(.center)

                    Button {
                        showApplicationSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("guide.apply.button".localized)
                        }
                        .font(LeyhomeTheme.Fonts.button)
                        .foregroundColor(.white)
                        .padding(.horizontal, LeyhomeTheme.Spacing.xl)
                        .padding(.vertical, LeyhomeTheme.Spacing.md)
                        .background(LeyhomeTheme.primary)
                        .cornerRadius(LeyhomeTheme.CornerRadius.lg)
                    }
                }
                .padding(LeyhomeTheme.Spacing.lg)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - GuideCard

struct GuideCard: View {
    let guide: Guide

    var body: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            // 头像
            AsyncImage(url: URL(string: guide.avatarUrl ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(LeyhomeTheme.primary.opacity(0.2))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(LeyhomeTheme.primary.opacity(0.5))
                    )
            }
            .frame(width: 70, height: 70)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(LeyhomeTheme.accent, lineWidth: guide.isVerified ? 2 : 0)
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(guide.name)
                        .font(.headline)

                    if guide.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(LeyhomeTheme.accent)
                    }
                }

                Text(guide.title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                // 标签
                HStack(spacing: 4) {
                    ForEach(guide.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(LeyhomeTheme.primary.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    GuidesView()
}
