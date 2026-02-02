//
//  MoodSelectorView.swift
//  Leyhome - 地脉归途
//
//  心绪选择器 - 5 列网格展示所有心绪类型，支持多选
//
//  Created on 2026/01/29.
//

import SwiftUI

/// 心绪选择视图（多选）
struct MoodSelectorView: View {
    @Binding var selectedMoods: Set<MoodType>

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(MoodType.allCases, id: \.rawValue) { mood in
                MoodButton(mood: mood, isSelected: selectedMoods.contains(mood)) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if selectedMoods.contains(mood) {
                            selectedMoods.remove(mood)
                        } else {
                            selectedMoods.insert(mood)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, LeyhomeTheme.Spacing.md)
    }
}

// MARK: - MoodButton

/// 单个心绪按钮 - 圆形图标 + 标签
struct MoodButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? mood.color : mood.color.opacity(0.15))
                        .frame(width: 52, height: 52)

                    if isSelected {
                        Circle()
                            .stroke(mood.color, lineWidth: 2)
                            .frame(width: 60, height: 60)
                    }

                    Image(systemName: mood.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : mood.color)
                }

                Text(mood.localizedName)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(isSelected ? mood.color : LeyhomeTheme.textSecondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

// MARK: - Preview

#Preview {
    MoodSelectorView(selectedMoods: .constant([.calm, .joy]))
        .padding()
}
