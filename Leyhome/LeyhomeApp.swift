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

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Journey.self,
            MoodRecord.self,
            SacredSite.self
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
