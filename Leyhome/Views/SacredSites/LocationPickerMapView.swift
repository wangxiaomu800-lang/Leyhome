//
//  LocationPickerMapView.swift
//  Leyhome - 地脉归途
//
//  可复用地图选点组件 - 长按放置标记或使用当前位置
//
//  Created on 2026/02/03.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationPickerMapView: View {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @StateObject private var trackingManager = TrackingManager.shared

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var pinCoordinate: CLLocationCoordinate2D?

    var body: some View {
        VStack(spacing: LeyhomeTheme.Spacing.sm) {
            // Map
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    if let pin = pinCoordinate {
                        Marker("location_picker.pin".localized, coordinate: pin)
                            .tint(LeyhomeTheme.primary)
                    }
                }
                .mapStyle(.standard)
                .frame(height: 240)
                .cornerRadius(LeyhomeTheme.CornerRadius.md)
                .gesture(
                    LongPressGesture(minimumDuration: 0.3)
                        .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                        .onEnded { value in
                            switch value {
                            case .second(true, let drag):
                                if let location = drag?.location,
                                   let coordinate = proxy.convert(location, from: .local) {
                                    withAnimation(.spring(response: 0.3)) {
                                        pinCoordinate = coordinate
                                        selectedCoordinate = coordinate
                                    }
                                }
                            default:
                                break
                            }
                        }
                )
            }

            // Coordinate display & current location button
            HStack {
                if let coord = pinCoordinate {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(LeyhomeTheme.primary)
                        Text(String(format: "%.4f, %.4f", coord.latitude, coord.longitude))
                            .font(LeyhomeTheme.Fonts.caption)
                            .foregroundColor(LeyhomeTheme.textSecondary)
                    }
                } else {
                    Text("location_picker.hint".localized)
                        .font(LeyhomeTheme.Fonts.caption)
                        .foregroundColor(LeyhomeTheme.textMuted)
                }

                Spacer()

                Button {
                    useCurrentLocation()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                        Text("location_picker.use_current".localized)
                            .font(LeyhomeTheme.Fonts.caption)
                    }
                    .foregroundColor(LeyhomeTheme.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(LeyhomeTheme.primary.opacity(0.1))
                    .cornerRadius(LeyhomeTheme.CornerRadius.sm)
                }
            }
        }
        .onAppear {
            if let loc = trackingManager.currentLocation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: loc.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                ))
            }
        }
    }

    private func useCurrentLocation() {
        guard let loc = trackingManager.currentLocation else { return }
        let coord = loc.coordinate
        withAnimation(.spring(response: 0.3)) {
            pinCoordinate = coord
            selectedCoordinate = coord
            cameraPosition = .region(MKCoordinateRegion(
                center: coord,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            ))
        }
    }
}
