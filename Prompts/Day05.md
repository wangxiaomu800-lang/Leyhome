# Day 5 开发提示词

## 今日目标
**心绪节点系统完整实现**

请阅读 `/Users/xiaomu/Desktop/Leyhome/GDD.md` 第4.1节（心绪节点设计）和 `/Users/xiaomu/Desktop/Leyhome/PRD.md` 第5.1.3节，然后完成以下任务。

---

## 任务清单

### 1. 情绪类型定义

**创建 `MoodType.swift`**（基于GDD情绪标签设计）：
```swift
import SwiftUI

enum MoodType: String, Codable, CaseIterable {
    case calm = "calm"              // 平静
    case joy = "joy"                // 愉悦
    case anxiety = "anxiety"        // 焦虑
    case relief = "relief"          // 释然
    case inspiration = "inspiration" // 灵感
    case nostalgia = "nostalgia"    // 怀旧
    case gratitude = "gratitude"    // 感恩
    case melancholy = "melancholy"  // 忧郁
    case wonder = "wonder"          // 惊叹
    case peace = "peace"            // 宁静

    var color: Color {
        switch self {
        case .calm: return LeyhomeTheme.Mood.calm
        case .joy: return LeyhomeTheme.Mood.joy
        case .anxiety: return LeyhomeTheme.Mood.anxiety
        case .relief: return LeyhomeTheme.Mood.relief
        case .inspiration: return LeyhomeTheme.Mood.inspiration
        case .nostalgia: return LeyhomeTheme.Mood.nostalgia
        case .gratitude: return LeyhomeTheme.Mood.gratitude
        case .melancholy: return Color(hex: "778899")
        case .wonder: return Color(hex: "FFB6C1")
        case .peace: return Color(hex: "B0E0E6")
        }
    }

    var icon: String {
        switch self {
        case .calm: return "leaf.fill"
        case .joy: return "sun.max.fill"
        case .anxiety: return "cloud.bolt.fill"
        case .relief: return "wind"
        case .inspiration: return "lightbulb.fill"
        case .nostalgia: return "clock.arrow.circlepath"
        case .gratitude: return "heart.fill"
        case .melancholy: return "cloud.rain.fill"
        case .wonder: return "sparkles"
        case .peace: return "moon.stars.fill"
        }
    }

    var nameZh: String {
        switch self {
        case .calm: return "平静"
        case .joy: return "愉悦"
        case .anxiety: return "焦虑"
        case .relief: return "释然"
        case .inspiration: return "灵感"
        case .nostalgia: return "怀旧"
        case .gratitude: return "感恩"
        case .melancholy: return "忧郁"
        case .wonder: return "惊叹"
        case .peace: return "宁静"
        }
    }

    var nameEn: String {
        switch self {
        case .calm: return "Calm"
        case .joy: return "Joy"
        case .anxiety: return "Anxiety"
        case .relief: return "Relief"
        case .inspiration: return "Inspiration"
        case .nostalgia: return "Nostalgia"
        case .gratitude: return "Gratitude"
        case .melancholy: return "Melancholy"
        case .wonder: return "Wonder"
        case .peace: return "Peace"
        }
    }
}
```

### 2. 心绪节点数据模型

**创建 `MoodNode.swift`**：
```swift
import Foundation
import SwiftData
import CoreLocation

@Model
class MoodNode: Identifiable {
    @Attribute(.unique) var id: UUID
    var trackId: UUID?
    var userId: UUID
    var moodType: String
    var content: String?

    // 位置
    var latitude: Double
    var longitude: Double

    // 媒体（JSON存储）
    var photosData: Data?      // [String] URLs
    var voiceNotesData: Data?  // [VoiceNote]
    var videoUrl: String?

    // 时间
    var createdAt: Date
    var updatedAt: Date

    // 隐私
    var isPublic: Bool = false

    init(userId: UUID, moodType: MoodType, latitude: Double, longitude: Double) {
        self.id = UUID()
        self.userId = userId
        self.moodType = moodType.rawValue
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var mood: MoodType {
        MoodType(rawValue: moodType) ?? .calm
    }

    // 照片URLs
    var photos: [String] {
        get {
            guard let data = photosData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            photosData = try? JSONEncoder().encode(newValue)
        }
    }

    // 语音笔记
    var voiceNotes: [VoiceNote] {
        get {
            guard let data = voiceNotesData else { return [] }
            return (try? JSONDecoder().decode([VoiceNote].self, from: data)) ?? []
        }
        set {
            voiceNotesData = try? JSONEncoder().encode(newValue)
        }
    }
}

struct VoiceNote: Codable, Identifiable {
    var id: UUID = UUID()
    var url: String
    var duration: TimeInterval
    var createdAt: Date
}
```

