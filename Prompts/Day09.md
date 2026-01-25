# Day 9 开发提示词

## 今日目标
**数据同步 + 商业化系统 + 数据洞察 + 引导页**

请阅读 `/Users/xiaomu/Desktop/Leyhome/PRD.md` 第7节（商业模式）和第8节（技术架构），然后完成以下任务。

---

## 任务清单

### 1. Supabase 数据同步服务

**创建 `SyncManager.swift`**：
```swift
import Foundation
import Supabase
import Network

@MainActor
class SyncManager: ObservableObject {
    static let shared = SyncManager()

    @Published var isSyncing = false
    @Published var lastSyncTime: Date?
    @Published var pendingChanges: Int = 0

    private let client = SupabaseConfig.client
    private let networkMonitor = NWPathMonitor()
    private var isOnline = true

    init() {
        setupNetworkMonitoring()
    }

    // MARK: - 网络监控
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                if self?.isOnline == true {
                    Task { await self?.syncPendingChanges() }
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue.global())
    }

    // MARK: - 同步轨迹
    func syncTrack(_ track: Track) async throws {
        guard isOnline else {
            markForLaterSync(track)
            return
        }

        isSyncing = true
        defer { isSyncing = false }

        let trackData: [String: Any] = [
            "id": track.id.uuidString,
            "user_id": track.userId.uuidString,
            "travel_mode": track.travelMode,
            "started_at": ISO8601DateFormatter().string(from: track.startedAt),
            "ended_at": track.endedAt.map { ISO8601DateFormatter().string(from: $0) } as Any,
            "total_distance": track.totalDistance,
            "average_speed": track.averageSpeed,
            "path": formatPathForPostGIS(track.points)
        ]

        try await client
            .from("tracks")
            .upsert(trackData)
            .execute()

        lastSyncTime = Date()
    }

    // MARK: - 同步心绪节点
    func syncNode(_ node: MoodNode) async throws {
        guard isOnline else {
            markForLaterSync(node)
            return
        }

        let nodeData: [String: Any] = [
            "id": node.id.uuidString,
            "track_id": node.trackId?.uuidString as Any,
            "user_id": node.userId.uuidString,
            "mood_type": node.moodType,
            "content": node.content as Any,
            "media_urls": node.photos,
            "location": "POINT(\(node.longitude) \(node.latitude))",
            "created_at": ISO8601DateFormatter().string(from: node.createdAt)
        ]

        try await client
            .from("nodes")
            .upsert(nodeData)
            .execute()
    }

    // MARK: - 同步回响
    func syncEcho(_ echo: Echo) async throws {
        let echoData: [String: Any] = [
            "id": echo.id.uuidString,
            "site_id": echo.siteId.uuidString,
            "user_id": echo.userId.uuidString,
            "content": echo.content,
            "media_urls": echo.mediaUrls,
            "is_public": echo.isPublic,
            "is_anonymous": echo.isAnonymous,
            "created_at": ISO8601DateFormatter().string(from: echo.createdAt)
        ]

        try await client
            .from("echoes")
            .upsert(echoData)
            .execute()
    }

    // MARK: - 拉取数据
    func fetchTracks(userId: UUID) async throws -> [Track] {
        let response = try await client
            .from("tracks")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("started_at", ascending: false)
            .execute()

        // TODO: 解析响应数据
        return []
    }

    func fetchSacredSites() async throws -> [SacredSite] {
        let response = try await client
            .from("sacred_sites")
            .select()
            .execute()

        // TODO: 解析响应数据
        return []
    }

    // MARK: - 辅助方法
    private func formatPathForPostGIS(_ points: [TrackPoint]) -> String {
        let coordString = points.map { "\($0.longitude) \($0.latitude)" }.joined(separator: ", ")
        return "LINESTRING(\(coordString))"
    }

    private func markForLaterSync(_ item: Any) {
        pendingChanges += 1
        // TODO: 存储到本地待同步队列
    }

    private func syncPendingChanges() async {
        // TODO: 同步所有待同步的数据
        pendingChanges = 0
    }
}
```

### 2. 存储服务（图片/音频上传）

