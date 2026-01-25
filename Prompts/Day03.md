# Day 3 开发提示词

## 今日目标
**心灵地图核心 - GPS轨迹记录 + 出行方式识别**

请阅读 `/Users/xiaomu/Desktop/Leyhome/GDD.md` 第4.1节（心灵地图系统）和 `/Users/xiaomu/Desktop/Leyhome/PRD.md` 第5.1节，然后完成以下任务。

---

## 任务清单

### 1. CoreLocation 权限配置

**更新 `Info.plist`**：
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>地脉归途需要访问您的位置来记录行走轨迹，绘制专属于您的心灵地图。</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>地脉归途需要在后台持续记录您的位置，确保每一步都被转化为独特的能量线。</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

### 2. 出行方式枚举

**创建 `TravelMode.swift`**（基于GDD能量线设计）：
```swift
import SwiftUI

enum TravelMode: String, Codable, CaseIterable {
    case walking = "walking"       // 步行/慢跑
    case cycling = "cycling"       // 骑行/电动车
    case driving = "driving"       // 驾车/火车
    case flying = "flying"         // 高铁/飞机

    // 速度区间 (PRD 5.1.1)
    var speedRange: ClosedRange<Double> {
        switch self {
        case .walking: return 0...10      // km/h
        case .cycling: return 10...30
        case .driving: return 30...120
        case .flying: return 120...1000
        }
    }

    // 能量线颜色 (GDD 6.2)
    var lineColor: Color {
        switch self {
        case .walking: return LeyhomeTheme.EnergyLine.walking  // 琥珀色
        case .cycling: return LeyhomeTheme.EnergyLine.cycling  // 青色
        case .driving: return LeyhomeTheme.EnergyLine.driving  // 银白色
        case .flying: return LeyhomeTheme.EnergyLine.flying    // 紫色
        }
    }

    // 线条宽度
    var lineWidth: CGFloat {
        switch self {
        case .walking: return 4
        case .cycling: return 3
        case .driving: return 2
        case .flying: return 1.5
        }
    }

    // 内在解读 (GDD 4.1)
    var meaningZh: String {
        switch self {
        case .walking: return "与大地深度连接 - 用双脚阅读大地，最适合内省"
        case .cycling: return "感受流动的世界 - 思绪活跃，充满创造力"
        case .driving: return "穿越空间的专注 - 专注方向和远方，宏观思考"
        case .flying: return "灵魂的俯瞰 - 抽离感，适合人生规划"
        }
    }

    var meaningEn: String {
        switch self {
        case .walking: return "Deep connection with earth - reading the ground with your feet"
        case .cycling: return "Feeling the flowing world - active thoughts, full of creativity"
        case .driving: return "Focused traversal - macro thinking, eyes on the horizon"
        case .flying: return "Soul's overview - detachment, perfect for life planning"
        }
    }

    // 图标
    var icon: String {
        switch self {
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .driving: return "car.fill"
        case .flying: return "airplane"
        }
    }

    // 根据速度判断出行方式
    static func detect(speedKmh: Double) -> TravelMode {
        for mode in TravelMode.allCases {
            if mode.speedRange.contains(speedKmh) {
                return mode
            }
        }
        return speedKmh < 0 ? .walking : .flying
    }
}
```

### 3. 轨迹数据模型

