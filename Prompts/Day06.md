# Day 6 开发提示词

## 今日目标
**圣迹系统完整实现（三层体系 + 星脉图 + 详情页 + 旅程规划器）**

请阅读 `/Users/xiaomu/Desktop/Leyhome/GDD.md` 第2.2节（三层地脉节点体系）、第4.2节（圣迹系统）和 `/Users/xiaomu/Desktop/Leyhome/PRD.md` 第5.2节，然后完成以下任务。

---

## 任务清单

### 1. 圣迹数据模型

**创建 `SacredSite.swift`**：
```swift
import Foundation
import SwiftData
import CoreLocation

enum SiteTier: Int, Codable {
    case primal = 1      // 源点圣迹 (Tier 1)
    case leyNode = 2     // 地脉节点 (Tier 2)
    case anchor = 3      // 心绪锚点 (Tier 3)

    var nameZh: String {
        switch self {
        case .primal: return "源点圣迹"
        case .leyNode: return "地脉节点"
        case .anchor: return "心绪锚点"
        }
    }

    var nameEn: String {
        switch self {
        case .primal: return "Primal Site"
        case .leyNode: return "Ley Node"
        case .anchor: return "Anchor of Serenity"
        }
    }

    // GDD 6.3 图标设计
    var iconStyle: SiteIconStyle {
        switch self {
        case .primal: return .mandala      // 动态旋转的光构几何体
        case .leyNode: return .elegant     // 精致的静态图标
        case .anchor: return .ripple       // 柔和的光点/涟漪
        }
    }
}

enum SiteIconStyle {
    case mandala   // 曼陀罗
    case elegant   // 精致线条
    case ripple    // 涟漪光点
}

@Model
class SacredSite: Identifiable {
    @Attribute(.unique) var id: UUID
    var tier: Int
    var nameZh: String
    var nameEn: String
    var descriptionZh: String  // 一句话描述
    var descriptionEn: String
    var loreZh: String         // 地脉解读（GDD: 充满灵性的官方文字）
    var loreEn: String
    var historyZh: String?     // 历史与传说
    var historyEn: String?

    // 位置
    var latitude: Double
    var longitude: Double
    var continent: String      // 大洲分类
    var country: String
    var region: String?

    // 媒体
    var imageUrl: String?
    var videoUrl: String?
    var iconType: String?      // 图标类型（用于 Tier 3）

    // 统计
    var visitorCount: Int = 0
    var echoCount: Int = 0
    var intentionCount: Int = 0

    // 创建者（用于用户提名的圣迹）
    var creatorId: UUID?
    var creatorName: String?

    var createdAt: Date

    init(tier: SiteTier, nameZh: String, nameEn: String) {
        self.id = UUID()
        self.tier = tier.rawValue
        self.nameZh = nameZh
        self.nameEn = nameEn
        self.descriptionZh = ""
        self.descriptionEn = ""
        self.loreZh = ""
        self.loreEn = ""
        self.latitude = 0
        self.longitude = 0
        self.continent = ""
        self.country = ""
        self.createdAt = Date()
    }

    var siteTier: SiteTier {
        SiteTier(rawValue: tier) ?? .anchor
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var name: String {
        LocalizationManager.shared.currentLanguage == "zh" ? nameZh : nameEn
    }

    var description: String {
        LocalizationManager.shared.currentLanguage == "zh" ? descriptionZh : descriptionEn
    }

    var lore: String {
        LocalizationManager.shared.currentLanguage == "zh" ? loreZh : loreEn
    }

    var history: String? {
        LocalizationManager.shared.currentLanguage == "zh" ? historyZh : historyEn
    }
}
```

### 2. 预置圣迹数据

