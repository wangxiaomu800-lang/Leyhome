//
//  SacredSiteDetailView.swift
//  Leyhome - 地脉归途
//
//  圣迹详情页 - 沉浸式头图、地脉解读、历史传说、统计、操作按钮
//
//  Created on 2026/01/30.
//  Updated on 2026/02/03: 向往按钮接入 AspiredSitesManager
//  Updated on 2026/02/03: Day 7 - 集成回响系统和意向系统
//

import SwiftUI

struct SacredSiteDetailView: View {
    let site: SacredSite
    @State private var showJourneyPlanner = false
    @State private var showIntentionSheet = false
    @StateObject private var aspiredManager = AspiredSitesManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    heroSection

                    VStack(spacing: LeyhomeTheme.Spacing.lg) {
                        loreSection

                        if let history = site.history, !history.isEmpty {
                            historySection(history)
                        }

                        statsSection

                        echoesSection

                        actionButtons
                    }
                    .padding(LeyhomeTheme.Spacing.md)
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .sheet(isPresented: $showJourneyPlanner) {
                JourneyPlannerView(site: site)
            }
            .sheet(isPresented: $showIntentionSheet) {
                IntentionSheet(site: site)
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [site.siteTier.color, LeyhomeTheme.primary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 300)

            if site.siteTier == .primal {
                Canvas { context, size in
                    for _ in 0..<30 {
                        let x = CGFloat.random(in: 0...size.width)
                        let y = CGFloat.random(in: 0...size.height)
                        let starSize = CGFloat.random(in: 1...2.5)
                        let rect = CGRect(x: x, y: y, width: starSize, height: starSize)
                        context.fill(Circle().path(in: rect), with: .color(.white.opacity(Double.random(in: 0.3...0.8))))
                    }
                }
                .frame(height: 300)
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 300)

            VStack(alignment: .leading, spacing: 8) {
                Text(site.siteTier.localizedName)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(site.siteTier.color)
                    .cornerRadius(4)

                Text(site.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                    Text(site.country)
                    if let region = site.region, !region.isEmpty {
                        Text("·")
                        Text(region)
                    }
                }
                .font(LeyhomeTheme.Fonts.bodySmall)
                .foregroundColor(.white.opacity(0.8))
            }
            .padding(LeyhomeTheme.Spacing.lg)
        }
    }

    // MARK: - Lore Section

    private var loreSection: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            HStack {
                Image(systemName: "book.closed.fill")
                    .foregroundColor(site.siteTier.color)
                Text("sacred.lore".localized)
                    .font(LeyhomeTheme.Fonts.headline)
                    .foregroundColor(LeyhomeTheme.textPrimary)
            }

            Text(site.lore)
                .font(LeyhomeTheme.Fonts.body)
                .foregroundColor(LeyhomeTheme.textSecondary)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(LeyhomeTheme.Spacing.md)
        .background(site.siteTier.color.opacity(0.08))
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
    }

    // MARK: - History Section

    private func historySection(_ history: String) -> some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            HStack {
                Image(systemName: "scroll.fill")
                    .foregroundColor(LeyhomeTheme.accent)
                Text("sacred.history".localized)
                    .font(LeyhomeTheme.Fonts.headline)
                    .foregroundColor(LeyhomeTheme.textPrimary)
            }

            Text(history)
                .font(LeyhomeTheme.Fonts.body)
                .foregroundColor(LeyhomeTheme.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: LeyhomeTheme.Spacing.lg) {
            SacredStatView(value: "\(site.visitorCount)", label: "sacred.visitors".localized, icon: "person.2.fill")
            SacredStatView(value: "\(site.echoCount)", label: "sacred.echoes".localized, icon: "bubble.left.fill")
            SacredStatView(value: "\(site.intentionCount)", label: "sacred.intentions".localized, icon: "heart.fill")
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color(.systemGray6))
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
    }

    // MARK: - Echoes Section

    private var echoesSection: some View {
        EchoesSection(site: site)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            // Plan journey
            Button {
                showJourneyPlanner = true
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                    Text("sacred.plan_journey".localized)
                }
                .leyhomePrimaryButton()
                .frame(maxWidth: .infinity)
            }

            // Aspire button - opens IntentionSheet or removes aspiration
            Button {
                if aspiredManager.isAspired(site) {
                    // Already aspired: directly toggle off
                    aspiredManager.toggleAspire(site)
                    site.intentionCount = max(0, site.intentionCount - 1)
                    site.updatedAt = Date()
                } else {
                    // Not aspired: show IntentionSheet
                    showIntentionSheet = true
                }
            } label: {
                HStack {
                    Image(systemName: aspiredManager.isAspired(site) ? "heart.fill" : "heart")
                    Text(aspiredManager.isAspired(site) ? "intention.aspired".localized : "intention.aspire".localized)
                }
                .leyhomeSecondaryButton()
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, LeyhomeTheme.Spacing.lg)
    }
}

// MARK: - SacredStatView

struct SacredStatView: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(LeyhomeTheme.primary)

            Text(value)
                .font(LeyhomeTheme.Fonts.titleSmall)
                .foregroundColor(LeyhomeTheme.primary)

            Text(label)
                .font(LeyhomeTheme.Fonts.caption)
                .foregroundColor(LeyhomeTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    let site = SacredSiteData.loadAllSites().first!
    SacredSiteDetailView(site: site)
}
