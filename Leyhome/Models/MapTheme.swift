//
//  MapTheme.swift
//  Leyhome - 地脉归途
//
//  地图主题系统 - 星尘 & 卫星
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
    case starDust = "star_dust"       // 星尘（默认）
    case satellite = "satellite"       // 卫星

    var id: String { rawValue }

    // MARK: - 地图类型

    /// 对应的 MKMapType
    var mapType: MKMapType {
        switch self {
        case .starDust:
            return .standard
        case .satellite:
            return .satellite
        }
    }

    // MARK: - 地图配置

    /// 是否使用 3D 视角
    var is3D: Bool {
        return false
    }

    /// 是否显示 POI（兴趣点）
    var showsPOI: Bool {
        switch self {
        case .starDust:
            return false
        case .satellite:
            return true
        }
    }

    // MARK: - 能量线颜色覆盖

    /// 主题专属能量线颜色覆盖（nil 表示使用默认出行方式颜色）
    func energyLineColorOverride(for mode: TransportMode) -> UIColor? {
        return nil
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
        case .satellite:
            return "globe.americas.fill"
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
        let theme = MapTheme(rawValue: saved)
        // 迁移：如果保存的是已删除主题，重置为星尘
        if theme == nil {
            UserDefaults.standard.set(MapTheme.starDust.rawValue, forKey: "selectedMapTheme")
        }
        self.currentTheme = theme ?? .starDust
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
