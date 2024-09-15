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
        VStack(spacing: 10) {
            Spacer()
            
            // Stopwatch if multiple sets
            if timerModel.numberOfSets > 1 {
                Text(timerModel.stopwatch.displayTime)
                    .font(.system(size: 50, weight: .semibold))
                    .padding(.bottom, 10)
                    .foregroundColor(.gray)
                    .opacity(timerModel.stopwatch.isPaused ? 0.7 : 1.0)  // Lower opacity when paused
            }
            
            Spacer()
            
            // Timer Countdown with conditional opacity
            Text(timerModel.timerStringValue)
                .font(.system(size: timerModel.hours > 0 ? 120 : 90, weight: .semibold))
                .padding()
                .foregroundColor(timerModel.isPaused ? .gray : .white)  // Dimmed color when paused
                .opacity(timerModel.isPaused ? 0.6 : 1.0)  // Lower opacity when paused
            
            // set progress + progress bar
            ZStack(alignment: .leading) {
                // Background rectangle (Violet)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("DarkVioletAsset"))
                    .frame(width: 300, height: 55)

                // Foreground rectangle (Brighter violet, fills based on progress)
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("VioletAsset"), Color("BrightVioletAsset")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: CGFloat(300 * timerModel.progress), height: 55)
                    .animation(.linear(duration: 1.0), value: timerModel.progress)
                    
                // Text center of bar
                Text("\(timerModel.currentSet)/\(timerModel.numberOfSets)")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.init(white: 0.7))
                    .shadow(color: Color("DarkVioletAsset"), radius: 4, x: 0, y: 2)
                    .frame(width: 300, height: 55, alignment: .center)
            }
             
            Spacer()
            
            // HStack for both play/pause and stopwatch buttons
            HStack(spacing: 30) {
                // Start/Stop Button
                Button {
                    if timerModel.isStarted && !timerModel.isPaused {
                        timerModel.pauseTimer()
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
                    Image(systemName: timerModel.isFinished ? "repeat" :
                                    (!timerModel.isStarted || timerModel.isPaused ? "play.fill" : "stop.fill"))
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .frame(width: 90, height: 90)
                        .background {
                            Circle()
                                .fill(Color("TealAsset"))
                        }
                        .shadow(color: Color("BlueAsset"), radius: 15, x: 0, y: 0)
                        // Dim play button when running
                        .opacity(timerModel.isStarted && !timerModel.isPaused ? 0.6 : 1.0)
                }
                
                // Stopwatch Button
                Button {
                    timerModel.stopwatch.toggle()
                } label: {
                    Image(systemName: "timer")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .frame(width: 90, height: 90)
                        .background {
                            Circle()
                                .fill(Color("BlueAsset"))
                        }
                        .shadow(color: Color("TealAsset"), radius: 15, x: 0, y: 0)
                        // Dim play button when running
                        .opacity(!timerModel.stopwatch.isPaused ? 0.6 : 1.0)
                }
            }
            
            Spacer()
        }
        .preferredColorScheme(.dark)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if timerModel.isStarted && !timerModel.isPaused {
                timerModel.updateTimer()
            }
            
            timerModel.objectWillChange.send()
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
            self.timerStringValue = "01:13"  // Example time for the preview
        }
    }
}
