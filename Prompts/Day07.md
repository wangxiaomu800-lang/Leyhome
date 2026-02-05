# Day 7 开发提示词

## 今日目标
**回响系统 + 意向系统 + 寻迹申请系统**

请阅读 `/Users/xiaomu/Desktop/Leyhome/GDD.md` 第4.3-4.4节（回响系统、意向系统）和 `/Users/xiaomu/Desktop/Leyhome/PRD.md` 第5.3-5.4节及5.2.6节（寻迹申请），然后完成以下任务。如已开发，请跳过

---

## 任务清单

### 1. 回响数据模型

**创建 `Echo.swift`**：
```swift
import Foundation
import SwiftData

@Model
class Echo: Identifiable {
    @Attribute(.unique) var id: UUID
    var siteId: UUID
    var userId: UUID
    var userNickname: String?
    var userAvatarUrl: String?

    var content: String
    var mediaUrlsData: Data?  // [String]

    var isPublic: Bool = false
    var isAnonymous: Bool = false

    var createdAt: Date
    var updatedAt: Date

    init(siteId: UUID, userId: UUID, content: String) {
        self.id = UUID()
        self.siteId = siteId
        self.userId = userId
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var mediaUrls: [String] {
        get {
            guard let data = mediaUrlsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            mediaUrlsData = try? JSONEncoder().encode(newValue)
        }
    }

    var displayName: String {
        if isAnonymous {
            return "echo.anonymous".localized
        }
        return userNickname ?? "echo.anonymous".localized
    }
}
```

### 2. 回响列表组件

**创建 `EchoesSection.swift`**（嵌入圣迹详情页）：
```swift
import SwiftUI

struct EchoesSection: View {
    let siteId: UUID
    @State private var echoes: [Echo] = []
    @State private var showComposer = false
    @State private var selectedTab = 0  // 0=众人的回响, 1=我的回响

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            // 标题和Tab切换
            HStack {
                Text("echo.title".localized)
                    .font(.headline)

                Spacer()

                Picker("", selection: $selectedTab) {
                    Text("echo.public".localized).tag(0)
                    Text("echo.mine".localized).tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }

            // 内容
            if filteredEchoes.isEmpty {
                EmptyEchoView()
            } else {
                LazyVStack(spacing: LeyhomeTheme.Spacing.md) {
                    ForEach(filteredEchoes) { echo in
                        EchoCard(echo: echo)
                    }
                }
            }

            // 留下回响按钮
            Button(action: { showComposer = true }) {
                HStack {
                    Image(systemName: "plus.bubble.fill")
                    Text("echo.leave".localized)
                }
                .font(.subheadline)
                .foregroundColor(LeyhomeTheme.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LeyhomeTheme.primary.opacity(0.1))
                .cornerRadius(LeyhomeTheme.CornerRadius.md)
            }
        }
        .sheet(isPresented: $showComposer) {
            EchoComposerView(siteId: siteId) { newEcho in
                echoes.insert(newEcho, at: 0)
            }
        }
        .onAppear {
            loadEchoes()
        }
    }

    private var filteredEchoes: [Echo] {
        if selectedTab == 1 {
            // 我的回响
            // TODO: 根据当前用户ID筛选
            return echoes.filter { $0.userId == UUID() }
        }
        return echoes.filter { $0.isPublic }
    }

    private func loadEchoes() {
        // TODO: 从Supabase加载
    }
}

struct EmptyEchoView: View {
    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            // GDD: "零回响"状态的诗意文案
            Text("echo.empty".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LeyhomeTheme.Spacing.xl)
    }
}

struct EchoCard: View {
    let echo: Echo

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            // 头部：用户信息
            HStack {
                if echo.isAnonymous {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                } else {
                    AsyncImage(url: URL(string: echo.userAvatarUrl ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(echo.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(echo.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // 内容
            Text(echo.content)
                .font(.body)
                .lineSpacing(4)

            // 媒体预览
            if !echo.mediaUrls.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(echo.mediaUrls, id: \.self) { url in
                            AsyncImage(url: URL(string: url)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
    }
}
```

### 3. 回响发布视图

