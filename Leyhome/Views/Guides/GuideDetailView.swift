//
//  GuideDetailView.swift
//  Leyhome - 地脉归途
//
//  先行者详情页 + 星图列表
//
//  Created on 2026/02/04.
//

import SwiftUI

struct GuideDetailView: View {
    let guide: Guide
    @State private var constellations: [Constellation] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 头部背景
                ZStack(alignment: .bottom) {
                    AsyncImage(url: URL(string: guide.coverImageUrl ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        LinearGradient(
                            colors: [LeyhomeTheme.primary, LeyhomeTheme.starlight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    .frame(height: 200)
                    .clipped()

                    // 渐变遮罩
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

                // 头像和信息（悬浮效果）
                VStack(spacing: LeyhomeTheme.Spacing.md) {
                    AsyncImage(url: URL(string: guide.avatarUrl ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle().fill(Color(.systemGray6))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title)
                                    .foregroundColor(Color(.systemGray3))
                            )
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 4))
                    .shadow(radius: 5)
                    .offset(y: -50)

                    VStack(spacing: 4) {
                        HStack {
                            Text(guide.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            if guide.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(LeyhomeTheme.accent)
                            }
                        }

                        Text(guide.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .offset(y: -40)

                    Text(guide.bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .offset(y: -30)
                }
                .padding(.bottom, -30)

                // 星图列表
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
                    Text("guides.constellations".localized)
                        .font(.headline)
                        .padding(.horizontal)

                    if constellations.isEmpty {
                        Text("guides.no_constellations".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(constellations) { constellation in
                            NavigationLink(destination: ConstellationDetailView(constellation: constellation, guide: guide)) {
                                ConstellationCard(constellation: constellation)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            constellations = GuideData.loadConstellations(for: guide)
        }
    }
}

// MARK: - ConstellationCard

struct ConstellationCard: View {
    let constellation: Constellation

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            // 封面图
            AsyncImage(url: URL(string: constellation.coverImageUrl ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(LeyhomeTheme.starlight.opacity(0.3))
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundColor(LeyhomeTheme.starlight)
                    )
            }
            .frame(height: 150)
            .clipped()
            .cornerRadius(LeyhomeTheme.CornerRadius.sm)

            // 信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(constellation.name)
                        .font(.headline)

                    Spacer()

                    if constellation.isPremium {
                        Label("Premium", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }

                Text(constellation.constellationDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // 统计
                HStack(spacing: LeyhomeTheme.Spacing.md) {
                    Label(String(format: "%.1f km", constellation.totalDistance), systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    Label(String(format: "%.0f h", constellation.estimatedHours), systemImage: "clock")
                    Label("\(constellation.resonanceCount)", systemImage: "person.2")

                    Spacer()

                    // 难度
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: i <= constellation.difficulty ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(i <= constellation.difficulty ? LeyhomeTheme.accent : .gray)
                        }
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
