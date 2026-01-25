# Day 4 开发提示词

## 今日目标
**心灵地图核心 - 能量线渲染 + 艺术化地图**

请阅读 `/Users/xiaomu/Desktop/Leyhome/GDD.md` 第4.1节（能量线设计）和第6.2节（能量线视觉），然后完成以下任务。

---

## 任务清单

### 1. MapKit 基础集成

**更新 `MapView.swift`**：
```swift
import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showRecordingControl = true

    var body: some View {
        ZStack {
            // 地图层
            Map(position: $cameraPosition) {
                // 用户位置
                UserAnnotation()

                // 能量线
                ForEach(displayedTracks) { track in
                    EnergyLineOverlay(track: track)
                }

                // 心绪节点（明天实现）
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }

            // 记录控制面板
            VStack {
                Spacer()
                if showRecordingControl {
                    RecordingControlView()
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .onAppear {
            locationManager.requestAlwaysAuthorization()
        }
    }

    private var displayedTracks: [Track] {
        // TODO: 从本地数据库加载
        if let current = locationManager.currentTrack {
            return [current]
        }
        return []
    }
}
```

### 2. 能量线渲染器

**创建 `EnergyLineOverlay.swift`**：
```swift
import SwiftUI
import MapKit

struct EnergyLineOverlay: MapContent {
    let track: Track

    var body: some MapContent {
        let coordinates = track.points.map { $0.coordinate }

        if coordinates.count >= 2 {
            MapPolyline(coordinates: coordinates)
                .stroke(
                    energyLineGradient,
                    style: StrokeStyle(
                        lineWidth: travelMode.lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
        }
    }

    private var travelMode: TravelMode {
        TravelMode(rawValue: track.travelMode) ?? .walking
    }

    private var energyLineGradient: LinearGradient {
        let baseColor = travelMode.lineColor
        return LinearGradient(
            colors: [
                baseColor.opacity(0.6),
                baseColor,
                baseColor.opacity(0.8)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
```

### 3. 高级能量线渲染（脉动效果）

**创建 `EnergyLineRenderer.swift`**（使用 UIKit 覆盖层实现高级效果）：
```swift
import MapKit
import SwiftUI

class EnergyLineRenderer: MKPolylineRenderer {
    var travelMode: TravelMode = .walking
    var animationPhase: CGFloat = 0

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let polyline = self.polyline else { return }

        let path = self.path
        context.addPath(path)

        // 基础线条
        context.setStrokeColor(travelMode.lineColor.cgColor ?? UIColor.orange.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        // 发光效果
        context.setShadow(
            offset: .zero,
            blur: 8,
            color: travelMode.lineColor.cgColor ?? UIColor.orange.cgColor
        )

        context.strokePath()

        // 脉动光点（步行模式）
        if travelMode == .walking {
            drawPulsingDots(in: context, along: polyline, phase: animationPhase)
        }

        // 流光效果（骑行模式）
        if travelMode == .cycling {
            drawFlowingLight(in: context, along: polyline, phase: animationPhase)
        }
    }

    private func drawPulsingDots(in context: CGContext, along polyline: MKPolyline, phase: CGFloat) {
        // 在轨迹上绘制脉动光点
        let pointCount = polyline.pointCount
        guard pointCount > 0 else { return }

        let dotIndex = Int(phase * CGFloat(pointCount)) % pointCount
        let mapPoint = polyline.points()[dotIndex]
        let point = self.point(for: mapPoint)

        context.setFillColor(UIColor.white.withAlphaComponent(0.8).cgColor)
        context.fillEllipse(in: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8))
    }

    private func drawFlowingLight(in context: CGContext, along polyline: MKPolyline, phase: CGFloat) {
        // 流光效果实现
    }
}

// MARK: - UIViewRepresentable 包装器
struct EnergyLineMapView: UIViewRepresentable {
    let tracks: [Track]
    @Binding var region: MKCoordinateRegion

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 移除旧的覆盖层
        mapView.removeOverlays(mapView.overlays)

        // 添加新的能量线
        for track in tracks {
            let coordinates = track.points.map { $0.coordinate }
            if coordinates.count >= 2 {
                let polyline = TravelModePolyline(coordinates: coordinates, count: coordinates.count)
                polyline.travelMode = TravelMode(rawValue: track.travelMode) ?? .walking
                mapView.addOverlay(polyline)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? TravelModePolyline {
                let renderer = EnergyLineRenderer(polyline: polyline)
                renderer.travelMode = polyline.travelMode
                renderer.lineWidth = polyline.travelMode.lineWidth * 2
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// 自定义 Polyline 类，携带出行方式信息
class TravelModePolyline: MKPolyline {
    var travelMode: TravelMode = .walking
}
```

