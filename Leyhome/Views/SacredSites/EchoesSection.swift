//
//  EchoesSection.swift
//  Leyhome - 地脉归途
//
//  回响列表组件 - 嵌入圣迹详情页，展示公开回响和我的回响
//
//  Created on 2026/02/03.
//  Updated on 2026/02/03: 添加回响定位限制检查
//

import SwiftUI
import SwiftData
import Supabase
import CoreLocation

struct EchoesSection: View {
    let site: SacredSite

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var trackingManager = TrackingManager.shared

    @Query private var allEchoes: [Echo]
    @Query private var visitedLocations: [VisitedLocation]
    @State private var selectedTab = 0  // 0 = 公开, 1 = 我的
    @State private var showComposer = false
    @State private var showDistanceAlert = false
    @State private var currentDistance: Double = 0

    init(site: SacredSite) {
        self.site = site
        // Query echoes for this site
        let siteId = site.id
        let predicate = #Predicate<Echo> { echo in
            echo.siteId == siteId
        }
        _allEchoes = Query(filter: predicate, sort: [SortDescriptor(\.createdAt, order: .reverse)])
    }

    private var currentUserId: String {
        authManager.currentUser?.id.uuidString ?? ""
    }

    /// 检查用户是否曾到访过该圣迹
    private var hasVisited: Bool {
        let userId = currentUserId
        let siteId = site.id
        return visitedLocations.contains { visited in
            visited.siteId == siteId && visited.userId == userId
        }
    }

    /// 获取到达圣迹所需的距离阈值
    private var requiredDistance: Double {
        EchoDistanceThreshold.threshold(for: site)
    }

    /// 格式化的距离阈值
    private var formattedRequiredDistance: String {
        EchoDistanceThreshold.formatDistance(requiredDistance)
    }

    /// 格式化的当前距离
    private var formattedCurrentDistance: String {
        EchoDistanceThreshold.formatDistance(currentDistance)
    }

    private var publicEchoes: [Echo] {
        allEchoes.filter { $0.isPublic }
    }

    private var myEchoes: [Echo] {
        allEchoes.filter { $0.userId == currentUserId }
    }

    private var filteredEchoes: [Echo] {
        selectedTab == 0 ? publicEchoes : myEchoes
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            headerSection
            tabPicker
            echoesContent
            leaveEchoButton
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color(.systemGray6))
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .sheet(isPresented: $showComposer) {
            EchoComposerView(siteId: site.id) { echo in
                saveEcho(echo)
            }
        }
        .alert("echo.distance_required".localized, isPresented: $showDistanceAlert) {
            Button("button.confirm".localized, role: .cancel) {}
        } message: {
            Text(String(format: "echo.distance_message".localized, formattedCurrentDistance, formattedRequiredDistance))
        }
        .onAppear {
            calculateCurrentDistance()
        }
    }

    /// 计算当前到圣迹的距离
    private func calculateCurrentDistance() {
        guard let location = trackingManager.currentLocation else { return }
        let siteLocation = CLLocation(latitude: site.latitude, longitude: site.longitude)
        currentDistance = location.distance(from: siteLocation)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .foregroundColor(LeyhomeTheme.starlight)
            Text("echo.title".localized)
                .font(LeyhomeTheme.Fonts.headline)
                .foregroundColor(LeyhomeTheme.textPrimary)
        }
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack(spacing: 0) {
            tabButton(title: "echo.public".localized, index: 0, count: publicEchoes.count)
            tabButton(title: "echo.mine".localized, index: 1, count: myEchoes.count)
        }
        .background(Color(.systemGray5))
        .cornerRadius(LeyhomeTheme.CornerRadius.sm)
    }

    private func tabButton(title: String, index: Int, count: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            HStack(spacing: 4) {
                Text(title)
                if count > 0 {
                    Text("(\(count))")
                        .font(LeyhomeTheme.Fonts.caption)
                }
            }
            .font(LeyhomeTheme.Fonts.bodySmall)
            .foregroundColor(selectedTab == index ? .white : LeyhomeTheme.textSecondary)
            .padding(.horizontal, LeyhomeTheme.Spacing.md)
            .padding(.vertical, LeyhomeTheme.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(selectedTab == index ? LeyhomeTheme.primary : Color.clear)
            .cornerRadius(LeyhomeTheme.CornerRadius.sm)
        }
    }

    // MARK: - Echoes Content

    @ViewBuilder
    private var echoesContent: some View {
        if filteredEchoes.isEmpty {
            emptyState
        } else {
            VStack(spacing: LeyhomeTheme.Spacing.sm) {
                ForEach(filteredEchoes) { echo in
                    EchoCard(echo: echo)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: LeyhomeTheme.Spacing.sm) {
            Image(systemName: "bubble.left.and.text.bubble.right")
                .font(.system(size: 32))
                .foregroundColor(LeyhomeTheme.textMuted)

            Text("echo.empty".localized)
                .font(LeyhomeTheme.Fonts.bodySmall)
                .foregroundColor(LeyhomeTheme.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LeyhomeTheme.Spacing.xl)
    }

    // MARK: - Leave Echo Button

    private var leaveEchoButton: some View {
        Button {
            if hasVisited {
                showComposer = true
            } else {
                calculateCurrentDistance()
                showDistanceAlert = true
            }
        } label: {
            HStack {
                Image(systemName: "plus.bubble")
                Text("echo.leave".localized)
            }
            .font(LeyhomeTheme.Fonts.button)
            .foregroundColor(LeyhomeTheme.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, LeyhomeTheme.Spacing.sm)
            .background(Color(.systemBackground))
            .cornerRadius(LeyhomeTheme.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.sm)
                    .stroke(LeyhomeTheme.primary.opacity(0.5), lineWidth: 1)
            )
        }
    }

    // MARK: - Actions

    private func saveEcho(_ echo: Echo) {
        modelContext.insert(echo)
        try? modelContext.save()
    }
}

// MARK: - EchoCard

struct EchoCard: View {
    let echo: Echo

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            // Header: Avatar + Name + Time
            HStack(spacing: LeyhomeTheme.Spacing.sm) {
                // Avatar
                Circle()
                    .fill(LeyhomeTheme.primary.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(echo.displayName.prefix(1)))
                            .font(LeyhomeTheme.Fonts.bodySmall)
                            .foregroundColor(LeyhomeTheme.primary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(echo.displayName)
                        .font(LeyhomeTheme.Fonts.bodySmall)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    Text(echo.formattedDate)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textMuted)
                }

                Spacer()

                // Privacy indicator
                if !echo.isPublic {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(LeyhomeTheme.textMuted)
                }
            }

            // Content
            Text(echo.content)
                .font(LeyhomeTheme.Fonts.body)
                .foregroundColor(LeyhomeTheme.textPrimary)
                .lineSpacing(4)

            // Media preview (if any)
            if !echo.mediaUrls.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: LeyhomeTheme.Spacing.xs) {
                        ForEach(echo.mediaUrls, id: \.self) { url in
                            AsyncImage(url: URL(string: url)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    Color.gray.opacity(0.3)
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.xs))
                        }
                    }
                }
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(LeyhomeTheme.CornerRadius.sm)
    }
}

// MARK: - Preview

#Preview {
    let site = SacredSite(tier: .leyNode, nameZh: "测试圣迹", nameEn: "Test Site")
    return EchoesSection(site: site)
        .environmentObject(AuthManager())
        .padding()
}
