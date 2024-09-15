//
//  WorkoutApp.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-02.
//

import SwiftUI
import BackgroundTasks

@main
struct WorkoutApp: App {
    @StateObject var timerModel: TimerModel = .init()
    @Environment(\.scenePhase) var phase
    @State var lastActiveTimeStamp: Date = Date()
    
    private let taskIdentifier: String = "com.yegor.WorkoutApp.timerTask"

    var body: some Scene {
        WindowGroup {
            TimerSetUpView()
                .environmentObject(timerModel)  // Use the @StateObject instance
        }
        .onChange(of: phase) { oldPhase, newPhase in
            if newPhase == .background {
                // If the app goes into the background, cancel the timer start
                if !timerModel.isStarted {
                    timerModel.cancelPendingTimerStart()
                }
            } else if newPhase == .active {
                // Handle returning to the foreground if necessary
            }
        }
    }

    // Handle changes in app lifecycle (foreground, background, inactive)
    private func handleAppLifecycleChange(newPhase: ScenePhase) {
        if timerModel.isStarted {
            switch newPhase {
            case .background:
                timerModel.isPaused = true
                timerModel.stopwatch.pause()
                lastActiveTimeStamp = Date()
                startBackgroundTask()  // Register a background task when going into background

            case .active:
                timerModel.isPaused = false
                timerModel.stopwatch.resume()
                adjustTimersAfterBackground()
                stopBackgroundTask()  // Stop background task when back to foreground

            default:
                break
            }
        }
    }

    // Adjust the timers after returning from background
    private func adjustTimersAfterBackground() {
        let currentTimeStampDiff = Date().timeIntervalSince(lastActiveTimeStamp)
        
        // Adjust the remaining time for the current set
        var newTimeLeft = timerModel.timeLeft - Int(currentTimeStampDiff)
        
        // If the time left is negative, adjust across sets
        while newTimeLeft <= 0 && timerModel.currentSet < timerModel.numberOfSets {
            newTimeLeft += timerModel.secondsPerSet
            timerModel.currentSet += 1
        }

        // Check if all sets are completed
        if timerModel.currentSet >= timerModel.numberOfSets && newTimeLeft <= 0 {
            timerModel.isStarted = false
            timerModel.isPaused = true
            timerModel.isFinished = true
        } else {
            // Update the remaining time for the current set
            timerModel.timeLeft = newTimeLeft
        }
        
        // Adjust the stopwatch (add the time difference to the total elapsed time)
        timerModel.stopwatch.elapsedTime += Int(currentTimeStampDiff)
    }

    // Register background task to ensure app is woken up when necessary
    private func startBackgroundTask() {
        // Register a background task with the system
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleBackgroundTask(task: task as! BGProcessingTask)
        }

        scheduleBackgroundTask()
    }

    // Schedule the background task
    private func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: taskIdentifier)
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }

    // Handle the background task
    private func handleBackgroundTask(task: BGProcessingTask) {
        // Perform any background updates if necessary
        adjustTimersAfterBackground()

        // Mark task complete
        task.setTaskCompleted(success: true)
    }

    // Stop background task when returning to foreground
    private func stopBackgroundTask() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
}
