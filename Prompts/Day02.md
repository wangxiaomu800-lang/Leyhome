# Day 2 开发提示词

## 今日目标
**用户系统完整实现 + 数据层架构（Apple ID + Google 登录）**

请阅读 `/Users/xiaomu/Desktop/Leyhome/GDD.md` 和 `/Users/xiaomu/Desktop/Leyhome/PRD.md`，然后完成以下任务。

---

## 任务清单

### 1. Apple ID 登录实现 + Google 登录实现

**配置 Sign in with Apple 能力**：
1. 在 Xcode 中添加 "Sign in with Apple" Capability
2. 在 Apple Developer 后台配置 App ID

**创建 `AuthManager.swift`**：
```swift
import AuthenticationServices
import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?

    func signInWithApple() async {
        // 实现 Apple ID 登录
    }

    func signOut() async {
        // 实现退出登录
    }

    func checkAuthStatus() async {
        // 检查登录状态
    }
}
```

**创建 `AppleSignInButton.swift`**：
```swift
import SwiftUI
import AuthenticationServices

struct AppleSignInButton: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            Task {
                await handleSignIn(result: result)
            }
        }
        .signInWithAppleButtonStyle(.white)
        .frame(height: 50)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
    }

    private func handleSignIn(result: Result<ASAuthorization, Error>) async {
        // 处理登录结果
    }
}
```

### 2. Supabase Auth 集成

**创建 `SupabaseAuthService.swift`**：
```swift
import Supabase

class SupabaseAuthService {
    static let shared = SupabaseAuthService()
    private let client = SupabaseConfig.client

    // 使用 Apple ID Token 登录 Supabase
    func signInWithApple(idToken: String, nonce: String) async throws -> User {
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        return try await fetchOrCreateUser(authId: session.user.id.uuidString)
    }

    // 获取或创建用户
    func fetchOrCreateUser(authId: String) async throws -> User {
        // 实现用户查询/创建逻辑
    }

    // 退出登录
    func signOut() async throws {
        try await client.auth.signOut()
    }

    // 获取当前会话
    func getCurrentSession() async throws -> Session? {
        return try await client.auth.session
    }
}
```

### 3. 用户数据模型

**创建 `User.swift`**：
```swift
import Foundation
import SwiftData

@Model
class User: Identifiable {
    @Attribute(.unique) var id: UUID
    var appleId: String?
    var nickname: String
    var avatarUrl: String?
    var createdAt: Date
    var updatedAt: Date

    // 统计数据
    var totalDistance: Double = 0
    var totalTracks: Int = 0
    var totalNodes: Int = 0
    var visitedSites: Int = 0

    // 称号
    var titles: [String] = []

    init(id: UUID = UUID(), appleId: String? = nil, nickname: String = "归途者".localized) {
        self.id = id
        self.appleId = appleId
        self.nickname = nickname
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// Supabase 响应映射
struct UserResponse: Codable {
    let id: String
    let appleId: String?
    let nickname: String?
    let avatarUrl: String?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case appleId = "apple_id"
        case nickname
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

### 4. SwiftData 本地存储配置

**更新 `LeyhomeApp.swift`**：
```swift
import SwiftUI
import SwiftData

@main
struct LeyhomeApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Track.self,
            MoodNode.self,
            // 其他模型...
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
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
                .environmentObject(localizationManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
```

**创建 `RootView.swift`**：
```swift
import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        Group {
            if authManager.isLoading {
                LaunchScreenView()
            } else if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .task {
            await authManager.checkAuthStatus()
        }
    }
}
```

### 5. 个人中心页面

**创建 `ProfileView.swift`**：
```swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    // 用户头像和昵称
                    ProfileHeaderView()

                    // 统计数据卡片
                    StatsCardView()

                    // 我的旅程
                    MyJourneysSection()

                    // 我的回响
                    MyEchoesSection()

                    // 称号墙
                    TitlesSection()

                    // 设置入口
                    SettingsSection()
                }
                .padding()
            }
            .background(LeyhomeTheme.secondary)
            .navigationTitle("tab.profile".localized)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}
```

**创建 `SettingsView.swift`**：
```swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                // 语言设置
                Section("settings.language".localized) {
                    Picker("settings.language".localized, selection: $localizationManager.currentLanguage) {
                        Text("简体中文").tag("zh")
                        Text("English").tag("en")
                    }
                }

                // 通知设置
                Section("settings.notifications".localized) {
                    Toggle("settings.notifications.track".localized, isOn: .constant(true))
                    Toggle("settings.notifications.echo".localized, isOn: .constant(true))
                }

                // 隐私设置
                Section("settings.privacy".localized) {
                    NavigationLink("settings.privacy.policy".localized) {
                        PrivacyPolicyView()
                    }
                    NavigationLink("settings.privacy.data".localized) {
                        DataManagementView()
                    }
                }

                // 关于
                Section("settings.about".localized) {
                    HStack {
                        Text("settings.version".localized)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }

                // 退出登录
                Section {
                    Button(role: .destructive) {
                        Task {
                            await authManager.signOut()
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("settings.logout".localized)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("settings.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("button.done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}
```

### 6. 国际化文案补充

在 `Localizable.xcstrings` 中添加：
```
// 个人中心
"profile.stats.distance" = "总里程" / "Total Distance"
"profile.stats.tracks" = "轨迹数" / "Tracks"
"profile.stats.nodes" = "心绪节点" / "Mood Nodes"
"profile.stats.sites" = "到访圣迹" / "Sites Visited"
"profile.journeys" = "我的旅程" / "My Journeys"
"profile.echoes" = "我的回响" / "My Echoes"
"profile.titles" = "称号墙" / "Titles"

// 设置
"settings.title" = "设置" / "Settings"
"settings.language" = "语言" / "Language"
"settings.notifications" = "通知" / "Notifications"
"settings.notifications.track" = "轨迹记录提醒" / "Track Recording"
"settings.notifications.echo" = "回响通知" / "Echo Notifications"
"settings.privacy" = "隐私" / "Privacy"
"settings.privacy.policy" = "隐私政策" / "Privacy Policy"
"settings.privacy.data" = "数据管理" / "Data Management"
"settings.about" = "关于" / "About"
"settings.version" = "版本" / "Version"
"settings.logout" = "退出登录" / "Sign Out"
"button.done" = "完成" / "Done"

// 用户
"user.default_name" = "归途者" / "Wayfarer"
```

---

## 验收标准
- [ ] Apple ID 登录流程完整可用
- [ ] Google 登录流程完整可用
- [ ] 登录后进入主界面，用户信息正确保存
- [ ] 个人中心页面显示用户基本信息
- [ ] 设置页面可切换中英文语言
- [ ] 退出登录功能正常
- [ ] SwiftData 本地存储正常工作

---

## 技术要点
- Sign in with Apple 需要配置 nonce 用于安全验证
- Supabase Auth 使用 JWT Token，需要妥善管理会话
- 语言切换后需要刷新界面，考虑使用 `@AppStorage` 存储用户偏好

---

## 完成后
提交代码到 GitHub，备注："Day 2: 用户系统完整实现 + 数据层架构"