### 3. 情绪选择器

**创建 `MoodSelectorView.swift`**：
```swift
import SwiftUI

struct MoodSelectorView: View {
    @Binding var selectedMood: MoodType?
    @Environment(\.dismiss) var dismiss

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.lg) {
            // 标题
            Text("node.select_mood".localized)
                .font(.title2)
                .fontWeight(.semibold)

            Text("node.select_mood.hint".localized)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // 情绪网格
            LazyVGrid(columns: columns, spacing: LeyhomeTheme.Spacing.md) {
                ForEach(MoodType.allCases, id: \.self) { mood in
                    MoodButton(
                        mood: mood,
                        isSelected: selectedMood == mood
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedMood = mood
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }

            Spacer()

            // 确认按钮
            if selectedMood != nil {
                Button(action: { dismiss() }) {
                    Text("button.confirm".localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LeyhomeTheme.primary)
                        .cornerRadius(LeyhomeTheme.CornerRadius.md)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding()
    }
}

struct MoodButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(mood.color.opacity(isSelected ? 1 : 0.3))
                        .frame(width: 50, height: 50)

                    Image(systemName: mood.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : mood.color)
                }
                .scaleEffect(isSelected ? 1.1 : 1.0)

                Text(mood.nameZh)
                    .font(.caption2)
                    .foregroundColor(isSelected ? mood.color : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
```

### 4. 节点创建视图

**创建 `NodeCreatorSheet.swift`**：
```swift
import SwiftUI
import PhotosUI
import CoreLocation

struct NodeCreatorSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager

    let coordinate: CLLocationCoordinate2D
    let trackId: UUID?

    @State private var selectedMood: MoodType?
    @State private var content: String = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []
    @State private var showMoodSelector = true
    @State private var isRecordingVoice = false
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    if showMoodSelector {
                        // 情绪选择
                        MoodSelectorView(selectedMood: $selectedMood)
                            .onChange(of: selectedMood) { _, newValue in
                                if newValue != nil {
                                    withAnimation {
                                        showMoodSelector = false
                                    }
                                }
                            }
                    } else {
                        // 内容编辑
                        NodeContentEditor(
                            mood: selectedMood ?? .calm,
                            content: $content,
                            selectedPhotos: $selectedPhotos,
                            photoImages: $photoImages,
                            isRecordingVoice: $isRecordingVoice,
                            onChangeMood: {
                                withAnimation {
                                    showMoodSelector = true
                                }
                            }
                        )
                    }
                }
            }
            .navigationTitle("node.create.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("button.cancel".localized) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !showMoodSelector {
                        Button("button.save".localized) {
                            saveNode()
                        }
                        .disabled(isSaving)
                    }
                }
            }
        }
    }

    private func saveNode() {
        guard let userId = authManager.currentUser?.id,
              let mood = selectedMood else { return }

        isSaving = true

        Task {
            let node = MoodNode(
                userId: userId,
                moodType: mood,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            node.trackId = trackId
            node.content = content.isEmpty ? nil : content

            // 上传照片（简化处理）
            // TODO: 实现图片上传到 Supabase Storage

            // 保存到本地
            // TODO: 使用 ModelContext 保存

            await MainActor.run {
                isSaving = false
                dismiss()
            }
        }
    }
}

struct NodeContentEditor: View {
    let mood: MoodType
    @Binding var content: String
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var photoImages: [UIImage]
    @Binding var isRecordingVoice: Bool
    let onChangeMood: () -> Void

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.lg) {
            // 已选情绪（可点击更改）
            Button(action: onChangeMood) {
                HStack {
                    Image(systemName: mood.icon)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(mood.color)
                        .clipShape(Circle())

                    Text(mood.nameZh)
                        .foregroundColor(mood.color)

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            // 文字输入（GDD: 一句话日记，极简）
            VStack(alignment: .leading, spacing: 8) {
                Text("node.content.hint".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextEditor(text: $content)
                    .frame(minHeight: 100, maxHeight: 200)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(LeyhomeTheme.CornerRadius.sm)
            }

            // 照片选择
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("node.photos".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 9,
                        matching: .images
                    ) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(LeyhomeTheme.primary)
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

            // 语音胶囊（GDD: 30秒感悟）
            VStack(alignment: .leading, spacing: 8) {
                Text("node.voice".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(action: toggleVoiceRecording) {
                    HStack {
                        Image(systemName: isRecordingVoice ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.title2)
                        Text(isRecordingVoice ? "node.voice.stop".localized : "node.voice.start".localized)
                    }
                    .foregroundColor(isRecordingVoice ? .red : LeyhomeTheme.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(LeyhomeTheme.CornerRadius.sm)
                }
            }
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

    private func removePhoto(at index: Int) {
        photoImages.remove(at: index)
        selectedPhotos.remove(at: index)
    }

    private func toggleVoiceRecording() {
        isRecordingVoice.toggle()
        // TODO: 实现录音逻辑
    }
}
```

