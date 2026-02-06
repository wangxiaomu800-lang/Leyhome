//
//  LeyhomeApp.swift
//  Leyhome - 地脉归途
//
//  Created on 2026/01/26.
//

import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct LeyhomeApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var languageManager = LanguageManager.shared

    init() {
        #if DEBUG
        // 模拟已订阅状态（测试数据洞察等高级功能）
        // SubscriptionManager.debugOverridePremium = true

        // 重置引导页（测试引导流程）
        // UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        #endif
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Journey.self,
            MoodRecord.self,
            SacredSite.self,
            Echo.self,
            VisitedLocation.self,
            Guide.self,
            Constellation.self,
            ConstellationNode.self,
            Intention.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(languageManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .environment(\.locale, .init(identifier: languageManager.currentLanguage.languageCode ?? "en"))
        }
        .modelContainer(sharedModelContainer)
    }
}
