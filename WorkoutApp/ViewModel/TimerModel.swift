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
    
    @Published var stopwatch: Stopwatch = .init()
    private let instance = SoundManager.instance
    
    // Default initializer
    override init() {
        super.init()
        self.authorizeNotification()
        instance.preloadPrepareBeeps() // Preload sounds here during initialization
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
        isStarted = true
        isPaused = false
        addNewTimer = false
        prepareTimer()
        stopwatch.start()
//        addNotification()
    }
    
    func pauseTimer() {
        isPaused = true
        stopwatch.pause()
        
    }
    
    func resumeTimer() {
        isPaused = false
        stopwatch.resume()
    }
    
    func resetTimer() {
        isStarted = false
        isFinished = false
        isPaused = true
        setHMS(seconds: secondsPerSet)
        timeLeft = secondsPerSet
        updateTimerStringValue()
        currentSet = 1
        stopwatch.reset()
    }
    
//    func pauseTimer() {
//        withAnimation {
//            isStarted = false
//            hours = 0
//            minutes = 0
//            seconds = 0
//            stopwatch.stop()
//        }
//        secondsPerSet = 0
//        timeLeft = 0
//        timerStringValue = "00:00"
//    }
//    func resetTimer() {
    
//    func pauseTimer() {
//        withAnimation {
//            isStarted = false
//            hours = 0
//            minutes = 0
//            seconds = 0
//            stopwatch.stop()
//        }
//        secondsPerSet = 0
//        timeLeft = 0
//        timerStringValue = "00:00"
//    }
    
    func updateTimer() {
        timeLeft -= 1
        
        if isAlertSoundOn && timeLeft == 3 {
            instance.playPrepareBeeps()
        }
        if timeLeft == 0 {
            if currentSet >= numberOfSets {
                isStarted = false
                isFinished = true
            } else {
                timeLeft = secondsPerSet
                updateTimerStringValue()
                currentSet += 1
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