**创建 `EchoComposerView.swift`**：
```swift
import SwiftUI
import PhotosUI

struct EchoComposerView: View {
    let siteId: UUID
    let onSave: (Echo) -> Void

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager

    @State private var content = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []
    @State private var isPublic = false
    @State private var isAnonymous = false
    @State private var isSaving = false

    private let maxCharacters = 500

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    // 内容输入
                    VStack(alignment: .leading, spacing: 8) {
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(LeyhomeTheme.CornerRadius.sm)

                        HStack {
                            Text("\(content.count)/\(maxCharacters)")
                                .font(.caption)
                                .foregroundColor(content.count > maxCharacters ? .red : .secondary)

                            Spacer()
                        }
                    }

                    // 照片选择
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("echo.photos".localized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Spacer()

                            PhotosPicker(
                                selection: $selectedPhotos,
                                maxSelectionCount: 9,
                                matching: .images
                            ) {
                                Label("echo.add_photo".localized, systemImage: "photo.badge.plus")
                                    .font(.caption)
                            }
                        }

                        if !photoImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(photoImages.enumerated()), id: \.offset) { index, image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(alignment: .topTrailing) {
                                                Button(action: { removePhoto(at: index) }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.white)
                                                        .background(Color.black.opacity(0.5))
                                                        .clipShape(Circle())
                                                }
                                                .padding(4)
                                            }
                                    }
                                }
                            }
                        }
                    }

                    // 隐私设置（GDD: 默认"仅自己可见"）
                    VStack(spacing: LeyhomeTheme.Spacing.md) {
                        Toggle(isOn: $isPublic) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("echo.visibility.public".localized)
                                    .font(.subheadline)
                                Text("echo.visibility.public.hint".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        if isPublic {
                            Toggle(isOn: $isAnonymous) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("echo.anonymous".localized)
                                        .font(.subheadline)
                                    Text("echo.anonymous.hint".localized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
                }
                .padding()
            }
            .navigationTitle("echo.compose".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("button.cancel".localized) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("echo.publish".localized) {
                        saveEcho()
                    }
                    .disabled(content.isEmpty || content.count > maxCharacters || isSaving)
                }
            }
            .onChange(of: selectedPhotos) { _, newValue in
                loadPhotos(from: newValue)
            }
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) {
        photoImages = []
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                if case .success(let data) = result, let data = data,
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        photoImages.append(image)
                    }
                }
            }
        }
    }

    private func removePhoto(at index: Int) {
        photoImages.remove(at: index)
        selectedPhotos.remove(at: index)
    }

    private func saveEcho() {
        guard let userId = authManager.currentUser?.id else { return }

        isSaving = true

        let echo = Echo(siteId: siteId, userId: userId, content: content)
        echo.isPublic = isPublic
        echo.isAnonymous = isAnonymous
        echo.userNickname = authManager.currentUser?.nickname

        // TODO: 上传图片到 Supabase Storage

        Task {
            // TODO: 保存到 Supabase
            await MainActor.run {
                isSaving = false
                onSave(echo)
                dismiss()
            }
        }
    }
}
```

### 4. 意向数据模型

**创建 `Intention.swift`**：
```swift
import Foundation
import SwiftData

@Model
class Intention: Identifiable {
    @Attribute(.unique) var id: UUID
    var siteId: UUID
    var userId: UUID
    var targetYear: Int
    var targetMonth: Int
    var createdAt: Date

    init(siteId: UUID, userId: UUID, year: Int, month: Int) {
        self.id = UUID()
        self.siteId = siteId
        self.userId = userId
        self.targetYear = year
        self.targetMonth = month
        self.createdAt = Date()
    }
}

// 意向统计
struct IntentionStats {
    let siteId: UUID
    let totalCount: Int
    let monthlyBreakdown: [String: Int]  // "2026-07": 42
}
```

### 5. 意向Sheet

