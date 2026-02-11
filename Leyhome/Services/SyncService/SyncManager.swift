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
import CoreLocation

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

// MARK: - Remote Decodable 结构体

/// Supabase journeys 表解码
struct RemoteJourney: Decodable {
    let id: UUID
    let userId: String
    let name: String
    let startTime: Date
    let endTime: Date?
    let transportMode: String
    let distance: Double
    let duration: Double
    let startLocation: LocationJSON?
    let endLocation: LocationJSON?
    let pathPoints: [LocationJSON]?
    let moodRecordIds: [UUID]?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, distance, duration
        case userId = "user_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case transportMode = "transport_mode"
        case startLocation = "start_location"
        case endLocation = "end_location"
        case pathPoints = "path_points"
        case moodRecordIds = "mood_record_ids"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Supabase mood_records 表解码
struct RemoteMoodRecord: Decodable {
    let id: UUID
    let userId: String
    let moodType: String
    let moodTypes: [String]?
    let intensity: Int
    let note: String?
    let recordTime: Date
    let location: LocationJSON?
    let locationName: String?
    let journeyId: UUID?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, intensity, note, location
        case userId = "user_id"
        case moodType = "mood_type"
        case moodTypes = "mood_types"
        case recordTime = "record_time"
        case locationName = "location_name"
        case journeyId = "journey_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// JSONB 坐标解码
struct LocationJSON: Codable {
    let latitude: Double
    let longitude: Double
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

    /// SwiftData ModelContainer（用于 pull 操作）
    private var modelContainer: ModelContainer?

    /// 共享 ISO8601 日期格式化器
    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

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

    /// 配置 ModelContainer（App 启动时调用）
    func configure(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
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

    // MARK: - 全量同步（离线队列）

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

    // MARK: - Journey 同步（推送）

    func syncJourney(_ journey: Journey) async {
        let payload = buildJourneyPayload(journey)

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
            print("[SyncManager] Journey synced: \(journey.id)")
        } catch {
            print("[SyncManager] Journey sync failed: \(error)")
            if let data = try? JSONEncoder().encode(payload) {
                enqueue(.journey, entityId: journey.id, action: .create, payload: data)
            }
        }
    }

    private func buildJourneyPayload(_ journey: Journey) -> [String: AnyJSON] {
        var payload: [String: AnyJSON] = [
            "id": .string(journey.id.uuidString),
            "user_id": .string(journey.userID),
            "name": .string(journey.name),
            "start_time": .string(isoFormatter.string(from: journey.startTime)),
            "end_time": journey.endTime.map { .string(isoFormatter.string(from: $0)) } ?? .null,
            "transport_mode": .string(journey.transportMode.rawValue),
            "distance": .double(journey.distance),
            "duration": .double(journey.duration),
            "mood_record_ids": .array(journey.moodRecordIDs.map { .string($0.uuidString) }),
            "created_at": .string(isoFormatter.string(from: journey.createdAt)),
            "updated_at": .string(isoFormatter.string(from: journey.updatedAt))
        ]

        // start_location JSONB
        if let loc = journey.startLocation {
            payload["start_location"] = .object([
                "latitude": .double(loc.latitude),
                "longitude": .double(loc.longitude)
            ])
        } else {
            payload["start_location"] = .null
        }

        // end_location JSONB
        if let loc = journey.endLocation {
            payload["end_location"] = .object([
                "latitude": .double(loc.latitude),
                "longitude": .double(loc.longitude)
            ])
        } else {
            payload["end_location"] = .null
        }

        // path_points JSONB 数组
        let points = journey.pathPoints
        if !points.isEmpty {
            payload["path_points"] = .array(points.map { coord in
                .object([
                    "latitude": .double(coord.latitude),
                    "longitude": .double(coord.longitude)
                ])
            })
        } else {
            payload["path_points"] = .null
        }

        return payload
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

    // MARK: - MoodRecord 同步（推送）

    func syncMoodRecord(_ record: MoodRecord) async {
        let payload = buildMoodRecordPayload(record)

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
            print("[SyncManager] MoodRecord synced: \(record.id)")
        } catch {
            print("[SyncManager] MoodRecord sync failed: \(error)")
            if let data = try? JSONEncoder().encode(payload) {
                enqueue(.moodRecord, entityId: record.id, action: .create, payload: data)
            }
        }
    }

