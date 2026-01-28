//
//  TrackingManager.swift
//  Leyhome - 地脉归途
//
//  轨迹追踪管理器 - 管理 GPS 轨迹记录
//
//  Created on 2026/01/26.
//  Enhanced on 2026/01/28: Intelligent sampling & TransportMode integration
//

import Foundation
import CoreLocation
import Combine

class TrackingManager: NSObject, ObservableObject {
    static let shared = TrackingManager()

    // MARK: - Published Properties
    @Published var isTracking = false
    @Published var currentLocation: CLLocation?
    @Published var currentTrack: [CLLocationCoordinate2D] = []
    @Published var currentTransportMode: TransportMode = .walking
    @Published var totalDistance: Double = 0  // 米
    @Published var duration: TimeInterval = 0  // 秒
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private var startTime: Date?
    private var timer: Timer?
    private var lastLocation: CLLocation?
    private var lastRecordedLocation: CLLocation?
    private var lastRecordedTime: Date?

    // MARK: - Initialization
    override private init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10  // 每移动10米更新一次

        // 后台定位配置（需要在 Xcode 项目设置中启用 Background Modes - Location updates）
        #if os(iOS)
        // 暂时注释掉后台定位，避免崩溃
        // locationManager.allowsBackgroundLocationUpdates = true
        // locationManager.showsBackgroundLocationIndicator = true
        #endif

        locationManager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: - 位置更新控制

    /// 开始更新位置（不开始追踪记录）
    /// 用于地图页面显示当前位置
    func startLocationUpdates() {
        guard authorizationStatus != .denied && authorizationStatus != .restricted else {
            print("❌ startLocationUpdates: 定位权限被拒绝")
            return
        }

        locationManager.startUpdatingLocation()
        print("📍 开始更新位置（仅定位，不追踪）")
    }

    /// 停止更新位置
    func stopLocationUpdates() {
        if !isTracking {
            locationManager.stopUpdatingLocation()
            print("📍 停止更新位置")
        }
    }

    // MARK: - 智能采样

    /// 判断是否应该记录该位置点
    /// - Parameter location: 待判断的位置
    /// - Returns: true 表示应该记录
    private func shouldRecordLocation(_ location: CLLocation) -> Bool {
        guard let last = lastRecordedLocation else { return true }

        // 1. 精度过滤：拒绝精度低于 50 米的点
        guard location.horizontalAccuracy < 50 else { return false }

        // 2. 时间过滤：至少间隔 1 秒（测试模式下放宽到 0.5 秒）
        if let lastTime = lastRecordedTime {
            #if DEBUG
            let minInterval: TimeInterval = 0.5  // 调试模式：0.5秒
            #else
            let minInterval: TimeInterval = 1.0  // 生产模式：1秒
            #endif

            if location.timestamp.timeIntervalSince(lastTime) < minInterval {
                return false
            }
        }

        // 3. 距离过滤：根据出行方式动态调整阈值
        let distance = location.distance(from: last)
        let threshold: Double

        #if DEBUG
        // 调试模式：降低距离阈值以便测试
        switch currentTransportMode {
        case .walking: threshold = 1    // 1米（生产：5米）
        case .cycling: threshold = 5    // 5米（生产：15米）
        case .driving: threshold = 10   // 10米（生产：50米）
        case .flying: threshold = 50    // 50米（生产：500米）
        }
        #else
        // 生产模式：正常阈值
        switch currentTransportMode {
        case .walking: threshold = 5
        case .cycling: threshold = 15
        case .driving: threshold = 50
        case .flying: threshold = 500
        }
        #endif

        guard distance >= threshold else { return false }

        // 4. 速度验证：防止异常跳点（超过 200 km/h）
        if location.speed >= 0 {
            let speedKmh = location.speed * 3.6
            guard speedKmh < 200 else { return false }
        }

        return true
    }

    // MARK: - 请求定位权限
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    // MARK: - 开始追踪
    func startTracking() {
        guard !isTracking else {
            print("⚠️ startTracking: 已经在追踪状态")
            return
        }

        // 检查定位权限
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            print("❌ startTracking: 定位权限被拒绝")
            return
        }

        // 重置数据
        currentTrack = []
        totalDistance = 0
        duration = 0
        lastLocation = nil
        lastRecordedLocation = nil
        lastRecordedTime = nil

        // 开始记录
        startTime = Date()
        isTracking = true
        locationManager.startUpdatingLocation()

        print("✅ startTracking: 开始追踪")
        print("   - 权限状态: \(authorizationStatus.rawValue)")
        print("   - 当前位置: \(currentLocation?.coordinate.latitude ?? 0), \(currentLocation?.coordinate.longitude ?? 0)")