**创建 `StorageService.swift`**：
```swift
import Foundation
import Supabase
import UIKit

class StorageService {
    static let shared = StorageService()
    private let client = SupabaseConfig.client

    // 上传图片
    func uploadImage(_ image: UIImage, path: String) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImage
        }

        let fileName = "\(path)/\(UUID().uuidString).jpg"

        try await client.storage
            .from("media")
            .upload(path: fileName, file: data, options: FileOptions(contentType: "image/jpeg"))

        // 获取公开 URL
        let publicUrl = try client.storage
            .from("media")
            .getPublicURL(path: fileName)

        return publicUrl.absoluteString
    }

    // 上传多张图片
    func uploadImages(_ images: [UIImage], folder: String) async throws -> [String] {
        var urls: [String] = []
        for (index, image) in images.enumerated() {
            let url = try await uploadImage(image, path: "\(folder)/\(index)")
            urls.append(url)
        }
        return urls
    }

    // 上传音频
    func uploadAudio(data: Data, path: String) async throws -> String {
        let fileName = "\(path)/\(UUID().uuidString).m4a"

        try await client.storage
            .from("media")
            .upload(path: fileName, file: data, options: FileOptions(contentType: "audio/m4a"))

        let publicUrl = try client.storage
            .from("media")
            .getPublicURL(path: fileName)

        return publicUrl.absoluteString
    }

    enum StorageError: Error {
        case invalidImage
        case uploadFailed
    }
}
```

### 3. 订阅系统

**创建 `SubscriptionManager.swift`**（基于PRD 7.2）：
```swift
import StoreKit
import SwiftUI

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var isSubscribed = false
    @Published var subscriptionStatus: Product.SubscriptionInfo.Status?
    @Published var availableProducts: [Product] = []
    @Published var isLoading = false

    private let productIds = [
        "com.leyhome.subscription.monthly",
        "com.leyhome.subscription.yearly"
    ]

    init() {
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }

    // 加载产品
    func loadProducts() async {
        isLoading = true
        do {
            availableProducts = try await Product.products(for: productIds)
        } catch {
            print("Failed to load products: \(error)")
        }
        isLoading = false
    }

    // 购买订阅
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await checkSubscriptionStatus()
            return true

        case .pending:
            return false

        case .userCancelled:
            return false

        @unknown default:
            return false
        }
    }

    // 恢复购买
    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productType == .autoRenewable {
                    isSubscribed = true
                }
            }
        }
    }

    // 检查订阅状态
    func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productType == .autoRenewable {
                    isSubscribed = transaction.revocationDate == nil
                    return
                }
            }
        }
        isSubscribed = false
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    enum SubscriptionError: Error {
        case verificationFailed
        case purchaseFailed
    }
}
```

### 4. 订阅页面

**创建 `SubscriptionView.swift`**：
```swift
import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.xl) {
                    // 头部
                    VStack(spacing: LeyhomeTheme.Spacing.md) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(LeyhomeTheme.accent)

                        Text("subscription.title".localized)
                            .font(.title)
                            .fontWeight(.bold)

                        Text("subscription.subtitle".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    // 权益列表（PRD 7.2）
                    VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
                        BenefitRow(icon: "icloud.fill", title: "subscription.benefit.cloud".localized, description: "subscription.benefit.cloud.desc".localized)
                        BenefitRow(icon: "arrow.triangle.2.circlepath", title: "subscription.benefit.sync".localized, description: "subscription.benefit.sync.desc".localized)
                        BenefitRow(icon: "person.2.fill", title: "subscription.benefit.guides".localized, description: "subscription.benefit.guides.desc".localized)
                        BenefitRow(icon: "chart.bar.fill", title: "subscription.benefit.insights".localized, description: "subscription.benefit.insights.desc".localized)
                        BenefitRow(icon: "paintpalette.fill", title: "subscription.benefit.themes".localized, description: "subscription.benefit.themes.desc".localized)
                        BenefitRow(icon: "heart.fill", title: "subscription.benefit.support".localized, description: "subscription.benefit.support.desc".localized)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
                    .padding(.horizontal)

                    // 价格选项
                    VStack(spacing: LeyhomeTheme.Spacing.md) {
                        ForEach(subscriptionManager.availableProducts, id: \.id) { product in
                            ProductCard(
                                product: product,
                                isSelected: selectedProduct?.id == product.id,
                                isYearly: product.id.contains("yearly")
                            ) {
                                selectedProduct = product
                            }
                        }
                    }
                    .padding(.horizontal)

                    // 订阅按钮
                    Button(action: purchase) {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("subscription.subscribe".localized)
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedProduct != nil ? LeyhomeTheme.primary : Color.gray)
                        .cornerRadius(LeyhomeTheme.CornerRadius.md)
                    }
                    .disabled(selectedProduct == nil || isPurchasing)
                    .padding(.horizontal)

                    // 恢复购买
                    Button("subscription.restore".localized) {
                        Task { await subscriptionManager.restorePurchases() }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    // 条款
                    VStack(spacing: 4) {
                        Text("subscription.terms".localized)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 16) {
                            Link("subscription.privacy".localized, destination: URL(string: "https://leyhome.app/privacy")!)
                            Link("subscription.tos".localized, destination: URL(string: "https://leyhome.app/terms")!)
                        }
                        .font(.caption2)
                    }
                    .padding()
                }
            }
            .navigationTitle("subscription.premium".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("button.close".localized) { dismiss() }
                }
            }
            .alert("subscription.error".localized, isPresented: $showError) {
                Button("button.ok".localized) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func purchase() {
        guard let product = selectedProduct else { return }
        isPurchasing = true

        Task {
            do {
                let success = try await subscriptionManager.purchase(product)
                if success {
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isPurchasing = false
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(LeyhomeTheme.primary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let isYearly: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(isYearly ? "subscription.yearly".localized : "subscription.monthly".localized)
                            .font(.headline)

                        if isYearly {
                            Text("subscription.save".localized)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }

                    Text(product.displayPrice + (isYearly ? "/\("subscription.year".localized)" : "/\("subscription.month".localized)"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? LeyhomeTheme.primary : .gray)
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
```

