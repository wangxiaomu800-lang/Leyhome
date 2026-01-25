# Day 8 开发提示词

## 今日目标
**引路系统完整实现（先行者 + 星图 + 共鸣行走 + 强制反思）**

请阅读 `/Users/xiaomu/Desktop/Leyhome/GDD.md` 第4.5节（引路系统）和 `/Users/xiaomu/Desktop/Leyhome/PRD.md` 第5.5节，然后完成以下任务。

---

## 任务清单

### 1. 先行者数据模型

**创建 `Guide.swift`**：
```swift
import Foundation
import SwiftData

@Model
class Guide: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var titleZh: String       // 身份/头衔
    var titleEn: String
    var bioZh: String         // 简介
    var bioEn: String
    var avatarUrl: String?
    var coverImageUrl: String?

    var isVerified: Bool = true
    var followerCount: Int = 0

    // 专长标签
    var tagsData: Data?  // [String]

    var createdAt: Date

    init(name: String, titleZh: String, titleEn: String) {
        self.id = UUID()
        self.name = name
        self.titleZh = titleZh
        self.titleEn = titleEn
        self.bioZh = ""
        self.bioEn = ""
        self.createdAt = Date()
    }

    var title: String {
        LocalizationManager.shared.currentLanguage == "zh" ? titleZh : titleEn
    }

    var bio: String {
        LocalizationManager.shared.currentLanguage == "zh" ? bioZh : bioEn
    }

    var tags: [String] {
        get {
            guard let data = tagsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            tagsData = try? JSONEncoder().encode(newValue)
        }
    }
}
```

### 2. 星图数据模型

**创建 `Constellation.swift`**（基于GDD 4.5.2）：
```swift
import Foundation
import SwiftData
import CoreLocation

@Model
class Constellation: Identifiable {
    @Attribute(.unique) var id: UUID
    var guideId: UUID
    var nameZh: String
    var nameEn: String
    var descriptionZh: String
    var descriptionEn: String
    var coverImageUrl: String?

    // 难度/时长
    var difficulty: Int = 1  // 1-5
    var estimatedHours: Double = 0
    var totalDistance: Double = 0  // km

    // 统计
    var resonanceCount: Int = 0  // 共鸣行走次数

    var isPremium: Bool = false  // 订阅专属
    var createdAt: Date

    init(guideId: UUID, nameZh: String, nameEn: String) {
        self.id = UUID()
        self.guideId = guideId
        self.nameZh = nameZh
        self.nameEn = nameEn
        self.descriptionZh = ""
        self.descriptionEn = ""
        self.createdAt = Date()
    }

    var name: String {
        LocalizationManager.shared.currentLanguage == "zh" ? nameZh : nameEn
    }

    var description: String {
        LocalizationManager.shared.currentLanguage == "zh" ? descriptionZh : descriptionEn
    }
}

// 星图中的节点（先行者的心绪记录点）
@Model
class ConstellationNode: Identifiable {
    @Attribute(.unique) var id: UUID
    var constellationId: UUID
    var order: Int  // 节点顺序

    var latitude: Double
    var longitude: Double

    // 先行者在此处的感悟
    var titleZh: String?
    var titleEn: String?
    var contentZh: String
    var contentEn: String
    var audioUrl: String?  // 语音引导

    var createdAt: Date

    init(constellationId: UUID, order: Int) {
        self.id = UUID()
        self.constellationId = constellationId
        self.order = order
        self.latitude = 0
        self.longitude = 0
        self.contentZh = ""
        self.contentEn = ""
        self.createdAt = Date()
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var content: String {
        LocalizationManager.shared.currentLanguage == "zh" ? contentZh : contentEn
    }
}
```

### 3. 预置先行者数据