**创建 `SacredSiteData.swift`**：
```swift
import Foundation

struct SacredSiteData {
    static let primalSites: [[String: Any]] = [
        // Tier 1 源点圣迹（GDD示例）
        [
            "nameZh": "吉萨金字塔",
            "nameEn": "Great Pyramid of Giza",
            "descriptionZh": "地球主脉的心脏，古老文明的永恒见证",
            "descriptionEn": "The heart of Earth's main ley line, eternal witness of ancient civilization",
            "loreZh": "四千年来，金字塔默默矗立于尼罗河畔，它不仅是法老的安息之所，更是地球能量网络最重要的枢纽之一。站在它脚下，你能感受到时间的厚重与宇宙的浩瀚交织在一起。",
            "loreEn": "For four millennia, the pyramids have stood silently by the Nile. More than a pharaoh's resting place, they are one of the most crucial hubs in Earth's energy network. Standing at their base, you can feel the weight of time intertwining with the vastness of the universe.",
            "latitude": 29.9792,
            "longitude": 31.1342,
            "continent": "Africa",
            "country": "Egypt",
            "imageUrl": "https://example.com/pyramid.jpg"
        ],
        [
            "nameZh": "马丘比丘",
            "nameEn": "Machu Picchu",
            "descriptionZh": "云端之城，印加帝国的精神圣殿",
            "descriptionEn": "City in the clouds, spiritual sanctuary of the Inca Empire",
            "loreZh": "隐匿于安第斯山脉的云雾之中，马丘比丘承载着印加文明对宇宙的理解。这里的每一块石头都经过精心打磨，与星辰的轨迹完美呼应。攀登至此，你将完成一次穿越时空的朝圣。",
            "loreEn": "Hidden in the mists of the Andes, Machu Picchu embodies the Inca understanding of the cosmos. Every stone here is precisely crafted, perfectly aligned with the trajectories of stars. Climbing here, you complete a pilgrimage through time and space.",
            "latitude": -13.1631,
            "longitude": -72.5450,
            "continent": "South America",
            "country": "Peru",
            "imageUrl": "https://example.com/machupicchu.jpg"
        ],
        [
            "nameZh": "巨石阵",
            "nameEn": "Stonehenge",
            "descriptionZh": "史前巨石圈，天地交汇的神秘门户",
            "descriptionEn": "Prehistoric stone circle, a mysterious gateway where heaven and earth meet",
            "loreZh": "五千年前的先民，用超乎想象的智慧竖起这些巨石。每年夏至日出，阳光穿过石门洒向祭坛，天地之间的能量在此刻达到顶峰。这是一个与宇宙对话的地方。",
            "loreEn": "Five thousand years ago, our ancestors erected these massive stones with unimaginable wisdom. Every summer solstice, sunrise light passes through the stone gates onto the altar, when the energy between heaven and earth reaches its peak.",
            "latitude": 51.1789,
            "longitude": -1.8262,
            "continent": "Europe",
            "country": "United Kingdom",
            "imageUrl": "https://example.com/stonehenge.jpg"
        ],
        [
            "nameZh": "泰山",
            "nameEn": "Mount Tai",
            "descriptionZh": "五岳之首，帝王封禅之地",
            "descriptionEn": "Chief of the Five Sacred Mountains, where emperors communed with heaven",
            "loreZh": "自古以来，泰山便是中华民族精神的象征。七十二位帝王曾在此封禅，祈求天地庇佑。登临泰山之巅，云海翻涌，仿佛触手可及天庭。这里的每一步，都是与先人的对话。",
            "loreEn": "Since ancient times, Mount Tai has been a symbol of the Chinese spirit. Seventy-two emperors performed the Feng and Shan sacrifices here. At the summit, clouds surge like seas, as if heaven is within reach.",
            "latitude": 36.2541,
            "longitude": 117.1010,
            "continent": "Asia",
            "country": "China",
            "imageUrl": "https://example.com/mounttai.jpg"
        ],
        [
            "nameZh": "富士山",
            "nameEn": "Mount Fuji",
            "descriptionZh": "日本圣山，自然与精神的完美统一",
            "descriptionEn": "Japan's sacred mountain, perfect unity of nature and spirit",
            "loreZh": "富士山是日本人心中永恒的精神家园。无论是远眺还是攀登，它都能给予你内心的宁静与力量。那完美的圆锥形轮廓，仿佛是大地与天空之间最优雅的连接。",
            "loreEn": "Mount Fuji is the eternal spiritual home in the hearts of the Japanese. Whether viewed from afar or climbed, it bestows inner peace and strength. Its perfect conical silhouette seems like the most elegant connection between earth and sky.",
            "latitude": 35.3606,
            "longitude": 138.7274,
            "continent": "Asia",
            "country": "Japan",
            "imageUrl": "https://example.com/fuji.jpg"
        ]
    ]

    static let leyNodes: [[String: Any]] = [
        // Tier 2 地脉节点（示例）
        [
            "nameZh": "西湖",
            "nameEn": "West Lake",
            "descriptionZh": "人间天堂，千年诗意的栖居",
            "descriptionEn": "Paradise on earth, a millennium of poetic dwelling",
            "loreZh": "西湖是江南灵气的凝聚之地。苏堤、断桥、雷峰塔，每一处都承载着无数文人墨客的情思。漫步湖畔，你会发现自己不知不觉已融入这幅水墨画中。",
            "loreEn": "West Lake is where the spirit of Jiangnan converges. Su Causeway, Broken Bridge, Leifeng Pagoda - each carries the emotions of countless poets and scholars.",
            "latitude": 30.2590,
            "longitude": 120.1388,
            "continent": "Asia",
            "country": "China",
            "region": "Hangzhou"
        ],
        [
            "nameZh": "中央公园",
            "nameEn": "Central Park",
            "descriptionZh": "都市绿洲，钢铁森林中的呼吸",
            "descriptionEn": "Urban oasis, breathing space in the concrete jungle",
            "loreZh": "在曼哈顿的心脏地带，中央公园是这座不夜城最珍贵的喘息之地。无论季节如何更迭，这里始终是纽约人寻找内心平静的圣地。",
            "loreEn": "In the heart of Manhattan, Central Park is this city's most precious breathing space. Regardless of the season, it remains the sanctuary where New Yorkers find inner peace.",
            "latitude": 40.7829,
            "longitude": -73.9654,
            "continent": "North America",
            "country": "USA",
            "region": "New York"
        ]
    ]

    // 加载圣迹数据
    static func loadAllSites() -> [SacredSite] {
        var sites: [SacredSite] = []

        for data in primalSites {
            let site = createSite(from: data, tier: .primal)
            sites.append(site)
        }

        for data in leyNodes {
            let site = createSite(from: data, tier: .leyNode)
            sites.append(site)
        }

        return sites
    }

    private static func createSite(from data: [String: Any], tier: SiteTier) -> SacredSite {
        let site = SacredSite(
            tier: tier,
            nameZh: data["nameZh"] as? String ?? "",
            nameEn: data["nameEn"] as? String ?? ""
        )
        site.descriptionZh = data["descriptionZh"] as? String ?? ""
        site.descriptionEn = data["descriptionEn"] as? String ?? ""
        site.loreZh = data["loreZh"] as? String ?? ""
        site.loreEn = data["loreEn"] as? String ?? ""
        site.latitude = data["latitude"] as? Double ?? 0
        site.longitude = data["longitude"] as? Double ?? 0
        site.continent = data["continent"] as? String ?? ""
        site.country = data["country"] as? String ?? ""
        site.region = data["region"] as? String
        site.imageUrl = data["imageUrl"] as? String
        return site
    }
}
```

