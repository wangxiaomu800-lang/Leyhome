//
//  ReflectionView.swift
//  Leyhome - 地脉归途
//
//  强制反思界面 - 共鸣行走完成后必须填写
//
//  Created on 2026/02/04.
//

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

                    // 先行者感悟引用区
                    VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                        HStack {
                            AsyncImage(url: URL(string: guide.avatarUrl ?? "")) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Circle().fill(Color(.systemGray6))
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.caption)
                                            .foregroundColor(Color(.systemGray3))
                                    )
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                            Text("\(guide.name) " + "reflection.felt".localized)
                                .font(.subheadline)
                        }

                        Text("\u{300C}\("reflection.guide_quote".localized)\u{300D}")
                            .font(.body)
                            .italic()
                            .padding()
                            .background(LeyhomeTheme.starlight.opacity(0.2))
                            .cornerRadius(LeyhomeTheme.CornerRadius.md)
                    }
                    .padding(.horizontal)

                    // "而你呢？" - 用户反思区
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
                            .background(Color(.systemGray6))
                            .cornerRadius(LeyhomeTheme.CornerRadius.sm)

                        Text("reflection.hint".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    // 保存按钮（必须选择情绪 + 输入文字才能点击）
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

    // MARK: - Private

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

// MARK: - MoodChip

struct MoodChip: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: mood.icon)
                    .font(.title3)
                Text(mood.localizedName)
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
