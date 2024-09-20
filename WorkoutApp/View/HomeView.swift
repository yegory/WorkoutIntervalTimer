//
//  HomeView.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-19.
//

import SwiftUI

struct HomeView: View {
    @State private var showMenu = false
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme // Detect light/dark mode
    @EnvironmentObject var timerModel: TimerModel

    var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $selectedTab) {
                    DashboardView()
                        .tag(0)
                    
                    TimerSetUpView() // Your desired dashboard view
                        .tag(1)
                    
                    Text("Performance")
                        .tag(2)
                    
                    Text("Exercises")
                        .tag(3)
                    
                    Text("Notifications")
                        .tag(4)
                }
                .background(colorScheme == .dark ? Color.black : Color.white) // Adaptive background
                
                SideMenuView(isShowing: $showMenu, selectedTab: $selectedTab)
            }
            .toolbar(showMenu ? .hidden : .visible, for: .navigationBar)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showMenu.toggle()
                    }, label: {
                        Image(systemName: "line.3.horizontal")
                    })
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