### 3. 星脉图视图

**创建 `StarMapView.swift`**（基于GDD 4.2.2）：
```swift
import SwiftUI
import MapKit

struct StarMapView: View {
    @State private var sites: [SacredSite] = []
    @State private var selectedSite: SacredSite?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showSiteDetail = false

    var body: some View {
        ZStack {
            // 星空背景
            StarryBackground()

            // 地图层
            Map(position: $cameraPosition) {
                ForEach(sites) { site in
                    Annotation(site.name, coordinate: site.coordinate) {
                        SiteMarker(site: site, isSelected: selectedSite?.id == site.id)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedSite = site
                                }
                            }
                    }
                }
            }
            .mapStyle(.imagery(elevation: .realistic))
            .opacity(0.7)

            // 底部卡片
            VStack {
                Spacer()
                if let site = selectedSite {
                    SitePreviewCard(site: site) {
                        showSiteDetail = true
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()
        }
        .sheet(isPresented: $showSiteDetail) {
            if let site = selectedSite {
                SacredSiteDetailView(site: site)
            }
        }
        .onAppear {
            sites = SacredSiteData.loadAllSites()
        }
    }
}

struct StarryBackground: View {
    @State private var stars: [Star] = []

    var body: some View {
        Canvas { context, size in
            for star in stars {
                let rect = CGRect(x: star.x * size.width, y: star.y * size.height, width: star.size, height: star.size)
                context.fill(Circle().path(in: rect), with: .color(.white.opacity(star.brightness)))
            }
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "0a0a1a"), Color(hex: "1a1a3a")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            stars = (0..<100).map { _ in
                Star(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: 0...1),
                    size: CGFloat.random(in: 1...3),
                    brightness: Double.random(in: 0.3...1.0)
                )
            }
        }
    }
}

struct Star {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let brightness: Double
}

struct SiteMarker: View {
    let site: SacredSite
    let isSelected: Bool

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // 根据 Tier 显示不同样式
            switch site.siteTier {
            case .primal:
                // 曼陀罗动态效果
                MandalaMarker(rotation: rotation)
                    .frame(width: 40, height: 40)
                    .onAppear {
                        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }

            case .leyNode:
                // 精致图标
                Circle()
                    .fill(LeyhomeTheme.accent)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )

            case .anchor:
                // 涟漪光点
                RippleMarker()
                    .frame(width: 20, height: 20)
            }
        }
        .scaleEffect(isSelected ? 1.3 : 1.0)
        .shadow(color: site.siteTier == .primal ? LeyhomeTheme.accent : .white, radius: isSelected ? 10 : 5)
    }
}

struct MandalaMarker: View {
    let rotation: Double

    var body: some View {
        ZStack {
            ForEach(0..<6) { i in
                Capsule()
                    .fill(LeyhomeTheme.accent)
                    .frame(width: 3, height: 20)
                    .offset(y: -10)
                    .rotationEffect(.degrees(Double(i) * 60 + rotation))
            }
            Circle()
                .fill(Color.white)
                .frame(width: 10, height: 10)
        }
    }
}

struct RippleMarker: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(LeyhomeTheme.starlight, lineWidth: 2)
                .scaleEffect(scale)
                .opacity(opacity)

            Circle()
                .fill(LeyhomeTheme.starlight)
                .frame(width: 8, height: 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false)) {
                scale = 2.0
                opacity = 0
            }
        }
    }
}

struct SitePreviewCard: View {
    let site: SacredSite
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: LeyhomeTheme.Spacing.md) {
                // 缩略图
                AsyncImage(url: URL(string: site.imageUrl ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    // Tier 标签
                    Text(site.siteTier.nameZh)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(LeyhomeTheme.accent.opacity(0.2))
                        .cornerRadius(4)

                    Text(site.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(site.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(LeyhomeTheme.CornerRadius.md)
        }
        .buttonStyle(.plain)
    }
}
```

