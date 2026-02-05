//
//  StarMapView.swift
//  Leyhome - 地脉归途
//
//  星脉图视图 - 星空背景 + 3D 卫星地图 + 三层圣迹标注
//
//  Created on 2026/01/30.
//  Updated on 2026/02/03: 锚点可见性筛选（公开/私有 + 1km 范围 + 每人2个）
//

import SwiftUI
import MapKit
import CoreLocation
import Supabase

// MARK: - StarMapView

struct StarMapView: View {
    let sites: [SacredSite]

    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var trackingManager = TrackingManager.shared

    @State private var selectedSite: SacredSite?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showSiteDetail = false
    @State private var hasSetInitialPosition = false

    /// 筛选可见的圣迹（含锚点可见性逻辑）
    private var visibleSites: [SacredSite] {
        let currentUserId = authManager.currentUser?.id.uuidString

        // 非锚点圣迹：全部显示
        let nonAnchors = sites.filter { $0.siteTier != .anchor }

        // 锚点圣迹：根据可见性和距离筛选
        let anchors = sites.filter { $0.siteTier == .anchor }

        // 自己的所有锚点（无论公开与否）
        let myAnchors = anchors.filter { $0.creatorUserId == currentUserId }

        // 其他人的公开锚点：需在 1km 范围内，每人最多显示 2 个
        var nearbyPublicAnchors: [SacredSite] = []
        if let location = trackingManager.currentLocation {
            let otherPublicAnchors = anchors.filter { site in
                site.isPublic && site.creatorUserId != currentUserId
            }

            // 按距离筛选 1km 范围内
            let withinRange = otherPublicAnchors.filter { site in
                let siteLocation = CLLocation(latitude: site.latitude, longitude: site.longitude)
                return location.distance(from: siteLocation) <= 1000
            }

            // 按创建者分组，每人最多 2 个
            var userCounts: [String: Int] = [:]
            for anchor in withinRange {
                guard let creatorId = anchor.creatorUserId else { continue }
                let count = userCounts[creatorId] ?? 0
                if count < 2 {
                    nearbyPublicAnchors.append(anchor)
                    userCounts[creatorId] = count + 1
                }
            }
        }

        return nonAnchors + myAnchors + nearbyPublicAnchors
    }

    var body: some View {
        ZStack {
            // 星空背景
            StarryBackground()

            // 地图层
            Map(position: $cameraPosition) {
                ForEach(visibleSites) { site in
                    Annotation(site.name, coordinate: site.coordinate) {
                        SiteMarker(site: site, isSelected: selectedSite?.id == site.id)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedSite = site
                                }
                            }
                    }
                }
            }
            .mapStyle(.imagery(elevation: .realistic))
            .opacity(0.7)

            // 底部预览卡片
            VStack {
                Spacer()
                if let site = selectedSite {
                    SitePreviewCard(site: site) {
                        showSiteDetail = true
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.horizontal, LeyhomeTheme.Spacing.md)
                    .padding(.bottom, LeyhomeTheme.Spacing.md)
                }
            }
            .animation(.spring(response: 0.4), value: selectedSite?.id)
        }
        .sheet(isPresented: $showSiteDetail) {
            if let site = selectedSite {
                SacredSiteDetailView(site: site)
            }
        }
        .onAppear {
            setInitialCameraPosition()
        }
        .onChange(of: trackingManager.currentLocation) { _, _ in
            // 只在首次获取到位置时设置，避免后续位置更新干扰用户操作
            if !hasSetInitialPosition {
                setInitialCameraPosition()
            }
        }
    }

    /// 根据用户当前位置设置初始相机位置，使地球面向用户所在区域
    private func setInitialCameraPosition() {
        guard !hasSetInitialPosition else { return }
        guard let location = trackingManager.currentLocation else { return }

        let userCoordinate = location.coordinate
        // 距离约 40,000 km，呈现完整地球视角且用户所在区域居中
        let camera = MapCamera(
            centerCoordinate: userCoordinate,
            distance: 40_000_000,
            heading: 0,
            pitch: 0
        )
        cameraPosition = .camera(camera)
        hasSetInitialPosition = true
    }
}

// MARK: - StarryBackground

struct StarryBackground: View {
    @State private var stars: [Star] = []

    var body: some View {
        Canvas { context, size in
            for star in stars {
                let rect = CGRect(
                    x: star.x * size.width,
                    y: star.y * size.height,
                    width: star.size,
                    height: star.size
                )
                context.fill(
                    Circle().path(in: rect),
                    with: .color(.white.opacity(star.brightness))
                )
            }
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "0a0a1a"), Color(hex: "1a1a3a")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            stars = (0..<120).map { _ in
                Star(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: 0...1),
                    size: CGFloat.random(in: 1...3),
                    brightness: Double.random(in: 0.3...1.0)
                )
            }
        }
    }
}

