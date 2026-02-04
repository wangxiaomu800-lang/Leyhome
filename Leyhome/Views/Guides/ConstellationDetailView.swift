//
//  ConstellationDetailView.swift
//  Leyhome - 地脉归途
//
//  星图详情 + 地图连线 + 节点列表
//
//  Created on 2026/02/04.
//

import SwiftUI
import MapKit

struct ConstellationDetailView: View {
    let constellation: Constellation
    let guide: Guide
    @State private var nodes: [ConstellationNode] = []
    @State private var showResonanceMode = false
    @State private var selectedNode: ConstellationNode?

    var body: some View {
        ScrollView {
            VStack(spacing: LeyhomeTheme.Spacing.lg) {
                // 星图可视化（星座连线）
                ConstellationMapView(nodes: nodes, selectedNode: $selectedNode)
                    .frame(height: 300)
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)

                // 星图信息
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
                    Text(constellation.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(constellation.constellationDescription)
                        .font(.body)
                        .foregroundColor(.secondary)

                    // 先行者信息
                    HStack {
                        AsyncImage(url: URL(string: guide.avatarUrl ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Circle().fill(Color(.systemGray6))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.caption)
                                        .foregroundColor(Color(.systemGray3))
                                )
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text("guides.created_by".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(guide.name)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.horizontal)

                // 节点预览列表
                VStack(alignment: .leading, spacing: LeyhomeTheme.Spacing.md) {
                    Text("guides.nodes".localized)
                        .font(.headline)

                    ForEach(nodes.sorted(by: { $0.order < $1.order })) { node in
                        NodePreviewRow(node: node, isSelected: selectedNode?.id == node.id) {
                            selectedNode = node
                        }
                    }
                }
                .padding(.horizontal)

                // 开始共鸣行走按钮
                Button(action: { showResonanceMode = true }) {
                    HStack {
                        Image(systemName: "figure.walk")
                        Text("guides.start_resonance".localized)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LeyhomeTheme.primary)
                    .cornerRadius(LeyhomeTheme.CornerRadius.md)
                }
                .padding()
            }
        }
        .navigationTitle("guides.constellation".localized)
        .fullScreenCover(isPresented: $showResonanceMode) {
            ResonanceWalkView(constellation: constellation, nodes: nodes, guide: guide)
        }
        .onAppear {
            nodes = GuideData.loadNodes(for: constellation)
        }
    }
}

// MARK: - ConstellationMapView

struct ConstellationMapView: View {
    let nodes: [ConstellationNode]
    @Binding var selectedNode: ConstellationNode?

    var body: some View {
        Map {
            // 连线（星图效果）
            if nodes.count >= 2 {
                let coordinates = nodes.sorted(by: { $0.order < $1.order }).map { $0.coordinate }
                MapPolyline(coordinates: coordinates)
                    .stroke(LeyhomeTheme.starlight.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
            }

            // 节点标记
            ForEach(nodes) { node in
                Annotation("", coordinate: node.coordinate) {
                    ConstellationNodeMarker(
                        order: node.order,
                        isSelected: selectedNode?.id == node.id
                    )
                    .onTapGesture {
                        selectedNode = node
                    }
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
    }
}

// MARK: - ConstellationNodeMarker

struct ConstellationNodeMarker: View {
    let order: Int
    let isSelected: Bool

    var body: some View {
        ZStack {
            // 光晕
            Circle()
                .fill(LeyhomeTheme.starlight.opacity(0.3))
                .frame(width: 40, height: 40)
                .scaleEffect(isSelected ? 1.5 : 1.0)

            // 主体
            Circle()
                .fill(isSelected ? LeyhomeTheme.accent : LeyhomeTheme.starlight)
                .frame(width: 24, height: 24)

            Text("\(order)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - NodePreviewRow

struct NodePreviewRow: View {
    let node: ConstellationNode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: LeyhomeTheme.Spacing.md) {
                // 序号
                ZStack {
                    Circle()
                        .fill(isSelected ? LeyhomeTheme.primary : Color(.systemGray6))
                        .frame(width: 32, height: 32)
                    Text("\(node.order)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    if let title = node.nodeTitle {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    Text(node.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if node.audioUrl != nil {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption)
                        .foregroundColor(LeyhomeTheme.primary)
                }
            }
            .padding()
            .background(isSelected ? LeyhomeTheme.primary.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(LeyhomeTheme.CornerRadius.sm)
        }
        .buttonStyle(.plain)
    }
}
