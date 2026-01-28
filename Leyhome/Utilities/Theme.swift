//
//  Theme.swift
//  Leyhome - 地脉归途
//
//  Created on 2026/01/26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Leyhome Design System
struct LeyhomeTheme {

    // MARK: - 主色调 (GDD 6.1)
    static let primary = Color(hex: "2D5A4E")      // 深青绿 - 自然与宁静
    static let secondary = Color(hex: "F5F0E6")    // 暖白 - 温暖与安全
    static let accent = Color(hex: "D4A574")       // 琥珀金 - 能量与智慧
    static let starlight = Color(hex: "A8C8E8")    // 淡蓝 - 星空与梦想

    // MARK: - 背景色
    static let background = Color(hex: "F5F0E6")   // 默认背景

    struct Background {
        static let primary = Color(hex: "F5F0E6")   // 暖白背景
        static let dark = Color(hex: "1A1A2E")      // 深色背景（星空主题）
        static let card = Color.white
    }

    // MARK: - 文本颜色
    static let textPrimary = Color(hex: "2D5A4E")
    static let textSecondary = Color(hex: "6B7280")
    static let textMuted = Color(hex: "9CA3AF")

    // MARK: - 状态颜色
    static let success = Color(hex: "66B380")
    static let warning = Color(hex: "E6B366")
    static let danger = Color(hex: "CC8080")

    // MARK: - 能量线颜色 (GDD 6.2)
    struct EnergyLine {
        static let walking = Color(hex: "D4A574")   // 琥珀色 - 步行
        static let cycling = Color(hex: "4ECDC4")   // 青色 - 骑行
        static let driving = Color(hex: "E8E8E8")   // 银白色 - 驾车
        static let flying = Color(hex: "9B7EDE")    // 紫色 - 飞行

        // 渐变色
        static let walkingGradient = LinearGradient(
            colors: [Color(hex: "D4A574"), Color(hex: "8B6914")],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let cyclingGradient = LinearGradient(
            colors: [Color(hex: "4ECDC4"), Color(hex: "95E1D3")],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let drivingGradient = LinearGradient(
            colors: [Color(hex: "E8E8E8"), Color(hex: "A8C8E8")],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let flyingGradient = LinearGradient(
            colors: [Color(hex: "9B7EDE"), Color(hex: "DDA0DD")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - 情绪颜色
    struct Mood {
        static let calm = Color(hex: "7EC8E3")       // 平静 - 天蓝
        static let joy = Color(hex: "FFD93D")        // 愉悦 - 明黄
        static let anxiety = Color(hex: "FF6B6B")    // 焦虑 - 珊瑚红
        static let relief = Color(hex: "95E1D3")     // 释然 - 薄荷绿
        static let inspiration = Color(hex: "DDA0DD") // 灵感 - 淡紫
        static let nostalgia = Color(hex: "DEB887")  // 怀旧 - 沙棕
        static let gratitude = Color(hex: "98D8C8")  // 感恩 - 青绿
    }

    // MARK: - 圣迹层级颜色
    struct SacredSite {
        static let tier1 = Color(hex: "FFD700")      // 源点圣迹 - 金色
        static let tier2 = Color(hex: "D4A574")      // 地脉节点 - 琥珀
        static let tier3 = Color(hex: "A8C8E8")      // 心绪锚点 - 淡蓝
    }

    // MARK: - 字体
    struct Fonts {
        // 优雅的衬线标题字体
        static let largeTitle = Font.system(size: 28, weight: .light)
        static let title = Font.custom("Georgia", size: 24)
        static let titleLarge = Font.custom("Georgia", size: 32)
        static let titleSmall = Font.custom("Georgia", size: 20)

        // 清晰的无衬线正文字体
        static let headline = Font.system(size: 18, weight: .medium)
        static let body = Font.system(size: 16)
        static let bodyLarge = Font.system(size: 18)
        static let bodySmall = Font.system(size: 14)
        static let callout = Font.system(size: 14)

        // 手写风格引用字体
        static let quote = Font.custom("Snell Roundhand", size: 18)
        static let quoteLarge = Font.custom("Snell Roundhand", size: 24)

        // 功能性字体
        static let caption = Font.system(size: 12)
        static let button = Font.system(size: 16, weight: .medium)
        static let tabBar = Font.system(size: 10)
    }

    // MARK: - 间距
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - 圆角
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let full: CGFloat = 9999 // 用于圆形按钮
    }

    // MARK: - 阴影
    struct Shadow {
        static let light = (color: Color.black.opacity(0.08), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.12), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(4))
        static let heavy = (color: Color.black.opacity(0.16), radius: CGFloat(24), x: CGFloat(0), y: CGFloat(8))
    }

    // MARK: - 动画时长
    struct Animation {
        static let fast: Double = 0.15
        static let normal: Double = 0.3
        static let slow: Double = 0.5
        static let breath: Double = 2.0  // 呼吸感动画
        static let breathing = SwiftUI.Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
    }

    // MARK: - 线条宽度（能量线）
    struct LineWidth {
        static let walking: CGFloat = 4
        static let cycling: CGFloat = 3
        static let driving: CGFloat = 2
        static let flying: CGFloat = 1.5
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // 转换为 hex 字符串
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

// MARK: - View Modifiers for Theme
extension View {
    func leyhomeCardStyle() -> some View {
        self
            .background(LeyhomeTheme.Background.card)
            .cornerRadius(LeyhomeTheme.CornerRadius.md)
            .shadow(
                color: LeyhomeTheme.Shadow.light.color,
                radius: LeyhomeTheme.Shadow.light.radius,
                x: LeyhomeTheme.Shadow.light.x,
                y: LeyhomeTheme.Shadow.light.y
            )
    }

    func leyhomePrimaryButton() -> some View {
        self
            .font(LeyhomeTheme.Fonts.button)
            .foregroundColor(.white)
            .padding(.horizontal, LeyhomeTheme.Spacing.lg)
            .padding(.vertical, LeyhomeTheme.Spacing.md)
            .background(LeyhomeTheme.primary)
            .cornerRadius(LeyhomeTheme.CornerRadius.lg)
    }

    func leyhomeSecondaryButton() -> some View {
        self
            .font(LeyhomeTheme.Fonts.button)
            .foregroundColor(LeyhomeTheme.primary)
            .padding(.horizontal, LeyhomeTheme.Spacing.lg)
            .padding(.vertical, LeyhomeTheme.Spacing.md)
            .background(LeyhomeTheme.secondary)
            .cornerRadius(LeyhomeTheme.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.lg)
                    .stroke(LeyhomeTheme.primary, lineWidth: 1)
            )
    }
}