### 5. 数据洞察页面

**创建 `InsightsView.swift`**（基于PRD 4.1.4）：
```swift
import SwiftUI
import Charts

struct InsightsView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var stats: UserStats?
    @State private var showSubscription = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if subscriptionManager.isSubscribed {
                    insightsContent
                } else {
                    lockedContent
                }
            }
            .navigationTitle("insights.title".localized)
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
            .onAppear {
                loadStats()
            }
        }
    }

    private var insightsContent: some View {
        VStack(spacing: LeyhomeTheme.Spacing.lg) {
            // 总览卡片
            OverviewCard(stats: stats)

            // 出行方式分布
            TravelModeChart(stats: stats)

            // 情绪分布
            MoodDistributionChart(stats: stats)

            // 周活跃度
            WeeklyActivityChart(stats: stats)

            // 个人成长报告
            GrowthReportSection(stats: stats)
        }
        .padding()
    }

    private var lockedContent: some View {
        VStack(spacing: LeyhomeTheme.Spacing.xl) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("insights.locked.title".localized)
                .font(.title2)
                .fontWeight(.bold)

            Text("insights.locked.subtitle".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: { showSubscription = true }) {
                Text("insights.unlock".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LeyhomeTheme.primary)
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    private func loadStats() {
        // TODO: 从数据库加载统计
        stats = UserStats.sample
    }
}

struct UserStats {
    var totalDistance: Double
    var totalTracks: Int
    var totalNodes: Int
    var visitedSites: Int
    var travelModeDistribution: [TravelMode: Double]
    var moodDistribution: [MoodType: Int]
    var weeklyActivity: [Int: Int]  // weekday: count
    var streakDays: Int
    var longestStreak: Int

    static var sample: UserStats {
        UserStats(
            totalDistance: 156.8,
            totalTracks: 42,
            totalNodes: 128,
            visitedSites: 8,
            travelModeDistribution: [.walking: 0.6, .cycling: 0.25, .driving: 0.1, .flying: 0.05],
            moodDistribution: [.calm: 35, .joy: 28, .inspiration: 20, .gratitude: 15, .nostalgia: 12],
            weeklyActivity: [1: 5, 2: 3, 3: 4, 4: 6, 5: 2, 6: 8, 7: 7],
            streakDays: 12,
            longestStreak: 21
        )
    }
}

struct OverviewCard: View {
    let stats: UserStats?

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            Text("insights.overview".localized)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LeyhomeTheme.Spacing.md) {
                StatCard(value: String(format: "%.1f km", stats?.totalDistance ?? 0), label: "insights.distance".localized, icon: "figure.walk")
                StatCard(value: "\(stats?.totalTracks ?? 0)", label: "insights.tracks".localized, icon: "map")
                StatCard(value: "\(stats?.totalNodes ?? 0)", label: "insights.nodes".localized, icon: "mappin.circle")
                StatCard(value: "\(stats?.visitedSites ?? 0)", label: "insights.sites".localized, icon: "star")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(LeyhomeTheme.primary)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(LeyhomeTheme.CornerRadius.sm)
    }
}

struct TravelModeChart: View {
    let stats: UserStats?

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            Text("insights.travel_modes".localized)
                .font(.headline)

            if let distribution = stats?.travelModeDistribution {
                Chart {
                    ForEach(Array(distribution.keys), id: \.self) { mode in
                        SectorMark(
                            angle: .value("Percentage", distribution[mode] ?? 0),
                            innerRadius: .ratio(0.5),
                            angularInset: 1.5
                        )
                        .foregroundStyle(mode.lineColor)
                        .cornerRadius(5)
                    }
                }
                .frame(height: 200)

                // 图例
                HStack(spacing: LeyhomeTheme.Spacing.md) {
                    ForEach(Array(distribution.keys), id: \.self) { mode in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(mode.lineColor)
                                .frame(width: 10, height: 10)
                            Text(mode.rawValue)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct MoodDistributionChart: View {
    let stats: UserStats?

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            Text("insights.moods".localized)
                .font(.headline)

            if let distribution = stats?.moodDistribution {
                Chart {
                    ForEach(Array(distribution.keys.sorted(by: { distribution[$0]! > distribution[$1]! })), id: \.self) { mood in
                        BarMark(
                            x: .value("Count", distribution[mood] ?? 0),
                            y: .value("Mood", mood.nameZh)
                        )
                        .foregroundStyle(mood.color)
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct WeeklyActivityChart: View {
    let stats: UserStats?

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            Text("insights.weekly".localized)
                .font(.headline)

            if let activity = stats?.weeklyActivity {
                Chart {
                    ForEach(1...7, id: \.self) { day in
                        BarMark(
                            x: .value("Day", weekdayName(day)),
                            y: .value("Count", activity[day] ?? 0)
                        )
                        .foregroundStyle(LeyhomeTheme.primary)
                    }
                }
                .frame(height: 150)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private func weekdayName(_ day: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols[day - 1]
    }
}

struct GrowthReportSection: View {
    let stats: UserStats?

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            Text("insights.growth".localized)
                .font(.headline)

            HStack(spacing: LeyhomeTheme.Spacing.lg) {
                VStack {
                    Text("\(stats?.streakDays ?? 0)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(LeyhomeTheme.primary)
                    Text("insights.current_streak".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Text("\(stats?.longestStreak ?? 0)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(LeyhomeTheme.accent)
                    Text("insights.longest_streak".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
```

