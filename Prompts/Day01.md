# Day 1 开发提示词

## 今日目标
**项目基础架构 + 国际化框架 + 设计系统**

请阅读 `/Users/xiaomu/Desktop/Leyhome/GDD.md` 和 `/Users/xiaomu/Desktop/Leyhome/PRD.md`，然后完成以下任务。

---

## 任务清单

### 1. 项目目录结构
创建标准 SwiftUI 项目结构：
```
Leyhome/
├── App/
│   └── LeyhomeApp.swift
├── Models/
│   ├── User/
│   ├── Track/
│   ├── Node/
│   ├── SacredSite/
│   ├── Echo/
│   ├── Intention/
│   └── Guide/
├── Views/
│   ├── Main/
│   ├── Map/
│   ├── SacredSites/
│   ├── Guides/
│   ├── Profile/
│   └── Components/
├── Services/
│   ├── LocationService/
│   ├── SupabaseService/
│   ├── AudioService/
│   └── SyncService/
├── Managers/
│   ├── AuthManager.swift
│   ├── TrackingManager.swift
│   └── ThemeManager.swift
├── Extensions/
├── Utilities/
├── Resources/
│   ├── Localizable.xcstrings (国际化)
│   ├── Assets.xcassets
│   └── Fonts/
└── Localization/
    └── LocalizationManager.swift
```

### 2. 国际化框架搭建
必须在项目开始时就配置好中英文支持：

**创建 `Localizable.xcstrings` 文件**，包含以下基础文案：
```
// Tab 名称
"tab.map" = "心灵地图" / "Soul Map"
"tab.sacred_sites" = "圣迹" / "Sacred Sites"
"tab.guides" = "引路" / "Guides"
"tab.profile" = "我的" / "Profile"

// 通用
"app.name" = "地脉归途" / "Leyhome"
"app.slogan" = "所有的出发，都是为了回家" / "Every departure leads us home"

// 按钮
"button.start" = "开始" / "Start"
"button.end" = "结束" / "End"
"button.save" = "保存" / "Save"
"button.cancel" = "取消" / "Cancel"
"button.confirm" = "确认" / "Confirm"

// 登录
"login.welcome" = "欢迎回家" / "Welcome Home"
"login.apple" = "使用 Apple 登录" / "Sign in with Apple"
"login.google" = "使用 Google 登录" / "Sign in with Google"
```

**创建 `LocalizationManager.swift`**：
```swift
import Foundation

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    @Published var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"

    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
```

### 3. 设计系统（基于GDD视觉设计章节）

**创建 `Theme.swift`**：
```swift
import SwiftUI

struct LeyhomeTheme {
    // 主色调 (GDD 6.1)
    static let primary = Color(hex: "2D5A4E")      // 深青绿 - 自然与宁静
    static let secondary = Color(hex: "F5F0E6")    // 暖白 - 温暖与安全
    static let accent = Color(hex: "D4A574")       // 琥珀金 - 能量与智慧
    static let starlight = Color(hex: "A8C8E8")    // 淡蓝 - 星空与梦想

    // 能量线颜色 (GDD 6.2)
    struct EnergyLine {
        static let walking = Color(hex: "D4A574")   // 琥珀色 - 步行
        static let cycling = Color(hex: "4ECDC4")   // 青色 - 骑行
        static let driving = Color(hex: "E8E8E8")   // 银白色 - 驾车
        static let flying = Color(hex: "9B7EDE")    // 紫色 - 飞行
    }

    // 情绪颜色
    struct Mood {
        static let calm = Color(hex: "7EC8E3")      // 平静
        static let joy = Color(hex: "FFD93D")       // 愉悦
        static let anxiety = Color(hex: "FF6B6B")   // 焦虑
        static let relief = Color(hex: "95E1D3")    // 释然
        static let inspiration = Color(hex: "DDA0DD") // 灵感
        static let nostalgia = Color(hex: "DEB887")  // 怀旧
        static let gratitude = Color(hex: "98D8C8")  // 感恩
    }

    // 字体
    struct Fonts {
        static let title = Font.custom("Georgia", size: 24)     // 衬线标题
        static let body = Font.system(size: 16)                  // 无衬线正文
        static let quote = Font.custom("Snell Roundhand", size: 18) // 手写引用
    }

    // 间距
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // 圆角
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
```

