//
//  MapTheme.swift
//  Leyhome - 地脉归途
//
//  地图主题系统 - 五种视觉风格
//
//  Created on 2026/01/29.
//

import Foundation
import SwiftUI
import MapKit
import Combine

// MARK: - MapTheme

/// 地图主题枚举
enum MapTheme: String, CaseIterable, Identifiable {
    case starDust = "star_dust"           // 星尘（默认）
    case inkWash = "ink_wash"             // 水墨山水
    case ghibliSummer = "ghibli_summer"   // 吉卜力之夏
    case auroraLight = "aurora_light"     // 极光之夜
    case cyberpunk = "cyberpunk"          // 赛博朋克

    var id: String { rawValue }

    // MARK: - 地图类型

    /// 对应的 MKMapType
    var mapType: MKMapType {
        switch self {
        case .starDust:
            return .standard
        case .inkWash:
            return .satelliteFlyover
        case .ghibliSummer:
            return .standard
        case .auroraLight:
            return .hybridFlyover
        case .cyberpunk:
            return .hybrid
        }
    }

    // MARK: - 地图配置

    /// 是否使用 3D 视角
    var is3D: Bool {
        switch self {
        case .ghibliSummer, .auroraLight:
            return true
        default:
            return false
        }
    }

    /// 是否显示 POI（兴趣点）
    var showsPOI: Bool {
        switch self {
        case .starDust, .cyberpunk:
            return false
        default:
            return true
        }
    }

    // MARK: - 能量线颜色覆盖

    /// 主题专属能量线颜色覆盖（nil 表示使用默认出行方式颜色）
    func energyLineColorOverride(for mode: TransportMode) -> UIColor? {
        switch self {
        case .cyberpunk:
            // 赛博朋克主题：霓虹色
            switch mode {
            case .walking:
                return UIColor(Color(hex: "FF00FF"))  // 品红霓虹
            case .cycling:
                return UIColor(Color(hex: "00FFFF"))  // 青色霓虹
            case .driving:
                return UIColor(Color(hex: "FFFF00"))  // 黄色霓虹
            case .flying:
                return UIColor(Color(hex: "FF4500"))   // 橙红霓虹
            }
        default:
            return nil
        }
    }

    // MARK: - 付费标记

    /// 是否为高级主题（需要订阅）
    var isPremium: Bool {
        switch self {
        case .starDust:
            return false
        case .inkWash, .ghibliSummer, .auroraLight, .cyberpunk:
            return true
        }
    }

    // MARK: - 国际化

    /// 本地化名称
    var localizedName: String {
        "map.theme.\(rawValue)".localized
    }

    /// 图标
    var icon: String {
        switch self {
        case .starDust:
            return "sparkles"
        case .inkWash:
            return "paintbrush.pointed.fill"
        case .ghibliSummer:
            return "leaf.fill"
        case .auroraLight:
            return "moon.stars.fill"
        case .cyberpunk:
            return "bolt.fill"
        }
    }
}

// MARK: - ThemeManager

/// 地图主题管理器
class ThemeManager: ObservableObject {

    /// 单例
    static let shared = ThemeManager()

    /// 当前主题
    @Published var currentTheme: MapTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedMapTheme")
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "selectedMapTheme") ?? MapTheme.starDust.rawValue
        self.currentTheme = MapTheme(rawValue: saved) ?? .starDust
    }

    // MARK: - Public Methods

    /// 获取当前主题下的能量线颜色
    /// - Parameter mode: 出行方式
    /// - Returns: UIColor（主题覆盖色或默认出行方式颜色）
    func energyLineColor(for mode: TransportMode) -> UIColor {
        if let override = currentTheme.energyLineColorOverride(for: mode) {
            return override
        }
        return UIColor(mode.lineColor)
    }

    /// 切换主题
    func setTheme(_ theme: MapTheme) {
        currentTheme = theme
    }
}
