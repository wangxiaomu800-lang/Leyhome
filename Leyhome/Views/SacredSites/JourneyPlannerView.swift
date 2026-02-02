//
//  JourneyPlannerView.swift
//  Leyhome - 地脉归途
//
//  旅程规划器 - 5 种出行方式的哲学解读 + 系统导航
//  Based on GDD 4.2.4
//
//  Created on 2026/01/30.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - JourneyMode

enum JourneyMode: CaseIterable {
    case flying
    case highSpeedRail
    case train
    case driving
    case walking

    var icon: String {
        switch self {
        case .flying: return "airplane"
        case .highSpeedRail: return "tram.fill"
        case .train: return "train.side.front.car"
        case .driving: return "car.fill"
        case .walking: return "figure.walk"
        }
    }

    var titleZh: String {
        switch self {
        case .flying: return "飞机 - 超越凡尘"
        case .highSpeedRail: return "高铁 - 流动冥想"
        case .train: return "火车 - 感受脉搏"
        case .driving: return "自驾 - 自由意志"
        case .walking: return "步行 - 身心合一"
        }
    }

    var titleEn: String {
        switch self {
        case .flying: return "Flight - Beyond the Mundane"
        case .highSpeedRail: return "HSR - Flowing Meditation"
        case .train: return "Train - Feeling the Pulse"
        case .driving: return "Drive - Free Will"
        case .walking: return "Walk - Body and Soul as One"
        }
    }

    var localizedTitle: String {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? titleZh : titleEn
    }

    var descriptionZh: String {
        switch self {
        case .flying:
            return "以最快速度跨越物理障碍，如同灵魂出窍，从上帝视角审视山川河流。适合长距离的心灵跳跃。"
        case .highSpeedRail:
            return "平稳、高速、有节奏地穿行于大地之上。窗外飞速掠过的风景，容易让人进入流动的冥想状态。"
        case .train:
            return "以更从容、更贴近大地肌理的速度前行。火车与铁轨的'况且'声，如同大地的脉搏。"
        case .driving:
            return "拥有对路线和节奏的绝对掌控力。可以随时偏离主路，去探寻地图上没有标记的湖泊或古道。"
        case .walking:
            return "与大地最极致的连接。你的每一步都在与地脉共振，用双脚阅读土地的故事。这是最原始、最深刻的朝圣方式。"
        }
    }

    var descriptionEn: String {
        switch self {
        case .flying:
            return "Cross physical barriers at maximum speed, like an out-of-body experience, surveying mountains and rivers from a god's-eye view."
        case .highSpeedRail:
            return "Steady, fast, rhythmic travel across the land. The rapidly passing scenery outside easily induces a flowing meditative state."
        case .train:
            return "Moving at a more leisurely pace, closer to the texture of the earth. The clacking of train on tracks echoes like the pulse of the land."
        case .driving:
            return "Absolute control over route and rhythm. You can deviate from the main road at any time to explore unmarked lakes or ancient paths."
        case .walking:
            return "The most intimate connection with the earth. Every step resonates with the ley lines. This is the most primal, most profound way of pilgrimage."
        }
    }

    var localizedDescription: String {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? descriptionZh : descriptionEn
    }

    var cautionZh: String {
        switch self {
        case .flying:
            return "旅途大部分在高空，会暂时与地表能量隔绝。起降的繁忙可能消耗心神。"
        case .highSpeedRail:
            return "速度是它的优点也是缺点，你将看到风景但无法触摸。"
        case .train:
            return "需要将大量时间交予旅途本身，这是一次对'慢'的臣服。"
        case .driving:
            return "驾驶需要持续投入专注力，可能占据用于内省的'后台算力'。"
        case .walking:
            return "对体能和意志力的巨大考验。只适合作为旅程中最后、最神圣的一段仪式。"
        }
    }

    var cautionEn: String {
        switch self {
        case .flying:
            return "Most of the journey is at high altitude, temporarily severing connection with surface energy."
        case .highSpeedRail:
            return "Speed is both its strength and weakness — you'll see the scenery but cannot touch it."
        case .train:
            return "Requires surrendering a significant amount of time to the journey itself — a submission to 'slowness'."
        case .driving:
            return "Driving demands continuous focus, potentially occupying the mental bandwidth reserved for introspection."
        case .walking:
            return "A tremendous test of physical endurance and willpower. Best reserved as the final, most sacred ritual of the journey."
        }
    }

