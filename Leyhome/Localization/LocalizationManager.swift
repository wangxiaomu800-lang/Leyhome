//
//  LocalizationManager.swift
//  Leyhome - 地脉归途
//
//  Created on 2026/01/26.
//

import Foundation
import SwiftUI
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"

    private init() {}

    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }

    func setLanguage(_ languageCode: String) {
        currentLanguage = languageCode
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func localized(with arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}