**创建 `GuideData.swift`**：
```swift
import Foundation

struct GuideData {
    static let guides: [[String: Any]] = [
        [
            "name": "林深",
            "titleZh": "正念导师 · 山野行者",
            "titleEn": "Mindfulness Guide · Mountain Walker",
            "bioZh": "二十年山野徒步经验，致力于将正念冥想与户外行走相结合。相信每一步都是与自己的对话，每一座山都是内心的投影。",
            "bioEn": "Twenty years of mountain hiking experience, dedicated to combining mindfulness meditation with outdoor walking. Believes every step is a dialogue with oneself, every mountain a reflection of the inner world.",
            "avatarUrl": "https://example.com/guide1.jpg",
            "tags": ["正念", "徒步", "山野"]
        ],
        [
            "name": "苏晚",
            "titleZh": "城市漫游家 · 摄影师",
            "titleEn": "Urban Wanderer · Photographer",
            "bioZh": "用镜头捕捉城市的诗意角落，擅长在喧嚣中发现宁静。她的每一次漫步都是一次寻找美的旅程。",
            "bioEn": "Capturing poetic corners of cities through her lens, skilled at finding tranquility in chaos. Every stroll she takes is a journey of seeking beauty.",
            "avatarUrl": "https://example.com/guide2.jpg",
            "tags": ["城市", "摄影", "慢生活"]
        ],
        [
            "name": "云归",
            "titleZh": "诗人 · 古道研究者",
            "titleEn": "Poet · Ancient Trail Researcher",
            "bioZh": "研究中国古代驿道与茶马古道多年，用诗歌记录行走中的感悟。每一条古道都是前人留下的密语，等待我们去破译。",
            "bioEn": "Years of research on ancient Chinese postal roads and tea-horse trails, recording walking insights through poetry. Every ancient trail is a cipher left by our ancestors, waiting to be decoded.",
            "avatarUrl": "https://example.com/guide3.jpg",
            "tags": ["古道", "诗歌", "历史"]
        ]
    ]

    static let constellations: [[String: Any]] = [
        [
            "guideName": "林深",
            "nameZh": "城市边缘的呼吸",
            "nameEn": "Breathing at the City's Edge",
            "descriptionZh": "在城市与自然的交界处，找到内心的宁静。这条路线带你从繁华走向寂静，从喧嚣回归本真。",
            "descriptionEn": "Find inner peace at the boundary between city and nature. This route takes you from bustle to silence, from chaos back to authenticity.",
            "difficulty": 2,
            "estimatedHours": 3,
            "totalDistance": 8.5,
            "isPremium": false,
            "nodes": [
                [
                    "order": 1,
                    "latitude": 39.9042,
                    "longitude": 116.4074,
                    "titleZh": "起点 · 城市的边界",
                    "contentZh": "站在这里，回望身后的城市。那些高楼、车流、霓虹——它们构成了我们日常的背景音。但现在，让我们暂时按下静音键。深呼吸，准备好了吗？",
                    "contentEn": "Stand here, look back at the city behind you. Those buildings, traffic, neon lights—they form the background noise of our daily lives. But now, let's press the mute button. Take a deep breath. Are you ready?",
                    "audioUrl": "https://example.com/audio1.mp3"
                ],
                [
                    "order": 2,
                    "latitude": 39.9142,
                    "longitude": 116.4174,
                    "titleZh": "林间小径",
                    "contentZh": "当树叶开始遮蔽天空，脚下的路变得柔软，你会发现自己的呼吸也随之放缓。不要急着赶路，让每一步都落在当下。",
                    "contentEn": "When leaves begin to cover the sky and the path underfoot softens, you'll find your breathing slows down too. Don't rush. Let every step land in the present moment.",
                    "audioUrl": "https://example.com/audio2.mp3"
                ],
                [
                    "order": 3,
                    "latitude": 39.9242,
                    "longitude": 116.4274,
                    "titleZh": "终点 · 山顶的风",
                    "contentZh": "站在这里，风从四面八方吹来。闭上眼睛，感受它穿过你的身体。你不是在对抗风，而是成为风的一部分。这就是归途——回到最初的、最简单的自己。",
                    "contentEn": "Standing here, wind blows from all directions. Close your eyes, feel it pass through your body. You're not fighting the wind—you're becoming part of it. This is the return journey—back to the original, simplest self.",
                    "audioUrl": "https://example.com/audio3.mp3"
                ]
            ]
        ],
        [
            "guideName": "苏晚",
            "nameZh": "老城巷陌的光影",
            "nameEn": "Light and Shadow in Old Town Alleys",
            "descriptionZh": "在老城的小巷中穿行，用眼睛捕捉被时间遗忘的美好。这不仅是一次行走，更是一次与城市记忆的对话。",
            "descriptionEn": "Wander through old town alleys, capturing beauty forgotten by time. This is not just a walk, but a dialogue with the city's memory.",
            "difficulty": 1,
            "estimatedHours": 2,
            "totalDistance": 4.2,
            "isPremium": false,
            "nodes": [
                [
                    "order": 1,
                    "latitude": 39.9342,
                    "longitude": 116.3974,
                    "titleZh": "晨光中的老墙",
                    "contentZh": "看这面斑驳的老墙，阳光在上面画出了时间的年轮。那些裂缝、青苔、褪色的标语——每一处痕迹都是一个故事的开端。",
                    "contentEn": "Look at this mottled old wall, sunlight painting rings of time upon it. Those cracks, moss, faded slogans—every mark is the beginning of a story.",
                    "audioUrl": "https://example.com/audio4.mp3"
                ]
            ]
        ]
    ]

    static func loadAllGuides() -> [Guide] {
        guides.map { data in
            let guide = Guide(
                name: data["name"] as! String,
                titleZh: data["titleZh"] as! String,
                titleEn: data["titleEn"] as! String
            )
            guide.bioZh = data["bioZh"] as? String ?? ""
            guide.bioEn = data["bioEn"] as? String ?? ""
            guide.avatarUrl = data["avatarUrl"] as? String
            guide.tags = data["tags"] as? [String] ?? []
            return guide
        }
    }
}
```

