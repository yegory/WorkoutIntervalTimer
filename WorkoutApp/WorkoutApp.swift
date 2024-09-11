//
//  WorkoutApp.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-02.
//

import SwiftUI

@main
struct WorkoutApp: App {
    // Since we're doing background fetching -> initializing here
    @StateObject var timerModel: TimerModel = .init()
    // Scene Phase
    @Environment(\.scenePhase) var phase
    // Storing Last Timestamp
    @State var lastActiveTimeStamp: Date = Date()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerModel)
        }
        .onChange(of: phase) { oldPhase, newPhase in
            if timerModel.isStarted {
                if newPhase == .background {
                    lastActiveTimeStamp = Date()
                }
                
                if newPhase == .active {
                    // Find the difference in time between when the app went to the background and when it became active again
                    let currentTimeStampDiff = Date().timeIntervalSince(lastActiveTimeStamp)
                    if timerModel.totalSeconds - Int(currentTimeStampDiff) <= 0 {
                        timerModel.isStarted = false
                        timerModel.totalSeconds = 0
                        timerModel.isFinished = true
                    } else {
                        timerModel.totalSeconds -= Int(currentTimeStampDiff)
                    }
                }
            }
        }
    }
}