**创建 `Track.swift`**：
```swift
import Foundation
import SwiftData
import CoreLocation

@Model
class Track: Identifiable {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var travelMode: String  // TravelMode rawValue
    var startedAt: Date
    var endedAt: Date?
    var isActive: Bool

    // 轨迹点数组 (存储为 JSON)
    var pointsData: Data?

    // 统计数据
    var totalDistance: Double = 0  // 米
    var averageSpeed: Double = 0   // km/h
    var maxSpeed: Double = 0       // km/h

    // 本地属性
    @Transient var points: [TrackPoint] = []

    init(userId: UUID, travelMode: TravelMode = .walking) {
        self.id = UUID()
        self.userId = userId
        self.travelMode = travelMode.rawValue
        self.startedAt = Date()
        self.isActive = true
    }

    // 添加轨迹点
    func addPoint(_ point: TrackPoint) {
        points.append(point)
        updateStats()
        savePoints()
    }

    // 计算统计数据
    private func updateStats() {
        guard points.count >= 2 else { return }

        var distance: Double = 0
        var speeds: [Double] = []

        for i in 1..<points.count {
            let prev = points[i-1]
            let curr = points[i]

            let loc1 = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
            let loc2 = CLLocation(latitude: curr.latitude, longitude: curr.longitude)

            distance += loc1.distance(from: loc2)

            let timeDiff = curr.timestamp.timeIntervalSince(prev.timestamp)
            if timeDiff > 0 {
                let speed = loc1.distance(from: loc2) / timeDiff * 3.6 // m/s to km/h
                speeds.append(speed)
            }
        }

        self.totalDistance = distance
        self.averageSpeed = speeds.isEmpty ? 0 : speeds.reduce(0, +) / Double(speeds.count)
        self.maxSpeed = speeds.max() ?? 0
    }

    // 保存点到 Data
    private func savePoints() {
        pointsData = try? JSONEncoder().encode(points)
    }

    // 从 Data 加载点
    func loadPoints() {
        if let data = pointsData {
            points = (try? JSONDecoder().decode([TrackPoint].self, from: data)) ?? []
        }
    }

    // 结束轨迹
    func finish() {
        self.endedAt = Date()
        self.isActive = false
        savePoints()
    }
}

struct TrackPoint: Codable, Identifiable {
    var id: UUID = UUID()
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var speed: Double  // m/s
    var timestamp: Date
    var accuracy: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var speedKmh: Double {
        speed * 3.6
    }
}
```

### 4. 位置服务管理器

**创建 `LocationManager.swift`**：
```swift
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()

    private let locationManager = CLLocationManager()

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isRecording = false
    @Published var currentTrack: Track?
    @Published var detectedMode: TravelMode = .walking
    @Published var error: String?

    // 智能采样配置
    private var lastRecordedLocation: CLLocation?
    private var minDistanceFilter: Double = 10  // 最小距离阈值（米）
    private var speedBasedAccuracy: CLLocationAccuracy {
        switch detectedMode {
        case .walking: return kCLLocationAccuracyBest
        case .cycling: return kCLLocationAccuracyNearestTenMeters
        case .driving: return kCLLocationAccuracyHundredMeters
        case .flying: return kCLLocationAccuracyKilometer
        }
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
    }

    // 请求权限
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    // 开始记录
    func startRecording(userId: UUID) {
        guard !isRecording else { return }

        currentTrack = Track(userId: userId)
        isRecording = true
        lastRecordedLocation = nil

        locationManager.startUpdatingLocation()
    }

    // 结束记录
    func stopRecording() -> Track? {
        guard isRecording, let track = currentTrack else { return nil }

        locationManager.stopUpdatingLocation()
        track.finish()

        isRecording = false
        let finishedTrack = track
        currentTrack = nil

        return finishedTrack
    }

    // 智能采样算法
    private func shouldRecordLocation(_ location: CLLocation) -> Bool {
        guard let last = lastRecordedLocation else { return true }

        // 距离阈值（根据速度动态调整）
        let distance = location.distance(from: last)
        let threshold: Double

        switch detectedMode {
        case .walking: threshold = 5
        case .cycling: threshold = 15
        case .driving: threshold = 50
        case .flying: threshold = 500
        }

        return distance >= threshold
    }

    // 更新出行方式
    private func updateTravelMode(speed: Double) {
        let speedKmh = speed * 3.6
        let newMode = TravelMode.detect(speedKmh: speedKmh)

        if newMode != detectedMode {
            // 防抖：连续3次相同才切换
            // 简化处理：直接切换
            detectedMode = newMode
            locationManager.desiredAccuracy = speedBasedAccuracy
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            self.currentLocation = location

            // 更新出行方式
            if location.speed >= 0 {
                self.updateTravelMode(speed: location.speed)
            }

            // 记录中才添加点
            if self.isRecording, self.shouldRecordLocation(location) {
                let point = TrackPoint(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    altitude: location.altitude,
                    speed: max(0, location.speed),
                    timestamp: location.timestamp,
                    accuracy: location.horizontalAccuracy
                )

                self.currentTrack?.addPoint(point)
                self.lastRecordedLocation = location
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.error = error.localizedDescription
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}
```

### 5. 轨迹记录控制 UI