### 4. 引路主视图

**创建 `GuidesView.swift`**：
```swift
import SwiftUI

struct GuidesView: View {
    @State private var guides: [Guide] = []
    @State private var selectedGuide: Guide?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    // 顶部介绍
                    VStack(spacing: LeyhomeTheme.Spacing.sm) {
                        Text("guides.intro.title".localized)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("guides.intro.subtitle".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    // 先行者列表
                    LazyVStack(spacing: LeyhomeTheme.Spacing.md) {
                        ForEach(guides) { guide in
                            NavigationLink(destination: GuideDetailView(guide: guide)) {
                                GuideCard(guide: guide)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(LeyhomeTheme.secondary)
            .navigationTitle("tab.guides".localized)
            .onAppear {
                guides = GuideData.loadAllGuides()
            }
        }
    }
}

struct GuideCard: View {
    let guide: Guide

    var body: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            // 头像
            AsyncImage(url: URL(string: guide.avatarUrl ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(LeyhomeTheme.primary.opacity(0.2))
            }
            .frame(width: 70, height: 70)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(LeyhomeTheme.accent, lineWidth: guide.isVerified ? 2 : 0)
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(guide.name)
                        .font(.headline)

                    if guide.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(LeyhomeTheme.accent)
                    }
                }

                Text(guide.title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                // 标签
                HStack(spacing: 4) {
                    ForEach(guide.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(LeyhomeTheme.primary.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
```

### 5. 先行者详情页

