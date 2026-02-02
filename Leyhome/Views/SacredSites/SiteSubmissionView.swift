//
//  SiteSubmissionView.swift
//  Leyhome - 地脉归途
//
//  圣迹申请 - 三段式 Tab 容器
//
//  Created on 2026/02/02.
//  Rewritten on 2026/02/03: 三 Tab（申请圣迹 / 申请节点 / 我的锚点）
//

import SwiftUI

struct SiteSubmissionView: View {
    @Environment(\.dismiss) private var dismiss

    enum SubmissionTab: String, CaseIterable {
        case sacredSite = "sacred_site"
        case leyNode = "ley_node"
        case anchor = "anchor"

        var localizedName: String {
            switch self {
            case .sacredSite: return "submission.tab.sacred".localized
            case .leyNode: return "submission.tab.node".localized
            case .anchor: return "submission.tab.anchor".localized
            }
        }
    }

    @State private var selectedTab: SubmissionTab = .anchor
    @State private var submitted = false

    var body: some View {
        NavigationStack {
            if submitted {
                submittedView
            } else {
                VStack(spacing: 0) {
                    // Segmented tab picker
                    Picker("", selection: $selectedTab) {
                        ForEach(SubmissionTab.allCases, id: \.self) { tab in
                            Text(tab.localizedName).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, LeyhomeTheme.Spacing.md)
                    .padding(.vertical, LeyhomeTheme.Spacing.sm)

                    // Tab content
                    switch selectedTab {
                    case .sacredSite:
                        SacredSiteApplicationView(submitted: $submitted)
                    case .leyNode:
                        LeyNodeApplicationView(submitted: $submitted)
                    case .anchor:
                        AnchorSubmissionView(submitted: $submitted)
                    }
                }
                .navigationTitle("submission.title".localized)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("button.cancel".localized) { dismiss() }
                    }
                }
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
}

// MARK: - Preview

#Preview {
    SiteSubmissionView()
}
