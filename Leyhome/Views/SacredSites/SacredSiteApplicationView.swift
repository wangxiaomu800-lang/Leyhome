//
//  SacredSiteApplicationView.swift
//  Leyhome - 地脉归途
//
//  申请圣迹 - 5步向导（寻迹流程）
//
//  Created on 2026/02/03.
//

import SwiftUI
import PhotosUI
import CoreLocation
import UIKit

struct SacredSiteApplicationView: View {
    @Binding var submitted: Bool

    @State private var currentStep = 0
    private let totalSteps = 5

    // Step 1: Location
    @State private var selectedCoordinate: CLLocationCoordinate2D?

    // Step 2: Naming
    @State private var siteName = ""
    @State private var siteTagline = ""

    // Step 3: Reasons
    @State private var historyLegend = ""
    @State private var personalExperience = ""
    @State private var terrainFeature = ""

    // Step 4: Evidence
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []

    // Step 5: Oath
    @State private var oathAgreed = false

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            progressBar
                .padding(.horizontal, LeyhomeTheme.Spacing.md)
                .padding(.top, LeyhomeTheme.Spacing.sm)

            // Step content
            ScrollView {
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.lg) {
                    switch currentStep {
                    case 0: stepLocation
                    case 1: stepNaming
                    case 2: stepReasons
                    case 3: stepEvidence
                    case 4: stepOath
                    default: EmptyView()
                    }
                }
                .padding(LeyhomeTheme.Spacing.md)
            }

            // Navigation buttons
            navigationButtons
                .padding(LeyhomeTheme.Spacing.md)
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? LeyhomeTheme.primary : Color(.systemGray4))
                    .frame(height: 4)
            }
        }
    }

    // MARK: - Step 1: Location

    private var stepLocation: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            stepHeader(
                icon: "mappin.and.ellipse",
                title: "sacred_app.step1_title".localized,
                subtitle: "sacred_app.step1_subtitle".localized
            )

            LocationPickerMapView(selectedCoordinate: $selectedCoordinate)
        }
    }

    // MARK: - Step 2: Naming

    private var stepNaming: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            stepHeader(
                icon: "character.cursor.ibeam",
                title: "sacred_app.step2_title".localized,
                subtitle: "sacred_app.step2_subtitle".localized
            )

            VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                HStack {
                    Text("sacred_app.site_name".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)
                    Spacer()
                    Text("\(siteName.count)/4")
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(siteName.count >= 4 ? LeyhomeTheme.success : LeyhomeTheme.textMuted)
                }

                TextField("sacred_app.site_name_placeholder".localized, text: $siteName)
                    .textFieldStyle(.roundedBorder)

                Text("sacred_app.site_name_hint".localized)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(LeyhomeTheme.textMuted)
            }

            VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                HStack {
                    Text("sacred_app.tagline".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)
                    Spacer()
                    Text("\(siteTagline.count)/10")
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(siteTagline.count >= 10 ? LeyhomeTheme.success : LeyhomeTheme.textMuted)
                }

                TextField("sacred_app.tagline_placeholder".localized, text: $siteTagline)
                    .textFieldStyle(.roundedBorder)

                Text("sacred_app.tagline_hint".localized)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(LeyhomeTheme.textMuted)
            }
        }
    }

    // MARK: - Step 3: Reasons

    private var stepReasons: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            stepHeader(
                icon: "text.alignleft",
                title: "sacred_app.step3_title".localized,
                subtitle: "sacred_app.step3_subtitle".localized
            )

            reasonEditor(
                title: "sacred_app.reason_history".localized,
                placeholder: "sacred_app.reason_history_hint".localized,
                text: $historyLegend
            )

            reasonEditor(
                title: "sacred_app.reason_personal".localized,
                placeholder: "sacred_app.reason_personal_hint".localized,
                text: $personalExperience
            )

            reasonEditor(
                title: "sacred_app.reason_terrain".localized,
                placeholder: "sacred_app.reason_terrain_hint".localized,
                text: $terrainFeature
            )
        }
    }

    // MARK: - Step 4: Evidence

    private var stepEvidence: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            stepHeader(
                icon: "photo.on.rectangle.angled",
                title: "sacred_app.step4_title".localized,
                subtitle: "sacred_app.step4_subtitle".localized
            )

            // Photo picker
            VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                HStack {
                    Text("sacred_app.photos".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    Spacer()

                    Text("\(selectedPhotos.count)/3+")
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(selectedPhotos.count >= 3 ? LeyhomeTheme.success : LeyhomeTheme.textMuted)
                }

                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 10,
                    matching: .images
                ) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text("sacred_app.select_photos".localized)
                    }
                    .font(LeyhomeTheme.Fonts.body)
                    .foregroundColor(LeyhomeTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(LeyhomeTheme.Spacing.md)
                    .background(LeyhomeTheme.primary.opacity(0.08))
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.md)
                            .stroke(LeyhomeTheme.primary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [6]))
                    )
                }
                .onChange(of: selectedPhotos) { _, newItems in
                    loadImages(from: newItems)
                }

                // Photo previews
                if !loadedImages.isEmpty {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(loadedImages.indices, id: \.self) { index in
                            Image(uiImage: loadedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }

                Text("sacred_app.photos_hint".localized)
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(LeyhomeTheme.textMuted)
            }
        }
    }

    private func loadImages(from items: [PhotosPickerItem]) {
        loadedImages = []
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            loadedImages.append(uiImage)
                        }
                    }
                case .failure:
                    break
                }
            }
        }
    }

    // MARK: - Step 5: Oath

    private var stepOath: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
            stepHeader(
                icon: "hand.raised.fill",
                title: "sacred_app.step5_title".localized,
                subtitle: "sacred_app.step5_subtitle".localized
            )

            // Oath text
            VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                Text("sacred_app.oath_text".localized)
                    .font(LeyhomeTheme.Fonts.body)
                    .foregroundColor(LeyhomeTheme.textSecondary)
                    .lineSpacing(6)
                    .padding(LeyhomeTheme.Spacing.md)
                    .background(LeyhomeTheme.SacredSite.tier1.opacity(0.08))
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
            }

            // Agreement toggle
            Toggle(isOn: $oathAgreed) {
                Text("sacred_app.oath_agree".localized)
                    .font(LeyhomeTheme.Fonts.body)
                    .foregroundColor(LeyhomeTheme.textPrimary)
            }
            .tint(LeyhomeTheme.primary)
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            if currentStep > 0 {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentStep -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("sacred_app.prev".localized)
                    }
                    .leyhomeSecondaryButton()
                    .frame(maxWidth: .infinity)
                }
            }

            if currentStep < totalSteps - 1 {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentStep += 1
                    }
                } label: {
                    HStack {
                        Text("sacred_app.next".localized)
                        Image(systemName: "chevron.right")
                    }
                    .leyhomePrimaryButton()
                    .frame(maxWidth: .infinity)
                }
                .disabled(!isCurrentStepValid)
                .opacity(isCurrentStepValid ? 1.0 : 0.5)
            } else {
                Button(action: submitSacredSite) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("sacred_app.submit".localized)
                    }
                    .leyhomePrimaryButton()
                    .frame(maxWidth: .infinity)
                }
                .disabled(!isCurrentStepValid)
                .opacity(isCurrentStepValid ? 1.0 : 0.5)
            }
        }
    }

    // MARK: - Helpers

    private func stepHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.xs) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(LeyhomeTheme.SacredSite.tier1)
                Text(title)
                    .font(LeyhomeTheme.Fonts.title)
                    .foregroundColor(LeyhomeTheme.textPrimary)
            }
            Text(subtitle)
                .font(LeyhomeTheme.Fonts.body)
                .foregroundColor(LeyhomeTheme.textSecondary)
                .lineSpacing(4)
        }
    }

    private func reasonEditor(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            Text(title)
                .font(LeyhomeTheme.Fonts.headline)
                .foregroundColor(LeyhomeTheme.textPrimary)

            ZStack(alignment: .topLeading) {
                TextEditor(text: text)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(LeyhomeTheme.CornerRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.sm)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )

                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(LeyhomeTheme.Fonts.body)
                        .foregroundColor(LeyhomeTheme.textMuted)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }
        }
    }

    private var isCurrentStepValid: Bool {
        switch currentStep {
        case 0: return selectedCoordinate != nil
        case 1:
            let trimmedName = siteName.trimmingCharacters(in: .whitespaces)
            let trimmedTagline = siteTagline.trimmingCharacters(in: .whitespaces)
            return trimmedName.count >= 4 && trimmedTagline.count >= 10
        case 2:
            return !historyLegend.trimmingCharacters(in: .whitespaces).isEmpty ||
                   !personalExperience.trimmingCharacters(in: .whitespaces).isEmpty ||
                   !terrainFeature.trimmingCharacters(in: .whitespaces).isEmpty
        case 3: return selectedPhotos.count >= 3
        case 4: return oathAgreed
        default: return false
        }
    }

    private func submitSacredSite() {
        guard let coord = selectedCoordinate else { return }

        let site = SacredSite(tier: .primal, nameZh: siteName, nameEn: siteName)
        site.descriptionZh = siteTagline
        site.descriptionEn = siteTagline

        var loreText = ""
        if !historyLegend.isEmpty { loreText += historyLegend }
        if !personalExperience.isEmpty {
            if !loreText.isEmpty { loreText += "\n\n" }
            loreText += personalExperience
        }
        if !terrainFeature.isEmpty {
            if !loreText.isEmpty { loreText += "\n\n" }
            loreText += terrainFeature
        }
        site.loreZh = loreText
        site.loreEn = loreText

        if !historyLegend.isEmpty {
            site.historyZh = historyLegend
            site.historyEn = historyLegend
        }

        site.latitude = coord.latitude
        site.longitude = coord.longitude
        site.continent = "user_submitted"
        site.country = "submission.user_site".localized
        site.creatorId = UUID()

        UserDefaults.standard.set(true, forKey: "has_submitted_site")

        withAnimation(.spring(response: 0.4)) {
            submitted = true
        }
    }
}