**创建 `GuideDetailView.swift`**：
```swift
import SwiftUI

struct GuideDetailView: View {
    let guide: Guide
    @State private var constellations: [Constellation] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 头部背景
                ZStack(alignment: .bottom) {
                    AsyncImage(url: URL(string: guide.coverImageUrl ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        LinearGradient(
                            colors: [LeyhomeTheme.primary, LeyhomeTheme.starlight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    .frame(height: 200)
                    .clipped()

                    // 渐变遮罩
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

                // 头像和信息（悬浮效果）
                VStack(spacing: LeyhomeTheme.Spacing.md) {
                    AsyncImage(url: URL(string: guide.avatarUrl ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 5)
                    .offset(y: -50)

                    VStack(spacing: 4) {
                        HStack {
                            Text(guide.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            if guide.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(LeyhomeTheme.accent)
                            }
                        }

                        Text(guide.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .offset(y: -40)

                    Text(guide.bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .offset(y: -30)
                }
                .padding(.bottom, -30)

                // 星图列表
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
                    Text("guides.constellations".localized)
                        .font(.headline)
                        .padding(.horizontal)

                    if constellations.isEmpty {
                        Text("guides.no_constellations".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(constellations) { constellation in
                            NavigationLink(destination: ConstellationDetailView(constellation: constellation, guide: guide)) {
                                ConstellationCard(constellation: constellation)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadConstellations()
        }
    }

    private func loadConstellations() {
        // TODO: 从数据源加载
    }
}

struct ConstellationCard: View {
    let constellation: Constellation

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            // 封面图
            AsyncImage(url: URL(string: constellation.coverImageUrl ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(LeyhomeTheme.starlight.opacity(0.3))
            }
            .frame(height: 150)
            .clipped()
            .cornerRadius(LeyhomeTheme.CornerRadius.sm)

            // 信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(constellation.name)
                        .font(.headline)

                    Spacer()

                    if constellation.isPremium {
                        Label("Premium", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }

                Text(constellation.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // 统计
                HStack(spacing: LeyhomeTheme.Spacing.md) {
                    Label(String(format: "%.1f km", constellation.totalDistance), systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    Label(String(format: "%.0f h", constellation.estimatedHours), systemImage: "clock")
                    Label("\(constellation.resonanceCount)", systemImage: "person.2")

                    Spacer()

                    // 难度
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: i <= constellation.difficulty ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(i <= constellation.difficulty ? LeyhomeTheme.accent : .gray)
                        }
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
```

### 6. 星图详情与共鸣行走

**创建 `ConstellationDetailView.swift`**：
```swift
import SwiftUI
import MapKit

struct ConstellationDetailView: View {
    let constellation: Constellation
    let guide: Guide
    @State private var nodes: [ConstellationNode] = []
    @State private var showResonanceMode = false
    @State private var selectedNode: ConstellationNode?

    var body: some View {
        ScrollView {
            VStack(spacing: LeyhomeTheme.Spacing.lg) {
                // 星图可视化（GDD: 星座连线）
                ConstellationMapView(nodes: nodes, selectedNode: $selectedNode)
                    .frame(height: 300)
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)

                // 星图信息
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
                    Text(constellation.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(constellation.description)
                        .font(.body)
                        .foregroundColor(.secondary)

                    // 先行者信息
                    HStack {
                        AsyncImage(url: URL(string: guide.avatarUrl ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text("guides.created_by".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(guide.name)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.horizontal)

                // 节点预览列表
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
                    Text("guides.nodes".localized)
                        .font(.headline)

                    ForEach(nodes.sorted(by: { $0.order < $1.order })) { node in
                        NodePreviewRow(node: node, isSelected: selectedNode?.id == node.id) {
                            selectedNode = node
                        }
                    }
                }
                .padding(.horizontal)

                // 开始共鸣行走按钮
                Button(action: { showResonanceMode = true }) {
                    HStack {
                        Image(systemName: "figure.walk")
                        Text("guides.start_resonance".localized)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LeyhomeTheme.primary)
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
                }
                .padding()
            }
        }
        .navigationTitle("guides.constellation".localized)
        .fullScreenCover(isPresented: $showResonanceMode) {
            ResonanceWalkView(constellation: constellation, nodes: nodes, guide: guide)
        }
        .onAppear {
            loadNodes()
        }
    }

    private func loadNodes() {
        // TODO: 从数据源加载
    }
}

struct ConstellationMapView: View {
    let nodes: [ConstellationNode]
    @Binding var selectedNode: ConstellationNode?

    var body: some View {
        Map {
            // 连线（星图效果）
            if nodes.count >= 2 {
                let coordinates = nodes.sorted(by: { $0.order < $1.order }).map { $0.coordinate }
                MapPolyline(coordinates: coordinates)
                    .stroke(LeyhomeTheme.starlight.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
            }

            // 节点
            ForEach(nodes) { node in
                Annotation("", coordinate: node.coordinate) {
                    ConstellationNodeMarker(
                        order: node.order,
                        isSelected: selectedNode?.id == node.id
                    )
                    .onTapGesture {
                        selectedNode = node
                    }
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
    }
}

struct ConstellationNodeMarker: View {
    let order: Int
    let isSelected: Bool

    var body: some View {
        ZStack {
            // 光晕
            Circle()
                .fill(LeyhomeTheme.starlight.opacity(0.3))
                .frame(width: 40, height: 40)
                .scaleEffect(isSelected ? 1.5 : 1.0)

            // 主体
            Circle()
                .fill(isSelected ? LeyhomeTheme.accent : LeyhomeTheme.starlight)
                .frame(width: 24, height: 24)

            Text("\(order)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct NodePreviewRow: View {
    let node: ConstellationNode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: LeyhomeTheme.Spacing.md) {
                // 序号
                ZStack {
                    Circle()
                        .fill(isSelected ? LeyhomeTheme.primary : Color.gray.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Text("\(node.order)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    if let title = node.titleZh {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    Text(node.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if node.audioUrl != nil {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption)
                        .foregroundColor(LeyhomeTheme.primary)
                }
            }
            .padding()
            .background(isSelected ? LeyhomeTheme.primary.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(LeyhomeTheme.CornerRadius.sm)
        }
        .buttonStyle(.plain)
    }
}
```

