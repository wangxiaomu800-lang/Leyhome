//
//  SyncManager.swift
//  Leyhome - 地脉归途
//
//  数据同步管理器 - 负责 SwiftData ↔ Supabase 双向同步
//
//  Created on 2026/02/05.
//

import Foundation
import SwiftUI
import SwiftData
import Network
import Supabase
import Combine

// MARK: - 离线队列模型

/// 待同步变更
struct PendingChange: Codable, Identifiable {
    let id: UUID
    let entityType: EntityType
    let entityId: UUID
    let action: ChangeAction
    let payload: Data?
    let createdAt: Date

    enum EntityType: String, Codable {
        case journey
        case moodRecord
        case echo
    }

    enum ChangeAction: String, Codable {
        case create
        case update
        case delete
    }
}

// MARK: - SyncManager

@MainActor
class SyncManager: ObservableObject {
    static let shared = SyncManager()

    // MARK: - Published

    @Published var isSyncing = false
    @Published var isOnline = true
    @Published var lastSyncTime: Date?
    @Published var pendingChangesCount = 0

    // MARK: - Private

    private let supabase = SupabaseConfig.shared
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.leyhome.networkMonitor")
    private let pendingKey = "com.leyhome.pendingChanges"

    /// 离线队列
    private var pendingChanges: [PendingChange] = [] {
        didSet {
            pendingChangesCount = pendingChanges.count
            savePendingChanges()
        }
    }

    // MARK: - Init

    private init() {
        loadPendingChanges()
        startNetworkMonitoring()
    }

    // MARK: - 网络监控

    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                let wasOffline = self?.isOnline == false
                self?.isOnline = path.status == .satisfied

                // 从离线恢复在线时，自动同步
                if wasOffline && path.status == .satisfied {
                    await self?.syncAll()
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }

    // MARK: - 离线队列持久化

    private func savePendingChanges() {
        if let data = try? JSONEncoder().encode(pendingChanges) {
            UserDefaults.standard.set(data, forKey: pendingKey)
        }
    }

    private func loadPendingChanges() {
        guard let data = UserDefaults.standard.data(forKey: pendingKey),
              let changes = try? JSONDecoder().decode([PendingChange].self, from: data) else {
            return
        }
        pendingChanges = changes
    }

    // MARK: - 入队

    func enqueue(_ entityType: PendingChange.EntityType, entityId: UUID, action: PendingChange.ChangeAction, payload: Data? = nil) {
        let change = PendingChange(
            id: UUID(),
            entityType: entityType,
            entityId: entityId,
            action: action,
            payload: payload,
            createdAt: Date()
        )
        pendingChanges.append(change)

        // 在线时立即尝试同步
        if isOnline {
            Task { await syncAll() }
        }
    }

    // MARK: - 全量同步

    func syncAll() async {
        guard isOnline, !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        // 处理离线队列
        var remaining: [PendingChange] = []
        for change in pendingChanges {
            do {
                try await processChange(change)
            } catch {
                print("[SyncManager] Failed to sync change \(change.id): \(error)")
                remaining.append(change)
            }
        }
        pendingChanges = remaining
        lastSyncTime = Date()
    }

    // MARK: - 处理单条变更

    private func processChange(_ change: PendingChange) async throws {
        switch change.entityType {
        case .journey:
            try await syncJourneyChange(change)
        case .moodRecord:
            try await syncMoodRecordChange(change)
        case .echo:
            try await syncEchoChange(change)
        }
    }

    // MARK: - Journey 同步

    func syncJourney(_ journey: Journey) async {
        let payload: [String: AnyJSON] = [
            "id": .string(journey.id.uuidString),
            "user_id": .string(journey.userID),
            "name": .string(journey.name),
            "start_time": .string(ISO8601DateFormatter().string(from: journey.startTime)),
            "end_time": journey.endTime.map { .string(ISO8601DateFormatter().string(from: $0)) } ?? .null,
            "transport_mode": .string(journey.transportMode.rawValue),
            "distance": .double(journey.distance),
            "duration": .double(journey.duration),
            "created_at": .string(ISO8601DateFormatter().string(from: journey.createdAt))
        ]

        guard isOnline else {
            if let data = try? JSONEncoder().encode(payload) {
                enqueue(.journey, entityId: journey.id, action: .create, payload: data)
            }
            return
        }

        do {
            try await supabase
                .from("journeys")
                .upsert(payload)
                .execute()
        } catch {
            print("[SyncManager] Journey sync failed: \(error)")
            if let data = try? JSONEncoder().encode(payload) {
                enqueue(.journey, entityId: journey.id, action: .create, payload: data)
            }
        }
    }

    private func syncJourneyChange(_ change: PendingChange) async throws {
        guard let data = change.payload else { return }
        let payload = try JSONDecoder().decode([String: AnyJSON].self, from: data)

        switch change.action {
        case .create, .update:
            try await supabase
                .from("journeys")
                .upsert(payload)
                .execute()
        case .delete:
            try await supabase
                .from("journeys")
                .delete()
                .eq("id", value: change.entityId.uuidString)
                .execute()
        }
    }

