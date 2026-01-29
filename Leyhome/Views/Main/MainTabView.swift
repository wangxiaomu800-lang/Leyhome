//
//  MainTabView.swift
//  Leyhome - 地脉归途
//
//  Created on 2026/01/26.
//  Updated on 2026/01/29: 添加旅程 Tab
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("tab.map".localized)
                }
                .tag(0)

            JourneyListView()
                .tabItem {
                    Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
                    Text("tab.journeys".localized)
                }
                .tag(1)

            SacredSitesView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("tab.sacred_sites".localized)
                }
                .tag(2)

            GuidesView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("tab.guides".localized)
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("tab.profile".localized)
                }
                .tag(4)
        }
        .tint(LeyhomeTheme.primary)
    }
}

#Preview {
    MainTabView()
}