### 4. 能量线动画控制器

**创建 `EnergyLineAnimator.swift`**：
```swift
import SwiftUI
import Combine

class EnergyLineAnimator: ObservableObject {
    @Published var phase: CGFloat = 0

    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0

    func startAnimation() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
        animationStartTime = CACurrentMediaTime()
    }

    func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func update() {
        let elapsed = CACurrentMediaTime() - animationStartTime
        // 每3秒循环一次
        phase = CGFloat(elapsed.truncatingRemainder(dividingBy: 3.0)) / 3.0
    }
}
```

### 5. 地图主题系统

**创建 `MapTheme.swift`**（基于GDD 6.4）：
```swift
import SwiftUI
import MapKit

enum MapTheme: String, CaseIterable {
    case starDust = "star_dust"          // 默认：星尘
    case inkWash = "ink_wash"            // 水墨山水
    case ghibliSummer = "ghibli_summer"  // 吉卜力之夏
    case auroraLight = "aurora_light"    // 极光之夜
    case cyberpunk = "cyberpunk"         // 赛博朋克

    var nameZh: String {
        switch self {
        case .starDust: return "星尘"
        case .inkWash: return "水墨山水"
        case .ghibliSummer: return "吉卜力之夏"
        case .auroraLight: return "极光之夜"
        case .cyberpunk: return "赛博朋克"
        }
    }

    var nameEn: String {
        switch self {
        case .starDust: return "Star Dust"
        case .inkWash: return "Ink Wash"
        case .ghibliSummer: return "Ghibli Summer"
        case .auroraLight: return "Aurora Night"
        case .cyberpunk: return "Cyberpunk"
        }
    }

    var isPremium: Bool {
        self != .starDust
    }

    var mapStyle: MapStyle {
        switch self {
        case .starDust:
            return .standard(elevation: .realistic, pointsOfInterest: .excludingAll)
        case .inkWash:
            return .imagery(elevation: .flat)
        case .ghibliSummer:
            return .standard(elevation: .realistic)
        case .auroraLight:
            return .hybrid(elevation: .realistic)
        case .cyberpunk:
            return .hybrid(elevation: .flat)
        }
    }

    // 能量线颜色覆盖
    var energyLineColorOverride: [TravelMode: Color]? {
        switch self {
        case .cyberpunk:
            return [
                .walking: Color(hex: "FF00FF"),    // 霓虹粉
                .cycling: Color(hex: "00FFFF"),   // 霓虹青
                .driving: Color(hex: "FFFF00"),   // 霓虹黄
                .flying: Color(hex: "FF0080")     // 霓虹红
            ]
        default:
            return nil
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: MapTheme = .starDust
    @Published var isPremiumUser: Bool = false

    func setTheme(_ theme: MapTheme) {
        if theme.isPremium && !isPremiumUser {
            // 提示升级
            return
        }
        currentTheme = theme
    }

    func energyLineColor(for mode: TravelMode) -> Color {
        if let override = currentTheme.energyLineColorOverride?[mode] {
            return override
        }
        return mode.lineColor
    }
}
```

### 6. 时间轴滑块

**创建 `TimelineSlider.swift`**：
```swift
import SwiftUI

struct TimelineSlider: View {
    @Binding var selectedDate: Date
    let dateRange: ClosedRange<Date>
    @State private var isDragging = false

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.sm) {
            // 日期显示
            Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)

            // 滑块
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 轨道
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)

                    // 已选择部分
                    Capsule()
                        .fill(LeyhomeTheme.primary)
                        .frame(width: progressWidth(in: geometry), height: 4)

                    // 滑块
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .shadow(radius: 2)
                        .offset(x: progressWidth(in: geometry) - 10)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    isDragging = true
                                    updateDate(from: value.location.x, in: geometry)
                                }
                                .onEnded { _ in
                                    isDragging = false
                                }
                        )
                }
            }
            .frame(height: 20)

            // 日期范围标签
            HStack {
                Text(dateRange.lowerBound.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text(dateRange.upperBound.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }

    private func progressWidth(in geometry: GeometryProxy) -> CGFloat {
        let totalRange = dateRange.upperBound.timeIntervalSince(dateRange.lowerBound)
        let currentProgress = selectedDate.timeIntervalSince(dateRange.lowerBound)
        let ratio = totalRange > 0 ? currentProgress / totalRange : 0
        return geometry.size.width * CGFloat(ratio)
    }

    private func updateDate(from x: CGFloat, in geometry: GeometryProxy) {
        let ratio = max(0, min(1, x / geometry.size.width))
        let totalRange = dateRange.upperBound.timeIntervalSince(dateRange.lowerBound)
        let newInterval = totalRange * Double(ratio)
        selectedDate = dateRange.lowerBound.addingTimeInterval(newInterval)
    }
}
```

