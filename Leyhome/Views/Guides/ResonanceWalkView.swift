//
//  ResonanceWalkView.swift
//  Leyhome - 地脉归途
//
//  共鸣行走全屏模式
//
//  Created on 2026/02/04.
//

import SwiftUI
import MapKit
import AVFoundation
import CoreLocation
import Combine

struct ResonanceWalkView: View {
    let constellation: Constellation
    let nodes: [ConstellationNode]
    let guide: Guide

    @Environment(\.dismiss) var dismiss
    @ObservedObject private var trackingManager = TrackingManager.shared
    @StateObject private var audioPlayer = AudioPlayerManager()

    @State private var currentNodeIndex = 0
    @State private var isWalking = false
    @State private var showNodeContent = false
    @State private var reachedNodes: Set<UUID> = []
    @State private var showReflection = false

    private let proximityThreshold: Double = 50 // 米

    var body: some View {
        ZStack {
            // 地图层
            Map {
                UserAnnotation()

                // 先行者的"光之路"
                if nodes.count >= 2 {
                    let coordinates = nodes.sorted(by: { $0.order < $1.order }).map { $0.coordinate }
                    MapPolyline(coordinates: coordinates)
                        .stroke(LeyhomeTheme.starlight, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                }

                // 节点标记
                ForEach(nodes) { node in
                    Annotation("", coordinate: node.coordinate) {
                        ResonanceNodeMarker(
                            order: node.order,
                            isReached: reachedNodes.contains(node.id),
                            isCurrent: nodes[safe: currentNodeIndex]?.id == node.id
                        )
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))

            // 顶部控制栏
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }

                    Spacer()

                    // 进度指示
                    Text("\(reachedNodes.count)/\(nodes.count)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                }
                .padding()

                Spacer()

                // 底部内容卡片
                if let currentNode = nodes[safe: currentNodeIndex] {
                    ResonanceContentCard(
                        node: currentNode,
                        guide: guide,
                        isNearby: isNearNode(currentNode),
                        audioPlayer: audioPlayer
                    )
                    .transition(.move(edge: .bottom))
                }
            }

            // 到达节点时的浮层
            if showNodeContent, let node = nodes[safe: currentNodeIndex] {
                NodeArrivalOverlay(
                    node: node,
                    guide: guide,
                    onContinue: {
                        showNodeContent = false
                        moveToNextNode()
                    }
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            trackingManager.requestAuthorization()
            trackingManager.startLocationUpdates()
        }
        .onDisappear {
            trackingManager.stopLocationUpdates()
        }
        .onReceive(trackingManager.$currentLocation) { location in
            if let location = location {
                checkProximity(location)
            }
        }
        .fullScreenCover(isPresented: $showReflection) {
            ReflectionView(constellation: constellation, guide: guide) {
                dismiss()
            }
        }
    }

    // MARK: - Private Methods

    private func isNearNode(_ node: ConstellationNode) -> Bool {
        guard let location = trackingManager.currentLocation else { return false }
        let nodeLocation = CLLocation(latitude: node.latitude, longitude: node.longitude)
        return location.distance(from: nodeLocation) < proximityThreshold
    }

    private func checkProximity(_ location: CLLocation) {
        guard let currentNode = nodes[safe: currentNodeIndex],
              !reachedNodes.contains(currentNode.id) else { return }

        let nodeLocation = CLLocation(latitude: currentNode.latitude, longitude: currentNode.longitude)
        let distance = location.distance(from: nodeLocation)

        if distance < proximityThreshold {
            // 到达节点
            reachedNodes.insert(currentNode.id)

            // 播放音频
            if let audioUrl = currentNode.audioUrl {
                audioPlayer.play(url: audioUrl)
            }

            // 显示内容
            withAnimation {
                showNodeContent = true
            }

            // 触觉反馈
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func moveToNextNode() {
        if currentNodeIndex < nodes.count - 1 {
            currentNodeIndex += 1
        } else {
            // 完成所有节点，进入强制反思
            showReflection = true
        }
    }
}

// MARK: - ResonanceNodeMarker

struct ResonanceNodeMarker: View {
    let order: Int
    let isReached: Bool
    let isCurrent: Bool

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // 脉冲效果（当前节点）
            if isCurrent && !isReached {
                Circle()
                    .stroke(LeyhomeTheme.accent, lineWidth: 2)
                    .frame(width: 50, height: 50)
                    .scaleEffect(pulseScale)
                    .opacity(2 - pulseScale)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                            pulseScale = 2.0
                        }
                    }
            }

            Circle()
                .fill(isReached ? Color.green : (isCurrent ? LeyhomeTheme.accent : LeyhomeTheme.starlight))
                .frame(width: 30, height: 30)

            if isReached {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            } else {
                Text("\(order)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - ResonanceContentCard

struct ResonanceContentCard: View {
    let node: ConstellationNode
    let guide: Guide
    let isNearby: Bool
    let audioPlayer: AudioPlayerManager

    var body: some View {
        VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.sm) {
            HStack {
                AsyncImage(url: URL(string: guide.avatarUrl ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(Color(.systemGray6))
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(guide.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("guides.says".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 距离提示
                if !isNearby {
                    Text("guides.approach".localized)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            if isNearby {
                Text(node.content)
                    .font(.body)
                    .lineSpacing(4)

                if node.audioUrl != nil {
                    Button(action: {
                        if audioPlayer.isPlaying {
                            audioPlayer.stop()
                        } else {
                            audioPlayer.play(url: node.audioUrl!)
                        }
                    }) {
                        HStack {
                            Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            Text(audioPlayer.isPlaying ? "guides.pause".localized : "guides.listen".localized)
                        }
                        .font(.subheadline)
                        .foregroundColor(LeyhomeTheme.primary)
                    }
                }
            } else {
                Text("guides.content_locked".localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(LeyhomeTheme.CornerRadius.md)
        .padding()
    }
}

// MARK: - NodeArrivalOverlay

struct NodeArrivalOverlay: View {
    let node: ConstellationNode
    let guide: Guide
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: LeyhomeTheme.Spacing.lg) {
                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .foregroundColor(LeyhomeTheme.accent)

                Text("guides.arrived".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(node.content)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: onContinue) {
                    Text("guides.continue".localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LeyhomeTheme.primary)
                        .cornerRadius(LeyhomeTheme.CornerRadius.md)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

// MARK: - AudioPlayerManager

class AudioPlayerManager: ObservableObject {
    @Published var isPlaying = false

    func play(url: String) {
        // TODO: 实现实际的音频播放
        isPlaying = true
    }

    func stop() {
        isPlaying = false
    }
}

// MARK: - Array Safe Subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
