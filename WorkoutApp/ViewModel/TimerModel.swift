//
//  TimerModel.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-02.
//

import SwiftUI

class TimerModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    /// Timer-related properties
    @Published var isStarted: Bool = false
    @Published var isFinished: Bool = false
    @Published var isPaused: Bool = true
    @Published var numberOfSets: Int = 1
    @Published var currentSet: Int = 1
    @Published var isAlertSoundOn: Bool = true
    
    /// Time Handling
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var timeLeft: Int = 0
    @Published var secondsPerSet: Int = 0
    @Published var timerStringValue: String = "00:00"
    
    var progressPercent: CGFloat {
        if secondsPerSet > 0 {
            return (CGFloat(secondsPerSet - timeLeft) / CGFloat(secondsPerSet)) * 100
        } else {
            return 0.0
        }
    }
    
    @Published var stopwatch: Stopwatch = .init()
    @Published var startTime: Date = Date()
    
    private var timerDispatchWorkItem: DispatchWorkItem?
    
    var canChangeTimer: Bool {
        return !isStarted || isFinished
    }
    
    /// Default initializer
    override init() {
        super.init()
        self.authorizeNotification()
         
        // Preload sounds here during initialization
        SoundManager.instance.preloadPrepareBeeps()
    }
    
    // MARK: - Timer Lifecycle Methods
    
    /// Prepares the timer by calculating time per set and resetting the current state.
    /// Should be called before starting or restarting the timer.
    func prepareTimer() {
        secondsPerSet = (hours * 3600) + (minutes * 60) + seconds
        timeLeft = secondsPerSet
        currentSet = 1
        updateTimerStringValue() // Update the UI string for the time.
    }

    /// Starts the timer after a 5-second delay. Handles both the stopwatch and the timer itself.
    func startTimer() {
        prepareTimer() // Ensure the timer is set up.
        handleAlerts()
        // Delay the actual start by 5 seconds
        timerDispatchWorkItem = DispatchWorkItem {
            self.beginTimer() // Moved core logic to `beginTimer()`
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: timerDispatchWorkItem!)
    }

    /// This contains the core logic for starting the timer.
    /// Separated from `startTimer()` to avoid duplication during restarts.
    private func beginTimer() {
        isStarted = true
        startTime = Date()
        stopwatch.start()
        isPaused = false
        handleAlerts()
    }
    
    /// Pauses the current timer without resetting progress or time.
    func pauseTimer() {
        isPaused = true
    }
    
    /// Resumes the timer from where it was paused.
    func resumeTimer() {
        isPaused = false
        if stopwatch.isPaused {
            stopwatch.toggle()
        }
    }
    
    /// Resets the timer to its initial state and stops all progress.
    func reset() {
        isStarted = false
        isFinished = false
        isPaused = true
        setHMS(seconds: 0)
        timeLeft = 0
        timerStringValue = "00:00"
        currentSet = 1
        stopwatch.reset()
        cancelPendingTimerStart()
    }
    
    /// Restarts the timer, reusing the existing timer setup and stopwatch, but resetting progress.
    func restart() {
        isStarted = false
        isFinished = false
        isPaused = true
        setHMS(seconds: secondsPerSet)
        stopwatch.reset()
        startTimer()
    }
    
    // MARK: - Timer Progress Methods\
    
    /// Updates the timer each second, reducing the time left and managing sound alerts.
    /// This function should be called regularly (e.g., with a scheduled timer).
    func updateTimer() {
        timeLeft -= 1

        if timeLeft <= 0 {
            handleTimerCompletion() // Handle what happens when time runs out.
        }
        handleAlerts()
        setHMS(seconds: timeLeft) // Update hours, minutes, seconds
        updateTimerStringValue() // Update UI string
    }
    
    /// Handles different sound alerts as the timer approaches certain milestones.
    private func handleAlerts() {
        if isAlertSoundOn {
            if timeLeft == 1 || timeLeft == 2 || timeLeft == 3 {
                SoundManager.instance.playBlip() // Play beep for the last 3 seconds
            } else if timeLeft == 10 {
                SoundManager.instance.playRoundIncoming() // 10-second warning
            } else if !isStarted || isFinished {
                SoundManager.instance.playStartFinishTimer()
            } else if timeLeft == secondsPerSet {
                SoundManager.instance.playNewRound()
            }
        }
    }
    
    /// Handles logic when the timer for the current set finishes.
    private func handleTimerCompletion() {
        if currentSet >= numberOfSets {
            isFinished = true
            isStarted = false
        } else {
            // Move to the next set
            timeLeft = secondsPerSet
            currentSet += 1
        }
    }
    
    // MARK: - Utility Methods
    
    /// Cancels any pending timer starts (e.g., when the app enters the background).
    func cancelPendingTimerStart() {
        timerDispatchWorkItem?.cancel()
    }

    /// Converts a given number of seconds into hours, minutes, and seconds, and sets class fields.
    func setHMS(seconds: Int = 0) {
        self.hours = seconds / 3600
        self.minutes = (seconds / 60) % 60
        self.seconds = (seconds % 60)
    }

    /// Updates the `timerStringValue` to reflect the current time in HH:MM:SS format.
    func updateTimerStringValue() {
        timerStringValue = "\(hours == 0 ? "" : "\(hours):")\(minutes >= 10 ? "\(minutes)" : "0\(minutes)"):\(seconds >= 10 ? "\(seconds)" : "0\(seconds)")"
    }
    
    // MARK: - Notification Handling

    func addNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Timer"
        content.subtitle = "Timer Finished"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(secondsPerSet * numberOfSets), repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // Notification setup
    func authorizeNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]){ _, _ in }
        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner])
    }
}

