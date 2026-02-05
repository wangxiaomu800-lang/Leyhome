//
//  AnchorSubmissionView.swift
//  Leyhome - 地脉归途
//
//  我的锚点 - 从 SiteSubmissionView 提取，改为锚点专属文案
//
//  Created on 2026/02/03.
//  Updated on 2026/02/03: 添加可见性选项
//

import SwiftUI
import CoreLocation
import Supabase

struct AnchorSubmissionView: View {
    @StateObject private var trackingManager = TrackingManager.shared
    @EnvironmentObject private var authManager: AuthManager
    @Binding var submitted: Bool

    @State private var anchorName = ""
    @State private var anchorStory = ""
    @State private var useCurrentLocation = true
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var isPublic = false  // 默认仅自己可见

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.lg) {
                // Intro
                Text("anchor.intro".localized)
                    .font(LeyhomeTheme.Fonts.body)
                    .foregroundColor(LeyhomeTheme.textSecondary)
                    .lineSpacing(4)

                // Anchor name
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                    Text("anchor.name".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    TextField("anchor.name_placeholder".localized, text: $anchorName)
                        .textFieldStyle(.roundedBorder)
                }

                // Story
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                    Text("anchor.story".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    TextEditor(text: $anchorStory)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(LeyhomeTheme.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.sm)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )

                    Text("anchor.story_hint".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textMuted)
                }

                // Location
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

                // Visibility
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                    Text("anchor.visibility.title".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    Toggle(isOn: $isPublic) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("anchor.visibility.public".localized)
                                .font(LeyhomeTheme.Fonts.body)
                                .foregroundColor(LeyhomeTheme.textPrimary)
                            Text("anchor.visibility.public.hint".localized)
                                .font(LeyhomeTheme.Fonts.caption)
                                .foregroundColor(LeyhomeTheme.textMuted)
                        }
                    }
                    .tint(LeyhomeTheme.primary)

                    if !isPublic {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                            Text("anchor.visibility.private.hint".localized)
                                .font(LeyhomeTheme.Fonts.caption)
                        }
                        .foregroundColor(LeyhomeTheme.textMuted)
                        .padding(LeyhomeTheme.Spacing.sm)
                        .background(Color(.systemGray6))
                        .cornerRadius(LeyhomeTheme.CornerRadius.sm)
                    }
                }

                // Submit
                Button(action: submitAnchor) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("anchor.submit".localized)
                    }
                    .leyhomePrimaryButton()
                    .frame(maxWidth: .infinity)
                }
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.5)
            }
            .padding(LeyhomeTheme.Spacing.md)
        }
    }

    private var isFormValid: Bool {
        !anchorName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !anchorStory.trimmingCharacters(in: .whitespaces).isEmpty &&
        (useCurrentLocation ? trackingManager.currentLocation != nil : !latitude.isEmpty && !longitude.isEmpty)
    }

    private func submitAnchor() {
        let coord: CLLocationCoordinate2D
        if useCurrentLocation, let loc = trackingManager.currentLocation {
            coord = loc.coordinate
        } else {
            coord = CLLocationCoordinate2D(
                latitude: Double(latitude) ?? 0,
                longitude: Double(longitude) ?? 0
            )
        }

        let site = SacredSite(tier: .anchor, nameZh: anchorName, nameEn: anchorName)
        site.descriptionZh = String(anchorStory.prefix(150))
        site.descriptionEn = String(anchorStory.prefix(150))
        site.loreZh = anchorStory
        site.loreEn = anchorStory
        site.latitude = coord.latitude
        site.longitude = coord.longitude
        site.continent = "user_submitted"
        site.country = "submission.user_site".localized
        site.creatorId = UUID()

        // 设置可见性和创建者
        site.isPublic = isPublic
        site.creatorUserId = authManager.currentUser?.id.uuidString

        UserDefaults.standard.set(true, forKey: "has_submitted_site")

        withAnimation(.spring(response: 0.4)) {
            submitted = true
        }
    }
}
