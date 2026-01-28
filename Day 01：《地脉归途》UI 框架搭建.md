# Day 01：《地脉归途》UI 框架搭建

## 角色设定

你是一位资深的 iOS 开发专家，精通 Swift 5 和 SwiftUI，对构建富有诗意和情感的 App 体验充满热情。

## 项目信息

- **项目名称**：地脉归途 (Leyhome)

- **项目路径**：【替换为你的项目路径】

- **最低支持版本**：iOS 16.0

- **架构模式**：SwiftUI + MVVM

## 任务目标

搭建 App 的基础 UI 框架，包含主题配色、启动页、Tab 导航和占位视图，整体风格需体现“宁静、简约、诗意”的治愈感。

---

## 第一步：创建主题配色文件

创建 `Theme/LeyhomeTheme.swift`，定义治愈与自然风格的配色：

swift

```swift
import SwiftUI

/// 地脉归途主题配色
enum LeyhomeTheme {    // MARK: - 主色调 (自然与宁静)
    /// 主背景色 (暖白，如未漂白的纸张)
    static let background = Color(red: 0.96, green: 0.94, blue: 0.90) // #F5F0E6
    /// 卡片/表面背景色 (比主背景更亮的白色)
    static let surface = Color.white.opacity(0.8)        // MARK: - 强调色 (能量与智慧)
    /// 主强调色 (琥珀金，用于选中项和行动点)
    static let primary = Color(red: 0.83, green: 0.65, blue: 0.45) // #D4A574
    /// 次强调色 (星辰蓝，用于点缀和梦想)
    static let secondary = Color(red: 0.66, green: 0.78, blue: 0.91) // #A8C8E8

    // MARK: - 文字色
    /// 主文字色 (深青绿，沉稳且富有生命力)
    static let textPrimary = Color(red: 0.18, green: 0.35, blue: 0.31) // #2D5A4E
    /// 次要文字色 (中等灰色)
    static let textSecondary = Color.gray    /// 弱化文字色 (浅灰色)
    static let textMuted = Color.gray.opacity(0.6)    // MARK: - 状态色 (柔和自然)
    static let success = Color(red: 0.4, green: 0.7, blue: 0.5) // 柔和的绿
    static let warning = Color(red: 0.9, green: 0.7, blue: 0.4) // 温和的黄
    static let danger = Color(red: 0.8, green: 0.5, blue: 0.5)  // 褪色的红
}
```

---

## 第二步：创建启动页

创建 `Views/SplashView.swift`，一个宁静、富有诗意的启动页：

swift

```swift
import SwiftUI/// 启动页视图struct SplashView: View {    @State private var hasStartedAnimation = false    @State private var hasFinishedLoading = false    @Binding var isFinished: Bool    var body: some View {        ZStack {            // 背景色            LeyhomeTheme.background.ignoresSafeArea()            VStack(spacing: 24) {                Spacer()                // Logo - 能量线汇聚成一点                ZStack {                    // 呼吸感光晕                    Circle()                        .fill(                            RadialGradient(                                colors: [LeyhomeTheme.primary.opacity(0.3), LeyhomeTheme.primary.opacity(0)],                                center: .center,                                startRadius: 10,                                endRadius: 120
                            )                        )                        .scaleEffect(hasStartedAnimation ? 1.5 : 1.0)                        .animation(                            .easeInOut(duration: 2.5).repeatForever(autoreverses: true),                            value: hasStartedAnimation                        )                                        // 核心光点                    Circle()                        .fill(LeyhomeTheme.primary)                        .frame(width: 8, height: 8)                        .shadow(color: LeyhomeTheme.primary, radius: 10, x: 0, y: 0)                }                .opacity(hasStartedAnimation ? 1 : 0)                .frame(height: 150)                // 标题                VStack(spacing: 8) {                    Text("地脉归途")                        .font(.system(size: 32, weight: .light)) // 使用更优雅的字体                        .foregroundColor(LeyhomeTheme.textPrimary)                                        Text("LEYHOME")                        .font(.system(size: 12, weight: .regular))                        .foregroundColor(LeyhomeTheme.textSecondary)                        .kerning(4) // 增加字间距                }                .opacity(hasStartedAnimation ? 1 : 0)                                Spacer()                // 加载提示                Text(hasFinishedLoading ? "回归内在世界" : "正在唤醒地脉...")                    .font(.caption)                    .foregroundColor(LeyhomeTheme.textMuted)                    .animation(.easeInOut, value: hasFinishedLoading)                    .padding(.bottom, 60)            }        }        .onAppear {            // 启动入场动画            withAnimation(.easeOut(duration: 1.5)) {                hasStartedAnimation = true            }                        // 模拟加载            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {                hasFinishedLoading = true            }                        // 结束启动页            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {                withAnimation(.easeInOut(duration: 0.5)) {                    isFinished = true                }            }        }    }}

#Preview {    SplashView(isFinished: .constant(false))}
```

---

## 第三步：创建通用占位视图组件

创建 `Components/PlaceholderView.swift`，用于各 Tab 的初始占位：

swift

```swift
import SwiftUI/// 通用占位视图struct PlaceholderView: View {    let icon: String    let title: LocalizedStringKey    let subtitle: LocalizedStringKey    var body: some View {        ZStack {            LeyhomeTheme.background                .ignoresSafeArea()                        VStack(spacing: 16) {                Image(systemName: icon)                    .font(.system(size: 50, weight: .thin)) // 使用更纤细的图标                    .foregroundColor(LeyhomeTheme.primary)                Text(title)                    .font(.title2)                    .fontWeight(.light)                    .foregroundColor(LeyhomeTheme.textPrimary)                Text(subtitle)                    .font(.subheadline)                    .foregroundColor(LeyhomeTheme.textSecondary)                    .multilineTextAlignment(.center)                    .padding(.horizontal)            }        }    }}

#Preview {    PlaceholderView(        icon: "map.fill",        title: "心灵地图",        subtitle: "你的每一步，都在绘制独一无二的心灵画卷"
    )}
```