### 7. 共鸣行走模式

**创建 `ResonanceWalkView.swift`**（基于GDD 4.5.3-4.5.4）：
```swift
import SwiftUI
import MapKit
import AVFoundation

struct ResonanceWalkView: View {
    let constellation: Constellation
    let nodes: [ConstellationNode]
    let guide: Guide

    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var audioPlayer = AudioPlayerManager()

    @State private var currentNodeIndex = 0
    @State private var isWalking = false
    @State private var showNodeContent = false
    @State private var reachedNodes: Set<UUID> = []
    @State private var showReflection = false

    private let proximityThreshold: Double = 50  // 米

    var body: some View {
        ZStack {
            // 地图
            Map {
                // 用户位置
                UserAnnotation()

                // 先行者的"光之路"（GDD: 半透明发光轨迹）
                if nodes.count >= 2 {
                    let coordinates = nodes.sorted(by: { $0.order < $1.order }).map { $0.coordinate }
                    MapPolyline(coordinates: coordinates)
                        .stroke(LeyhomeTheme.starlight, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                }

                // 节点
                ForEach(nodes) { node in
                    Annotation("", coordinate: node.coordinate) {
                        ResonanceNodeMarker(
                            order: node.order,
                            isReached: reachedNodes.contains(node.id),
                            isCurrent: nodes[safe: currentNodeIndex]?.id == node.id
                        )
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))

            // 顶部控制栏
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }

                    Spacer()

                    // 进度指示
                    Text("\(reachedNodes.count)/\(nodes.count)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                }
                .padding()

                Spacer()

                // 底部内容卡片
                if let currentNode = nodes[safe: currentNodeIndex] {
                    ResonanceContentCard(
                        node: currentNode,
                        guide: guide,
                        isNearby: isNearNode(currentNode),
                        audioPlayer: audioPlayer
                    )
                    .transition(.move(edge: .bottom))
                }
            }

            // 到达节点时的浮层
            if showNodeContent, let node = nodes[safe: currentNodeIndex] {
                NodeArrivalOverlay(
                    node: node,
                    guide: guide,
                    onContinue: {
                        showNodeContent = false
                        moveToNextNode()
                    }
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            locationManager.requestAlwaysAuthorization()
        }
        .onChange(of: locationManager.currentLocation) { _, location in
            checkProximity(location)
        }
        .fullScreenCover(isPresented: $showReflection) {
            ReflectionView(constellation: constellation, guide: guide) {
                dismiss()
            }
        }
    }

    private func isNearNode(_ node: ConstellationNode) -> Bool {
        guard let location = locationManager.currentLocation else { return false }
        let nodeLocation = CLLocation(latitude: node.latitude, longitude: node.longitude)
        return location.distance(from: nodeLocation) < proximityThreshold
    }

    private func checkProximity(_ location: CLLocation?) {
        guard let location = location,
              let currentNode = nodes[safe: currentNodeIndex],
              !reachedNodes.contains(currentNode.id) else { return }

        let nodeLocation = CLLocation(latitude: currentNode.latitude, longitude: currentNode.longitude)
        let distance = location.distance(from: nodeLocation)

        if distance < proximityThreshold {
            // 到达节点
            reachedNodes.insert(currentNode.id)

            // 播放音频（GDD: 情景音频触发）
            if let audioUrl = currentNode.audioUrl {
                audioPlayer.play(url: audioUrl)
            }

            // 显示内容
            withAnimation {
                showNodeContent = true
            }

            // 触觉反馈
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func moveToNextNode() {
        if currentNodeIndex < nodes.count - 1 {
            currentNodeIndex += 1
        } else {
            // 完成所有节点，进入强制反思（GDD 4.5.4）
            showReflection = true
        }
    }
}

struct ResonanceNodeMarker: View {
    let order: Int
    let isReached: Bool
    let isCurrent: Bool

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // 脉冲效果（当前节点）
            if isCurrent && !isReached {
                Circle()
                    .stroke(LeyhomeTheme.accent, lineWidth: 2)
                    .frame(width: 50, height: 50)
                    .scaleEffect(pulseScale)
                    .opacity(2 - pulseScale)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                            pulseScale = 2.0
                        }
                    }
            }

            Circle()
                .fill(isReached ? Color.green : (isCurrent ? LeyhomeTheme.accent : LeyhomeTheme.starlight))
                .frame(width: 30, height: 30)

            if isReached {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            } else {
                Text("\(order)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

struct ResonanceContentCard: View {
    let node: ConstellationNode
    let guide: Guide
    let isNearby: Bool
    let audioPlayer: AudioPlayerManager

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            HStack {
                AsyncImage(url: URL(string: guide.avatarUrl ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(guide.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("guides.says".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 距离提示
                if !isNearby {
                    Text("guides.approach".localized)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            if isNearby {
                Text(node.content)
                    .font(.body)
                    .lineSpacing(4)

                if node.audioUrl != nil {
                    Button(action: { audioPlayer.play(url: node.audioUrl!) }) {
                        HStack {
                            Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            Text(audioPlayer.isPlaying ? "guides.pause".localized : "guides.listen".localized)
                        }
                        .font(.subheadline)
                        .foregroundColor(LeyhomeTheme.primary)
                    }
                }
            } else {
                Text("guides.content_locked".localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .padding()
    }
}

struct NodeArrivalOverlay: View {
    let node: ConstellationNode
    let guide: Guide
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: LeyhomeTheme.Spacing.lg) {
                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .foregroundColor(LeyhomeTheme.accent)

                Text("guides.arrived".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(node.content)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: onContinue) {
                    Text("guides.continue".localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LeyhomeTheme.primary)
                        .cornerRadius(LeyhomeTheme.CornerRadius.md)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}
```