extension TimerModel {
    func saveToUserDefaults() {
        UserDefaults.standard.set(isStarted, forKey: "isStarted")
        UserDefaults.standard.set(isFinished, forKey: "isFinished")
        UserDefaults.standard.set(isPaused, forKey: "isPaused")
        UserDefaults.standard.set(numberOfSets, forKey: "numberOfSets")
        UserDefaults.standard.set(currentSet, forKey: "currentSet")
        UserDefaults.standard.set(isAlertSoundOn, forKey: "isAlertSoundOn")
        
//        UserDefaults.standard.set(hours, forKey: "hours")
//        UserDefaults.standard.set(minutes, forKey: "minutes")
//        UserDefaults.standard.set(seconds, forKey: "seconds")
        UserDefaults.standard.set(timeLeft, forKey: "timeLeft")
        UserDefaults.standard.set(secondsPerSet, forKey: "secondsPerSet")
//        UserDefaults.standard.set(timerStringValue, forKey: "timerStringValue")
//        UserDefaults.standard.set(progress, forKey: "progress")
        
        UserDefaults.standard.set(stopwatch.elapsedTimeStatic, forKey: "stopwatchElapsedTimeStatic")
        UserDefaults.standard.set(stopwatch.elapsedTime, forKey: "stopwatchElapsedTime")
        UserDefaults.standard.set(stopwatch.isPaused, forKey: "stopwatchIsPaused")
        UserDefaults.standard.set(stopwatch.mostRecentStartDate, forKey: "stopwatchMostRecentStartDate")

    }
}

extension TimerModel {
    func restoreFromUserDefaults() {
        self.isStarted = UserDefaults.standard.bool(forKey: "isStarted")
        self.isFinished = UserDefaults.standard.bool(forKey: "isFinished")
        self.isPaused = UserDefaults.standard.bool(forKey: "isPaused")
        self.numberOfSets = UserDefaults.standard.integer(forKey: "numberOfSets")
        self.currentSet = UserDefaults.standard.integer(forKey: "currentSet")
        self.isAlertSoundOn = UserDefaults.standard.bool(forKey: "isAlertSoundOn")
        
//        self.hours = UserDefaults.standard.integer(forKey: "hours")
//        self.minutes = UserDefaults.standard.integer(forKey: "minutes")
//        self.seconds = UserDefaults.standard.integer(forKey: "seconds")
        self.timeLeft = UserDefaults.standard.integer(forKey: "timeLeft")
        self.secondsPerSet = UserDefaults.standard.integer(forKey: "secondsPerSet")
//        self.timerStringValue = UserDefaults.standard.string(forKey: "timerStringValue") ?? "00:00"
//        self.progress = CGFloat(UserDefaults.standard.float(forKey: "progress"))
        
        self.stopwatch.elapsedTimeStatic = UserDefaults.standard.double(forKey: "stopwatchElapsedTimeStatic")
        self.stopwatch.elapsedTime = UserDefaults.standard.double(forKey: "stopwatchElapsedTime")
        self.stopwatch.isPaused = UserDefaults.standard.bool(forKey: "stopwatchIsPaused")
        self.stopwatch.mostRecentStartDate = UserDefaults.standard.object(forKey: "stopwatchMostRecentStartDate") as? Date ?? Date()
    }
}
