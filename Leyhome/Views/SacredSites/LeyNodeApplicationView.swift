//
//  LeyNodeApplicationView.swift
//  Leyhome - 地脉归途
//
//  申请节点 - 简化版单页表单
//
//  Created on 2026/02/03.
//

import SwiftUI
import CoreLocation

struct LeyNodeApplicationView: View {
    @Binding var submitted: Bool

    @State private var nodeName = ""
    @State private var nodeDescription = ""
    @State private var nodeStory = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.lg) {
                // Intro
                Text("leynode.intro".localized)
                    .font(LeyhomeTheme.Fonts.body)
                    .foregroundColor(LeyhomeTheme.textSecondary)
                    .lineSpacing(4)

                // Location picker
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                    Text("leynode.location".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    LocationPickerMapView(selectedCoordinate: $selectedCoordinate)
                }

                // Node name
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                    Text("leynode.name".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    TextField("leynode.name_placeholder".localized, text: $nodeName)
                        .textFieldStyle(.roundedBorder)
                }

                // Short description
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                    Text("leynode.description".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    TextField("leynode.description_placeholder".localized, text: $nodeDescription)
                        .textFieldStyle(.roundedBorder)
                }

                // Story
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
                    Text("leynode.story".localized)
                        .font(LeyhomeTheme.Fonts.headline)
                        .foregroundColor(LeyhomeTheme.textPrimary)

                    TextEditor(text: $nodeStory)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(LeyhomeTheme.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.sm)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )

                    Text("leynode.story_hint".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textMuted)
                }

                // Submit
                Button(action: submitNode) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("leynode.submit".localized)
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
        !nodeName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !nodeDescription.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedCoordinate != nil
    }

    private func submitNode() {
        guard let coord = selectedCoordinate else { return }

        let site = SacredSite(tier: .leyNode, nameZh: nodeName, nameEn: nodeName)
        site.descriptionZh = nodeDescription
        site.descriptionEn = nodeDescription
        site.loreZh = nodeStory
        site.loreEn = nodeStory
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
