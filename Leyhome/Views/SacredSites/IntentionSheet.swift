//
//  IntentionSheet.swift
//  Leyhome - 地脉归途
//
//  意向选择 Sheet - 标记「我亦向往」/ 修改计划日期 / 取消向往
//
//  Created on 2026/02/03.
//  Updated on 2026/02/14: 每用户每圣迹唯一意向，支持修改与取消
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
    @State private var isSaved = false
    @State private var isUpdateMode = false     // 当前用户已有意向记录
    @State private var isLoading = true
    @State private var sameMonthCount: Int = 0
    @State private var showCancelConfirm = false

    private let currentYear = Calendar.current.component(.year, from: Date())
    private let currentMonth = Calendar.current.component(.month, from: Date())

    init(site: SacredSite) {
        self.site = site
        let now = Date()
        let year = Calendar.current.component(.year, from: now)
        let month = Calendar.current.component(.month, from: now)
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
                if isLoading {
                    ProgressView()
                        .padding()
                } else {
                    dateSelectionSection
                    statsSection
                    confirmButton
                    if isUpdateMode {
                        cancelButton
                    }
                }
                Spacer()
            }
            .padding(LeyhomeTheme.Spacing.md)
            .background(LeyhomeTheme.Background.primary)
            .navigationTitle(isUpdateMode ? "intention.update_title".localized : "intention.title".localized)
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
            Task { await loadUserIntention() }
        }
        .onChange(of: selectedYear) { _, _ in updateSameMonthCount() }
        .onChange(of: selectedMonth) { _, _ in updateSameMonthCount() }
        .confirmationDialog(
            "intention.cancel_confirm".localized,
            isPresented: $showCancelConfirm,
            titleVisibility: .visible
        ) {
            Button("intention.cancel_aspire".localized, role: .destructive) {
                cancelAspiration()
            }
            Button("button.cancel".localized, role: .cancel) {}
        }
    }

    // MARK: - Site Info Card

    private var siteInfoCard: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
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
            if sameMonthCount > 0 {
                Text("intention.count".localized(with: sameMonthCount, formattedSelectedDate))
                    .font(LeyhomeTheme.Fonts.bodySmall)
                    .foregroundColor(LeyhomeTheme.textSecondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("intention.none".localized)
                    .font(LeyhomeTheme.Fonts.bodySmall)
                    .foregroundColor(LeyhomeTheme.textMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
    }

    // MARK: - Confirm Button

    private var confirmButton: some View {
        Button {
            saveIntention()
        } label: {
            HStack {
                Image(systemName: isSaved ? "checkmark.circle.fill" : "heart.fill")
                Text(isSaved ? "intention.marked".localized : (isUpdateMode ? "intention.update".localized : "button.confirm".localized))
            }
            .leyhomePrimaryButton()
            .frame(maxWidth: .infinity)
        }
        .disabled(isSaved)
    }

    // MARK: - Cancel Aspiration Button

    private var cancelButton: some View {
        Button {
            showCancelConfirm = true
        } label: {
            Text("intention.cancel_aspire".localized)
                .font(LeyhomeTheme.Fonts.bodySmall)
                .foregroundColor(LeyhomeTheme.textMuted)
        }
    }

    // MARK: - Helpers

    private var validMonths: [Int] {
        if selectedYear == currentYear {
            return Array(currentMonth...12)
        }
        return Array(1...12)
    }

    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let lang = LocalizationManager.shared.currentLanguage
        formatter.locale = Locale(identifier: lang.hasPrefix("zh") ? "zh-Hans" : "en")
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

    /// 加载当前用户对该圣迹的已有意向（判断是新增还是修改模式）
    private func loadUserIntention() async {
        guard let userId = authManager.currentUser?.id else {
            await MainActor.run { isLoading = false }
            return
        }

        struct RemoteIntention: Decodable {
            let targetYear: Int
            let targetMonth: Int
            enum CodingKeys: String, CodingKey {
                case targetYear = "target_year"
                case targetMonth = "target_month"
            }
        }

        do {
            let existing: [RemoteIntention] = try await SupabaseConfig.shared
                .from("intentions")
                .select("target_year, target_month")
                .eq("user_id", value: userId.uuidString.lowercased())
                .eq("site_name_en", value: site.nameEn)
                .execute()
                .value

            await MainActor.run {
                if let record = existing.first {
                    isUpdateMode = true
                    selectedYear = record.targetYear
                    selectedMonth = record.targetMonth
                }
                isLoading = false
            }
            updateSameMonthCount()
        } catch {
            print("[IntentionSheet] loadUserIntention failed: \(error)")
            await MainActor.run { isLoading = false }
        }
    }

    private func updateSameMonthCount() {
        Task {
            do {
                let result = try await SupabaseConfig.shared
                    .from("intentions")
                    .select("id", head: false, count: .exact)
                    .eq("site_name_en", value: site.nameEn)
                    .eq("target_year", value: selectedYear)
                    .eq("target_month", value: selectedMonth)
                    .execute()
                let count = result.count ?? 0
                await MainActor.run { sameMonthCount = count }
            } catch {
                print("[IntentionSheet] updateSameMonthCount failed: \(error)")
            }
        }
    }

    /// 新增或更新意向（upsert）
    private func saveIntention() {
        guard let userId = authManager.currentUser?.id else { return }

        // 本地状态
        if !aspiredManager.isAspired(site) {
            aspiredManager.toggleAspire(site)
        }
        if !isUpdateMode {
            site.intentionCount += 1
            site.updatedAt = Date()
            try? modelContext.save()
        }
        isSaved = true

        Task {
            do {
                let payload: [String: AnyJSON] = [
                    "user_id": .string(userId.uuidString.lowercased()),
                    "site_name_en": .string(site.nameEn),
                    "target_year": .integer(selectedYear),
                    "target_month": .integer(selectedMonth)
                ]
                try await SupabaseConfig.shared
                    .from("intentions")
                    .upsert(payload, onConflict: "user_id,site_name_en")
                    .execute()
                print("[IntentionSheet] Intention upserted to Supabase")
            } catch {
                print("[IntentionSheet] Supabase upsert failed: \(error)")
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            dismiss()
        }
    }

    /// 取消向往（删除记录）
    private func cancelAspiration() {
        guard let userId = authManager.currentUser?.id else { return }

        // 更新本地状态
        if aspiredManager.isAspired(site) {
            aspiredManager.toggleAspire(site)
        }
        site.intentionCount = max(0, site.intentionCount - 1)
        site.updatedAt = Date()
        try? modelContext.save()

        Task {
            do {
                try await SupabaseConfig.shared
                    .from("intentions")
                    .delete()
                    .eq("user_id", value: userId.uuidString.lowercased())
                    .eq("site_name_en", value: site.nameEn)
                    .execute()
                print("[IntentionSheet] Intention deleted from Supabase")
            } catch {
                print("[IntentionSheet] Supabase delete failed: \(error)")
            }
        }

        dismiss()
    }
}

// MARK: - Preview

#Preview {
    let site = SacredSiteData.loadAllSites().first!
    IntentionSheet(site: site)
        .environmentObject(AuthManager())
}
