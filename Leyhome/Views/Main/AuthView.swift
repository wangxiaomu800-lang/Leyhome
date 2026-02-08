import SwiftUI

/// 认证页面「星图之门」- 深色星空登录体验
struct AuthView: View {
    // MARK: - State
    @EnvironmentObject var authManager: AuthManager

    /// 当前选中的Tab（登录/注册）
    @State private var selectedTab: AuthTab = .login

    /// 登录表单
    @State private var loginEmail = ""
    @State private var loginPassword = ""

    /// 注册表单
    @State private var registerEmail = ""
    @State private var registerOTP = ""
    @State private var registerPassword = ""
    @State private var registerConfirmPassword = ""

    /// 找回密码表单
    @State private var resetEmail = ""
    @State private var resetOTP = ""
    @State private var resetPassword = ""
    @State private var resetConfirmPassword = ""

    /// 是否显示忘记密码弹窗
    @State private var showResetPasswordSheet = false

    /// 是否显示邮箱登录/注册表单 Sheet
    @State private var showEmailSheet = false

    /// 找回密码流程步骤（1=发送验证码, 2=验证, 3=设置新密码）
    @State private var resetStep = 1

    /// 验证码倒计时（秒）
    @State private var otpCountdown = 0
    @State private var resetOtpCountdown = 0

    /// 倒计时定时器
    @State private var otpTimer: Timer? = nil
    @State private var resetOtpTimer: Timer? = nil

    /// 入场动画状态
    @State private var brandAppeared = false
    @State private var buttonsAppeared = false

    // MARK: - Tab枚举
    enum AuthTab {
        case login
        case register
    }

