//
//  LanguageManager.swift
//  Leyhome - 地脉归途
//
//  管理应用内语言切换
//

import SwiftUI
import Combine
import Foundation

/// 语言选项
enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"      // 跟随系统
    case chinese = "zh-Hans"    // 简体中文
    case english = "en"         // English

    var id: String { rawValue }

    /// 显示名称
    var displayName: String {
        switch self {
        case .system:
            return "language.follow_system".localized
        case .chinese:
            return "简体中文"
        case .english:
            return "English"
        }
    }

    /// 获取实际的语言代码
    var languageCode: String? {
        switch self {
        case .system:
            return Locale.current.language.languageCode?.identifier
        case .chinese:
            return "zh-Hans"
        case .english:
            return "en"
        }
    }

}

/// 语言管理器
@MainActor
class LanguageManager: ObservableObject {
    /// 单例
    static let shared = LanguageManager()

    /// 当前选择的语言
    @Published var currentLanguage: AppLanguage {
        didSet {
            saveLanguage()
            updateLocale()
            print("🌍 语言已切换到: \(currentLanguage.displayName)")
        }
    }

    /// 当前的 Locale（用于 SwiftUI environment）
    @Published var currentLocale: Locale

    /// UserDefaults 键
    private let languageKey = "app_language"

    private init() {
        // 从 UserDefaults 加载语言设置
        let language: AppLanguage
        if let savedLanguage = UserDefaults.standard.string(forKey: languageKey),
           let loadedLanguage = AppLanguage(rawValue: savedLanguage) {
            language = loadedLanguage
            print("🌍 加载已保存的语言设置: \(loadedLanguage.displayName)")
        } else {
            language = .system
            print("🌍 使用默认语言设置: 跟随系统")
        }

        // 初始化所有存储属性
        self.currentLanguage = language
        self.currentLocale = Self.getLocale(for: language)

        // 应用语言设置（包括 UIKit 组件）
        setAppLanguage(language)
    }

    /// 保存语言设置
    private func saveLanguage() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
        print("💾 语言设置已保存: \(currentLanguage.rawValue)")
    }

    /// 更新 Locale
    private func updateLocale() {
        currentLocale = Self.getLocale(for: currentLanguage)
        print("🌐 Locale 已更新: \(currentLocale.identifier)")
    }

    /// 切换语言
    func changeLanguage(to language: AppLanguage) {
        currentLanguage = language

        // 设置应用语言（用于影响 UIKit 组件，如 MKMapView）
        setAppLanguage(language)
    }

    /// 获取指定语言的 Locale
    private static func getLocale(for language: AppLanguage) -> Locale {
        switch language {
        case .system:
            return Locale.current
        case .chinese:
            return Locale(identifier: "zh-Hans")
        case .english:
            return Locale(identifier: "en")
        }
    }

    /// 设置应用的语言环境（影响 UIKit 组件）
    private func setAppLanguage(_ language: AppLanguage) {
        var languages: [String] = []

        switch language {
        case .system:
            // 跟随系统时，使用系统的首选语言
            languages = Locale.preferredLanguages
        case .chinese:
            languages = ["zh-Hans", "zh-CN"]
        case .english:
            languages = ["en", "en-US"]
        }

        // 设置 UserDefaults 的 AppleLanguages
        UserDefaults.standard.set(languages, forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        // 重新加载 Bundle（使用 swizzling 技术）
        Bundle.setLanguage(languages.first)

        print("🌍 应用语言环境已设置为: \(languages)")
    }
}

// MARK: - Bundle 扩展（支持运行时语言切换）

private var bundleKey: UInt8 = 0

extension Bundle {
    /// 设置 Bundle 的语言
    static func setLanguage(_ language: String?) {
        defer {
            // 清除缓存，强制重新加载
            object_setClass(Bundle.main, CustomBundle.self)
        }

        // 存储当前语言
        objc_setAssociatedObject(Bundle.main, &bundleKey, language, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    /// 获取当前 Bundle 语言
    var currentLanguage: String? {
        return objc_getAssociatedObject(self, &bundleKey) as? String
    }
}

/// 自定义 Bundle 类（用于语言切换）
private class CustomBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let language = currentLanguage,
              let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }

        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

