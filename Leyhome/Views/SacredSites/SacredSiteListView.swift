//
//  SacredSiteListView.swift
//  Leyhome - 地脉归途
//
//  圣迹列表视图 - 按大洲分组、筛选、搜索、向往筛选
//
//  Created on 2026/01/30.
//  Updated on 2026/02/03: 增加「我亦向往」筛选
//

import SwiftUI

// MARK: - SiteFilterMode

enum SiteFilterMode: Equatable {
    case all
    case tier(SiteTier)
    case aspired
}

struct SacredSiteListView: View {
    let sites: [SacredSite]

    @State private var searchText = ""
    @State private var filterMode: SiteFilterMode = .all
    @StateObject private var aspiredManager = AspiredSitesManager.shared

    var body: some View {
        List {
            // Filter bar
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "sacred.all".localized,
                            isSelected: filterMode == .all
                        ) {
                            filterMode = .all
                        }

                        ForEach(SiteTier.allCases, id: \.self) { tier in
                            FilterChip(
                                title: tier.localizedName,
                                isSelected: filterMode == .tier(tier),
                                color: tier.color
                            ) {
                                filterMode = filterMode == .tier(tier) ? .all : .tier(tier)
                            }
                        }

                        // Aspired filter
                        FilterChip(
                            title: "sacred.aspired".localized,
                            isSelected: filterMode == .aspired,
                            color: Color.pink
                        ) {
                            filterMode = filterMode == .aspired ? .all : .aspired
                        }
                    }
                    .padding(.vertical, LeyhomeTheme.Spacing.xs)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            // Grouped sites
            ForEach(groupedSites.keys.sorted(), id: \.self) { groupKey in
                Section(header: Text(groupKey)) {
                    ForEach(groupedSites[groupKey] ?? []) { site in
                        NavigationLink(destination: SacredSiteDetailView(site: site)) {
                            SiteRowView(site: site)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "sacred.search".localized)
    }

    private var filteredSites: [SacredSite] {
        var result = sites

        switch filterMode {
        case .all:
            break
        case .tier(let tier):
            result = result.filter { $0.siteTier == tier }
        case .aspired:
            result = result.filter { aspiredManager.isAspired($0) }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.country.localizedCaseInsensitiveContains(searchText) ||
                ($0.region ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    private var groupedSites: [String: [SacredSite]] {
        switch filterMode {
        case .aspired:
            return Dictionary(grouping: filteredSites) { $0.siteTier.localizedName }
        default:
            return Dictionary(grouping: filteredSites) { $0.continent }
        }
    }
}

// MARK: - SiteRowView

struct SiteRowView: View {
    let site: SacredSite

    var body: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            // Tier icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(site.siteTier.color.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: site.siteTier == .primal ? "sparkles" : site.siteTier == .leyNode ? "diamond.fill" : "drop.fill")
                    .font(.system(size: 20))
                    .foregroundColor(site.siteTier.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(site.name)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    if site.siteTier == .primal {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(LeyhomeTheme.SacredSite.tier1)
                    }
                }

                Text(site.country + (site.region != nil ? " · \(site.region!)" : ""))
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(LeyhomeTheme.textSecondary)

                HStack(spacing: LeyhomeTheme.Spacing.sm) {
                    Label("\(site.visitorCount)", systemImage: "person.2")
                    Label("\(site.echoCount)", systemImage: "bubble.left")
                }
                .font(.caption2)
                .foregroundColor(LeyhomeTheme.textMuted)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = LeyhomeTheme.primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LeyhomeTheme.Fonts.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color.gray.opacity(0.15))
                .foregroundColor(isSelected ? .white : LeyhomeTheme.textPrimary)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SacredSiteListView(sites: SacredSiteData.loadAllSites())
    }
}