    private func buildMoodRecordPayload(_ record: MoodRecord) -> [String: AnyJSON] {
        var payload: [String: AnyJSON] = [
            "id": .string(record.id.uuidString),
            "user_id": .string(record.userID),
            "mood_type": .string(record.moodType.rawValue),
            "mood_types": .array(record.moodTypes.map { .string($0.rawValue) }),
            "intensity": .integer(record.intensity),
            "note": record.note.map { .string($0) } ?? .null,
            "record_time": .string(isoFormatter.string(from: record.recordTime)),
            "location_name": record.locationName.map { .string($0) } ?? .null,
            "journey_id": record.journeyID.map { .string($0.uuidString) } ?? .null,
            "created_at": .string(isoFormatter.string(from: record.createdAt)),
            "updated_at": .string(isoFormatter.string(from: record.updatedAt))
        ]

        // location JSONB
        if let loc = record.location {
            payload["location"] = .object([
                "latitude": .double(loc.latitude),
                "longitude": .double(loc.longitude)
            ])
        } else {
            payload["location"] = .null
        }

        return payload
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

    // MARK: - Pull（从云端拉取到本地）

    /// 拉取所有数据（先 Journey 后 MoodRecord）
    func pullAll(userID: String) async {
        guard isOnline else { return }
        guard let container = modelContainer else {
            print("[SyncManager] pullAll skipped: modelContainer not configured")
            return
        }

        let context = ModelContext(container)
        await pullJourneys(userID: userID, context: context)
        await pullMoodRecords(userID: userID, context: context)

        do {
            try context.save()
            print("[SyncManager] pullAll completed for user \(userID)")
        } catch {
            print("[SyncManager] pullAll save failed: \(error)")
        }
    }

    private func pullJourneys(userID: String, context: ModelContext) async {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let remotes: [RemoteJourney] = try await supabase
                .from("journeys")
                .select()
                .eq("user_id", value: userID)
                .execute()
                .value

            // 获取所有本地 Journey
            let descriptor = FetchDescriptor<Journey>()
            let locals = (try? context.fetch(descriptor)) ?? []
            let localMap = Dictionary(uniqueKeysWithValues: locals.map { ($0.id, $0) })

            for remote in remotes {
                if let local = localMap[remote.id] {
                    // 存在 → updatedAt 大者胜
                    if remote.updatedAt > local.updatedAt {
                        applyRemoteJourney(remote, to: local)
                    }
                } else {
                    // 不存在 → 插入
                    let journey = createLocalJourney(from: remote)
                    context.insert(journey)
                }
            }

            print("[SyncManager] Pulled \(remotes.count) journeys")
        } catch {
            print("[SyncManager] pullJourneys failed: \(error)")
        }
    }

    private func pullMoodRecords(userID: String, context: ModelContext) async {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let remotes: [RemoteMoodRecord] = try await supabase
                .from("mood_records")
                .select()
                .eq("user_id", value: userID)
                .execute()
                .value

            // 获取所有本地 MoodRecord
            let descriptor = FetchDescriptor<MoodRecord>()
            let locals = (try? context.fetch(descriptor)) ?? []
            let localMap = Dictionary(uniqueKeysWithValues: locals.map { ($0.id, $0) })

            for remote in remotes {
                if let local = localMap[remote.id] {
                    if remote.updatedAt > local.updatedAt {
                        applyRemoteMoodRecord(remote, to: local)
                    }
                } else {
                    let record = createLocalMoodRecord(from: remote)
                    context.insert(record)
                }
            }

            print("[SyncManager] Pulled \(remotes.count) mood records")
        } catch {
            print("[SyncManager] pullMoodRecords failed: \(error)")
        }
    }

