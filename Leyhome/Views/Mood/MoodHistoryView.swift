//
//  MoodHistoryView.swift
//  Leyhome - 地脉归途
//
//  心绪历史列表 - 展示所有心绪记录，支持回顾
//
//  Created on 2026/01/29.
//

import SwiftUI
import SwiftData

/// 心绪历史回顾视图
struct MoodHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodRecord.recordTime, order: .reverse) private var moodRecords: [MoodRecord]

    @State private var selectedRecord: MoodRecord?

    var body: some View {
        Group {
            if moodRecords.isEmpty {
                emptyState
            } else {
                moodList
            }
        }
        .navigationTitle("mood.history.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedRecord) { record in
            NodeDetailView(moodRecord: record)
                .presentationDetents([.large])
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LeyhomeTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "heart.text.square")
                .font(.system(size: 56))
                .foregroundColor(LeyhomeTheme.primary.opacity(0.3))

            Text("mood.history.empty".localized)
                .font(LeyhomeTheme.Fonts.body)
                .foregroundColor(LeyhomeTheme.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(LeyhomeTheme.Spacing.lg)
    }

    // MARK: - Mood List

    private var moodList: some View {
        List {
            ForEach(groupedByDate, id: \.key) { dateString, records in
                Section {
                    ForEach(records) { record in
                        Button {
                            selectedRecord = record
                        } label: {
                            MoodRecordRow(record: record)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text(dateString)
                        .font(LeyhomeTheme.Fonts.bodySmall)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    /// 按日期分组的心绪记录
    private var groupedByDate: [(key: String, value: [MoodRecord])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let grouped = Dictionary(grouping: moodRecords) { record in
            formatter.string(from: record.recordTime)
        }

        return grouped.sorted { pair1, pair2 in
            guard let date1 = pair1.value.first?.recordTime,
                  let date2 = pair2.value.first?.recordTime else {
                return false
            }
            return date1 > date2
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MoodHistoryView()
            .modelContainer(for: [MoodRecord.self], inMemory: true)
    }
}