**创建 `IntentionSheet.swift`**（基于GDD 4.4）：
```swift
import SwiftUI

struct IntentionSheet: View {
    let site: SacredSite
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager

    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    @State private var intentionCount: Int = 0
    @State private var hasMarked = false
    @State private var isSaving = false

    init(site: SacredSite) {
        self.site = site
        let now = Date()
        let calendar = Calendar.current
        _selectedYear = State(initialValue: calendar.component(.year, from: now))
        _selectedMonth = State(initialValue: calendar.component(.month, from: now))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: LeyhomeTheme.Spacing.xl) {
                // 圣迹信息
                HStack(spacing: LeyhomeTheme.Spacing.md) {
                    AsyncImage(url: URL(string: site.imageUrl ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading) {
                        Text(site.name)
                            .font(.headline)
                        Text(site.country)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(LeyhomeTheme.CornerRadius.md)

                // 日期选择
                VStack(spacing: LeyhomeTheme.Spacing.md) {
                    Text("intention.when".localized)
                        .font(.headline)

                    HStack(spacing: LeyhomeTheme.Spacing.lg) {
                        // 年份
                        Picker("", selection: $selectedYear) {
                            ForEach(currentYear...(currentYear + 5), id: \.self) { year in
                                Text("\(year)").tag(year)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)

                        Text("intention.year".localized)

                        // 月份
                        Picker("", selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text("\(month)").tag(month)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)

                        Text("intention.month".localized)
                    }
                }

                Spacer()

                // 当前意向人数（GDD: 匿名数字反馈）
                if intentionCount > 0 {
                    Text("intention.count".localized(with: intentionCount, monthName))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LeyhomeTheme.starlight.opacity(0.2))
                        .cornerRadius(LeyhomeTheme.CornerRadius.md)
                }

                // 确认按钮
                Button(action: markIntention) {
                    HStack {
                        Image(systemName: hasMarked ? "checkmark.heart.fill" : "heart.fill")
                        Text(hasMarked ? "intention.marked".localized : "intention.aspire".localized)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(hasMarked ? Color.green : LeyhomeTheme.primary)
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
                }
                .disabled(hasMarked || isSaving)
            }
            .padding()
            .navigationTitle("intention.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("button.done".localized) { dismiss() }
                }
            }
            .onAppear {
                loadIntentionStats()
            }
        }
    }

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        var components = DateComponents()
        components.month = selectedMonth
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }

    private func loadIntentionStats() {
        // TODO: 从 Supabase 加载统计
        intentionCount = Int.random(in: 10...200) // 模拟数据
    }

    private func markIntention() {
        guard let userId = authManager.currentUser?.id else { return }

        isSaving = true

        let intention = Intention(
            siteId: site.id,
            userId: userId,
            year: selectedYear,
            month: selectedMonth
        )

        Task {
            // TODO: 保存到 Supabase
            await MainActor.run {
                isSaving = false
                hasMarked = true
                intentionCount += 1

                // 触觉反馈
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
}

extension String {
    func localized(with args: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: args)
    }
}
```

### 6. 寻迹申请系统

**创建 `Nomination.swift`**：
```swift
import Foundation
import SwiftData
import CoreLocation

enum NominationStatus: String, Codable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
}

@Model
class Nomination: Identifiable {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var userName: String?

    var name: String
    var description: String
    var reason: String  // 阐述理由

    // 位置
    var latitude: Double
    var longitude: Double

    // 媒体证据
    var mediaUrlsData: Data?

    var status: String = NominationStatus.pending.rawValue
    var rejectionReason: String?

    var createdAt: Date
    var reviewedAt: Date?

    init(userId: UUID, name: String) {
        self.id = UUID()
        self.userId = userId
        self.name = name
        self.description = ""
        self.reason = ""
        self.latitude = 0
        self.longitude = 0
        self.createdAt = Date()
    }

    var mediaUrls: [String] {
        get {
            guard let data = mediaUrlsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            mediaUrlsData = try? JSONEncoder().encode(newValue)
        }
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
```