### 4. 圣迹列表视图

**创建 `SacredSiteListView.swift`**：
```swift
import SwiftUI

struct SacredSiteListView: View {
    @State private var sites: [SacredSite] = []
    @State private var searchText = ""
    @State private var selectedContinent: String?
    @State private var selectedTier: SiteTier?

    private let continents = ["Asia", "Europe", "Africa", "North America", "South America", "Oceania"]

    var body: some View {
        List {
            // 筛选器
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "sacred.all".localized, isSelected: selectedTier == nil) {
                            selectedTier = nil
                        }
                        ForEach([SiteTier.primal, .leyNode, .anchor], id: \.self) { tier in
                            FilterChip(title: tier.nameZh, isSelected: selectedTier == tier) {
                                selectedTier = tier
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            // 按大洲分组
            ForEach(groupedSites.keys.sorted(), id: \.self) { continent in
                Section(header: Text(continent)) {
                    ForEach(groupedSites[continent] ?? []) { site in
                        NavigationLink(destination: SacredSiteDetailView(site: site)) {
                            SiteRowView(site: site)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "sacred.search".localized)
        .navigationTitle("tab.sacred_sites".localized)
        .onAppear {
            sites = SacredSiteData.loadAllSites()
        }
    }

    private var filteredSites: [SacredSite] {
        var result = sites

        if let tier = selectedTier {
            result = result.filter { $0.siteTier == tier }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.country.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    private var groupedSites: [String: [SacredSite]] {
        Dictionary(grouping: filteredSites) { $0.continent }
    }
}

struct SiteRowView: View {
    let site: SacredSite

    var body: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            AsyncImage(url: URL(string: site.imageUrl ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(site.name)
                        .font(.headline)

                    if site.siteTier == .primal {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(LeyhomeTheme.accent)
                    }
                }

                Text("\(site.country)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: LeyhomeTheme.Spacing.sm) {
                    Label("\(site.visitorCount)", systemImage: "person.2")
                    Label("\(site.echoCount)", systemImage: "bubble.left")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? LeyhomeTheme.primary : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}
```

### 5. 圣迹详情页