### 4. Tab 导航架构

**创建 `MainTabView.swift`**：
```swift
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("tab.map".localized)
                }
                .tag(0)

            SacredSitesView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("tab.sacred_sites".localized)
                }
                .tag(1)

            GuidesView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("tab.guides".localized)
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("tab.profile".localized)
                }
                .tag(3)
        }
        .tint(LeyhomeTheme.primary)
    }
}
```

### 5. 占位视图
为每个Tab创建占位视图：
- `MapView.swift` - 心灵地图
- `SacredSitesView.swift` - 圣迹
- `GuidesView.swift` - 引路
- `ProfileView.swift` - 我的

### 6. 登录页面UI

**创建 `LoginView.swift`**：
包含：
- 品牌Logo区域
- 欢迎语："所有的出发，都是为了回家"
- Apple ID登录按钮
- 隐私政策链接

### 7. Supabase 配置

**创建 Supabase 项目**并配置以下表结构：
```sql
-- 用户表
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    apple_id TEXT UNIQUE,
    nickname TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 轨迹表
CREATE TABLE tracks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    travel_mode TEXT, -- walking/cycling/driving/flying
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    path GEOGRAPHY(LINESTRING, 4326),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 心绪节点表
CREATE TABLE nodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    track_id UUID REFERENCES tracks(id),
    user_id UUID REFERENCES users(id),
    mood_type TEXT,
    content TEXT,
    media_urls TEXT[],
    location GEOGRAPHY(POINT, 4326),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 圣迹表
CREATE TABLE sacred_sites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tier INTEGER, -- 1=源点圣迹, 2=地脉节点, 3=心绪锚点
    name_zh TEXT,
    name_en TEXT,
    description_zh TEXT,
    description_en TEXT,
    lore_zh TEXT,
    lore_en TEXT,
    location GEOGRAPHY(POINT, 4326),
    image_url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 回响表
CREATE TABLE echoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID REFERENCES sacred_sites(id),
    user_id UUID REFERENCES users(id),
    content TEXT,
    media_urls TEXT[],
    is_public BOOLEAN DEFAULT FALSE,
    is_anonymous BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 意向表
CREATE TABLE intentions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID REFERENCES sacred_sites(id),
    user_id UUID REFERENCES users(id),
    target_year INTEGER,
    target_month INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 先行者表
CREATE TABLE guides (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT,
    title_zh TEXT,
    title_en TEXT,
    bio_zh TEXT,
    bio_en TEXT,
    avatar_url TEXT,
    is_verified BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 星图表
CREATE TABLE constellations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guide_id UUID REFERENCES guides(id),
    name_zh TEXT,
    name_en TEXT,
    description_zh TEXT,
    description_en TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 寻迹申请表
CREATE TABLE nominations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    name TEXT,
    description TEXT,
    reason TEXT,
    location GEOGRAPHY(POINT, 4326),
    media_urls TEXT[],
    status TEXT DEFAULT 'pending', -- pending/approved/rejected
    created_at TIMESTAMP DEFAULT NOW()
);
```

**创建 `SupabaseConfig.swift`**：
```swift
import Supabase

struct SupabaseConfig {
    static let url = URL(string: "YOUR_SUPABASE_URL")!
    static let anonKey = "YOUR_SUPABASE_ANON_KEY"

    static let client = SupabaseClient(
        supabaseURL: url,
        supabaseKey: anonKey
    )
}
```

---

## 验收标准
- [ ] 项目目录结构完整
- [ ] 国际化框架可用，中英文可切换
- [ ] 设计系统颜色/字体/间距已定义
- [ ] 4个Tab可正常切换
- [ ] 登录页UI显示正常
- [ ] Supabase项目已创建，表结构已配置

---

## 技术要点
- 使用 `Localizable.xcstrings`（Xcode 15+ String Catalogs）
- 所有用户可见文案必须使用 `.localized` 扩展
- 主题色使用 `LeyhomeTheme` 统一管理

---

## 完成后
提交代码到 GitHub，备注："Day 1: 项目基础架构 + 国际化框架 + 设计系统"