### 5. 节点地图标注

**创建 `NodeAnnotationView.swift`**：
```swift
import SwiftUI
import MapKit

struct NodeAnnotation: Identifiable {
    let id: UUID
    let node: MoodNode
    var coordinate: CLLocationCoordinate2D { node.coordinate }
}

struct NodeAnnotationView: View {
    let node: MoodNode
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // 节点图标
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                ZStack {
                    // 涟漪效果
                    Circle()
                        .fill(node.mood.color.opacity(0.3))
                        .frame(width: 36, height: 36)

                    Circle()
                        .fill(node.mood.color)
                        .frame(width: 28, height: 28)

                    Image(systemName: node.mood.icon)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }

            // 展开的详情卡片
            if isExpanded {
                NodePreviewCard(node: node)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

struct NodePreviewCard: View {
    let node: MoodNode

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: node.mood.icon)
                    .foregroundColor(node.mood.color)
                Text(node.mood.nameZh)
                    .font(.caption)
                    .fontWeight(.medium)

                Spacer()

                Text(node.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if let content = node.content, !content.isEmpty {
                Text(content)
                    .font(.caption)
                    .lineLimit(3)
            }

            // 媒体预览
            if !node.photos.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "photo")
                    Text("\(node.photos.count)")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .frame(width: 200)
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.sm)
        .shadow(radius: 4)
    }
}
```

### 6. 节点详情视图

