//
//  JourneyListView.swift
//  Leyhome - 地脉归途
//
//  旅程列表视图 - 按日期分组展示所有已保存的旅程
//
//  Created on 2026/01/29.
//

import SwiftUI
import SwiftData

struct JourneyListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Journey.startTime, order: .reverse) private var journeys: [Journey]

    @State private var selectedJourney: Journey?

    var body: some View {
        NavigationStack {
            Group {
                if journeys.isEmpty {
                    emptyStateView
                } else {
                    journeyList
                }
            }
            .navigationTitle("journey.title".localized)
            .sheet(item: $selectedJourney) { journey in
                JourneyDetailView(journey: journey)
            }
        }
    }

    // MARK: - Journey List

    private var journeyList: some View {
        List {
            ForEach(groupedJourneys, id: \.key) { dateString, dayJourneys in
                Section(header: Text(dateString)) {
                    ForEach(dayJourneys) { journey in
                        JourneyRowView(journey: journey)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedJourney = journey
                            }
                    }
                    .onDelete { indexSet in
                        deleteJourneys(dayJourneys: dayJourneys, at: indexSet)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: LeyhomeTheme.Spacing.lg) {
            Image(systemName: "map.fill")
                .font(.system(size: 64))
                .foregroundColor(LeyhomeTheme.primary.opacity(0.3))

            Text("journey.empty".localized)
                .font(LeyhomeTheme.Fonts.body)
                .foregroundColor(LeyhomeTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(LeyhomeTheme.Spacing.xl)
    }

    // MARK: - Grouped Journeys

    /// 按日期分组旅程
    private var groupedJourneys: [(key: String, value: [Journey])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let grouped = Dictionary(grouping: journeys) { journey in
            formatter.string(from: journey.startTime)
        }

        return grouped
            .sorted { $0.value.first!.startTime > $1.value.first!.startTime }
            .map { (key: $0.key, value: $0.value) }
    }

    // MARK: - Actions

    private func deleteJourneys(dayJourneys: [Journey], at offsets: IndexSet) {
        for index in offsets {
            let journey = dayJourneys[index]
            modelContext.delete(journey)
        }
        try? modelContext.save()
    }
}

// MARK: - Preview

#Preview {
    JourneyListView()
        .modelContainer(for: [Journey.self], inMemory: true)
}