    var localizedCaution: String {
        let lang = LocalizationManager.shared.currentLanguage
        return lang.hasPrefix("zh") ? cautionZh : cautionEn
    }
}

// MARK: - JourneyPlannerView

struct JourneyPlannerView: View {
    let site: SacredSite
    @Environment(\.dismiss) private var dismiss
    @StateObject private var trackingManager = TrackingManager.shared

    @State private var selectedMode: JourneyMode?
    @State private var estimatedDistance: Double = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    // 目的地卡片
                    DestinationCard(site: site, distance: estimatedDistance)

                    // 出行方式选择
                    Text("journey.choose_way".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(JourneyMode.allCases, id: \.icon) { mode in
                        JourneyModeCard(
                            mode: mode,
                            isSelected: selectedMode == mode
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedMode = selectedMode == mode ? nil : mode
                            }
                        }
                    }

                    // 开始导航按钮
                    if selectedMode != nil {
                        Button(action: startNavigation) {
                            HStack {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                Text("journey.start_nav".localized)
                            }
                            .leyhomePrimaryButton()
                            .frame(maxWidth: .infinity)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(LeyhomeTheme.Spacing.md)
            }
            .navigationTitle("journey.planner".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("button.cancel".localized) { dismiss() }
                }
            }
            .onAppear {
                calculateDistance()
            }
        }
    }

    private func calculateDistance() {
        guard let currentLocation = trackingManager.currentLocation else { return }
        let destination = CLLocation(latitude: site.latitude, longitude: site.longitude)
        estimatedDistance = currentLocation.distance(from: destination) / 1000 // km
    }

    private func startNavigation() {
        let coordinate = site.coordinate
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = site.name

        let launchOptions: [String: Any]
        switch selectedMode {
        case .walking:
            launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        case .driving:
            launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        default:
            launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault]
        }

        mapItem.openInMaps(launchOptions: launchOptions)
    }
}

// MARK: - JourneyModeCard

struct JourneyModeCard: View {
    let mode: JourneyMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                HStack {
                    Image(systemName: mode.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : LeyhomeTheme.primary)
                        .frame(width: 40, height: 40)
                        .background(isSelected ? LeyhomeTheme.primary : LeyhomeTheme.primary.opacity(0.1))
                        .cornerRadius(8)

                    Text(mode.localizedTitle)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(LeyhomeTheme.primary)
                    }
                }

                Text(mode.localizedDescription)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(LeyhomeTheme.textSecondary)
                    .lineLimit(isSelected ? nil : 2)

                if isSelected {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.caption)
                        Text(mode.localizedCaution)
                            .font(LeyhomeTheme.Fonts.caption)
                    }
                    .foregroundColor(.orange)
                    .padding(.top, 4)
                    .transition(.opacity)
                }
            }
            .padding(LeyhomeTheme.Spacing.md)
            .background(isSelected ? LeyhomeTheme.primary.opacity(0.08) : Color(.systemGray6))
            .cornerRadius(LeyhomeTheme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.md)
                    .stroke(isSelected ? LeyhomeTheme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - DestinationCard

struct DestinationCard: View {
    let site: SacredSite
    let distance: Double

    var body: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            // 层级图标
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(site.siteTier.color.opacity(0.2))
                    .frame(width: 56, height: 56)

                Image(systemName: site.siteTier == .primal ? "sparkles" : "diamond.fill")
                    .font(.system(size: 22))
                    .foregroundColor(site.siteTier.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(site.name)
                    .font(LeyhomeTheme.Fonts.headline)
                    .foregroundColor(LeyhomeTheme.textPrimary)
                Text(site.country)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(LeyhomeTheme.textSecondary)
            }

            Spacer()

            if distance > 0 {
                VStack(alignment: .trailing) {
                    Text(String(format: "%.0f km", distance))
                        .font(LeyhomeTheme.Fonts.titleSmall)
                        .foregroundColor(LeyhomeTheme.primary)
                    Text("journey.distance_label".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                }
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color(.systemGray6))
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
    }
}

// MARK: - Preview

#Preview {
    let site = SacredSiteData.loadAllSites().first!
    JourneyPlannerView(site: site)
}