**创建 `RecordingControlView.swift`**：
```swift
import SwiftUI

struct RecordingControlView: View {
    @StateObject private var locationManager = LocationManager.shared
    @EnvironmentObject var authManager: AuthManager
    @State private var showStopConfirm = false

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            if locationManager.isRecording {
                // 记录中状态
                RecordingStatusCard()

                // 停止按钮
                Button(action: { showStopConfirm = true }) {
                    HStack {
                        Image(systemName: "stop.circle.fill")
                        Text("recording.stop".localized)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
                }
            } else {
                // 开始按钮
                Button(action: startRecording) {
                    HStack {
                        Image(systemName: "record.circle")
                        Text("recording.start".localized)
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
        .alert("recording.stop.confirm.title".localized, isPresented: $showStopConfirm) {
            Button("button.cancel".localized, role: .cancel) {}
            Button("recording.stop.confirm".localized, role: .destructive) {
                stopRecording()
            }
        } message: {
            Text("recording.stop.confirm.message".localized)
        }
    }

    private func startRecording() {
        guard let userId = authManager.currentUser?.id else { return }
        locationManager.startRecording(userId: userId)

        // 触觉反馈
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func stopRecording() {
        if let track = locationManager.stopRecording() {
            // 保存轨迹
            saveTrack(track)
        }

        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    private func saveTrack(_ track: Track) {
        // 保存到本地和云端
        Task {
            // TODO: 实现保存逻辑
        }
    }
}

struct RecordingStatusCard: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var elapsedTime: TimeInterval = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.sm) {
            // 出行方式和时间
            HStack {
                Image(systemName: locationManager.detectedMode.icon)
                    .foregroundColor(locationManager.detectedMode.lineColor)

                Text(elapsedTimeString)
                    .font(.system(.title2, design: .monospaced))
                    .foregroundColor(LeyhomeTheme.primary)

                Spacer()

                // 脉动指示器
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                    .opacity(0.8)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(), value: true)
            }

            // 统计数据
            HStack(spacing: LeyhomeTheme.Spacing.lg) {
                StatItem(
                    title: "recording.distance".localized,
                    value: distanceString
                )
                StatItem(
                    title: "recording.speed".localized,
                    value: speedString
                )
                StatItem(
                    title: "recording.points".localized,
                    value: "\(locationManager.currentTrack?.points.count ?? 0)"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(radius: 2)
        .onReceive(timer) { _ in
            if let startedAt = locationManager.currentTrack?.startedAt {
                elapsedTime = Date().timeIntervalSince(startedAt)
            }
        }
    }

    private var elapsedTimeString: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private var distanceString: String {
        let meters = locationManager.currentTrack?.totalDistance ?? 0
        if meters < 1000 {
            return String(format: "%.0f m", meters)
        } else {
            return String(format: "%.2f km", meters / 1000)
        }
    }

    private var speedString: String {
        let speed = locationManager.currentTrack?.averageSpeed ?? 0
        return String(format: "%.1f km/h", speed)
    }
}

struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(LeyhomeTheme.primary)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
```

### 6. 国际化文案补充

```
// 记录
"recording.start" = "开始记录" / "Start Recording"
"recording.stop" = "结束记录" / "Stop Recording"
"recording.stop.confirm.title" = "结束本次旅程？" / "End this journey?"
"recording.stop.confirm.message" = "轨迹将被保存到你的心灵地图" / "The track will be saved to your soul map"
"recording.stop.confirm" = "结束" / "End"
"recording.distance" = "距离" / "Distance"
"recording.speed" = "均速" / "Avg Speed"
"recording.points" = "轨迹点" / "Points"

// 出行方式
"travel_mode.walking" = "步行" / "Walking"
"travel_mode.cycling" = "骑行" / "Cycling"
"travel_mode.driving" = "驾车" / "Driving"
"travel_mode.flying" = "飞行" / "Flying"
```

---

## 验收标准
- [ ] 定位权限请求正常弹出，描述文案清晰
- [ ] 后台定位正常工作，App切到后台继续记录
- [ ] 点击开始按钮后，实时显示记录状态
- [ ] 出行方式根据速度自动切换（可模拟测试）
- [ ] 结束记录后，轨迹数据正确保存
- [ ] 智能采样生效，不同速度下采样间隔不同

---

## 技术要点
- `allowsBackgroundLocationUpdates = true` 必须在有后台权限时才能设置
- `showsBackgroundLocationIndicator = true` 显示蓝色状态栏，提醒用户正在使用定位
- 智能采样可以显著减少电池消耗和数据量

---

## 完成后
提交代码到 GitHub，备注："Day 3: GPS轨迹记录 + 智能采样 + 出行方式识别"
