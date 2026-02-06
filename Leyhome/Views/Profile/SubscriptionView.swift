//
//  SubscriptionView.swift
//  Leyhome - 地脉归途
//
//  订阅页面 - 深度行者订阅展示与购买
//
//  Created on 2026/02/05.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [
                        LeyhomeTheme.primary.opacity(0.05),
                        LeyhomeTheme.Background.primary
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LeyhomeTheme.Spacing.lg) {
                        // 标题区
                        headerSection

                        // 权益列表
                        benefitsSection

                        // 产品卡片
                        productsSection

                        // 操作按钮
                        actionSection

                        // 条款链接
                        legalSection
                    }
                    .padding(.horizontal, LeyhomeTheme.Spacing.lg)
                    .padding(.bottom, LeyhomeTheme.Spacing.xxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(LeyhomeTheme.textMuted)
                    }
                }
            }
            .alert("subscription.error".localized, isPresented: $showError) {
                Button("button.ok".localized, role: .cancel) {}
            } message: {
                Text(errorText)
            }
        }
    }

    // MARK: - 标题区

    private var headerSection: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [LeyhomeTheme.accent, LeyhomeTheme.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, LeyhomeTheme.Spacing.xl)

            Text("subscription.title".localized)
                .font(LeyhomeTheme.Fonts.title)
                .foregroundColor(LeyhomeTheme.primary)

            Text("subscription.subtitle".localized)
                .font(LeyhomeTheme.Fonts.body)
                .foregroundColor(LeyhomeTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - 权益列表

    private var benefitsSection: some View {
        VStack(spacing: LeyhomeTheme.Spacing.sm) {
            BenefitRow(icon: "chart.bar.xaxis", title: "subscription.benefit.insights".localized)
            BenefitRow(icon: "icloud.and.arrow.up", title: "subscription.benefit.sync".localized)
            BenefitRow(icon: "map.fill", title: "subscription.benefit.routes".localized)
            BenefitRow(icon: "star.fill", title: "subscription.benefit.sites".localized)
            BenefitRow(icon: "paintbrush.fill", title: "subscription.benefit.themes".localized)
            BenefitRow(icon: "person.2.fill", title: "subscription.benefit.community".localized)
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color.white)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .shadow(
            color: LeyhomeTheme.Shadow.light.color,
            radius: LeyhomeTheme.Shadow.light.radius,
            x: LeyhomeTheme.Shadow.light.x,
            y: LeyhomeTheme.Shadow.light.y
        )
    }

    // MARK: - 产品卡片

    private var productsSection: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            if subscriptionManager.products.isEmpty {
                // 加载中或无产品
                VStack(spacing: LeyhomeTheme.Spacing.sm) {
                    ProgressView()
                    Text("subscription.loading".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textMuted)
                }
                .padding(LeyhomeTheme.Spacing.xl)
            } else {
                ForEach(subscriptionManager.products, id: \.id) { product in
                    ProductCard(
                        product: product,
                        isSelected: selectedProduct?.id == product.id,
                        isYearly: product.id == SubscriptionManager.yearlyID
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedProduct = product
                        }
                    }
                }
            }
        }
    }

    // MARK: - 操作按钮

    private var actionSection: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            // 订阅按钮
            Button {
                Task { await handlePurchase() }
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("subscription.subscribe".localized)
                        .font(LeyhomeTheme.Fonts.button)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, LeyhomeTheme.Spacing.md)
                .background(
                    selectedProduct != nil
                    ? LeyhomeTheme.primary
                    : LeyhomeTheme.textMuted
                )
                .foregroundColor(.white)
                .cornerRadius(LeyhomeTheme.CornerRadius.lg)
            }
            .disabled(selectedProduct == nil || isPurchasing)

            // 恢复购买
            Button {
                Task { await subscriptionManager.restorePurchases() }
            } label: {
                Text("subscription.restore".localized)
                    .font(LeyhomeTheme.Fonts.bodySmall)
                    .foregroundColor(LeyhomeTheme.textSecondary)
            }
        }
    }

    // MARK: - 条款链接

    private var legalSection: some View {
        VStack(spacing: LeyhomeTheme.Spacing.xs) {
            Text("subscription.legal_notice".localized)
                .font(LeyhomeTheme.Fonts.caption)
                .foregroundColor(LeyhomeTheme.textMuted)
                .multilineTextAlignment(.center)

            HStack(spacing: LeyhomeTheme.Spacing.md) {
                Link("subscription.terms".localized,
                     destination: URL(string: "https://leyhome.app/terms")!)
                Link("subscription.privacy".localized,
                     destination: URL(string: "https://leyhome.app/privacy")!)
            }
            .font(LeyhomeTheme.Fonts.caption)
            .foregroundColor(LeyhomeTheme.accent)
        }
        .padding(.top, LeyhomeTheme.Spacing.sm)
    }

    // MARK: - 购买逻辑

    private func handlePurchase() async {
        guard let product = selectedProduct else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let success = try await subscriptionManager.purchase(product)
            if success {
                dismiss()
            }
        } catch {
            errorText = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - BenefitRow

struct BenefitRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: LeyhomeTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(LeyhomeTheme.accent)
                .frame(width: 28)

            Text(title)
                .font(LeyhomeTheme.Fonts.body)
                .foregroundColor(LeyhomeTheme.textPrimary)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(LeyhomeTheme.success)
                .font(.system(size: 16))
        }
        .padding(.vertical, LeyhomeTheme.Spacing.xs)
    }
}

// MARK: - ProductCard

struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let isYearly: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(isYearly
                             ? "subscription.yearly".localized
                             : "subscription.monthly".localized)
                            .font(LeyhomeTheme.Fonts.headline)
                            .foregroundColor(LeyhomeTheme.textPrimary)

                        if isYearly {
                            Text("subscription.save_badge".localized)
                                .font(LeyhomeTheme.Fonts.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(LeyhomeTheme.accent)
                                .cornerRadius(LeyhomeTheme.CornerRadius.xs)
                        }
                    }

                    Text(isYearly
                         ? "subscription.yearly_desc".localized
                         : "subscription.monthly_desc".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(LeyhomeTheme.Fonts.titleSmall)
                    .foregroundColor(LeyhomeTheme.primary)
            }
            .padding(LeyhomeTheme.Spacing.md)
            .background(Color.white)
            .cornerRadius(LeyhomeTheme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.md)
                    .stroke(isSelected ? LeyhomeTheme.primary : Color.clear, lineWidth: 2)
            )
            .shadow(
                color: LeyhomeTheme.Shadow.light.color,
                radius: LeyhomeTheme.Shadow.light.radius,
                x: LeyhomeTheme.Shadow.light.x,
                y: LeyhomeTheme.Shadow.light.y
            )
        }
    }
}

#Preview {
    SubscriptionView()
}
