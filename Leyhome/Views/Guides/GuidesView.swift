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

struct GuidesView: View {
    @State private var guides: [Guide] = []

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
                }
            }
            .background(LeyhomeTheme.Background.primary)
            .navigationTitle("tab.guides".localized)
            .onAppear {
                guides = GuideData.loadAllGuides()
            }
        }
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
