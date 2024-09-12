////
////  TimerHandler.swift
////  WorkoutApp
////
////  Created by Yegor Yeryomenko on 2024-09-11.
////
//
//import Foundation
//
//class TimeHandler: ObservableObject {
//    // Variable
//    
//    
//    // Custom initializer
//    init(hours: Int = 0, minutes: Int = 0, seconds: Int = 0) {
//        self.hours = hours
//        self.minutes = minutes
//        self.seconds = seconds
//    }
//
//    func updateTimerStringValue() {
//        self.timerStringValue = "\(hours == 0 ? "" : "\(hours):")\(minutes >= 10 ? "\(minutes)" : "0\(minutes)"):\(seconds >= 10 ? "\(seconds)" : "0\(seconds)")"
//        print("updateTimerStringValue")
//    }
//    
//    func startTime() {
//        self.timeLeft = (hours * 3600) + (minutes * 60) + seconds
//        self.secondsPerSet = (hours * 3600) + (minutes * 60) + seconds
//        DispatchQueue.main.async {
//            self.updateTimerStringValue()
//        }
//        print("startTime")
//    }
//    
//    func updateTime() {
//        timeLeft -= 1
//        hours = timeLeft / 3600
//        minutes = (timeLeft / 60) % 60
//        seconds = timeLeft % 60
//        DispatchQueue.main.async {
//            self.updateTimerStringValue()
//        }
//        print("updateTime")
//    }
//    
//    func resetTime() {
//        hours = 0
//        minutes = 0
//        seconds = 0
//        timeLeft = 0
//        secondsPerSet = 0
//        DispatchQueue.main.async {
//            self.updateTimerStringValue()
//        }
//        print("resetTime")
//    }
//}
