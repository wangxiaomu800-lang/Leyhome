//
//  LoginView.swift
//  Leyhome - 地脉归途
//
//  登录页面 - Apple ID 登录
//
//  Created on 2026/01/26.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [
                    LeyhomeTheme.primary,
                    LeyhomeTheme.primary.opacity(0.8),
                    LeyhomeTheme.Background.dark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // 星星装饰背景
            StarFieldView()
                .opacity(0.6)

            VStack(spacing: 0) {
                Spacer()

                // Logo 区域
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    // App Logo (占位)
                    ZStack {
                        // 外圈光晕动画
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        LeyhomeTheme.accent.opacity(0.6),
                                        LeyhomeTheme.starlight.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .opacity(isAnimating ? 0.5 : 1.0)
                            .animation(
                                .easeInOut(duration: LeyhomeTheme.Animation.breath)
                                .repeatForever(autoreverses: true),
                                value: isAnimating
                            )

                        // 内圈
                        Circle()
                            .fill(LeyhomeTheme.accent.opacity(0.2))
                            .frame(width: 100, height: 100)

                        // Logo 图标
                        Image(systemName: "map.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [LeyhomeTheme.accent, LeyhomeTheme.starlight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    // App 名称
                    Text("app.name".localized)
                        .font(LeyhomeTheme.Fonts.titleLarge)
                        .foregroundColor(.white)

                    // 欢迎语
                    Text("login.welcome".localized)
                        .font(LeyhomeTheme.Fonts.title)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                // Slogan
                VStack(spacing: LeyhomeTheme.Spacing.sm) {
                    Text("app.slogan".localized)
                        .font(LeyhomeTheme.Fonts.quote)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, LeyhomeTheme.Spacing.xl)
                }

                Spacer()

                // 登录按钮区域
                VStack(spacing: LeyhomeTheme.Spacing.md) {
                    // Apple ID 登录按钮
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                    )
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 50)
                    .cornerRadius(LeyhomeTheme.CornerRadius.lg)

                    // 游客登录按钮 (开发测试用)
                    Button(action: {
                        authManager.signInAsGuest()
                    }) {
                        HStack {
                            Image(systemName: "person.fill.questionmark")
                            Text("login.guest".localized)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(LeyhomeTheme.primary)
                        .background(
                            RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.lg)
                                .fill(Color.white.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.lg)
                                .stroke(LeyhomeTheme.accent, lineWidth: 1.5)
                        )
                    }
                }
                .padding(.horizontal, LeyhomeTheme.Spacing.xl)

                // 隐私政策和条款
                VStack(spacing: LeyhomeTheme.Spacing.xs) {
                    Text("login.agreement".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(.white.opacity(0.6))

                    HStack(spacing: LeyhomeTheme.Spacing.sm) {
                        Button(action: {
                            // 打开服务条款
                        }) {
                            Text("login.terms_of_service".localized)
                                .font(LeyhomeTheme.Fonts.caption)
                                .foregroundColor(LeyhomeTheme.starlight)
                                .underline()
                        }

                        Text("&")
                            .font(LeyhomeTheme.Fonts.caption)
                            .foregroundColor(.white.opacity(0.6))

                        Button(action: {
                            // 打开隐私政策
                        }) {
                            Text("login.privacy_policy".localized)
                                .font(LeyhomeTheme.Fonts.caption)
                                .foregroundColor(LeyhomeTheme.starlight)
                                .underline()
                        }
                    }
                }
                .padding(.top, LeyhomeTheme.Spacing.lg)
                .padding(.bottom, LeyhomeTheme.Spacing.xxl)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }

    // MARK: - Apple Sign In Handler
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        authManager.handleAppleSignIn(result: result)
    }
}

// MARK: - 星空背景组件
struct StarFieldView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<50, id: \.self) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(Double.random(in: 0.2...0.8))
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
