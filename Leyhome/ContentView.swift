//
//  ContentView.swift
//  Leyhome - 地脉归途
//
//  主内容视图 - 处理登录状态和主界面切换
//
//  Created on 2026/01/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: LeyhomeTheme.Animation.normal), value: authManager.isAuthenticated)
    }
}

#Preview("Logged Out") {
    ContentView()
}

#Preview("Logged In") {
    MainTabView()
}
