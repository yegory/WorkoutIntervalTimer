//
//  WorkoutApp.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-02.
//

import SwiftUI

@main
struct WorkoutApp: App {
//    @Environment(\.scenePhase) var phase
//    @State var lastActiveTimeStamp: Date = Date()
    
    var body: some Scene {
        WindowGroup {
            TimerSetUpView()
                .environmentObject(TimerModel())
        }
//        .onChange(of: phase) { newPhase in
//            if timerModel.isStarted {
//                if newPhase == .background {
//                    lastActiveTimeStamp = Date()
//                }
//                
//                if newPhase == .active {
//                    let currentTimeStampDiff = Date().timeIntervalSince(lastActiveTimeStamp)
//                    if timerModel.timeHandler.timeLeft - Int(currentTimeStampDiff) <= 0 {
//                        timerModel.isStarted = false
//                        timerModel.timeHandler.resetTime()
//                        timerModel.isFinished = true
//                    } else {
//                        timerModel.timeHandler.timeLeft -= Int(currentTimeStampDiff)
//                    }
//                }
//            }
//        }
    }
}
