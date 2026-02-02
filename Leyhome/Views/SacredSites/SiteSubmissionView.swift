//
//  SiteSubmissionView.swift
//  Leyhome - 地脉归途
//
//  圣迹申请 - 用户提名心绪锚点（Tier 3）
//
//  Created on 2026/02/02.
//

import SwiftUI
import CoreLocation

struct SiteSubmissionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var trackingManager = TrackingManager.shared

    @State private var siteName = ""
    @State private var siteStory = ""
    @State private var useCurrentLocation = true
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var submitted = false

    var body: some View {
        NavigationStack {
            if submitted {
                submittedView
            } else {
                formView
            }
        }
    }

    // MARK: - Form

    private var formView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.lg) {
                // 引导语
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                    Text("submission.intro".localized)
                        .font(LeyhomeTheme.Fonts.body)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                        .lineSpacing(4)
                }

                // 圣迹名称
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                    Text("submission.name".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    TextField("submission.name_placeholder".localized, text: $siteName)
                        .textFieldStyle(.roundedBorder)
                }

                // 你与此地的故事
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                    Text("submission.story".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    TextEditor(text: $siteStory)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(LeyhomeTheme.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.sm)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )

                    Text("submission.story_hint".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textMuted)
                }

                // 位置
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                    Text("submission.location".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    Toggle(isOn: $useCurrentLocation) {
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .foregroundColor(LeyhomeTheme.primary)
                            Text("submission.use_current".localized)
                                .font(LeyhomeTheme.Fonts.body)
                                .foregroundColor(LeyhomeTheme.textPrimary)
                        }
                    }
                    .tint(LeyhomeTheme.primary)

                    if let location = trackingManager.currentLocation, useCurrentLocation {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(LeyhomeTheme.primary)
                            Text(String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude))
                                .font(LeyhomeTheme.Fonts.caption)
                                .foregroundColor(LeyhomeTheme.textSecondary)
                        }
                        .padding(LeyhomeTheme.Spacing.sm)
                        .background(LeyhomeTheme.primary.opacity(0.08))
                        .cornerRadius(LeyhomeTheme.CornerRadius.sm)
                    }

                    if !useCurrentLocation {
                        HStack(spacing: LeyhomeTheme.Spacing.sm) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("submission.lat".localized)
                                    .font(LeyhomeTheme.Fonts.caption)
                                    .foregroundColor(LeyhomeTheme.textMuted)
                                TextField("0.0000", text: $latitude)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("submission.lng".localized)
                                    .font(LeyhomeTheme.Fonts.caption)
                                    .foregroundColor(LeyhomeTheme.textMuted)
                                TextField("0.0000", text: $longitude)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                            }
                        }
                    }
                }

                // 提交按钮
                Button(action: submitSite) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("submission.submit".localized)
                    }
                    .leyhomePrimaryButton()
                    .frame(maxWidth: .infinity)
                }
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.5)
            }
            .padding(LeyhomeTheme.Spacing.md)
        }
        .navigationTitle("submission.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("button.cancel".localized) { dismiss() }
            }
        }
    }

    // MARK: - Submitted

    private var submittedView: some View {
        VStack(spacing: LeyhomeTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundColor(LeyhomeTheme.primary)

            Text("submission.success_title".localized)
                .font(LeyhomeTheme.Fonts.title)
                .foregroundColor(LeyhomeTheme.textPrimary)

            Text("submission.success_message".localized)
                .font(LeyhomeTheme.Fonts.body)
                .foregroundColor(LeyhomeTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LeyhomeTheme.Spacing.lg)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("button.done".localized)
                    .leyhomePrimaryButton()
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, LeyhomeTheme.Spacing.md)
            .padding(.bottom, LeyhomeTheme.Spacing.lg)
        }
        .navigationTitle("submission.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Logic

    private var isFormValid: Bool {
        !siteName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !siteStory.trimmingCharacters(in: .whitespaces).isEmpty &&
        (useCurrentLocation ? trackingManager.currentLocation != nil : !latitude.isEmpty && !longitude.isEmpty)
    }

    private func submitSite() {
        let coord: CLLocationCoordinate2D
        if useCurrentLocation, let loc = trackingManager.currentLocation {
            coord = loc.coordinate
        } else {
            coord = CLLocationCoordinate2D(
                latitude: Double(latitude) ?? 0,
                longitude: Double(longitude) ?? 0
            )
        }

        let site = SacredSite(tier: .anchor, nameZh: siteName, nameEn: siteName)
        site.descriptionZh = String(siteStory.prefix(150))
        site.descriptionEn = String(siteStory.prefix(150))
        site.loreZh = siteStory
        site.loreEn = siteStory
        site.latitude = coord.latitude
        site.longitude = coord.longitude
        site.continent = "user_submitted"
        site.country = "submission.user_site".localized
        site.creatorId = UUID()

        // 保存到本地（未来接入后端审核）
        UserDefaults.standard.set(true, forKey: "has_submitted_site")

        withAnimation(.spring(response: 0.4)) {
            submitted = true
        }
    }
}

// MARK: - Preview

#Preview {
    SiteSubmissionView()
}
