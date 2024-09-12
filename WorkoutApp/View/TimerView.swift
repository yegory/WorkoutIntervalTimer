//
//  TimerView.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-02.
//


import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerModel: TimerModel
    @State private var isPaused: Bool = true

    var body: some View {
        VStack(spacing: 10) {  // Reduced spacing for tighter layout
            Spacer()
            
            // Stopwatch if multiple sets
            if timerModel.numberOfSets > 1 {
                Text(timerModel.stopwatch.displayTime)
                    .font(.system(size: 50, weight: .semibold))  // Smaller font for stopwatch
                    .padding(.bottom, 10)  // Spacing from timer
                    .foregroundColor(.gray)
            }
            Spacer()
            
            //Timer Countdown
            Text(timerModel.timerStringValue)
                .font(.system(size: timerModel.hours > 0 ? 120 : 90, weight: .semibold))
                .padding()

            // Current Set if more than 1 set
            if timerModel.numberOfSets > 1 {
               Text("\(timerModel.currentSet)/\(timerModel.numberOfSets)")
                    .font(.system(size: 40, weight: .semibold))  // Smaller font for set display
                   .foregroundColor(.gray)  // Lighter text color for rounds
            }
            
             
            Spacer()
            
            // Start/Stop Button
            Button {
                if timerModel.isStarted && !timerModel.isPaused {
                    timerModel.pauseTimer()
                    // Cancelling All Notifications
                    UNUserNotificationCenter.current()
                        .removeAllPendingNotificationRequests()
                } else if (!timerModel.isStarted && timerModel.isPaused) {
                    timerModel.startTimer()
                } else if (timerModel.isStarted && timerModel.isPaused) {
                    timerModel.resumeTimer()
                } else if (timerModel.isFinished) {
                    timerModel.resetTimer()
                    timerModel.startTimer()
                }
            } label: {
                // Display different icons based on the timer's state
                Image(systemName: timerModel.isFinished ? "repeat" :
                                (!timerModel.isStarted || timerModel.isPaused ? "play.fill" : "stop.fill"))
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background {
                        Circle()
                            .fill(Color("PurpleAsset"))
                    }
                    .shadow(color: Color("PurpleAsset"), radius: 8, x: 0, y: 0)
            }
            Spacer()

        }
        .preferredColorScheme(.dark)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if timerModel.isStarted && !timerModel.isPaused {
                timerModel.updateTimer()
            }
        }
    }
}

#Preview {
    TimerView()
        .environmentObject(TimerModel(dummyInitialization: true))
}

// Dummy TimerModel class for preview
extension TimerModel {
    convenience init(dummyInitialization: Bool) {
        self.init()
        if dummyInitialization {
            // Initialize with dummy values
            self.numberOfSets = 30
            self.currentSet = 16
            self.stopwatch = Stopwatch() // Ensure Stopwatch is properly initialized
            self.timerStringValue = "00:01:13"  // Example time for the preview
        }
    }
}