**创建 `NominationFormView.swift`**（基于GDD 4.2.6 寻迹申请）：
```swift
import SwiftUI
import MapKit
import PhotosUI

struct NominationFormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager

    @State private var step = 1  // 1-5步
    @State private var name = ""
    @State private var description = ""
    @State private var reason = ""
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []
    @State private var agreedToTerms = false
    @State private var isSubmitting = false
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            VStack {
                // 步骤指示器
                StepIndicator(currentStep: step, totalSteps: 5)
                    .padding()

                // 步骤内容
                ScrollView {
                    switch step {
                    case 1:
                        LocationPickerStep(selectedLocation: $selectedLocation)
                    case 2:
                        NameDescriptionStep(name: $name, description: $description)
                    case 3:
                        ReasonStep(reason: $reason)
                    case 4:
                        EvidenceStep(selectedPhotos: $selectedPhotos, photoImages: $photoImages)
                    case 5:
                        CommitmentStep(agreedToTerms: $agreedToTerms)
                    default:
                        EmptyView()
                    }
                }

                // 导航按钮
                HStack(spacing: LeyhomeTheme.Spacing.md) {
                    if step > 1 {
                        Button("button.back".localized) {
                            withAnimation { step -= 1 }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(LeyhomeTheme.CornerRadius.md)
                    }

                    Button(step == 5 ? "nomination.submit".localized : "button.next".localized) {
                        if step == 5 {
                            submitNomination()
                        } else {
                            withAnimation { step += 1 }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canProceed ? LeyhomeTheme.primary : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
                    .disabled(!canProceed || isSubmitting)
                }
                .padding()
            }
            .navigationTitle("nomination.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("button.cancel".localized) { dismiss() }
                }
            }
            .alert("nomination.success.title".localized, isPresented: $showSuccess) {
                Button("button.done".localized) { dismiss() }
            } message: {
                Text("nomination.success.message".localized)
            }
        }
    }

    private var canProceed: Bool {
        switch step {
        case 1: return selectedLocation != nil
        case 2: return !name.isEmpty && !description.isEmpty
        case 3: return !reason.isEmpty
        case 4: return photoImages.count >= 3
        case 5: return agreedToTerms
        default: return true
        }
    }

    private func submitNomination() {
        guard let userId = authManager.currentUser?.id,
              let location = selectedLocation else { return }

        isSubmitting = true

        let nomination = Nomination(userId: userId, name: name)
        nomination.description = description
        nomination.reason = reason
        nomination.latitude = location.latitude
        nomination.longitude = location.longitude
        nomination.userName = authManager.currentUser?.nickname

        Task {
            // TODO: 上传照片和保存到 Supabase
            await MainActor.run {
                isSubmitting = false
                showSuccess = true
            }
        }
    }
}

struct StepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? LeyhomeTheme.primary : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)

                if step < totalSteps {
                    Rectangle()
                        .fill(step < currentStep ? LeyhomeTheme.primary : Color.gray.opacity(0.3))
                        .frame(height: 2)
                }
            }
        }
    }
}

// 步骤1: 精准定位
struct LocationPickerStep: View {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9, longitude: 116.4),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            Text("nomination.step1.title".localized)
                .font(.headline)

            Text("nomination.step1.hint".localized)
                .font(.caption)
                .foregroundColor(.secondary)

            // 地图选择
            Map(coordinateRegion: $region, interactionModes: .all)
                .frame(height: 300)
                .cornerRadius(LeyhomeTheme.CornerRadius.md)
                .overlay(
                    Image(systemName: "mappin")
                        .font(.title)
                        .foregroundColor(.red)
                )
                .onChange(of: region.center.latitude) { _, _ in
                    selectedLocation = region.center
                }

            if let location = selectedLocation {
                Text("(\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

// 步骤2: 命名定义
struct NameDescriptionStep: View {
    @Binding var name: String
    @Binding var description: String

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.lg) {
            Text("nomination.step2.title".localized)
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("nomination.name".localized)
                    .font(.subheadline)
                TextField("nomination.name.placeholder".localized, text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("nomination.description".localized)
                    .font(.subheadline)
                TextField("nomination.description.placeholder".localized, text: $description)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding()
    }
}

// 步骤3: 阐述理由
struct ReasonStep: View {
    @Binding var reason: String

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            Text("nomination.step3.title".localized)
                .font(.headline)

            Text("nomination.step3.hint".localized)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            TextEditor(text: $reason)
                .frame(minHeight: 200)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(LeyhomeTheme.CornerRadius.sm)
        }
        .padding()
    }
}

// 步骤4: 提供佐证
struct EvidenceStep: View {
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var photoImages: [UIImage]

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            Text("nomination.step4.title".localized)
                .font(.headline)

            Text("nomination.step4.hint".localized)
                .font(.caption)
                .foregroundColor(.secondary)

            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 9,
                matching: .images
            ) {
                VStack {
                    Image(systemName: "photo.badge.plus")
                        .font(.largeTitle)
                    Text("nomination.add_photos".localized)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(LeyhomeTheme.CornerRadius.md)
            }

            if !photoImages.isEmpty {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(Array(photoImages.enumerated()), id: \.offset) { _, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }

            Text("nomination.photos.required".localized)
                .font(.caption)
                .foregroundColor(photoImages.count >= 3 ? .green : .orange)
        }
        .padding()
        .onChange(of: selectedPhotos) { _, newValue in
            loadPhotos(from: newValue)
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) {
        photoImages = []
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                if case .success(let data) = result, let data = data,
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        photoImages.append(image)
                    }
                }
            }
        }
    }
}

// 步骤5: 提交承诺（GDD: 庄重、严肃）
struct CommitmentStep: View {
    @Binding var agreedToTerms: Bool

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.lg) {
            Image(systemName: "seal.fill")
                .font(.system(size: 60))
                .foregroundColor(LeyhomeTheme.accent)

            Text("nomination.step5.title".localized)
                .font(.headline)

            // GDD: 提交前的承诺
            Text("nomination.commitment".localized)
                .font(.body)
                .italic()
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(LeyhomeTheme.CornerRadius.md)

            Toggle(isOn: $agreedToTerms) {
                Text("nomination.agree".localized)
                    .font(.subheadline)
            }
        }
        .padding()
    }
}
```