### 8. 强制反思界面

**创建 `ReflectionView.swift`**（基于GDD 4.5.4）：
```swift
import SwiftUI

struct ReflectionView: View {
    let constellation: Constellation
    let guide: Guide
    let onComplete: () -> Void

    @State private var myReflection = ""
    @State private var selectedMood: MoodType?
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.xl) {
                    // 完成提示
                    VStack(spacing: LeyhomeTheme.Spacing.md) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 50))
                            .foregroundColor(LeyhomeTheme.accent)

                        Text("reflection.complete".localized)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("reflection.subtitle".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    // GDD: 左侧显示先行者的感悟
                    VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                        HStack {
                            AsyncImage(url: URL(string: guide.avatarUrl ?? "")) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Circle().fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                            Text("\(guide.name) " + "reflection.felt".localized)
                                .font(.subheadline)
                        }

                        // 先行者的核心感悟（简化展示）
                        Text("「\("reflection.guide_quote".localized)」")
                            .font(.body)
                            .italic()
                            .padding()
                            .background(LeyhomeTheme.starlight.opacity(0.2))
                            .cornerRadius(LeyhomeTheme.CornerRadius.md)
                    }
                    .padding(.horizontal)

                    // GDD: 右侧显示"而你呢？"
                    VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
                        Text("reflection.your_turn".localized)
                            .font(.headline)

                        // 情绪选择
                        Text("reflection.your_mood".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(MoodType.allCases, id: \.self) { mood in
                                    MoodChip(mood: mood, isSelected: selectedMood == mood) {
                                        selectedMood = mood
                                    }
                                }
                            }
                        }

                        // 文字输入
                        TextEditor(text: $myReflection)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(LeyhomeTheme.CornerRadius.sm)

                        Text("reflection.hint".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    // 保存按钮（GDD: 必须留下自己的感悟才能保存）
                    Button(action: saveReflection) {
                        Text("reflection.save".localized)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSave ? LeyhomeTheme.primary : Color.gray)
                            .cornerRadius(LeyhomeTheme.CornerRadius.md)
                    }
                    .disabled(!canSave || isSaving)
                    .padding()
                }
            }
            .navigationTitle("reflection.title".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var canSave: Bool {
        selectedMood != nil && !myReflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveReflection() {
        isSaving = true
        // TODO: 保存反思到数据库
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                isSaving = false
                onComplete()
            }
        }
    }
}

struct MoodChip: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: mood.icon)
                    .font(.title3)
                Text(mood.nameZh)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .white : mood.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? mood.color : mood.color.opacity(0.2))
            .cornerRadius(LeyhomeTheme.CornerRadius.sm)
        }
    }
}

// 辅助
class AudioPlayerManager: ObservableObject {
    @Published var isPlaying = false

    func play(url: String) {
        // TODO: 实现音频播放
        isPlaying = true
    }

    func stop() {
        isPlaying = false
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
```

