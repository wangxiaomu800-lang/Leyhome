//
//  AspiredSitesManager.swift
//  Leyhome - 地脉归途
//
//  向往状态持久化管理 - 使用 nameEn 作为稳定标识符
//
//  Created on 2026/02/03.
//

import Foundation
import Combine

class AspiredSitesManager: ObservableObject {
    static let shared = AspiredSitesManager()

    private let key = "aspired_site_names"
    @Published var aspiredNames: Set<String>

    private init() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        aspiredNames = Set(saved)
    }

    func isAspired(_ site: SacredSite) -> Bool {
        aspiredNames.contains(site.nameEn)
    }

    func toggleAspire(_ site: SacredSite) {
        if aspiredNames.contains(site.nameEn) {
            aspiredNames.remove(site.nameEn)
        } else {
            aspiredNames.insert(site.nameEn)
        }
        save()
    }

    private func save() {
        UserDefaults.standard.set(Array(aspiredNames), forKey: key)
    }
}
