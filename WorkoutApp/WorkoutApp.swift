//
//  WorkoutApp.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-02.
//

import SwiftUI

@main
struct WorkoutApp: App {
    @StateObject var timerLifecycleHandler = TimerLifecycleHandler()
    @Environment(\.scenePhase) var phase

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(timerLifecycleHandler.timerModel)
                .onAppear {
                    timerLifecycleHandler.clearUserDefaults()
                }
                .preferredColorScheme(.dark) // Uncomment to force dark mode
        }
        .onChange(of: phase) { newPhase in
            timerLifecycleHandler.handleTimerLifecycleHandler(newPhase: newPhase)
        }
        
    }
}