**创建 `SacredSiteDetailView.swift`**（基于GDD 4.2.3）：
```swift
import SwiftUI

struct SacredSiteDetailView: View {
    let site: SacredSite
    @State private var showJourneyPlanner = false
    @State private var showIntentionSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 沉浸式头图
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: site.imageUrl ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [LeyhomeTheme.primary, LeyhomeTheme.starlight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    }
                    .frame(height: 300)
                    .clipped()

                    // 渐变遮罩
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // 标题信息
                    VStack(alignment: .leading, spacing: 8) {
                        Text(site.siteTier.nameZh)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(LeyhomeTheme.accent)
                            .cornerRadius(4)

                        Text(site.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("\(site.country) · \(site.region ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }

                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    // 地脉解读（GDD: 充满灵性的官方文字）
                    VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                        Text("sacred.lore".localized)
                            .font(.headline)

                        Text(site.lore)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)

                    // 历史与传说
                    if let history = site.history, !history.isEmpty {
                        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                            Text("sacred.history".localized)
                                .font(.headline)

                            Text(history)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // 统计数据
                    HStack(spacing: LeyhomeTheme.Spacing.lg) {
                        StatView(value: "\(site.visitorCount)", label: "sacred.visitors".localized)
                        StatView(value: "\(site.echoCount)", label: "sacred.echoes".localized)
                        StatView(value: "\(site.intentionCount)", label: "sacred.intentions".localized)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)

                    // 此地的回响
                    EchoesSection(siteId: site.id)

                    // 操作按钮
                    VStack(spacing: LeyhomeTheme.Spacing.md) {
                        // 规划朝圣之旅
                        Button(action: { showJourneyPlanner = true }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("sacred.plan_journey".localized)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LeyhomeTheme.primary)
                            .cornerRadius(LeyhomeTheme.CornerRadius.md)
                        }

                        // 我亦向往
                        Button(action: { showIntentionSheet = true }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                Text("intention.aspire".localized)
                            }
                            .font(.headline)
                            .foregroundColor(LeyhomeTheme.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LeyhomeTheme.primary.opacity(0.1))
                            .cornerRadius(LeyhomeTheme.CornerRadius.md)
                        }
                    }
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showJourneyPlanner) {
            JourneyPlannerView(site: site)
        }
        .sheet(isPresented: $showIntentionSheet) {
            IntentionSheet(site: site)
        }
    }
}

struct StatView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(LeyhomeTheme.primary)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
```

### 6. 旅程规划器