struct Star {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let brightness: Double
}

// MARK: - SiteMarker

struct SiteMarker: View {
    let site: SacredSite
    let isSelected: Bool

    @State private var rotation: Double = 0
    @State private var glowPulse: Double = 0.6

    var body: some View {
        ZStack {
            // 外层光晕（所有层级共享，使标记在地球上清晰可见）
            Circle()
                .fill(site.siteTier.color.opacity(0.15))
                .frame(width: outerGlowSize, height: outerGlowSize)
                .blur(radius: 6)
                .opacity(glowPulse)

            switch site.siteTier {
            case .primal:
                // 曼陀罗动态效果
                MandalaMarker(rotation: rotation, color: site.siteTier.color)
                    .frame(width: 44, height: 44)
                    .onAppear {
                        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }

            case .leyNode:
                // 精致静态图标
                ZStack {
                    Circle()
                        .fill(site.siteTier.color)
                        .frame(width: 24, height: 24)

                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    Image(systemName: "diamond.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                }

            case .anchor:
                // 涟漪光点
                RippleMarker(color: site.siteTier.color)
                    .frame(width: 22, height: 22)
            }
        }
        .scaleEffect(isSelected ? 1.4 : 1.0)
        .shadow(color: site.siteTier.color, radius: isSelected ? 16 : 10)
        .shadow(color: site.siteTier.color.opacity(0.6), radius: isSelected ? 24 : 14)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowPulse = 1.0
            }
        }
    }

    private var outerGlowSize: CGFloat {
        switch site.siteTier {
        case .primal: return 60
        case .leyNode: return 44
        case .anchor: return 36
        }
    }
}

// MARK: - MandalaMarker

struct MandalaMarker: View {
    let rotation: Double
    let color: Color

    var body: some View {
        ZStack {
            // 外圈光芒
            ForEach(0..<6, id: \.self) { i in
                Capsule()
                    .fill(color)
                    .frame(width: 3, height: 16)
                    .offset(y: -8)
                    .rotationEffect(.degrees(Double(i) * 60 + rotation))
            }
            // 内圈
            ForEach(0..<6, id: \.self) { i in
                Capsule()
                    .fill(color.opacity(0.6))
                    .frame(width: 2, height: 11)
                    .offset(y: -5.5)
                    .rotationEffect(.degrees(Double(i) * 60 + 30 + rotation * 0.5))
            }
            // 中心
            Circle()
                .fill(Color.white)
                .frame(width: 10, height: 10)
                .shadow(color: color, radius: 5)
        }
    }
}

// MARK: - RippleMarker

struct RippleMarker: View {
    let color: Color
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: 2)
                .scaleEffect(scale)
                .opacity(opacity)

            Circle()
                .fill(color)
                .frame(width: 9, height: 9)
                .shadow(color: color, radius: 4)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                scale = 2.0
                opacity = 0
            }
        }
    }
}

// MARK: - SitePreviewCard

struct SitePreviewCard: View {
    let site: SacredSite
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: LeyhomeTheme.Spacing.md) {
                // 层级图标
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(site.siteTier.color.opacity(0.2))
                        .frame(width: 64, height: 64)

                    VStack(spacing: 2) {
                        Image(systemName: site.siteTier == .primal ? "sparkles" : site.siteTier == .leyNode ? "diamond.fill" : "drop.fill")
                            .font(.system(size: 22))
                            .foregroundColor(site.siteTier.color)

                        Text(site.siteTier.localizedName)
                            .font(.system(size: 8))
                            .foregroundColor(site.siteTier.color)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(site.name)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(.white)

                    Text(site.siteDescription)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)

                    HStack(spacing: LeyhomeTheme.Spacing.sm) {
                        Text(site.country)
                            .font(LeyhomeTheme.Fonts.caption)
                            .foregroundColor(.white.opacity(0.5))

                        if let region = site.region {
                            Text("·")
                                .foregroundColor(.white.opacity(0.3))
                            Text(region)
                                .font(LeyhomeTheme.Fonts.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(LeyhomeTheme.Spacing.md)
            .background(.ultraThinMaterial.opacity(0.9))
            .cornerRadius(LeyhomeTheme.CornerRadius.md)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    StarMapView(sites: SacredSiteData.loadAllSites())
}
