//
//  NodeContentEditor.swift
//  Leyhome - 地脉归途
//
//  心绪节点内容编辑器 - 文字、照片、语音
//
//  Created on 2026/01/29.
//

import SwiftUI
import PhotosUI

/// 心绪节点内容编辑器
struct NodeContentEditor: View {
    let selectedMoods: Set<MoodType>
    @Binding var noteText: String
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var photoImages: [UIImage]

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            // 已选情绪 badges
            if !selectedMoods.isEmpty {
                moodBadges
            }

            // 文字输入
            textInputSection

            // 照片选择
            photoSection

            // 语音录制（UI 占位）
            voiceRecordSection
        }
    }

    // MARK: - Mood Badges

    private var moodBadges: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(selectedMoods).sorted(by: { $0.rawValue < $1.rawValue }), id: \.rawValue) { mood in
                    HStack(spacing: 6) {
                        Image(systemName: mood.icon)
                            .font(.system(size: 14))
                        Text(mood.localizedName)
                            .font(LeyhomeTheme.Fonts.bodySmall)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(mood.color)
                    .cornerRadius(LeyhomeTheme.CornerRadius.full)
                }
            }
        }
    }

    // MARK: - Text Input

    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("node.text.label".localized)
                .font(LeyhomeTheme.Fonts.bodySmall)
                .foregroundColor(LeyhomeTheme.textSecondary)

            TextEditor(text: $noteText)
                .frame(minHeight: 100, maxHeight: 200)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(LeyhomeTheme.CornerRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.sm)
                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                )
        }
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("node.photo.label".localized)
                    .font(LeyhomeTheme.Fonts.bodySmall)
                    .foregroundColor(LeyhomeTheme.textSecondary)

                Spacer()

                Text("\(photoImages.count)/9")
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(LeyhomeTheme.textMuted)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // 已选照片
                    ForEach(photoImages.indices, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: photoImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Button {
                                photoImages.remove(at: index)
                                if index < selectedPhotos.count {
                                    selectedPhotos.remove(at: index)
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            }
                            .offset(x: 4, y: -4)
                        }
                    }

                    // 添加按钮
                    if photoImages.count < 9 {
                        PhotosPicker(
                            selection: $selectedPhotos,
                            maxSelectionCount: 9 - photoImages.count,
                            matching: .images
                        ) {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(LeyhomeTheme.textMuted)
                            }
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                    .foregroundColor(Color(.systemGray4))
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Voice Record Section

    private var voiceRecordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("node.voice.label".localized)
                .font(LeyhomeTheme.Fonts.bodySmall)
                .foregroundColor(LeyhomeTheme.textSecondary)

            Button {
                // 语音录制功能占位
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 16))
                    Text("node.voice.record".localized)
                        .font(LeyhomeTheme.Fonts.bodySmall)
                }
                .foregroundColor(LeyhomeTheme.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(LeyhomeTheme.primary.opacity(0.1))
                .cornerRadius(LeyhomeTheme.CornerRadius.lg)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NodeContentEditor(
        selectedMoods: [.calm, .joy],
        noteText: .constant(""),
        selectedPhotos: .constant([]),
        photoImages: .constant([])
    )
    .padding()
}
