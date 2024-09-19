//
//  TimerModel.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-02.
//

import SwiftUI

class TimerModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    // Timer-related properties
    @Published var isStarted: Bool = false
    @Published var isFinished: Bool = false
    @Published var isPaused: Bool = true
    @Published var addNewTimer: Bool = false
    @Published var numberOfSets: Int = 1
    @Published var currentSet: Int = 1
    @Published var isAlertSoundOn: Bool = true
    
    // Time Handling
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var timeLeft: Int = 0
    @Published var secondsPerSet: Int = 0
    @Published var timerStringValue: String = "00:00"
    @Published var progress: CGFloat = 0
    
    @Published var stopwatch: Stopwatch = .init()
    @Published var startTime: Date = Date()
    
    private var timerDispatchWorkItem: DispatchWorkItem?
    
    
    
    // Default initializer
    override init() {
        super.init()
        self.authorizeNotification()
         
        // Preload sounds here during initialization
        SoundManager.instance.preloadPrepareBeeps()
    }
    
    func updateTimerStringValue() {
           timerStringValue = "\(hours == 0 ? "" : "\(hours):")\(minutes >= 10 ? "\(minutes)" : "0\(minutes)"):\(seconds >= 10 ? "\(seconds)" : "0\(seconds)")"
    }
    
    func setHMS(seconds: Int = 0) {
        self.hours = seconds / 3600
        self.minutes = (seconds / 60) % 60
        self.seconds = (seconds % 60)
    }
    
    func prepareTimer() {
        secondsPerSet = (hours * 3600) + (minutes * 60) + seconds
        timeLeft = secondsPerSet
        updateTimerStringValue()
    }
    
    func startTimer() {
        prepareTimer()
        if isAlertSoundOn {
            SoundManager.instance.playStartFinishTimer()
        }

        // Create a dispatch work item for delayed execution
        timerDispatchWorkItem = DispatchWorkItem {
            self.isStarted = true
            self.startTime = Date()
            self.stopwatch.isPaused = false
            self.stopwatch.start()
            self.isPaused = false
            self.addNewTimer = false
            if self.isAlertSoundOn {
                SoundManager.instance.playNewRound()
            }
        }

        // Delay timer start by 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: timerDispatchWorkItem!)

        // TODO: Add notifications and handle app in background edge cases.
    }

    // Cancels the start if app goes into background
    func cancelPendingTimerStart() {
        timerDispatchWorkItem?.cancel()
    }
    
    func pauseTimer() {
        isPaused = true
    }
    
    func resumeTimer() {
        isPaused = false
        if stopwatch.isPaused {
            stopwatch.toggle()
        }
    }
    
    func resetTimer() {
        isStarted = false
        isFinished = false
        isPaused = true
        setHMS(seconds: secondsPerSet)
        timeLeft = secondsPerSet
        updateTimerStringValue()
        currentSet = 1
        progress = 0
        stopwatch.reset()
    }
    
    func updateTimer() {
        timeLeft -= 1
        progress = 1 - CGFloat(timeLeft) / CGFloat(secondsPerSet)

        if isAlertSoundOn && (timeLeft == 1 || timeLeft == 2 || timeLeft == 3) {
            SoundManager.instance.playBlip()
        } else if isAlertSoundOn && timeLeft == 10 {
            SoundManager.instance.playRoundIncoming()
        } else if timeLeft == 0 {
            if currentSet >= numberOfSets {
                isStarted = false
                isFinished = true
                if isAlertSoundOn {
                    SoundManager.instance.playStartFinishTimer()
                }
            } else {
                timeLeft = secondsPerSet
                updateTimerStringValue()
                currentSet += 1
                progress = 0
                if isAlertSoundOn {
                    SoundManager.instance.playNewRound()
                }
            }
        }
        setHMS(seconds: timeLeft)
        updateTimerStringValue()
    }
    

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
        UserDefaults.standard.set(addNewTimer, forKey: "addNewTimer")
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
        self.addNewTimer = UserDefaults.standard.bool(forKey: "addNewTimer")
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
