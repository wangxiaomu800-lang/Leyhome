//
//  SubscriptionManager.swift
//  Leyhome - 地脉归途
//
//  订阅管理器 - StoreKit 2 订阅管理
//
//  Created on 2026/02/05.
//

import Foundation
import StoreKit
import Combine

/// 订阅等级
enum SubscriptionTier: String {
    case free = "free"
    case premium = "premium"
}

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    // MARK: - Debug

    #if DEBUG
    /// 调试模式：设为 true 模拟已订阅状态
    static var debugOverridePremium = false
    #endif

    // MARK: - Product IDs

    static let monthlyID = "com.leyhome.premium.monthly"
    static let yearlyID = "com.leyhome.premium.yearly"
    private let productIDs: Set<String> = [monthlyID, yearlyID]

    // MARK: - Published

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var subscriptionTier: SubscriptionTier = .free
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private

    private var transactionListener: Task<Void, Never>?

    // MARK: - Init

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - 监听交易更新

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.checkSubscriptionStatus()
                }
            }
        }
    }

    // MARK: - 加载产品

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let storeProducts = try await Product.products(for: productIDs)
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            print("[SubscriptionManager] Failed to load products: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - 购买

    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await checkSubscriptionStatus()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - 恢复购买

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            print("[SubscriptionManager] Restore failed: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - 检查订阅状态

    func checkSubscriptionStatus() async {
        var hasActiveSubscription = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if productIDs.contains(transaction.productID) &&
                   transaction.revocationDate == nil {
                    hasActiveSubscription = true
                    purchasedProductIDs.insert(transaction.productID)
                }
            }
        }

        subscriptionTier = hasActiveSubscription ? .premium : .free
    }

    // MARK: - 便捷属性

    var isPremium: Bool {
        #if DEBUG
        if Self.debugOverridePremium { return true }
        #endif
        return subscriptionTier == .premium
    }

    var monthlyProduct: Product? {
        products.first { $0.id == Self.monthlyID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == Self.yearlyID }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let value):
            return value
        }
    }
}

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case verificationFailed
    case purchaseFailed(String)

    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "订阅验证失败"
        case .purchaseFailed(let reason):
            return "购买失败: \(reason)"
        }
    }
}
