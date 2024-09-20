//
//  TimerLifecycleHandler.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-19.
//

import SwiftUI
import BackgroundTasks

class TimerLifecycleHandler: ObservableObject {
    @Published var timerModel: TimerModel = .init()
    
    private let taskIdentifier: String = "com.yegor.WorkoutAppUnique19240.timerTask"
    
    func clearUserDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }

    func handleTimerLifecycleHandler(newPhase: ScenePhase) {
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
        } else if !timerModel.isStarted && newPhase == .background {
            timerModel.cancelPendingTimerStart()
            saveTimerState()  // Save the state before going to background
            startBackgroundTask()
        }
    }

    private func startBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleBackgroundTask(task: task as! BGProcessingTask)
        }
        scheduleBackgroundTask()
    }

    private func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: taskIdentifier)
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Handle error
        }
    }

    private func handleBackgroundTask(task: BGProcessingTask) {
        adjustTimersAfterBackground(pausedSince: Date(), updateTimer: true, updateStopwatch: true)
        task.setTaskCompleted(success: true)
    }

    private func stopBackgroundTask() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }

    private func saveTimerState() {
        timerModel.saveToUserDefaults()
        UserDefaults.standard.set(Date(), forKey: "pausedTime")
    }

    private func restoreTimerState() {
        if let pausedTime = UserDefaults.standard.value(forKey: "pausedTime") as? Date {
            timerModel.restoreFromUserDefaults()
            let updateTimer = timerModel.isStarted && !timerModel.isPaused
            let updateStopwatch = !timerModel.stopwatch.isPaused
            adjustTimersAfterBackground(pausedSince: pausedTime, updateTimer: updateTimer, updateStopwatch: updateStopwatch)
        }
    }

    private func adjustTimersAfterBackground(pausedSince: Date, updateTimer: Bool, updateStopwatch: Bool) {
        let now = Date()
        if updateStopwatch {
            timerModel.stopwatch.elapsedTimeStatic += now.timeIntervalSince(timerModel.stopwatch.mostRecentStartDate)
            timerModel.stopwatch.elapsedTime = timerModel.stopwatch.elapsedTimeStatic
            timerModel.stopwatch.mostRecentStartDate = now
        }
        if updateTimer {
            let totalElapsedTime = Int(now.timeIntervalSince(timerModel.startTime))
            let currentSetElapsedTime = totalElapsedTime % timerModel.secondsPerSet
            let timeLeftInSet = timerModel.secondsPerSet - currentSetElapsedTime
            let setsCompleted = totalElapsedTime / timerModel.secondsPerSet

            if setsCompleted >= timerModel.numberOfSets {
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
