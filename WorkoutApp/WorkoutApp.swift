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
        adjustTimersAfterBackground(pausedSince: Date())  // Use current date

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
        timerModel.pauseTimer()
        timerModel.stopwatch.pause()
        
        // Save when the timer was started
        UserDefaults.standard.set(timerModel.startTime, forKey: "startTime")
        // Save stopwatch start time
        UserDefaults.standard.set(timerModel.stopwatch.elapsedTimeStatic, forKey: "stopwatchElapsedTimeStatic")
        // Save stopwatch start time
        UserDefaults.standard.set(timerModel.stopwatch.mostRecentStartDate, forKey: "stopwatchMostRecentStartDate")
        // Save when the app was paused
        UserDefaults.standard.set(Date(), forKey: "pausedTime")
    }

    // Restore the timer state
    func restoreTimerState() {
        if let startTime = UserDefaults.standard.value(forKey: "startTime") as? Date,
           let stopwatchElapsedTimeStatic = UserDefaults.standard.value(forKey: "stopwatchElapsedTimeStatic") as? TimeInterval,
           let mostRecentStartDate = UserDefaults.standard.value(forKey: "stopwatchMostRecentStartDate") as? Date,
           let pausedTime = UserDefaults.standard.value(forKey: "pausedTime") as? Date {
            
            timerModel.startTime = startTime
            timerModel.stopwatch.elapsedTimeStatic = stopwatchElapsedTimeStatic
            timerModel.stopwatch.mostRecentStartDate = mostRecentStartDate
            // Adjust the timer state after the app was paused
            adjustTimersAfterBackground(pausedSince: pausedTime)
        }
    }
    
    // Adjust the timers after returning from background
    private func adjustTimersAfterBackground(pausedSince: Date) {
        let now = Date()
        // Update the stopwatch
        timerModel.stopwatch.elapsedTimeStatic += now.timeIntervalSince(timerModel.stopwatch.mostRecentStartDate)
        timerModel.stopwatch.elapsedTime = timerModel.stopwatch.elapsedTimeStatic
        
        // Update the most recent start date to now
        timerModel.stopwatch.mostRecentStartDate = now

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
            timerModel.resumeTimer()
        }
    }
}
