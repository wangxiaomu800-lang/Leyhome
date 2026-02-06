//
//  StorageService.swift
//  Leyhome - 地脉归途
//
//  文件上传服务 - 图片/音频上传到 Supabase Storage
//
//  Created on 2026/02/05.
//

import Foundation
import UIKit
import Supabase

@MainActor
class StorageService {
    static let shared = StorageService()

    private let supabase = SupabaseConfig.shared
    private let bucketName = "media"

    private init() {}

    // MARK: - 上传单张图片

    /// 上传图片到 Supabase Storage
    /// - Parameters:
    ///   - image: UIImage 对象
    ///   - path: 存储路径（如 "users/{userId}/photos/{filename}.jpg"）
    ///   - compressionQuality: JPEG 压缩质量 (0.0 - 1.0)
    /// - Returns: 公开 URL 字符串
    func uploadImage(_ image: UIImage, path: String, compressionQuality: CGFloat = 0.7) async throws -> String {
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            throw StorageError.compressionFailed
        }

        let filePath = sanitizePath(path)

        try await supabase.storage
            .from(bucketName)
            .upload(
                filePath,
                data: data,
                options: FileOptions(contentType: "image/jpeg", upsert: true)
            )

        let publicURL = try supabase.storage
            .from(bucketName)
            .getPublicURL(path: filePath)

        return publicURL.absoluteString
    }

    // MARK: - 批量上传图片

    /// 批量上传图片
    /// - Parameters:
    ///   - images: UIImage 数组
    ///   - basePath: 基础路径（如 "users/{userId}/photos"）
    /// - Returns: 公开 URL 数组
    func uploadImages(_ images: [UIImage], basePath: String) async throws -> [String] {
        var urls: [String] = []

        for (index, image) in images.enumerated() {
            let filename = "\(UUID().uuidString.prefix(8))_\(index).jpg"
            let path = "\(basePath)/\(filename)"
            let url = try await uploadImage(image, path: path)
            urls.append(url)
        }

        return urls
    }

    // MARK: - 上传音频

    /// 上传音频文件到 Supabase Storage
    /// - Parameters:
    ///   - fileURL: 本地音频文件 URL
    ///   - path: 存储路径
    /// - Returns: 公开 URL 字符串
    func uploadAudio(from fileURL: URL, path: String) async throws -> String {
        let data = try Data(contentsOf: fileURL)
        let filePath = sanitizePath(path)

        let contentType: String
        switch fileURL.pathExtension.lowercased() {
        case "m4a":
            contentType = "audio/mp4"
        case "mp3":
            contentType = "audio/mpeg"
        case "wav":
            contentType = "audio/wav"
        case "caf":
            contentType = "audio/x-caf"
        default:
            contentType = "audio/mp4"
        }

        try await supabase.storage
            .from(bucketName)
            .upload(
                filePath,
                data: data,
                options: FileOptions(contentType: contentType, upsert: true)
            )

        let publicURL = try supabase.storage
            .from(bucketName)
            .getPublicURL(path: filePath)

        return publicURL.absoluteString
    }

    // MARK: - 删除文件

    /// 删除 Storage 中的文件
    func deleteFile(path: String) async throws {
        try await supabase.storage
            .from(bucketName)
            .remove(paths: [sanitizePath(path)])
    }

    // MARK: - Helpers

    private func sanitizePath(_ path: String) -> String {
        path.replacingOccurrences(of: "//", with: "/")
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}

// MARK: - Errors

enum StorageError: LocalizedError {
    case compressionFailed
    case uploadFailed(String)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "图片压缩失败"
        case .uploadFailed(let reason):
            return "上传失败: \(reason)"
        case .invalidURL:
            return "无效的文件 URL"
        }
    }
}
