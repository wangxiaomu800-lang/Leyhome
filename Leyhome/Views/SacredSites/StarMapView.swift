//
//  StarMapView.swift
//  Leyhome - 地脉归途
//
//  星脉图视图 - 星空背景 + 3D 卫星地图 + 三层圣迹标注
//
//  Created on 2026/01/30.
//

import SwiftUI
import MapKit

// MARK: - StarMapView

struct StarMapView: View {
    let sites: [SacredSite]

    @State private var selectedSite: SacredSite?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showSiteDetail = false

    var body: some View {
        ZStack {
            // 星空背景
            StarryBackground()

            // 地图层
            Map(position: $cameraPosition) {
                ForEach(sites) { site in
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

    var body: some View {
        ZStack {
            switch site.siteTier {
            case .primal:
                // 曼陀罗动态效果
                MandalaMarker(rotation: rotation, color: site.siteTier.color)
                    .frame(width: 30, height: 30)
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
                        .frame(width: 18, height: 18)

                    Circle()
                        .stroke(Color.white, lineWidth: 1.5)
                        .frame(width: 18, height: 18)

                    Image(systemName: "diamond.fill")
                        .font(.system(size: 7))
                        .foregroundColor(.white)
                }

            case .anchor:
                // 涟漪光点
                RippleMarker(color: site.siteTier.color)
                    .frame(width: 16, height: 16)
            }
        }
        .scaleEffect(isSelected ? 1.4 : 1.0)
        .shadow(color: site.siteTier.color.opacity(0.8), radius: isSelected ? 12 : 6)
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
                    .frame(width: 2, height: 12)
                    .offset(y: -6)
                    .rotationEffect(.degrees(Double(i) * 60 + rotation))
            }
            // 内圈
            ForEach(0..<6, id: \.self) { i in
                Capsule()
                    .fill(color.opacity(0.6))
                    .frame(width: 1.5, height: 8)
                    .offset(y: -4)
                    .rotationEffect(.degrees(Double(i) * 60 + 30 + rotation * 0.5))
            }
            // 中心
            Circle()
                .fill(Color.white)
                .frame(width: 7, height: 7)
                .shadow(color: color, radius: 3)
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
                .stroke(color, lineWidth: 1.5)
                .scaleEffect(scale)
                .opacity(opacity)

            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
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
