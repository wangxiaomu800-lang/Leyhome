//
//  EchoComposerView.swift
//  Leyhome - 地脉归途
//
//  回响发布视图 - 用户在圣迹详情页留下回响
//
//  Created on 2026/02/03.
//

import SwiftUI
import PhotosUI
import Supabase

struct EchoComposerView: View {
    let siteId: UUID
    let onSave: (Echo) -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthManager

    @State private var content = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    @State private var isPublic = false
    @State private var isAnonymous = false
    @State private var isLoading = false

    private let maxCharacters = 500
    private let maxPhotos = 9

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LeyhomeTheme.Spacing.lg) {
                    contentSection
                    photosSection
                    privacySection
                }
                .padding(LeyhomeTheme.Spacing.md)
            }
            .background(LeyhomeTheme.Background.primary)
            .navigationTitle("echo.compose".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("button.cancel".localized) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("echo.publish".localized) {
                        saveEcho()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
            }
        }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            TextEditor(text: $content)
                .frame(minHeight: 150)
                .padding(LeyhomeTheme.Spacing.sm)
                .background(Color(.systemBackground))
                .cornerRadius(LeyhomeTheme.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.md)
                        .stroke(LeyhomeTheme.textMuted.opacity(0.3), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if content.isEmpty {
                        Text("node.text.label".localized)
                            .foregroundColor(LeyhomeTheme.textMuted)
                            .padding(.horizontal, LeyhomeTheme.Spacing.md)
                            .padding(.vertical, LeyhomeTheme.Spacing.md)
                            .allowsHitTesting(false)
                    }
                }

            HStack {
                Spacer()
                Text("\(content.count)/\(maxCharacters)")
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(content.count > maxCharacters ? LeyhomeTheme.danger : LeyhomeTheme.textMuted)
            }
        }
    }

    // MARK: - Photos Section

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(LeyhomeTheme.primary)
                Text("echo.photos".localized)
                    .font(LeyhomeTheme.Fonts.headline)
                    .foregroundColor(LeyhomeTheme.textPrimary)
                Spacer()
                Text("\(loadedImages.count)/\(maxPhotos)")
                    .font(LeyhomeTheme.Fonts.caption)
                    .foregroundColor(LeyhomeTheme.textMuted)
            }

            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80, maximum: 100), spacing: LeyhomeTheme.Spacing.sm)
            ], spacing: LeyhomeTheme.Spacing.sm) {
                ForEach(loadedImages.indices, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: loadedImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.sm))

                        Button {
                            removePhoto(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        .offset(x: 4, y: -4)
                    }
                }

                if loadedImages.count < maxPhotos {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: maxPhotos - loadedImages.count,
                        matching: .images
                    ) {
                        VStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                            Text("echo.add_photo".localized)
                                .font(LeyhomeTheme.Fonts.caption)
                        }
                        .foregroundColor(LeyhomeTheme.textMuted)
                        .frame(width: 80, height: 80)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: LeyhomeTheme.CornerRadius.sm))
                    }
                    .onChange(of: selectedPhotos) { _, newItems in
                        loadPhotos(newItems)
                    }
                }
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
    }

    // MARK: - Privacy Section

    private var privacySection: some View {
        VStack(spacing: LeyhomeTheme.Spacing.md) {
            Toggle(isOn: $isPublic) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("echo.visibility.public".localized)
                        .font(LeyhomeTheme.Fonts.body)
                        .foregroundColor(LeyhomeTheme.textPrimary)
                    Text("echo.visibility.public.hint".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textMuted)
                }
            }
            .tint(LeyhomeTheme.primary)

            if isPublic {
                Toggle(isOn: $isAnonymous) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("echo.anonymous".localized)
                            .font(LeyhomeTheme.Fonts.body)
                            .foregroundColor(LeyhomeTheme.textPrimary)
                        Text("echo.anonymous.hint".localized)
                            .font(LeyhomeTheme.Fonts.caption)
                            .foregroundColor(LeyhomeTheme.textMuted)
                    }
                }
                .tint(LeyhomeTheme.primary)
            }
        }
        .padding(LeyhomeTheme.Spacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
    }

    // MARK: - Actions

    private func loadPhotos(_ items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        loadedImages.append(image)
                    }
                }
            }
            await MainActor.run {
                selectedPhotos = []
            }
        }
    }

    private func removePhoto(at index: Int) {
        loadedImages.remove(at: index)
    }

    private func saveEcho() {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isLoading = true

        // Get current user ID
        let userId = authManager.currentUser?.id.uuidString ?? "anonymous"

        let echo = Echo(
            siteId: siteId,
            userId: userId,
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            isPublic: isPublic,
            isAnonymous: isAnonymous
        )

        // Set user info if available
        if let user = authManager.currentUser {
            echo.userNickname = user.userMetadata["full_name"]?.value as? String
            echo.userAvatarUrl = user.userMetadata["avatar_url"]?.value as? String
        }

        // TODO: Upload photos to storage and set mediaUrls
        // For now, we'll skip photo upload

        onSave(echo)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    EchoComposerView(siteId: UUID()) { echo in
        print("Saved echo: \(echo.content)")
    }
    .environmentObject(AuthManager())
}