### 6. 引导页

**创建 `OnboardingView.swift`**：
```swift
import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "map.fill",
            titleKey: "onboarding.page1.title",
            descriptionKey: "onboarding.page1.description"
        ),
        OnboardingPage(
            image: "sparkles",
            titleKey: "onboarding.page2.title",
            descriptionKey: "onboarding.page2.description"
        ),
        OnboardingPage(
            image: "star.fill",
            titleKey: "onboarding.page3.title",
            descriptionKey: "onboarding.page3.description"
        ),
        OnboardingPage(
            image: "person.2.fill",
            titleKey: "onboarding.page4.title",
            descriptionKey: "onboarding.page4.description"
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // 页面指示器
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? LeyhomeTheme.primary : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding()

            // 按钮
            Button(action: {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    hasCompletedOnboarding = true
                }
            }) {
                Text(currentPage < pages.count - 1 ? "onboarding.next".localized : "onboarding.start".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LeyhomeTheme.primary)
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
            }
            .padding(.horizontal)

            if currentPage < pages.count - 1 {
                Button("onboarding.skip".localized) {
                    hasCompletedOnboarding = true
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
            }
        }
        .background(LeyhomeTheme.secondary)
    }
}

struct OnboardingPage {
    let image: String
    let titleKey: String
    let descriptionKey: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.xl) {
            Spacer()

            Image(systemName: page.image)
                .font(.system(size: 80))
                .foregroundColor(LeyhomeTheme.primary)

            VStack(spacing: LeyhomeTheme.Spacing.md) {
                Text(page.titleKey.localized)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.descriptionKey.localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
            Spacer()
        }
        .padding()
    }
}
```

### 7. 国际化文案补充

