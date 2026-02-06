import SwiftUI

/// 根视图：控制启动页、认证页、引导页与主界面的切换
struct RootView: View {
    /// 认证管理器（从父视图注入）
    @EnvironmentObject var authManager: AuthManager

    /// 启动页是否完成
    @State private var splashFinished = false

    /// 是否完成新用户引导
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        ZStack {
            if !splashFinished {
                // 阶段 1: 显示启动页（检查会话状态）
                SplashView(onFinished: {
                    splashFinished = true
                })
                .transition(.opacity)
            } else if !authManager.isAuthenticated {
                // 阶段 2: 未登录，显示认证页
                AuthView()
                    .transition(.opacity)
            } else if !hasCompletedOnboarding {
                // 阶段 3: 已登录但未完成引导，显示引导页
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            } else {
                // 阶段 4: 已登录且完成引导，显示主界面
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: splashFinished)
        .animation(.easeInOut(duration: 0.5), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
    }
}

#Preview {
    RootView()
}
