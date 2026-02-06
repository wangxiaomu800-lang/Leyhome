//
//  OnboardingView.swift
//  Leyhome - 地脉归途
//
//  新用户引导页 - 4 页介绍核心功能
//
//  Created on 2026/02/05.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "map.fill",
            titleKey: "onboarding.map.title",
            descriptionKey: "onboarding.map.desc",
            color: LeyhomeTheme.primary
        ),
        OnboardingPage(
            icon: "heart.circle.fill",
            titleKey: "onboarding.mood.title",
            descriptionKey: "onboarding.mood.desc",
            color: LeyhomeTheme.Mood.joy
        ),
        OnboardingPage(
            icon: "star.fill",
            titleKey: "onboarding.sites.title",
            descriptionKey: "onboarding.sites.desc",
            color: LeyhomeTheme.accent
        ),
        OnboardingPage(
            icon: "person.2.fill",
            titleKey: "onboarding.guides.title",
            descriptionKey: "onboarding.guides.desc",
            color: LeyhomeTheme.starlight
        )
    ]

    var body: some View {
        ZStack {
            // 背景
            LeyhomeTheme.Background.primary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 跳过按钮
                HStack {
                    Spacer()
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("onboarding.skip".localized)
                            .font(LeyhomeTheme.Fonts.body)
                            .foregroundColor(LeyhomeTheme.textSecondary)
                    }
                    .padding(.trailing, LeyhomeTheme.Spacing.lg)
                    .padding(.top, LeyhomeTheme.Spacing.md)
                }

                // 页面内容
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // 页面指示器
                HStack(spacing: LeyhomeTheme.Spacing.sm) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage
                                  ? LeyhomeTheme.primary
                                  : LeyhomeTheme.textMuted.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.bottom, LeyhomeTheme.Spacing.lg)

                // 按钮
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage < pages.count - 1
                         ? "onboarding.next".localized
                         : "onboarding.start".localized)
                        .font(LeyhomeTheme.Fonts.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LeyhomeTheme.Spacing.md)
                        .background(LeyhomeTheme.primary)
                        .cornerRadius(LeyhomeTheme.CornerRadius.lg)
                }
                .padding(.horizontal, LeyhomeTheme.Spacing.xl)
                .padding(.bottom, LeyhomeTheme.Spacing.xxl)
            }
        }
    }

    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - OnboardingPage 数据模型

struct OnboardingPage {
    let icon: String
    let titleKey: String
    let descriptionKey: String
    let color: Color
}

// MARK: - 单页视图

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.xl) {
            Spacer()

            // 图标
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(page.color.opacity(0.08))
                    .frame(width: 220, height: 220)

                Image(systemName: page.icon)
                    .font(.system(size: 64))
                    .foregroundColor(page.color)
            }

            // 标题
            Text(page.titleKey.localized)
                .font(LeyhomeTheme.Fonts.title)
                .foregroundColor(LeyhomeTheme.primary)
                .multilineTextAlignment(.center)

            // 描述
            Text(page.descriptionKey.localized)
                .font(LeyhomeTheme.Fonts.body)
                .foregroundColor(LeyhomeTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LeyhomeTheme.Spacing.xl)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