    var body: some View {
        ZStack {
            // 层1: 深色渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "0A0A1A"),
                    Color(hex: "0D1B2A"),
                    Color(hex: "1A1A2E")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // 层2: 星空粒子
            StarFieldView()
                .opacity(0.7)
                .ignoresSafeArea()

            // 层3: 山脉剪影（底部）
            MountainSilhouetteView()
                .ignoresSafeArea()

            // 层4: 主内容
            VStack(spacing: 0) {
                Spacer()

                // 品牌区
                brandSection
                    .opacity(brandAppeared ? 1 : 0)
                    .offset(y: brandAppeared ? 0 : 20)

                Spacer()

                // 登录按钮区
                loginButtonsSection
                    .opacity(buttonsAppeared ? 1 : 0)
                    .offset(y: buttonsAppeared ? 0 : 20)

                // 条款区
                termsSection
                    .opacity(buttonsAppeared ? 1 : 0)
                    .padding(.top, LeyhomeTheme.Spacing.lg)
                    .padding(.bottom, LeyhomeTheme.Spacing.xxl)
            }

            // 层5: 加载指示器
            if authManager.isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                brandAppeared = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                buttonsAppeared = true
            }
        }
        .sheet(isPresented: $showEmailSheet) {
            emailFormSheet
        }
        .sheet(isPresented: $showResetPasswordSheet) {
            resetPasswordSheet
        }
    }

    // MARK: - Brand Section

    private var brandSection: some View {
        VStack(spacing: 16) {
            // 呼吸光晕 Logo
            ZStack {
                // 外圈光晕
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
                    .scaleEffect(brandAppeared ? 1.08 : 1.0)
                    .opacity(brandAppeared ? 0.5 : 1.0)
                    .animation(
                        .easeInOut(duration: LeyhomeTheme.Animation.breath)
                        .repeatForever(autoreverses: true),
                        value: brandAppeared
                    )

                // 内圈
                Circle()
                    .fill(LeyhomeTheme.accent.opacity(0.15))
                    .frame(width: 100, height: 100)

                // Logo 图标
                Image(systemName: "globe.asia.australia.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [LeyhomeTheme.accent, LeyhomeTheme.starlight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // 中文名
            Text("app.name".localized)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            // 英文名
            Text("LEYHOME")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .tracking(3)

            // Slogan
            Text("app.slogan".localized)
                .font(LeyhomeTheme.Fonts.quote)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Login Buttons Section

    private var loginButtonsSection: some View {
        VStack(spacing: 12) {
            // 邮件登录按钮
            Button(action: { showEmailSheet = true }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .font(.title3)
                    Text("login.email".localized)
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(LeyhomeTheme.primary)
                .cornerRadius(12)
            }

            // Apple 登录按钮
            Button(action: handleAppleLogin) {
                HStack {
                    Image(systemName: "apple.logo")
                        .font(.title3)
                    Text("login.apple".localized)
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.black)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }

            // Google 登录按钮
            Button(action: handleGoogleLogin) {
                HStack {
                    Image(systemName: "globe")
                        .font(.title3)
                    Text("login.google".localized)
                        .font(.headline)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, LeyhomeTheme.Spacing.xl)
    }

    // MARK: - Terms Section

    private var termsSection: some View {
        VStack(spacing: LeyhomeTheme.Spacing.xs) {
            Text("login.agreement".localized)
                .font(LeyhomeTheme.Fonts.caption)
                .foregroundColor(.white.opacity(0.5))

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
                    .foregroundColor(.white.opacity(0.5))

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
    }

    // MARK: - Email Form Sheet

    private var emailFormSheet: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0D1B2A")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Tab 切换
                        tabSwitcher

                        // 表单内容
                        if selectedTab == .login {
                            loginForm
                        } else {
                            registerForm
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEmailSheet = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Tab Switcher
    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = .login }) {
                Text("登录")
                    .font(.headline)
                    .foregroundColor(selectedTab == .login ? .white : .white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == .login
                            ? LeyhomeTheme.primary
                            : Color.clear
                    )
            }

            Button(action: { selectedTab = .register }) {
                Text("注册")
                    .font(.headline)
                    .foregroundColor(selectedTab == .register ? .white : .white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == .register
                            ? LeyhomeTheme.primary
                            : Color.clear
                    )
            }
        }
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
    }

    // MARK: - 登录表单
    private var loginForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("邮箱")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                TextField("请输入邮箱", text: $loginEmail)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("密码")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                SecureField("请输入密码", text: $loginPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.password)
            }

            if let error = authManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(LeyhomeTheme.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: handleLogin) {
                Text("登录")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LeyhomeTheme.primary)
                    .cornerRadius(12)
            }
            .disabled(loginEmail.isEmpty || loginPassword.isEmpty)
            .opacity(loginEmail.isEmpty || loginPassword.isEmpty ? 0.5 : 1.0)

            Button(action: {
                showEmailSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showResetPasswordSheet = true
                }
            }) {
                Text("忘记密码？")
                    .font(.subheadline)
                    .foregroundColor(LeyhomeTheme.starlight)
            }
        }
        .padding(.top, 20)
    }

    // MARK: - 注册表单
    private var registerForm: some View {
        VStack(spacing: 16) {
            if !authManager.otpVerified {
                registerStepOneAndTwo
            } else if authManager.needsPasswordSetup {
                registerStepThree
            }
        }
        .padding(.top, 20)
    }

    // MARK: - 注册步骤1和2
    private var registerStepOneAndTwo: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("邮箱")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    if authManager.otpSent {
                        Button("修改邮箱") {
                            authManager.resetState()
                            registerOTP = ""
                            otpCountdown = 0
                            otpTimer?.invalidate()
                        }
                        .font(.caption)
                        .foregroundColor(LeyhomeTheme.starlight)
                    }
                }

                TextField("请输入邮箱", text: $registerEmail)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .onChange(of: registerEmail) { _, _ in
                        authManager.errorMessage = nil
                    }
            }

            if !authManager.otpSent {
                Button(action: handleSendRegisterOTP) {
                    Text("发送验证码")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LeyhomeTheme.primary)
                        .cornerRadius(12)
                }
                .disabled(registerEmail.isEmpty)
                .opacity(registerEmail.isEmpty ? 0.5 : 1.0)
            }

            if authManager.otpSent {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("验证码")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))

                        Spacer()

                        if otpCountdown > 0 {
                            Text("\(otpCountdown)秒后重发")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                        } else {
                            Button("重新发送") {
                                handleSendRegisterOTP()
                            }
                            .font(.caption)
                            .foregroundColor(LeyhomeTheme.starlight)
                        }
                    }

                    TextField("请输入6位验证码", text: $registerOTP)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.oneTimeCode)
                        .keyboardType(.numberPad)
                }

                Button(action: handleVerifyRegisterOTP) {
                    Text("验证")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LeyhomeTheme.primary)
                        .cornerRadius(12)
                }
                .disabled(registerOTP.count != 6)
                .opacity(registerOTP.count != 6 ? 0.5 : 1.0)
            }

            if let error = authManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(LeyhomeTheme.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - 注册步骤3：设置密码
    private var registerStepThree: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(LeyhomeTheme.success)
                Text("验证成功！请设置密码完成注册")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(LeyhomeTheme.success.opacity(0.1))
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 8) {
                Text("设置密码")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                SecureField("请输入密码（至少6位）", text: $registerPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.newPassword)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("确认密码")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                SecureField("请再次输入密码", text: $registerConfirmPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.newPassword)
            }

            if !registerPassword.isEmpty {
                let validation = authManager.validatePassword(registerPassword)
                if !validation.isValid, let message = validation.message {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(LeyhomeTheme.warning)
                }
            }

            if !registerConfirmPassword.isEmpty && registerPassword != registerConfirmPassword {
                Text("两次输入的密码不一致")
                    .font(.caption)
                    .foregroundColor(LeyhomeTheme.danger)
            }

            if let error = authManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(LeyhomeTheme.danger)
            }

            Button(action: handleCompleteRegistration) {
                Text("完成注册")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LeyhomeTheme.primary)
                    .cornerRadius(12)
            }
            .disabled(!canCompleteRegistration)
            .opacity(canCompleteRegistration ? 1.0 : 0.5)
        }
    }

    // MARK: - 找回密码弹窗
    private var resetPasswordSheet: some View {
        NavigationView {
            ZStack {
                Color(hex: "0D1B2A")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        stepIndicator(currentStep: resetStep, totalSteps: 3)

                        switch resetStep {
                        case 1:
                            resetStepOne
                        case 2:
                            resetStepTwo
                        case 3:
                            resetStepThreeView
                        default:
                            EmptyView()
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("找回密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        showResetPasswordSheet = false
                        resetResetPasswordFlow()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }

    // MARK: - 找回密码步骤1
    private var resetStepOne: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("邮箱")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                TextField("请输入注册邮箱", text: $resetEmail)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }

            if let error = authManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(LeyhomeTheme.danger)
            }

            Button(action: handleSendResetOTP) {
                Text("发送验证码")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LeyhomeTheme.primary)
                    .cornerRadius(12)
            }
            .disabled(resetEmail.isEmpty || authManager.isLoading)
            .opacity(resetEmail.isEmpty ? 0.5 : 1.0)
        }
    }

    // MARK: - 找回密码步骤2
    private var resetStepTwo: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("验证码")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    if resetOtpCountdown > 0 {
                        Text("\(resetOtpCountdown)秒后重发")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                    } else {
                        Button("重新发送") {
                            resetStep = 1
                        }
                        .font(.caption)
                        .foregroundColor(LeyhomeTheme.starlight)
                    }
                }

                TextField("请输入6位验证码", text: $resetOTP)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
            }

            if let error = authManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(LeyhomeTheme.danger)
            }

            Button(action: handleVerifyResetOTP) {
                Text("验证")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LeyhomeTheme.primary)
                    .cornerRadius(12)
            }
            .disabled(resetOTP.count != 6 || authManager.isLoading)
            .opacity(resetOTP.count != 6 ? 0.5 : 1.0)
        }
    }

    // MARK: - 找回密码步骤3
    private var resetStepThreeView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(LeyhomeTheme.success)
                Text("验证成功！请设置新密码")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(LeyhomeTheme.success.opacity(0.1))
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 8) {
                Text("新密码")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                SecureField("请输入新密码（至少6位）", text: $resetPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.newPassword)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("确认密码")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                SecureField("请再次输入新密码", text: $resetConfirmPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.newPassword)
            }

            if !resetConfirmPassword.isEmpty && resetPassword != resetConfirmPassword {
                Text("两次输入的密码不一致")
                    .font(.caption)
                    .foregroundColor(LeyhomeTheme.danger)
            }

            if let error = authManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(LeyhomeTheme.danger)
            }

            Button(action: handleResetPassword) {
                Text("重置密码")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LeyhomeTheme.primary)
                    .cornerRadius(12)
            }
            .disabled(!canResetPassword || authManager.isLoading)
            .opacity(canResetPassword ? 1.0 : 0.5)
        }
    }

    // MARK: - 步骤指示器
    private func stepIndicator(currentStep: Int, totalSteps: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? LeyhomeTheme.primary : Color.white.opacity(0.2))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.bottom, 10)
    }

    // MARK: - Action Handlers

    /// 处理登录
    private func handleLogin() {
        Task {
            await authManager.signIn(email: loginEmail, password: loginPassword)
        }
    }

    /// 发送注册验证码
    private func handleSendRegisterOTP() {
        guard authManager.isValidEmail(registerEmail) else {
            authManager.errorMessage = "请输入有效的邮箱地址"
            return
        }

        Task {
            await authManager.sendRegisterOTP(email: registerEmail)
            if authManager.otpSent {
                startOTPCountdown()
            }
        }
    }

    /// 验证注册验证码
    private func handleVerifyRegisterOTP() {
        Task {
            await authManager.verifyRegisterOTP(email: registerEmail, code: registerOTP)
        }
    }

    /// 完成注册
    private func handleCompleteRegistration() {
        Task {
            await authManager.completeRegistration(password: registerPassword)
        }
    }

    /// 发送重置验证码
    private func handleSendResetOTP() {
        Task {
            await authManager.sendResetOTP(email: resetEmail)
            if authManager.otpSent {
                resetStep = 2
                startResetOTPCountdown()
            }
        }
    }

    /// 验证重置验证码
    private func handleVerifyResetOTP() {
        Task {
            await authManager.verifyResetOTP(email: resetEmail, code: resetOTP)
            if authManager.otpVerified {
                resetStep = 3
            }
        }
    }

    /// 重置密码
    private func handleResetPassword() {
        Task {
            await authManager.resetPassword(newPassword: resetPassword)
            if authManager.isAuthenticated {
                showResetPasswordSheet = false
                resetResetPasswordFlow()
            }
        }
    }

    /// Apple 登录（占位）
    private func handleAppleLogin() {
        authManager.errorMessage = "Apple 登录即将开放"
    }

    /// Google 登录
    private func handleGoogleLogin() {
        print("🔵 用户点击 Google 登录按钮")
        Task {
            await authManager.signInWithGoogle()
        }
    }

    // MARK: - Helper Functions

    /// 是否可以完成注册
    private var canCompleteRegistration: Bool {
        let validation = authManager.validatePassword(registerPassword)
        return validation.isValid &&
               registerPassword == registerConfirmPassword &&
               !registerPassword.isEmpty
    }

    /// 是否可以重置密码
    private var canResetPassword: Bool {
        let validation = authManager.validatePassword(resetPassword)
        return validation.isValid &&
               resetPassword == resetConfirmPassword &&
               !resetPassword.isEmpty
    }

    /// 启动注册验证码倒计时
    private func startOTPCountdown() {
        otpCountdown = 60
        otpTimer?.invalidate()
        otpTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if otpCountdown > 0 {
                otpCountdown -= 1
            } else {
                otpTimer?.invalidate()
            }
        }
    }

    /// 启动重置验证码倒计时
    private func startResetOTPCountdown() {
        resetOtpCountdown = 60
        resetOtpTimer?.invalidate()
        resetOtpTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if resetOtpCountdown > 0 {
                resetOtpCountdown -= 1
            } else {
                resetOtpTimer?.invalidate()
            }
        }
    }

    /// 重置找回密码流程
    private func resetResetPasswordFlow() {
        resetStep = 1
        resetEmail = ""
        resetOTP = ""
        resetPassword = ""
        resetConfirmPassword = ""
        resetOtpTimer?.invalidate()
        resetOtpCountdown = 0
        authManager.resetState()
    }
}

// MARK: - Preview
#Preview {
    AuthView()
        .environmentObject(AuthManager())
}
