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
    
    private let taskIdentifier: String = "com.yegor.WorkoutApp.timerTask"

    var body: some Scene {
        WindowGroup {
            
            TimerSetUpView()
                .environmentObject(timerModel)  // Use the @StateObject instance
                .onAppear {
                    clearUserDefaults()
                }
        }
        .onChange(of: phase) { newPhase in
            handleAppLifecycleChange(newPhase: newPhase)
        }
        
    }
    
    // Function to clear UserDefaults
    // This is particularly useful when encountering bug where opening and closing app
    // on timerModel.start() too quickly
    private func clearUserDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }

    // Handle changes in app lifecycle (foreground, background; inactive goes into default)
    private func handleAppLifecycleChange(newPhase: ScenePhase) {
        if timerModel.isStarted {
            switch newPhase {
                case .background:
                    saveTimerState()  // Save the state before going to background
                    startBackgroundTask()

                case .active:
                    restoreTimerState()  // Restore state when becoming active again
                    stopBackgroundTask()

                default:
                    break
            }
        }
        else if !timerModel.isStarted && newPhase == .background{
            timerModel.cancelPendingTimerStart()
            saveTimerState()  // Save the state before going to background
            startBackgroundTask()
        }
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
//            print("Could not schedule background task: \(error)")
        }
    }

    // Handle the background task
    private func handleBackgroundTask(task: BGProcessingTask) {
        // Perform any background updates if necessary
        adjustTimersAfterBackground(pausedSince: Date(), updateTimer: true, updateStopwatch: true)  // Use current date

        // Mark task complete
        task.setTaskCompleted(success: true)
    }

    // Stop background task when returning to foreground
    private func stopBackgroundTask() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }

    // Save the timer state
    func saveTimerState() {
        // TODO: save if timer / stopwatch are paused and account for this but for now assume both were running
        timerModel.saveToUserDefaults()
        // Save when the app was paused
        UserDefaults.standard.set(Date(), forKey: "pausedTime")
    }

    // Restore the timer state
    func restoreTimerState() {
        if let pausedTime = UserDefaults.standard.value(forKey: "pausedTime") as? Date {
            timerModel.restoreFromUserDefaults()
            // Adjust the timer state after the app was paused
            let updateTimer = timerModel.isStarted && !timerModel.isPaused
            let updateStopwatch = !timerModel.stopwatch.isPaused
            adjustTimersAfterBackground(pausedSince: pausedTime, updateTimer: updateTimer, updateStopwatch: updateStopwatch)
        }
    }
    
    // Adjust the timers after returning from background
    private func adjustTimersAfterBackground(pausedSince: Date, updateTimer: Bool, updateStopwatch: Bool) {
        let now = Date()
        // Update the stopwatch
        if updateStopwatch {
            timerModel.stopwatch.elapsedTimeStatic += now.timeIntervalSince(timerModel.stopwatch.mostRecentStartDate)
            timerModel.stopwatch.elapsedTime = timerModel.stopwatch.elapsedTimeStatic
            
            // Update the most recent start date to now
            timerModel.stopwatch.mostRecentStartDate = now
        }
        
        if updateTimer {
            // Adjust the timer
            let totalElapsedTime = Int(now.timeIntervalSince(timerModel.startTime))
            
            // Calculate how much time was left in the current set before background
            let currentSetElapsedTime = totalElapsedTime % timerModel.secondsPerSet
            let timeLeftInSet = timerModel.secondsPerSet - currentSetElapsedTime
            
            // Update the current set and remaining time
            let setsCompleted = totalElapsedTime / timerModel.secondsPerSet
            if setsCompleted >= timerModel.numberOfSets {
                // Timer finished
                timerModel.isStarted = false
                timerModel.isPaused = true
                timerModel.isFinished = true
                timerModel.timeLeft = 0
            } else {
                timerModel.currentSet = setsCompleted + 1
                timerModel.timeLeft = timeLeftInSet
            }
        }
    }
}