```
// 订阅
"subscription.title" = "成为深度行者" / "Become a Deep Walker"
"subscription.subtitle" = "解锁完整体验，开启深度探索之旅" / "Unlock the full experience, begin your deep exploration"
"subscription.premium" = "深度行者" / "Deep Walker"
"subscription.benefit.cloud" = "无限云端珍藏" / "Unlimited Cloud Storage"
"subscription.benefit.cloud.desc" = "所有轨迹和心绪永久保存" / "All tracks and moods permanently saved"
"subscription.benefit.sync" = "跨设备同步" / "Cross-device Sync"
"subscription.benefit.sync.desc" = "随时随地访问你的心灵地图" / "Access your soul map anytime, anywhere"
"subscription.benefit.guides" = "完整引路权限" / "Full Guide Access"
"subscription.benefit.guides.desc" = "体验所有先行者的星图" / "Experience all pathfinders' constellations"
"subscription.benefit.insights" = "深度数据洞察" / "Deep Data Insights"
"subscription.benefit.insights.desc" = "了解你的行走模式和成长轨迹" / "Understand your walking patterns and growth"
"subscription.benefit.themes" = "高级地图主题" / "Premium Map Themes"
"subscription.benefit.themes.desc" = "艺术家设计的独特视觉风格" / "Unique visual styles designed by artists"
"subscription.benefit.support" = "支持开发" / "Support Development"
"subscription.benefit.support.desc" = "帮助我们做得更好" / "Help us make it better"
"subscription.monthly" = "月度订阅" / "Monthly"
"subscription.yearly" = "年度订阅" / "Yearly"
"subscription.month" = "月" / "month"
"subscription.year" = "年" / "year"
"subscription.save" = "省17%" / "Save 17%"
"subscription.subscribe" = "开始订阅" / "Subscribe Now"
"subscription.restore" = "恢复购买" / "Restore Purchases"
"subscription.terms" = "订阅将自动续费，可随时在设置中取消" / "Subscription auto-renews. Cancel anytime in Settings."
"subscription.privacy" = "隐私政策" / "Privacy Policy"
"subscription.tos" = "服务条款" / "Terms of Service"
"subscription.error" = "购买失败" / "Purchase Failed"

// 数据洞察
"insights.title" = "数据洞察" / "Insights"
"insights.locked.title" = "解锁数据洞察" / "Unlock Insights"
"insights.locked.subtitle" = "订阅深度行者，了解你的行走模式和内心成长" / "Subscribe to Deep Walker to understand your walking patterns and inner growth"
"insights.unlock" = "解锁" / "Unlock"
"insights.overview" = "总览" / "Overview"
"insights.distance" = "总里程" / "Total Distance"
"insights.tracks" = "轨迹数" / "Tracks"
"insights.nodes" = "心绪节点" / "Mood Nodes"
"insights.sites" = "到访圣迹" / "Sites Visited"
"insights.travel_modes" = "出行方式分布" / "Travel Mode Distribution"
"insights.moods" = "情绪分布" / "Mood Distribution"
"insights.weekly" = "周活跃度" / "Weekly Activity"
"insights.growth" = "成长报告" / "Growth Report"
"insights.current_streak" = "当前连续" / "Current Streak"
"insights.longest_streak" = "最长连续" / "Longest Streak"

// 引导页
"onboarding.page1.title" = "心灵地图" / "Soul Map"
"onboarding.page1.description" = "将你的每一步转化为独特的能量线，绘制专属于你的心灵地图。" / "Transform every step into a unique energy line, drawing your personal soul map."
"onboarding.page2.title" = "心绪节点" / "Mood Nodes"
"onboarding.page2.description" = "在行走中记录思绪与感受，让每一个瞬间都有迹可循。" / "Record thoughts and feelings while walking, making every moment traceable."
"onboarding.page3.title" = "探索圣迹" / "Explore Sacred Sites"
"onboarding.page3.description" = "发现全球的能量圣地，连接内在世界与地球的脉搏。" / "Discover energy sites around the world, connecting your inner world with Earth's pulse."
"onboarding.page4.title" = "跟随先行者" / "Follow Pathfinders"
"onboarding.page4.description" = "在先行者的引导下，踏上寻找自我的归途。" / "Under the guidance of pathfinders, embark on the journey of self-discovery."
"onboarding.next" = "下一步" / "Next"
"onboarding.skip" = "跳过" / "Skip"
"onboarding.start" = "开始旅程" / "Begin Journey"

// 通用
"button.close" = "关闭" / "Close"
"button.ok" = "好的" / "OK"
```

---

## 验收标准
- [ ] 数据可正确同步到 Supabase
- [ ] 离线时数据保存本地，在线时自动同步
- [ ] 订阅页面显示正确，可选择月度/年度
- [ ] 购买流程正常（需在真机+沙盒环境测试）
- [ ] 数据洞察页面正确显示统计图表
- [ ] 非订阅用户看到锁定状态
- [ ] 引导页可正常浏览和跳过

---

## 完成后
提交代码到 GitHub，备注："Day 9: 数据同步 + 商业化系统 + 数据洞察 + 引导页"