### 7. 国际化文案补充

```
// 回响
"echo.title" = "此地的回响" / "Echoes of This Place"
"echo.public" = "众人的" / "Public"
"echo.mine" = "我的" / "Mine"
"echo.empty" = "万籁俱寂，此地的第一个回响，\n正等待你的声音。\n去感受，去记录，成为最初的共鸣者。" / "Silence reigns. The first echo of this place\nawaits your voice.\nFeel it, record it, become the first resonator."
"echo.leave" = "留下回响" / "Leave an Echo"
"echo.compose" = "写下回响" / "Write Echo"
"echo.publish" = "发布" / "Publish"
"echo.photos" = "照片" / "Photos"
"echo.add_photo" = "添加照片" / "Add Photo"
"echo.visibility.public" = "众生可见" / "Visible to All"
"echo.visibility.public.hint" = "其他行者可以看到你的回响" / "Other travelers can see your echo"
"echo.anonymous" = "匿名行者" / "Anonymous Traveler"
"echo.anonymous.hint" = "隐藏你的身份信息" / "Hide your identity"

// 意向
"intention.title" = "我亦向往" / "I Also Aspire"
"intention.aspire" = "我亦向往" / "I Also Aspire"
"intention.marked" = "已标记" / "Marked"
"intention.when" = "你计划何时前往？" / "When do you plan to go?"
"intention.year" = "年" / "Year"
"intention.month" = "月" / "Month"
"intention.count" = "包括你在内，已有 %d 位行者，向往于%@抵达此地。" / "Including you, %d travelers aspire to arrive here in %@."

// 寻迹申请
"nomination.title" = "寻迹申请" / "Site Nomination"
"nomination.submit" = "提交申请" / "Submit"
"nomination.step1.title" = "精准定位" / "Precise Location"
"nomination.step1.hint" = "在地图上放置探针，标记圣迹的位置" / "Place a pin on the map to mark the site's location"
"nomination.step2.title" = "命名与描述" / "Name & Description"
"nomination.name" = "圣迹名称" / "Site Name"
"nomination.name.placeholder" = "为这个地方起一个名字" / "Give this place a name"
"nomination.description" = "一句话描述" / "One-line Description"
"nomination.description.placeholder" = "用一句话描述它的特别之处" / "Describe what makes it special"
"nomination.step3.title" = "阐述理由" / "Explain Your Reason"
"nomination.step3.hint" = "描述这个地方的历史传说、个人体验或地貌特征" / "Describe the history, legends, personal experience, or geographical features"
"nomination.step4.title" = "提供佐证" / "Provide Evidence"
"nomination.step4.hint" = "上传实地照片或视频作为佐证" / "Upload photos or videos as evidence"
"nomination.add_photos" = "选择照片" / "Select Photos"
"nomination.photos.required" = "至少需要3张照片" / "At least 3 photos required"
"nomination.step5.title" = "庄重承诺" / "Solemn Commitment"
"nomination.commitment" = "我承诺，以上所有信息皆为我真诚的认知与发现。我愿与其他行者分享此地的荣光，并尊重其神秘与宁静。" / "I solemnly promise that all information above is my sincere knowledge and discovery. I am willing to share the glory of this place with other travelers, and respect its mystery and tranquility."
"nomination.agree" = "我已阅读并同意" / "I have read and agree"
"nomination.success.title" = "申请已提交" / "Nomination Submitted"
"nomination.success.message" = "感谢你的发现！我们将认真审核，并在通过后通知你。" / "Thank you for your discovery! We will carefully review it and notify you upon approval."

// 通用
"button.back" = "上一步" / "Back"
"button.next" = "下一步" / "Next"
```

---

## 验收标准
- [ ] 回响列表正确显示，区分公开/私密
- [ ] 可发布回响（文字+图片），隐私设置生效
- [ ] 零回响状态显示诗意文案
- [ ] 意向标记流程完整，选择年月后确认
- [ ] 意向统计数字正确显示
- [ ] 寻迹申请5步流程完整
- [ ] 申请表单验证正确

---

## 完成后
提交代码到 GitHub，备注："Day 7: 回响系统 + 意向系统 + 寻迹申请"