    // MARK: - Push（本地全量推送到云端）

    /// 推送所有本地数据到云端
    func pushAll(userID: String) async {
        guard isOnline else { return }
        guard let container = modelContainer else {
            print("[SyncManager] pushAll skipped: modelContainer not configured")
            return
        }

        let context = ModelContext(container)

        // 推送所有 Journey
        do {
            let descriptor = FetchDescriptor<Journey>()
            let journeys = (try? context.fetch(descriptor)) ?? []
            let userJourneys = journeys.filter { $0.userID == userID }
            for journey in userJourneys {
                await syncJourney(journey)
            }
            print("[SyncManager] Pushed \(userJourneys.count) journeys")
        }

        // 推送所有 MoodRecord
        do {
            let descriptor = FetchDescriptor<MoodRecord>()
            let records = (try? context.fetch(descriptor)) ?? []
            let userRecords = records.filter { $0.userID == userID }
            for record in userRecords {
                await syncMoodRecord(record)
            }
            print("[SyncManager] Pushed \(userRecords.count) mood records")
        }
    }

    // MARK: - Remote → Local 转换辅助

    private func applyRemoteJourney(_ remote: RemoteJourney, to local: Journey) {
        local.name = remote.name
        local.startTime = remote.startTime
        local.endTime = remote.endTime
        local.transportMode = TransportMode(rawValue: remote.transportMode) ?? .walking
        local.distance = remote.distance
        local.duration = remote.duration
        local.moodRecordIDs = remote.moodRecordIds ?? []
        local.updatedAt = remote.updatedAt

        if let loc = remote.startLocation {
            local.startLocation = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        }
        if let loc = remote.endLocation {
            local.endLocation = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        }
        if let pts = remote.pathPoints {
            local.pathPoints = pts.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        }
    }

    private func createLocalJourney(from remote: RemoteJourney) -> Journey {
        let journey = Journey(
            id: remote.id,
            userID: remote.userId,
            name: remote.name,
            startTime: remote.startTime,
            endTime: remote.endTime,
            transportMode: TransportMode(rawValue: remote.transportMode) ?? .walking,
            distance: remote.distance,
            duration: remote.duration,
            moodRecordIDs: remote.moodRecordIds ?? []
        )
        journey.createdAt = remote.createdAt
        journey.updatedAt = remote.updatedAt

        if let loc = remote.startLocation {
            journey.startLocation = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        }
        if let loc = remote.endLocation {
            journey.endLocation = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        }
        if let pts = remote.pathPoints {
            journey.pathPoints = pts.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        }
        return journey
    }

    private func applyRemoteMoodRecord(_ remote: RemoteMoodRecord, to local: MoodRecord) {
        local.moodType = MoodType(rawValue: remote.moodType) ?? .calm
        if let types = remote.moodTypes {
            local.moodTypes = types.compactMap { MoodType(rawValue: $0) }
        }
        local.intensity = remote.intensity
        local.note = remote.note
        local.recordTime = remote.recordTime
        local.locationName = remote.locationName
        local.journeyID = remote.journeyId
        local.updatedAt = remote.updatedAt

        if let loc = remote.location {
            local.location = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        }
    }

    private func createLocalMoodRecord(from remote: RemoteMoodRecord) -> MoodRecord {
        let moodTypes = remote.moodTypes?.compactMap { MoodType(rawValue: $0) }
        let record = MoodRecord(
            id: remote.id,
            userID: remote.userId,
            moodType: MoodType(rawValue: remote.moodType) ?? .calm,
            moodTypes: moodTypes,
            intensity: remote.intensity,
            note: remote.note,
            recordTime: remote.recordTime,
            journeyID: remote.journeyId,
            locationName: remote.locationName
        )
        record.createdAt = remote.createdAt
        record.updatedAt = remote.updatedAt

        if let loc = remote.location {
            record.location = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        }
        return record
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
            "created_at": .string(isoFormatter.string(from: echo.createdAt)),
            "updated_at": .string(isoFormatter.string(from: echo.updatedAt))
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