    // MARK: - MoodRecord 同步

    func syncMoodRecord(_ record: MoodRecord) async {
        let payload: [String: AnyJSON] = [
            "id": .string(record.id.uuidString),
            "user_id": .string(record.userID),
            "mood_type": .string(record.moodType.rawValue),
            "intensity": .integer(record.intensity),
            "note": record.note.map { .string($0) } ?? .null,
            "record_time": .string(ISO8601DateFormatter().string(from: record.recordTime)),
            "location_name": record.locationName.map { .string($0) } ?? .null,
            "journey_id": record.journeyID.map { .string($0.uuidString) } ?? .null,
            "created_at": .string(ISO8601DateFormatter().string(from: record.createdAt))
        ]

        guard isOnline else {
            if let data = try? JSONEncoder().encode(payload) {
                enqueue(.moodRecord, entityId: record.id, action: .create, payload: data)
            }
            return
        }

        do {
            try await supabase
                .from("mood_records")
                .upsert(payload)
                .execute()
        } catch {
            print("[SyncManager] MoodRecord sync failed: \(error)")
            if let data = try? JSONEncoder().encode(payload) {
                enqueue(.moodRecord, entityId: record.id, action: .create, payload: data)
            }
        }
    }

    private func syncMoodRecordChange(_ change: PendingChange) async throws {
        guard let data = change.payload else { return }
        let payload = try JSONDecoder().decode([String: AnyJSON].self, from: data)

        switch change.action {
        case .create, .update:
            try await supabase
                .from("mood_records")
                .upsert(payload)
                .execute()
        case .delete:
            try await supabase
                .from("mood_records")
                .delete()
                .eq("id", value: change.entityId.uuidString)
                .execute()
        }
    }

    // MARK: - Echo 同步

    func syncEcho(_ echo: Echo) async {
        let payload: [String: AnyJSON] = [
            "id": .string(echo.id.uuidString),
            "site_id": .string(echo.siteId.uuidString),
            "user_id": .string(echo.userId),
            "user_nickname": echo.userNickname.map { .string($0) } ?? .null,
            "content": .string(echo.content),
            "is_public": .bool(echo.isPublic),
            "is_anonymous": .bool(echo.isAnonymous),
            "created_at": .string(ISO8601DateFormatter().string(from: echo.createdAt)),
            "updated_at": .string(ISO8601DateFormatter().string(from: echo.updatedAt))
        ]

        guard isOnline else {
            if let data = try? JSONEncoder().encode(payload) {
                enqueue(.echo, entityId: echo.id, action: .create, payload: data)
            }
            return
        }

        do {
            try await supabase
                .from("echoes")
                .upsert(payload)
                .execute()
        } catch {
            print("[SyncManager] Echo sync failed: \(error)")
            if let data = try? JSONEncoder().encode(payload) {
                enqueue(.echo, entityId: echo.id, action: .create, payload: data)
            }
        }
    }

    private func syncEchoChange(_ change: PendingChange) async throws {
        guard let data = change.payload else { return }
        let payload = try JSONDecoder().decode([String: AnyJSON].self, from: data)

        switch change.action {
        case .create, .update:
            try await supabase
                .from("echoes")
                .upsert(payload)
                .execute()
        case .delete:
            try await supabase
                .from("echoes")
                .delete()
                .eq("id", value: change.entityId.uuidString)
                .execute()
        }
    }

    // MARK: - 拉取圣迹数据

    struct RemoteSacredSite: Decodable {
        let id: UUID
        let tier: Int
        let nameZh: String
        let nameEn: String
        let descriptionZh: String
        let descriptionEn: String
        let loreZh: String
        let loreEn: String
        let historyZh: String?
        let historyEn: String?
        let latitude: Double
        let longitude: Double
        let continent: String
        let country: String
        let region: String?
        let imageUrl: String?
        let visitorCount: Int
        let echoCount: Int
        let intentionCount: Int
        let createdAt: String

        enum CodingKeys: String, CodingKey {
            case id, tier, latitude, longitude, continent, country, region
            case nameZh = "name_zh"
            case nameEn = "name_en"
            case descriptionZh = "description_zh"
            case descriptionEn = "description_en"
            case loreZh = "lore_zh"
            case loreEn = "lore_en"
            case historyZh = "history_zh"
            case historyEn = "history_en"
            case imageUrl = "image_url"
            case visitorCount = "visitor_count"
            case echoCount = "echo_count"
            case intentionCount = "intention_count"
            case createdAt = "created_at"
        }
    }

    func fetchSacredSites() async -> [RemoteSacredSite] {
        guard isOnline else { return [] }

        do {
            let sites: [RemoteSacredSite] = try await supabase
                .from("sacred_sites")
                .select()
                .execute()
                .value
            return sites
        } catch {
            print("[SyncManager] Fetch sacred sites failed: \(error)")
            return []
        }
    }

    // MARK: - Cleanup

    deinit {
        monitor.cancel()
    }
}
