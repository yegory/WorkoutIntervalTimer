//
//  Stopwatch.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-11.
//

import Foundation

class Stopwatch: ObservableObject {
    @Published var elapsedTime: Int = 0
    private var timer: Timer?
    @Published var isPaused: Bool = true
    
    // Computed property to display time in "hh:mm:ss" format
    var displayTime: String {
        let hours = elapsedTime / 3600
        let minutes = (elapsedTime % 3600) / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func start() {
        if timer == nil {
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
