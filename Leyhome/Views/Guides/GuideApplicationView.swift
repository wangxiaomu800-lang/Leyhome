//
//  GuideApplicationView.swift
//  Leyhome - 地脉归途
//
//  先行者申请表单
//
//  Created on 2026/02/06.
//

import SwiftUI
import SwiftData
import Supabase

struct GuideApplicationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthManager

    @State private var name = ""
    @State private var titleZh = ""
    @State private var titleEn = ""
    @State private var bioZh = ""
    @State private var bioEn = ""
    @State private var tagInput = ""
    @State private var tags: [String] = []

    @State private var showSuccess = false
    @State private var isSubmitting = false

    /// 最多 3 个标签
    private let maxTags = 3

    var body: some View {
        NavigationStack {
            Form {
                // 基本信息
                Section {
                    TextField("guide.application.name".localized, text: $name)
                } header: {
                    Text("guide.application.section.basic".localized)
                }

                // 中文信息
                Section {
                    TextField("guide.application.title".localized, text: $titleZh)
                    TextEditor(text: $bioZh)
                        .frame(minHeight: 80)
                } header: {
                    Text("guide.application.section.chinese".localized)
                }

                // 英文信息
                Section {
                    TextField("guide.application.title".localized, text: $titleEn)
                    TextEditor(text: $bioEn)
                        .frame(minHeight: 80)
                } header: {
                    Text("guide.application.section.english".localized)
                }

                // 擅长标签
                Section {
                    HStack {
                        TextField("guide.application.tag.placeholder".localized, text: $tagInput)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            addTag()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(tags.count < maxTags ? LeyhomeTheme.accent : LeyhomeTheme.textMuted)
                        }
                        .disabled(tags.count >= maxTags || tagInput.isEmpty)
                    }

                    if !tags.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Text(tag)
                                        .font(LeyhomeTheme.Fonts.caption)
                                    Button {
                                        removeTag(tag)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 12))
                                    }
                                }
                                .foregroundColor(LeyhomeTheme.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(LeyhomeTheme.primary.opacity(0.1))
                                .cornerRadius(LeyhomeTheme.CornerRadius.sm)
                            }
                        }
                    }
                } header: {
                    Text("guide.application.section.tags".localized)
                } footer: {
                    Text("guide.application.tags.hint".localized(with: maxTags))
                }

                // 提交说明
                Section {
                    Text("guide.application.note".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textSecondary)
                }
            }
            .navigationTitle("guide.application.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("button.cancel".localized) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        submitApplication()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("guide.application.submit".localized)
                        }
                    }
                    .disabled(!isFormValid || isSubmitting)
                }
            }
            .alert("guide.application.success.title".localized, isPresented: $showSuccess) {
                Button("button.ok".localized) {
                    dismiss()
                }
            } message: {
                Text("guide.application.success.message".localized)
            }
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !titleZh.trimmingCharacters(in: .whitespaces).isEmpty &&
        !titleEn.trimmingCharacters(in: .whitespaces).isEmpty &&
        !bioZh.trimmingCharacters(in: .whitespaces).isEmpty &&
        !bioEn.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Actions

    private func addTag() {
        let tag = tagInput.trimmingCharacters(in: .whitespaces)
        guard !tag.isEmpty, tags.count < maxTags, !tags.contains(tag) else { return }
        tags.append(tag)
        tagInput = ""
    }

    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    private func submitApplication() {
        guard let userId = authManager.currentUser?.id.uuidString else { return }

        isSubmitting = true

        let application = GuideApplication(
            userId: userId,
            name: name.trimmingCharacters(in: .whitespaces),
            titleZh: titleZh.trimmingCharacters(in: .whitespaces),
            titleEn: titleEn.trimmingCharacters(in: .whitespaces),
            bioZh: bioZh.trimmingCharacters(in: .whitespaces),
            bioEn: bioEn.trimmingCharacters(in: .whitespaces),
            tags: tags
        )

        modelContext.insert(application)

        do {
            try modelContext.save()
            isSubmitting = false
            showSuccess = true
        } catch {
            isSubmitting = false
            print("❌ 保存申请失败: \(error)")
        }
    }
}

#Preview {
    GuideApplicationView()
        .environmentObject(AuthManager())
}
