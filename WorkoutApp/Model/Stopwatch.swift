//
//  Stopwatch.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-11.
//

import Foundation

class Stopwatch: ObservableObject {
    private var timer: Timer?
    
    @Published var isPaused: Bool = true
    // This one only updates when user leaves and opens app again (app phases)
    @Published var elapsedTimeStatic: TimeInterval = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var mostRecentStartDate: Date = Date()
    
    /// Scenarios:
    ///  1. User starts timer.
    ///  2. Leaves app
    ///  3. We add now() - mostRecentStartDate to elapsedTimeStatic and set ElapsedTime to static
    ///  4. We make most recent start date = now()
    
    // Computed property to display time in "hh:mm:ss" format
    var displayTime: String {
        let time = Int(elapsedTime)
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        // Return a string where hours are not displayed if h=0
        return "\(hours == 0 ? "" : "\(hours):")\(minutes >= 10 ? "\(minutes)" : "0\(minutes)"):\(seconds >= 10 ? "\(seconds)" : "0\(seconds)")"
    }
    
    func start() {
        if timer == nil {
            mostRecentStartDate = Date()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.elapsedTime += 1
                self.objectWillChange.send()  // This manually notifies any observers about the change
            }
        }
    }
    
    func pause() {
        isPaused = true
        stop() // Stops the timer, but time stays the same until reset is called
    }
    
    func resume() {
        if isPaused {
            isPaused = false
            start()
        }
    }
    
    func stop(reset: Bool = false) {
        timer?.invalidate()
        timer = nil
        if reset {
            elapsedTime = 0 // Resets the time to 0 if specified
        }
    }
    
    func reset() {
        stop(reset: true) // Stop and reset time
        isPaused = false
    }
    
    func toggle() {
        if isPaused {
            resume()
        } else {
            pause()
        }
    }
}
