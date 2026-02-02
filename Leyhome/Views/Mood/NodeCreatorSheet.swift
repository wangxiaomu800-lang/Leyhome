//
//  NodeCreatorSheet.swift
//  Leyhome - 地脉归途
//
//  心绪节点创建页 - 两阶段：选择情绪（多选） → 编辑内容
//
//  Created on 2026/01/29.
//

import SwiftUI
import SwiftData
import PhotosUI
import CoreLocation
import Supabase

/// 心绪节点创建 Sheet
struct NodeCreatorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager

    /// 长按选中的坐标
    let coordinate: CLLocationCoordinate2D

    /// 关联的旅程 ID
    var journeyID: UUID?

    /// 保存完成后回调（返回新创建的 MoodRecord ID）
    var onSave: ((UUID) -> Void)?

    // MARK: - State

    /// 当前阶段：1 选择情绪，2 编辑内容
    @State private var phase: Int = 1
    @State private var selectedMoods: Set<MoodType> = []
    @State private var noteText: String = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    if phase == 1 {
                        // Phase 1: 选择心绪（可多选）
                        phaseOneView
                    } else {
                        // Phase 2: 编辑内容
                        phaseTwoView
                    }
                }
                .padding(.vertical, LeyhomeTheme.Spacing.md)
            }
            .navigationTitle(phase == 1 ? "node.create.select_mood".localized : "node.create.add_content".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("button.cancel".localized) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if phase == 2 {
                        Button("button.save".localized) {
                            saveNode()
                        }
                        .disabled(selectedMoods.isEmpty || isSaving)
                        .fontWeight(.semibold)
                    }
                }
            }
            .onChange(of: selectedPhotos) { _, newItems in
                loadPhotos(from: newItems)
            }
        }
    }

    // MARK: - Phase 1: Select Mood

    private var phaseOneView: some View {
        VStack(spacing: LeyhomeTheme.Spacing.lg) {
            Text("node.create.how_feeling".localized)
                .font(LeyhomeTheme.Fonts.headline)
                .foregroundColor(LeyhomeTheme.textPrimary)

            Text("node.create.multi_select_hint".localized)
                .font(LeyhomeTheme.Fonts.caption)
                .foregroundColor(LeyhomeTheme.textSecondary)

            MoodSelectorView(selectedMoods: $selectedMoods)

            if !selectedMoods.isEmpty {
                // 显示已选心绪标签
                selectedMoodTags

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        phase = 2
                    }
                } label: {
                    Text("node.create.next".localized)
                        .leyhomePrimaryButton()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.top, LeyhomeTheme.Spacing.lg)
    }

    /// 已选心绪标签展示
    private var selectedMoodTags: some View {
        FlowLayout(spacing: 8) {
            ForEach(Array(selectedMoods).sorted(by: { $0.rawValue < $1.rawValue }), id: \.rawValue) { mood in
                HStack(spacing: 4) {
                    Image(systemName: mood.icon)
                        .font(.system(size: 12))
                    Text(mood.localizedName)
                        .font(LeyhomeTheme.Fonts.caption)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(mood.color.opacity(0.15))
                .foregroundColor(mood.color)
                .cornerRadius(16)
            }
        }
        .padding(.horizontal, LeyhomeTheme.Spacing.md)
    }

    // MARK: - Phase 2: Edit Content

    private var phaseTwoView: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            NodeContentEditor(
                selectedMoods: selectedMoods,
                noteText: $noteText,
                selectedPhotos: $selectedPhotos,
                photoImages: $photoImages
            )
            .padding(.horizontal, LeyhomeTheme.Spacing.md)
        }
    }

    // MARK: - Actions

    private func loadPhotos(from items: [PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            await MainActor.run {
                photoImages = images
            }
        }
    }

    private func saveNode() {
        guard !selectedMoods.isEmpty else { return }
        isSaving = true

        let userID = authManager.currentUser?.id.uuidString ?? "guest"
        let moodArray = Array(selectedMoods)
        let primaryMood = moodArray.first!

        let record = MoodRecord(
            userID: userID,
            moodType: primaryMood,
            moodTypes: moodArray,
            note: noteText.isEmpty ? nil : noteText,
            recordTime: Date(),
            journeyID: journeyID
        )
        record.location = coordinate

        // 保存照片到本地
        var paths: [String] = []
        for (index, image) in photoImages.enumerated() {
            if let path = saveImageLocally(image, recordID: record.id, index: index) {
                paths.append(path)
            }
        }
        record.imagePaths = paths

        modelContext.insert(record)

        do {
            try modelContext.save()
            #if DEBUG
            print("✅ 心绪节点保存成功: \(moodArray.map { $0.displayName }.joined(separator: ", "))")
            #endif
            onSave?(record.id)
        } catch {
            #if DEBUG
            print("❌ 心绪节点保存失败: \(error.localizedDescription)")
            #endif
        }

        isSaving = false
        dismiss()
    }

    /// 将图片保存到本地文档目录
    private func saveImageLocally(_ image: UIImage, recordID: UUID, index: Int) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }

        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MoodPhotos", isDirectory: true)

        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let fileName = "\(recordID.uuidString)_\(index).jpg"
        let fileURL = dir.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            #if DEBUG
            print("❌ 照片保存失败: \(error.localizedDescription)")
            #endif
            return nil
        }
    }
}

// MARK: - FlowLayout

/// 自适应流式布局
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}

// MARK: - Preview

#Preview {
    NodeCreatorSheet(coordinate: CLLocationCoordinate2D(latitude: 39.9, longitude: 116.4))
        .modelContainer(for: [MoodRecord.self], inMemory: true)
}
