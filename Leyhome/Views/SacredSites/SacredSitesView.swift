//
//  SacredSitesView.swift
//  Leyhome - 地脉归途
//
//  圣迹视图 - 星脉图 / 列表切换
//
//  Created on 2026/01/26.
//  Rewritten on 2026/01/30: Day 6 完整圣迹系统
//

import SwiftUI

struct SacredSitesView: View {
    @State private var sites: [SacredSite] = []
    @State private var viewMode: SacredViewMode = .starMap
    @State private var showSubmission = false

    enum SacredViewMode: String, CaseIterable {
        case starMap = "star_map"
        case list = "list"

        var icon: String {
            switch self {
            case .starMap: return "globe.americas.fill"
            case .list: return "list.bullet"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // 星脉图背景（暗色）
                if viewMode == .starMap {
                    Color(hex: "0a0a1a").ignoresSafeArea()
                } else {
                    LeyhomeTheme.Background.primary.ignoresSafeArea()
                }

                VStack(spacing: 0) {
                    // 顶部标题栏
                    headerBar

                    // 内容区
                    switch viewMode {
                    case .starMap:
                        StarMapView(sites: sites)
                    case .list:
                        SacredSiteListView(sites: sites)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if sites.isEmpty {
                    sites = SacredSiteData.loadAllSites()
                }
            }
            .sheet(isPresented: $showSubmission) {
                SiteSubmissionView()
            }
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Text("tab.sacred_sites".localized)
                .font(LeyhomeTheme.Fonts.headline)
                .foregroundColor(viewMode == .starMap ? .white : LeyhomeTheme.textPrimary)

            Spacer()

            // 申请圣迹
            Button {
                showSubmission = true
            } label: {
                Image(systemName: "plus.circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(viewMode == .starMap ? .white.opacity(0.8) : LeyhomeTheme.primary)
            }
            .padding(.trailing, LeyhomeTheme.Spacing.sm)

            // 视图切换
            HStack(spacing: 0) {
                ForEach(SacredViewMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewMode = mode
                        }
                    } label: {
                        Image(systemName: mode.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(viewMode == mode ? .white : (viewMode == .starMap ? .white.opacity(0.5) : LeyhomeTheme.textMuted))
                            .frame(width: 36, height: 32)
                            .background(viewMode == mode ? LeyhomeTheme.primary : Color.clear)
                            .cornerRadius(6)
                    }
                }
            }
            .padding(2)
            .background(viewMode == .starMap ? Color.white.opacity(0.1) : Color(.systemGray5))
            .cornerRadius(8)
        }
        .padding(.horizontal, LeyhomeTheme.Spacing.md)
        .padding(.vertical, LeyhomeTheme.Spacing.sm)
    }
}

// MARK: - Preview

#Preview {
    SacredSitesView()
}