### 9. 国际化文案补充

```
// 引路
"guides.intro.title" = "跟随先行者的脚步" / "Follow the Pathfinders"
"guides.intro.subtitle" = "他们曾在这些路上寻找答案，现在邀请你一同行走" / "They once sought answers on these paths, now inviting you to walk together"
"guides.constellations" = "星图合集" / "Constellations"
"guides.no_constellations" = "暂无星图" / "No constellations yet"
"guides.constellation" = "星图" / "Constellation"
"guides.created_by" = "创建者" / "Created by"
"guides.nodes" = "行走节点" / "Walking Nodes"
"guides.start_resonance" = "开始共鸣行走" / "Start Resonance Walk"
"guides.says" = "在此感悟" / "felt here"
"guides.approach" = "接近后解锁" / "Approach to unlock"
"guides.content_locked" = "走近这个节点，聆听先行者的声音…" / "Approach this node to hear the pathfinder's voice..."
"guides.listen" = "聆听" / "Listen"
"guides.pause" = "暂停" / "Pause"
"guides.arrived" = "你已抵达" / "You Have Arrived"
"guides.continue" = "继续旅程" / "Continue Journey"

// 反思
"reflection.title" = "共鸣回响" / "Resonance Reflection"
"reflection.complete" = "共鸣行走完成" / "Resonance Walk Complete"
"reflection.subtitle" = "先行者在此留下了感悟，而你呢？" / "The pathfinder left insights here. What about you?"
"reflection.felt" = "在此感受到了" / "felt here"
"reflection.guide_quote" = "行走本身就是目的，每一步都是回家的路。" / "Walking itself is the destination; every step is a path home."
"reflection.your_turn" = "而你呢？" / "And you?"
"reflection.your_mood" = "此刻的心情" / "How do you feel?"
"reflection.hint" = "写下你的感悟，让这次行走真正属于你" / "Write your reflection, make this walk truly yours"
"reflection.save" = "保存我的回响" / "Save My Echo"
```

---

## 验收标准
- [ ] 先行者列表显示正确，有认证标识
- [ ] 先行者详情页显示简介和星图列表
- [ ] 星图详情显示节点连线（星座效果）
- [ ] 共鸣行走模式可进入，显示"光之路"
- [ ] 接近节点时自动触发内容显示
- [ ] 音频播放功能正常
- [ ] 完成所有节点后进入强制反思界面
- [ ] 必须填写反思才能保存

---

## 完成后
提交代码到 GitHub，备注："Day 8: 引路系统完整实现（先行者 + 星图 + 共鸣行走 + 强制反思）"