---

## 第四步：创建各 Tab 页面文件

根据 PRD 和 GDD 的核心功能，创建 `Views/Tabs/` 文件夹，包含 4 个 Tab 页面：

### 4.1 MapTabView.swift (心灵地图)

swift

```swift
import SwiftUI

struct MapTabView: View {    var body: some View {        PlaceholderView(            icon: "map.fill",            title: "心灵地图",            subtitle: "你的每一步，都在绘制独一无二的心灵画卷"
        )    }}
```

### 4.2 SitesTabView.swift (圣迹)

swift

```swift
import SwiftUI

struct SitesTabView: View {    var body: some View {        PlaceholderView(            icon: "sparkles", // 星辰/圣迹的意象
            title: "圣迹",            subtitle: "探索世界的能量节点，感受孤独的共鸣"
        )    }}
```

### 4.3 GuidanceTabView.swift (引路)

swift

```swift
import SwiftUI

struct GuidanceTabView: View {    var body: some View {        PlaceholderView(            icon: "person.wave.2.fill", // 两人同行的意象
            title: "引路",            subtitle: "跟随先行者的脚步，借他人之光照亮自己的路"
        )    }}
```

### 4.4 ProfileTabView.swift (我的)

swift

```swift
import SwiftUI

struct ProfileTabView: View {    var body: some View {        PlaceholderView(            icon: "person.fill",            title: "我的",            subtitle: "回顾你的成长，整理内在世界"
        )    }}
```

---

## 第五步：创建主 Tab 导航视图

创建 `Views/MainTabView.swift`，作为 App 的主导航：

swift

```swift
import SwiftUIstruct MainTabView: View {    @State private var selectedTab = 0

    init() {        // 自定义 TabBar 外观，营造温暖、通透的感觉        let appearance = UITabBarAppearance()        appearance.configureWithOpaqueBackground()        appearance.backgroundColor = UIColor(LeyhomeTheme.background).withAlphaComponent(0.8)        appearance.shadowColor = .clear // 移除顶部分隔线        UITabBar.appearance().standardAppearance = appearance        UITabBar.appearance().scrollEdgeAppearance = appearance    }    var body: some View {        TabView(selection: $selectedTab) {            MapTabView()                .tabItem {                    Image(systemName: "map.fill")                    Text("地图")                }                .tag(0)            SitesTabView()                .tabItem {                    Image(systemName: "sparkles")                    Text("圣迹")                }                .tag(1)            GuidanceTabView()                .tabItem {                    Image(systemName: "person.wave.2.fill")                    Text("引路")                }                .tag(2)            ProfileTabView()                .tabItem {                    Image(systemName: "person.fill")                    Text("我的")                }                .tag(3)        }        .tint(LeyhomeTheme.primary) // 选中项颜色    }}

#Preview {    MainTabView()}
```

---

## 第六步：创建根视图（控制启动流程）

创建 `Views/RootView.swift`，控制启动页到主界面的切换：

swift

```swift
import SwiftUI

/// 根视图：控制启动页与主界面的切换
struct RootView: View {    @State private var splashFinished = false

    var body: some View {        ZStack {            if splashFinished {                MainTabView()                    .transition(.opacity) // 使用淡入淡出，更柔和
            } else {                SplashView(isFinished: $splashFinished)            }        }        .animation(.easeInOut(duration: 0.8), value: splashFinished)    }}
```

---

## 第七步：修改 App 入口

修改 App 入口文件，将主视图替换为 `RootView`：

swift

```swift
import SwiftUI

@main
struct LeyhomeApp: App {    var body: some Scene {        WindowGroup {            RootView()        }    }}
```

---

## 第八步：文件结构

完成后项目结构如下：

```
Leyhome/├── LeyhomeApp.swift               # App 入口
├── Theme/│   └── LeyhomeTheme.swift         # 主题配色
├── Components/│   └── PlaceholderView.swift      # 通用占位视图
└── Views/    ├── RootView.swift             # 根视图（控制启动流程）
    ├── SplashView.swift           # 启动页（宁静风格）
    ├── MainTabView.swift          # 主 Tab 导航
    └── Tabs/        ├── MapTabView.swift       # 地图 Tab
        ├── SitesTabView.swift     # 圣迹 Tab
        ├── GuidanceTabView.swift  # 引路 Tab
        └── ProfileTabView.swift   # 我的 Tab
```

---

## 代码规范

1. 所有用户可见文本应使用 `LocalizedStringKey` 类型，为多语言做准备。

2. 颜色统一使用 `LeyhomeTheme` 中定义的颜色，确保视觉一致性。

3. 每个 `View` 文件包含 `#Preview` 预览代码。

4. 文件按功能分文件夹组织，保持结构清晰。

---

## 输出要求

1. 按上述结构创建所有文件。

2. 确保每个文件可以独立编译。

3. App 启动时先显示宁静风格的启动页，3 秒后自动进入主界面。

4. 启动页有符合“治愈”和“诗意”感的动画效果。

5. 主界面显示 4 个 Tab，Tab 栏风格简约，选中项为琥珀金色。
