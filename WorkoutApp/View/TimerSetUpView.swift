//
//  TimerSetUpView.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-11.
//
//

import SwiftUI

struct TimerSetUpView: View {
    @EnvironmentObject var timerModel: TimerModel
    @State private var numberOfSets: Int = 1
    @State private var selectedHour: Int = 0
    @State private var selectedMinute: Int = 0
    @State private var selectedSecond: Int = 0
    @State private var isAlertSoundOn: Bool = true
    @State private var isPresentingTimerView: Bool = false  // State to control presentation
    
    private var formattedTimeToComplete: String {
        let totalHours = numberOfSets * selectedHour
        let totalMinutes = numberOfSets * selectedMinute
        let totalSeconds = numberOfSets * selectedSecond
        
        let hours = totalHours + (totalMinutes / 60)
        let minutes = (totalMinutes % 60) + (totalSeconds / 60)
        let seconds = totalSeconds % 60
        
        return "\(hours == 0 ? "" : "\(hours):")\(minutes >= 10 ? "\(minutes)" : "0\(minutes)"):\(seconds >= 10 ? "\(seconds)" : "0\(seconds)")"
    }
    
    var body: some View {
        VStack(spacing: 30) {
            
            Text("Total Time: \(formattedTimeToComplete)")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                )
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)
            
            HStack {
                Button(action: {
                    numberOfSets = 1
                }) {
                    Image(systemName: "delete.backward.fill")
                        .font(.title)
                        .foregroundColor(.mint)
                }
                
                Button(action: {
                    if numberOfSets > 1 {
                        numberOfSets -= 1
                    }
                }) {
                    Image(systemName: "minus.square.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                }
                
                Button(action: {
                    numberOfSets += 1
                }) {
                    Text("Sets: \(numberOfSets)")
                        .font(.title2)
                        .frame(width: 150, alignment: .center)
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                        )
                        .padding(.vertical)
                }
            }
            .padding(.horizontal)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.purple, lineWidth: 3)
                    .blur(radius: 4)
            )
            
            VStack {
                Text("Select Time Per Set")
                    .font(.title2)
                    .foregroundColor(.white)
                
                TimePickerView(selectedHour: $selectedHour, selectedMinute: $selectedMinute, selectedSecond: $selectedSecond)
            }
            .padding(.top)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.purple, lineWidth: 3)
                    .blur(radius: 4)
            )
            
            HStack(spacing: 10) {
                // Button to start timer and present TimerView
                Button(action: {
                    // Initialize TimerHandler with selected time
                    timerModel.hours = selectedHour
                    timerModel.minutes = selectedMinute
                    timerModel.seconds = selectedSecond
                    timerModel.updateTimerStringValue()
                    timerModel.numberOfSets = numberOfSets
                    timerModel.isAlertSoundOn = isAlertSoundOn
                    // Present TimerView
                    isPresentingTimerView = true
                }) {
                    Text("Start Timer")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedHour == 0 && selectedMinute == 0 && selectedSecond == 0)
                .background((selectedHour == 0 && selectedMinute == 0 && selectedSecond == 0) ? Color.red.opacity(0.5) : Color.blue)
                .cornerRadius(15)
                .fullScreenCover(isPresented: $isPresentingTimerView) {
                    TimerView()
                        .environmentObject(timerModel)  // Pass the TimerModel to the new view
                }
                
                Toggle("Alert Sound", isOn: $isAlertSoundOn)
                    .padding()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.purple, lineWidth: 3)
                            .blur(radius: 5)
                    )
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    .toggleStyle(SwitchToggleStyle(tint: .purple))
            }
        }
        .padding()
        .background(Color.black)
        .ignoresSafeArea()
    }
}

#Preview {
    TimerSetUpView()
        .environmentObject(TimerModel())
}