        // 启动计时器
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.duration = Date().timeIntervalSince(startTime)
        }
    }

    // MARK: - 停止追踪
    func stopTracking() -> Journey? {
        guard isTracking else {
            print("⚠️ stopTracking: 当前未在追踪状态")
            return nil
        }
        guard let startTime = startTime else {
            print("⚠️ stopTracking: startTime 为空")
            return nil
        }

        // 降低最小点数要求：至少 1 个点即可停止（调试模式）
        #if DEBUG
        guard currentTrack.count >= 1 else {
            print("⚠️ stopTracking: 轨迹点不足（当前: \(currentTrack.count)）")
            return nil
        }
        #else
        guard currentTrack.count >= 2 else {
            print("⚠️ stopTracking: 轨迹点不足（当前: \(currentTrack.count)）")
            return nil
        }
        #endif

        isTracking = false
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil

        // 创建 Journey 对象
        let journey = Journey(
            userID: "", // 需要外部传入
            name: "Journey_\(Date().formatted())",
            startTime: startTime,
            endTime: Date(),
            transportMode: currentTransportMode,
            distance: totalDistance,
            duration: duration
        )

        // 设置路径点
        journey.pathPoints = currentTrack
        journey.startLocation = currentTrack.first
        journey.endLocation = currentTrack.last

        // 重置状态
        self.startTime = nil
        currentTrack = []
        totalDistance = 0
        duration = 0
        lastLocation = nil
        lastRecordedLocation = nil
        lastRecordedTime = nil

        return journey
    }

    // MARK: - 暂停/恢复
    func pauseTracking() {
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
    }

    func resumeTracking() {
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.duration = Date().timeIntervalSince(startTime)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension TrackingManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // 更新当前位置（无论是否在追踪）
        currentLocation = location

        #if DEBUG
        print("📍 收到位置更新: (\(location.coordinate.latitude), \(location.coordinate.longitude))")
        print("   - 精度: \(location.horizontalAccuracy)m, 速度: \(location.speed)m/s")
        print("   - 追踪状态: \(isTracking), 轨迹点数: \(currentTrack.count)")
        #endif

        if isTracking {
            // 自动检测出行方式
            if location.speed >= 0 {
                let speedKmh = location.speed * 3.6
                let oldMode = currentTransportMode
                currentTransportMode = TransportMode.detect(speedKmh: speedKmh)

                #if DEBUG
                if oldMode != currentTransportMode {
                    print("🚶‍♂️ 出行方式变化: \(oldMode.rawValue) → \(currentTransportMode.rawValue)")
                }
                #endif
            }

            // 智能采样判断
            guard shouldRecordLocation(location) else {
                #if DEBUG
                print("   ⏭️ 跳过该点（不满足采样条件）")
                #endif
                return
            }

            // 计算距离
            if let lastLocation = lastLocation {
                let distance = location.distance(from: lastLocation)
                totalDistance += distance

                #if DEBUG
                print("   ➕ 记录新点，距离增加: \(distance)m，总距离: \(totalDistance)m")
                #endif
            }

            // 添加到轨迹
            currentTrack.append(location.coordinate)
            lastLocation = location
            lastRecordedLocation = location
            lastRecordedTime = location.timestamp
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let oldStatus = authorizationStatus
        authorizationStatus = manager.authorizationStatus

        print("🔐 定位权限状态变化:")
        print("   - 旧状态: \(oldStatus.rawValue)")
        print("   - 新状态: \(authorizationStatus.rawValue)")

        switch authorizationStatus {
        case .notDetermined:
            print("   ℹ️ 未确定，需要请求权限")
        case .restricted:
            print("   ⚠️ 受限制（家长控制等）")
        case .denied:
            print("   ❌ 用户拒绝了定位权限")
        case .authorizedWhenInUse:
            print("   ✅ 已授权（使用时）")
            // 权限授予后，自动开始更新位置
            if oldStatus == .notDetermined {
                startLocationUpdates()
            }
        case .authorizedAlways:
            print("   ✅ 已授权（始终）")
            // 权限授予后，自动开始更新位置
            if oldStatus == .notDetermined {
                startLocationUpdates()
            }
        @unknown default:
            print("   ❓ 未知状态")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ 定位失败: \(error.localizedDescription)")
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("   → 定位权限被拒绝")
            case .locationUnknown:
                print("   → 位置未知（可能是模拟器未设置位置）")
            case .network:
                print("   → 网络错误")
            default:
                print("   → 错误码: \(clError.code.rawValue)")
            }
        }
    }
}
