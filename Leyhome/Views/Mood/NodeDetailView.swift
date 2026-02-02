//
//  NodeDetailView.swift
//  Leyhome - 地脉归途
//
//  心绪节点详情页 - 查看情绪、内容、照片、语音和位置
//
//  Created on 2026/01/29.
//

import SwiftUI
import SwiftData
import MapKit

/// 心绪节点详情视图
struct NodeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let moodRecord: MoodRecord
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    // 情绪头部
                    moodHeader

                    // 时间信息
                    timeInfo

                    // 文字内容
                    if let note = moodRecord.note, !note.isEmpty {
                        noteSection(note)
                    }

                    // 照片
                    if !moodRecord.imagePaths.isEmpty {
                        PhotoGridView(imagePaths: moodRecord.imagePaths)
                    }

                    // 语音笔记
                    if !moodRecord.voiceNotes.isEmpty {
                        VoiceNotePlayer(voiceNotes: moodRecord.voiceNotes)
                    }

                    // 小地图
                    if moodRecord.location != nil {
                        MiniMapView(coordinate: moodRecord.location!)
                    }

                    // 删除按钮
                    deleteButton
                }
                .padding(LeyhomeTheme.Spacing.md)
            }
            .navigationTitle("node.detail.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("node.detail.close".localized) {
                        dismiss()
                    }
                }
            }
            .alert("node.delete.confirm".localized, isPresented: $showDeleteConfirm) {
                Button("button.cancel".localized, role: .cancel) {}
                Button("node.delete".localized, role: .destructive) {
                    deleteNode()
                }
            }
        }
    }

    // MARK: - Mood Header

    private var moodHeader: some View {
        VStack(spacing: 12) {
            // 主要心绪大图标
            ZStack {
                Circle()
                    .fill(moodRecord.moodType.color.opacity(0.2))
                    .frame(width: 100, height: 100)

                Circle()
                    .fill(moodRecord.moodType.color)
                    .frame(width: 72, height: 72)

                Image(systemName: moodRecord.moodType.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }

            // 多心绪标签
            if moodRecord.moodTypes.count > 1 {
                HStack(spacing: 8) {
                    ForEach(moodRecord.moodTypes, id: \.rawValue) { mood in
                        HStack(spacing: 4) {
                            Image(systemName: mood.icon)
                                .font(.system(size: 12))
                            Text(mood.localizedName)
                                .font(LeyhomeTheme.Fonts.bodySmall)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(mood.color.opacity(0.15))
                        .foregroundColor(mood.color)
                        .cornerRadius(16)
                    }
                }
            } else {
                Text(moodRecord.moodType.localizedName)
                    .font(LeyhomeTheme.Fonts.title)
                    .foregroundColor(moodRecord.moodType.color)
            }
        }
        .padding(.top, LeyhomeTheme.Spacing.md)
    }

    // MARK: - Time Info

    private var timeInfo: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            Label {
                Text(moodRecord.recordTime, style: .date)
            } icon: {
                Image(systemName: "calendar")
            }

            Label {
                Text(moodRecord.recordTime, style: .time)
            } icon: {
                Image(systemName: "clock")
            }
        }
        .font(LeyhomeTheme.Fonts.bodySmall)
        .foregroundColor(LeyhomeTheme.textSecondary)
    }

    // MARK: - Note Section

    private func noteSection(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("node.detail.note".localized)
                .font(LeyhomeTheme.Fonts.bodySmall)
                .foregroundColor(LeyhomeTheme.textSecondary)

            Text(note)
                .font(LeyhomeTheme.Fonts.body)
                .foregroundColor(LeyhomeTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(LeyhomeTheme.Spacing.md)
                .background(Color(.systemGray6))
                .cornerRadius(LeyhomeTheme.CornerRadius.sm)
        }
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("node.delete".localized)
            }
            .font(LeyhomeTheme.Fonts.body)
            .foregroundColor(LeyhomeTheme.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(LeyhomeTheme.danger.opacity(0.1))
            .cornerRadius(LeyhomeTheme.CornerRadius.md)
        }
        .padding(.top, LeyhomeTheme.Spacing.md)
    }

    private func deleteNode() {
        modelContext.delete(moodRecord)
        do {
            try modelContext.save()
            #if DEBUG
            print("✅ 心绪节点已删除")
            #endif
        } catch {
            #if DEBUG
            print("❌ 删除失败: \(error.localizedDescription)")
            #endif
        }
        dismiss()
    }
}

// MARK: - PhotoGridView

/// 照片网格视图
struct PhotoGridView: View {
    let imagePaths: [String]

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("node.detail.photos".localized)
                .font(LeyhomeTheme.Fonts.bodySmall)
                .foregroundColor(LeyhomeTheme.textSecondary)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(imagePaths, id: \.self) { path in
                    if let image = loadImage(path) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(minHeight: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
        }
    }

    private func loadImage(_ fileName: String) -> UIImage? {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MoodPhotos")
        let fileURL = dir.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - VoiceNotePlayer

/// 语音笔记播放器（UI 占位）
struct VoiceNotePlayer: View {
    let voiceNotes: [VoiceNote]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("node.detail.voice".localized)
                .font(LeyhomeTheme.Fonts.bodySmall)
                .foregroundColor(LeyhomeTheme.textSecondary)

            ForEach(voiceNotes) { note in
                HStack(spacing: 12) {
                    Button {
                        // 播放功能占位
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(LeyhomeTheme.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(formatDuration(note.duration))
                            .font(LeyhomeTheme.Fonts.body)
                            .foregroundColor(LeyhomeTheme.textPrimary)

                        Text(note.createdAt, style: .time)
                            .font(LeyhomeTheme.Fonts.caption)
                            .foregroundColor(LeyhomeTheme.textMuted)
                    }

                    Spacer()
                }
                .padding(LeyhomeTheme.Spacing.sm)
                .background(Color(.systemGray6))
                .cornerRadius(LeyhomeTheme.CornerRadius.sm)
            }
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - MiniMapView

/// 小地图视图
struct MiniMapView: View {
    let coordinate: CLLocationCoordinate2D

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("node.detail.location".localized)
                .font(LeyhomeTheme.Fonts.bodySmall)
                .foregroundColor(LeyhomeTheme.textSecondary)

            Map(initialPosition: .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))) {
                Marker("", coordinate: coordinate)
                    .tint(LeyhomeTheme.primary)
            }
            .frame(height: 160)
            .cornerRadius(LeyhomeTheme.CornerRadius.md)
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Preview

#Preview {
    let record = MoodRecord(userID: "preview", moodType: .calm, note: "今天天气真好，心情很平静。")
    return NodeDetailView(moodRecord: record)
        .modelContainer(for: [MoodRecord.self], inMemory: true)
}