### 7. 轨迹列表视图

**创建 `TrackListView.swift`**：
```swift
import SwiftUI

struct TrackListView: View {
    @State private var tracks: [Track] = []
    @State private var selectedTrack: Track?

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedTracks.keys.sorted().reversed(), id: \.self) { date in
                    Section(header: Text(date.formatted(date: .abbreviated, time: .omitted))) {
                        ForEach(groupedTracks[date] ?? []) { track in
                            TrackRowView(track: track)
                                .onTapGesture {
                                    selectedTrack = track
                                }
                        }
                    }
                }
            }
            .navigationTitle("tracks.title".localized)
            .sheet(item: $selectedTrack) { track in
                TrackDetailView(track: track)
            }
        }
    }

    private var groupedTracks: [Date: [Track]] {
        Dictionary(grouping: tracks) { track in
            Calendar.current.startOfDay(for: track.startedAt)
        }
    }
}

struct TrackRowView: View {
    let track: Track

    var body: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            // 出行方式图标
            Image(systemName: travelMode.icon)
                .foregroundColor(travelMode.lineColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                // 时间
                Text(track.startedAt.formatted(date: .omitted, time: .shortened))
                    .font(.headline)

                // 统计
                HStack(spacing: LeyhomeTheme.Spacing.sm) {
                    Label(distanceString, systemImage: "ruler")
                    Label(durationString, systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            // 节点数量
            if nodeCount > 0 {
                Label("\(nodeCount)", systemImage: "mappin.circle")
                    .font(.caption)
                    .foregroundColor(LeyhomeTheme.accent)
            }
        }
        .padding(.vertical, 4)
    }

    private var travelMode: TravelMode {
        TravelMode(rawValue: track.travelMode) ?? .walking
    }

    private var distanceString: String {
        let km = track.totalDistance / 1000
        return String(format: "%.1f km", km)
    }

    private var durationString: String {
        guard let endedAt = track.endedAt else { return "--" }
        let duration = endedAt.timeIntervalSince(track.startedAt)
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }

    private var nodeCount: Int {
        // TODO: 从关联的节点中获取
        return 0
    }
}
```

### 8. 国际化文案补充

```
// 地图
"map.theme" = "地图主题" / "Map Theme"
"map.theme.star_dust" = "星尘" / "Star Dust"
"map.theme.ink_wash" = "水墨山水" / "Ink Wash"
"map.theme.ghibli_summer" = "吉卜力之夏" / "Ghibli Summer"
"map.theme.aurora_light" = "极光之夜" / "Aurora Night"
"map.theme.cyberpunk" = "赛博朋克" / "Cyberpunk"
"map.theme.premium" = "订阅解锁" / "Premium"

// 轨迹
"tracks.title" = "我的旅程" / "My Journeys"
"tracks.empty" = "还没有记录\n开始你的第一段旅程吧" / "No tracks yet\nStart your first journey"
"tracks.detail" = "旅程详情" / "Journey Detail"
```

---

## 验收标准
- [ ] 地图正常显示，可平移缩放
- [ ] 当前位置显示正确
- [ ] 记录的轨迹以能量线形式显示
- [ ] 不同出行方式显示不同颜色
- [ ] 能量线有呼吸感动画效果
- [ ] 轨迹列表可查看历史记录

---

## 技术要点
- iOS 17+ 使用新的 `Map` API，更简洁
- 复杂动画效果可能需要使用 `MKMapView` + `CADisplayLink`
- 注意内存管理，大量轨迹点可能导致性能问题

---

## 完成后
提交代码到 GitHub，备注："Day 4: 能量线渲染 + 地图主题 + 轨迹列表"