**创建 `NodeDetailView.swift`**：
```swift
import SwiftUI

struct NodeDetailView: View {
    let node: MoodNode
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    // 情绪头部
                    VStack(spacing: LeyhomeTheme.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(node.mood.color.opacity(0.2))
                                .frame(width: 100, height: 100)

                            Circle()
                                .fill(node.mood.color)
                                .frame(width: 80, height: 80)

                            Image(systemName: node.mood.icon)
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }

                        Text(node.mood.nameZh)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(node.mood.color)

                        Text(node.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    // 内容
                    if let content = node.content, !content.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("node.content".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(content)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(LeyhomeTheme.CornerRadius.md)
                    }

                    // 照片
                    if !node.photos.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("node.photos".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            PhotoGridView(urls: node.photos)
                        }
                    }

                    // 语音笔记
                    if !node.voiceNotes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("node.voice".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            ForEach(node.voiceNotes) { note in
                                VoiceNotePlayer(note: note)
                            }
                        }
                    }

                    // 位置信息
                    MiniMapView(coordinate: node.coordinate)
                        .frame(height: 150)
                        .cornerRadius(LeyhomeTheme.CornerRadius.md)
                }
                .padding()
            }
            .navigationTitle("node.detail".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: shareNode) {
                            Label("button.share".localized, systemImage: "square.and.arrow.up")
                        }
                        Button(role: .destructive, action: { showDeleteConfirm = true }) {
                            Label("button.delete".localized, systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("node.delete.confirm".localized, isPresented: $showDeleteConfirm) {
                Button("button.cancel".localized, role: .cancel) {}
                Button("button.delete".localized, role: .destructive) {
                    deleteNode()
                }
            }
        }
    }

    private func shareNode() {
        // 分享逻辑
    }

    private func deleteNode() {
        // 删除逻辑
        dismiss()
    }
}

struct PhotoGridView: View {
    let urls: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
            ForEach(urls, id: \.self) { url in
                AsyncImage(url: URL(string: url)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
    }
}

struct VoiceNotePlayer: View {
    let note: VoiceNote
    @State private var isPlaying = false

    var body: some View {
        HStack {
            Button(action: togglePlay) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(LeyhomeTheme.primary)
            }

            // 波形占位符
            RoundedRectangle(cornerRadius: 2)
                .fill(LeyhomeTheme.primary.opacity(0.3))
                .frame(height: 30)

            Text(formatDuration(note.duration))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(LeyhomeTheme.CornerRadius.sm)
    }

    private func togglePlay() {
        isPlaying.toggle()
        // TODO: 实现播放逻辑
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct MiniMapView: View {
    let coordinate: CLLocationCoordinate2D

    var body: some View {
        // 简化的小地图
        Map {
            Marker("", coordinate: coordinate)
        }
        .disabled(true)
    }
}
```

### 7. 国际化文案补充

```
// 心绪节点
"node.create.title" = "记录此刻" / "Capture This Moment"
"node.select_mood" = "此刻的心情" / "How are you feeling?"
"node.select_mood.hint" = "选择最能代表你此刻感受的情绪" / "Choose the emotion that best describes your current feeling"
"node.content" = "想法" / "Thoughts"
"node.content.hint" = "有什么一闪而过的念头吗？" / "Any fleeting thoughts?"
"node.photos" = "照片" / "Photos"
"node.voice" = "语音胶囊" / "Voice Capsule"
"node.voice.start" = "录制语音" / "Record Voice"
"node.voice.stop" = "停止录制" / "Stop Recording"
"node.detail" = "心绪详情" / "Mood Detail"
"node.delete.confirm" = "确定删除这条心绪记录？" / "Delete this mood record?"

// 情绪
"mood.calm" = "平静" / "Calm"
"mood.joy" = "愉悦" / "Joy"
"mood.anxiety" = "焦虑" / "Anxiety"
"mood.relief" = "释然" / "Relief"
"mood.inspiration" = "灵感" / "Inspiration"
"mood.nostalgia" = "怀旧" / "Nostalgia"
"mood.gratitude" = "感恩" / "Gratitude"
"mood.melancholy" = "忧郁" / "Melancholy"
"mood.wonder" = "惊叹" / "Wonder"
"mood.peace" = "宁静" / "Peace"

// 通用
"button.share" = "分享" / "Share"
"button.delete" = "删除" / "Delete"
```

---

## 验收标准
- [ ] 点击轨迹/地图可触发创建节点
- [ ] 情绪选择器UI美观，交互流畅
- [ ] 可添加文字内容（500字限制）
- [ ] 可选择照片（最多9张）
- [ ] 语音录制UI完成（录制逻辑可后续完善）
- [ ] 节点在地图上正确显示
- [ ] 点击节点可查看详情
- [ ] 节点可删除

---

## 技术要点
- `PhotosPicker` 是 iOS 16+ 的现代图片选择方式
- 语音录制使用 `AVAudioRecorder`
- 节点动画使用 `.transition()` 和 `withAnimation`

---

## 完成后
提交代码到 GitHub，备注："Day 5: 心绪节点系统完整实现"
