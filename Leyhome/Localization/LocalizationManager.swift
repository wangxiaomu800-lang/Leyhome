//
//  LocalizationManager.swift
//  Leyhome - 地脉归途
//
//  Created on 2026/01/26.
//

import Foundation

/// 轻量语言查询（供非 SwiftUI 代码使用）
class LocalizationManager {
    static let shared = LocalizationManager()
    private init() {}

    /// 当前解析后的语言代码（"zh-Hans" 或 "en"）
    var currentLanguage: String {
        let saved = UserDefaults.standard.string(forKey: "app_language") ?? "system"
        switch saved {
        case "zh-Hans":
            return "zh-Hans"
        case "en":
            return "en"
        default:
            let sysLang = Locale.preferredLanguages.first ?? "en"
            return sysLang.hasPrefix("zh") ? "zh-Hans" : "en"
        }
    }
}

extension String {
    var localized: String {
        let language = resolvedLanguageCode()
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        }
        return NSLocalizedString(self, comment: "")
    }

    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }

    /// 从 UserDefaults 读取用户选择的语言，解析为 Bundle 可用的语言代码
    private func resolvedLanguageCode() -> String {
        let saved = UserDefaults.standard.string(forKey: "app_language") ?? "system"
        switch saved {
        case "zh-Hans":
            return "zh-Hans"
        case "en":
            return "en"
        default:
            // system: 根据系统语言判断
            let sysLang = Locale.preferredLanguages.first ?? "en"
            if sysLang.hasPrefix("zh") {
                return "zh-Hans"
            }
            return "en"
        }
    }
}