**创建 `JourneyPlannerView.swift`**（基于GDD 4.2.4）：
```swift
import SwiftUI
import CoreLocation

struct JourneyPlannerView: View {
    let site: SacredSite
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager.shared

    @State private var selectedMode: JourneyMode?
    @State private var estimatedDistance: Double = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    // 目的地卡片
                    DestinationCard(site: site, distance: estimatedDistance)

                    // 出行方式选择（GDD 4.2.4 哲学解读）
                    Text("journey.choose_way".localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(JourneyMode.allCases, id: \.self) { mode in
                        JourneyModeCard(
                            mode: mode,
                            isSelected: selectedMode == mode
                        ) {
                            withAnimation {
                                selectedMode = mode
                            }
                        }
                    }

                    // 开始导航按钮
                    if selectedMode != nil {
                        Button(action: startNavigation) {
                            HStack {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                Text("journey.start".localized)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LeyhomeTheme.primary)
                            .cornerRadius(LeyhomeTheme.CornerRadius.md)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("journey.planner".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("button.cancel".localized) { dismiss() }
                }
            }
            .onAppear {
                calculateDistance()
            }
        }
    }

    private func calculateDistance() {
        guard let currentLocation = locationManager.currentLocation else { return }
        let destination = CLLocation(latitude: site.latitude, longitude: site.longitude)
        estimatedDistance = currentLocation.distance(from: destination) / 1000 // km
    }

    private func startNavigation() {
        // 调用系统地图导航
        let coordinate = site.coordinate
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = site.name

        let launchOptions: [String: Any]
        switch selectedMode {
        case .walking:
            launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        case .driving:
            launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        default:
            launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault]
        }

        mapItem.openInMaps(launchOptions: launchOptions)
    }
}

enum JourneyMode: CaseIterable {
    case flying
    case highSpeedRail
    case train
    case driving
    case walking

    var icon: String {
        switch self {
        case .flying: return "airplane"
        case .highSpeedRail: return "tram.fill"
        case .train: return "train.side.front.car"
        case .driving: return "car.fill"
        case .walking: return "figure.walk"
        }
    }

    // GDD 旅程规划器设计
    var titleZh: String {
        switch self {
        case .flying: return "飞机 - 超越凡尘"
        case .highSpeedRail: return "高铁 - 流动冥想"
        case .train: return "火车 - 感受脉搏"
        case .driving: return "自驾 - 自由意志"
        case .walking: return "步行 - 身心合一"
        }
    }

    var descriptionZh: String {
        switch self {
        case .flying:
            return "以最快速度跨越物理障碍，如同灵魂出窍，从上帝视角审视山川河流。适合长距离的心灵跳跃。"
        case .highSpeedRail:
            return "平稳、高速、有节奏地穿行于大地之上。窗外飞速掠过的风景，容易让人进入流动的冥想状态。"
        case .train:
            return "以更从容、更贴近大地肌理的速度前行。火车与铁轨的'况且'声，如同大地的脉搏。"
        case .driving:
            return "拥有对路线和节奏的绝对掌控力。可以随时偏离主路，去探寻地图上没有标记的湖泊或古道。"
        case .walking:
            return "与大地最极致的连接。你的每一步都在与地脉共振，用双脚阅读土地的故事。这是最原始、最深刻的朝圣方式。"
        }
    }

    var cautionZh: String {
        switch self {
        case .flying:
            return "旅途大部分在高空，会暂时与地表能量隔绝。起降的繁忙可能消耗心神。"
        case .highSpeedRail:
            return "速度是它的优点也是缺点，你将看到风景但无法触摸。"
        case .train:
            return "需要将大量时间交予旅途本身，这是一次对'慢'的臣服。"
        case .driving:
            return "驾驶需要持续投入专注力，可能占据用于内省的'后台算力'。"
        case .walking:
            return "对体能和意志力的巨大考验。只适合作为旅程中最后、最神圣的一段仪式。"
        }
    }
}

struct JourneyModeCard: View {
    let mode: JourneyMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                HStack {
                    Image(systemName: mode.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : LeyhomeTheme.primary)
                        .frame(width: 40, height: 40)
                        .background(isSelected ? LeyhomeTheme.primary : LeyhomeTheme.primary.opacity(0.1))
                        .cornerRadius(8)

                    Text(mode.titleZh)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(LeyhomeTheme.primary)
                    }
                }

                Text(mode.descriptionZh)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(isSelected ? nil : 2)

                if isSelected {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.caption)
                        Text(mode.cautionZh)
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(isSelected ? LeyhomeTheme.primary.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(LeyhomeTheme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.md)
                    .stroke(isSelected ? LeyhomeTheme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct DestinationCard: View {
    let site: SacredSite
    let distance: Double

    var body: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            AsyncImage(url: URL(string: site.imageUrl ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(site.name)
                    .font(.headline)
                Text("\(site.country)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(String(format: "%.0f km", distance))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(LeyhomeTheme.primary)
                Text("journey.distance".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
    }
}
```

### 7. 国际化文案补充

```
// 圣迹
"sacred.all" = "全部" / "All"
"sacred.search" = "搜索圣迹" / "Search sacred sites"
"sacred.lore" = "地脉解读" / "Ley Line Interpretation"
"sacred.history" = "历史与传说" / "History & Legends"
"sacred.visitors" = "到访" / "Visitors"
"sacred.echoes" = "回响" / "Echoes"
"sacred.intentions" = "向往" / "Aspirations"
"sacred.plan_journey" = "规划朝圣之旅" / "Plan Your Pilgrimage"

// 旅程规划
"journey.planner" = "旅程规划" / "Journey Planner"
"journey.choose_way" = "选择你的旅途方式" / "Choose Your Way"
"journey.distance" = "直线距离" / "Distance"
"journey.start" = "开始导航" / "Start Navigation"
```

---

## 验收标准
- [ ] 星脉图正确显示，三种 Tier 有不同视觉效果
- [ ] 源点圣迹有曼陀罗动画
- [ ] 圣迹列表可按大洲分类，可搜索
- [ ] 圣迹详情页信息完整，有沉浸式头图
- [ ] 旅程规划器展示5种出行方式的哲学解读
- [ ] 可跳转到系统地图导航

---

## 完成后
提交代码到 GitHub，备注："Day 6: 圣迹系统完整实现（三层体系 + 星脉图 + 旅程规划器）"
