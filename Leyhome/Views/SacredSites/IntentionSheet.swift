//
//  IntentionSheet.swift
//  Leyhome - 地脉归途
//
//  意向选择 Sheet - 用户标记「我亦向往」时选择计划到达的年月
//
//  Created on 2026/02/03.
//

import SwiftUI
import SwiftData
import Supabase

struct IntentionSheet: View {
    let site: SacredSite

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var aspiredManager = AspiredSitesManager.shared

    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    @State private var hasMarked = false
    @State private var intentionCount: Int = 0
    @State private var sameMonthCount: Int = 0

    private let currentYear = Calendar.current.component(.year, from: Date())
    private let currentMonth = Calendar.current.component(.month, from: Date())

    init(site: SacredSite) {
        self.site = site
        // Default to next month or current month
        let now = Date()
        let year = Calendar.current.component(.year, from: now)
        let month = Calendar.current.component(.month, from: now)

        // If current month, default to next month
        if month == 12 {
            _selectedYear = State(initialValue: year + 1)
            _selectedMonth = State(initialValue: 1)
        } else {
            _selectedYear = State(initialValue: year)
            _selectedMonth = State(initialValue: month + 1)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: LeyhomeTheme.Spacing.lg) {
                siteInfoCard
                dateSelectionSection
                statsSection
                confirmButton
                Spacer()
            }
            .padding(LeyhomeTheme.Spacing.md)
            .background(LeyhomeTheme.Background.primary)
            .navigationTitle("intention.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("button.cancel".localized) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadIntentionStats()
        }
        .onChange(of: selectedYear) { _, _ in
            updateSameMonthCount()
        }
        .onChange(of: selectedMonth) { _, _ in
            updateSameMonthCount()
        }
    }

    // MARK: - Site Info Card

    private var siteInfoCard: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            // Site image placeholder
            RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.sm)
                .fill(
                    LinearGradient(
                        colors: [site.siteTier.color, LeyhomeTheme.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "mountain.2.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.8))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(site.siteTier.localizedName)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(site.siteTier.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(site.siteTier.color.opacity(0.15))
                    .cornerRadius(4)

                Text(site.name)
                    .font(LeyhomeTheme.Fonts.headline)
                    .foregroundColor(LeyhomeTheme.textPrimary)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption2)
                    Text(site.country)
                }
                .font(LeyhomeTheme.Fonts.caption)
                .foregroundColor(LeyhomeTheme.textSecondary)
            }

            Spacer()
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
    }

    // MARK: - Date Selection Section

    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            Text("intention.when".localized)
                .font(LeyhomeTheme.Fonts.headline)
                .foregroundColor(LeyhomeTheme.textPrimary)

            HStack(spacing: LeyhomeTheme.Spacing.md) {
                // Year picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("intention.year".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)

                    Picker("", selection: $selectedYear) {
                        ForEach(currentYear...(currentYear + 5), id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .clipped()
                }
                .frame(maxWidth: .infinity)
                .padding(LeyhomeTheme.Spacing.sm)
                .background(Color(.systemBackground))
                .cornerRadius(LeyhomeTheme.CornerRadius.sm)

                // Month picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("intention.month".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)

                    Picker("", selection: $selectedMonth) {
                        ForEach(validMonths, id: \.self) { month in
                            Text(monthName(month)).tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .clipped()
                }
                .frame(maxWidth: .infinity)
                .padding(LeyhomeTheme.Spacing.sm)
                .background(Color(.systemBackground))
                .cornerRadius(LeyhomeTheme.CornerRadius.sm)
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: LeyhomeTheme.Spacing.sm) {
            if sameMonthCount > 0 || hasMarked {
                let displayCount = hasMarked ? sameMonthCount + 1 : sameMonthCount
                let dateString = formattedSelectedDate

                Text("intention.count".localized(with: displayCount, dateString))
                    .font(LeyhomeTheme.Fonts.bodySmall)
                    .foregroundColor(LeyhomeTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
    }

    // MARK: - Confirm Button

    private var confirmButton: some View {
        Button {
            markIntention()
        } label: {
            HStack {
                Image(systemName: hasMarked ? "checkmark.circle.fill" : "heart.fill")
                Text(hasMarked ? "intention.marked".localized : "button.confirm".localized)
            }
            .leyhomePrimaryButton()
            .frame(maxWidth: .infinity)
        }
        .disabled(hasMarked)
    }

    // MARK: - Helpers

    private var validMonths: [Int] {
        if selectedYear == currentYear {
            // Only show current month onwards for current year
            return Array(currentMonth...12)
        }
        return Array(1...12)
    }

    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        var components = DateComponents()
        components.month = month
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(month)"
    }

    private var formattedSelectedDate: String {
        let lang = LocalizationManager.shared.currentLanguage
        if lang.hasPrefix("zh") {
            return "\(selectedYear)年\(selectedMonth)月"
        } else {
            return "\(monthName(selectedMonth)) \(selectedYear)"
        }
    }

    // MARK: - Data Operations

    private func loadIntentionStats() {
        // TODO: Load from SwiftData or Supabase
        // For now, use site's intentionCount
        intentionCount = site.intentionCount
        sameMonthCount = 0
    }

    private func updateSameMonthCount() {
        // TODO: Query actual count for selected month
        // For now, simulate
        sameMonthCount = Int.random(in: 0...20)
    }

    private func markIntention() {
        guard let userId = authManager.currentUser?.id.uuidString else {
            // Handle not logged in
            return
        }

        // Create intention record
        let intention = Intention(
            siteId: site.id,
            userId: userId,
            targetYear: selectedYear,
            targetMonth: selectedMonth
        )

        modelContext.insert(intention)

        // Update site's intention count
        site.intentionCount += 1
        site.updatedAt = Date()

        // Mark as aspired via AspiredSitesManager
        if !aspiredManager.isAspired(site) {
            aspiredManager.toggleAspire(site)
        }

        try? modelContext.save()

        hasMarked = true

        // Dismiss after a short delay to show the "marked" state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    let site = SacredSiteData.loadAllSites().first!
    IntentionSheet(site: site)
        .environmentObject(AuthManager())
}
