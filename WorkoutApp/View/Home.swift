//
//  Home.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-02.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var timerModel: TimerModel
//    @State private var showPicker = false
    var body: some View {
        VStack {
            Text("Blu")
                .font(.title2.bold())
                .foregroundStyle(.white)
            
            GeometryReader { proxy in
                VStack(spacing: 15) {
                    // Timer Ring
                    ZStack {
                        // outer solid ring
                        Circle()
                            .fill(.blue.opacity(0.05))
                            .padding(-40)
                        
                        Circle()
                            .trim(from: 0, to: timerModel.progress)
                            .stroke(.white.opacity(0.05), lineWidth: 80)
                            .blur(radius: 11)
                            .padding(-5)
                        
                        // Shadow
                        Circle()
                            .stroke(Color("PurpleAsset"), lineWidth: 8)
                            .blur(radius: 13)
                            .padding(-6)
                            .brightness(0.8)
                        
                        // inner fill
                        Circle()
                            .fill(Color("BGAsset"))
                            .padding(-4)
                        
                            // main line
                        Circle()
                            .trim(from: 0, to: timerModel.progress)
                            .stroke(Color("PurpleAsset"), lineWidth: 11)
                            .padding(-9)
                        
                        // Knob
                        GeometryReader { proxy in
                            let size = proxy.size
                            
                            Circle()
                                .fill(Color("PurpleAsset"))
                                .colorMultiply(.purple)
                                .frame(width: 30, height: 30)
                                .overlay(content: {
                                    Circle()
                                        .fill(.white)
                                        .padding(5)
                                        .blur(radius: 4)
                                        .padding(2)
                                })
                                .frame(width: size.width, height: size.height, alignment: .center)
                            // since view rotated 90 degrees, using x-axis
                                .offset(x: size.height / 2 + 10 )
                                .rotationEffect(.init(degrees: timerModel.progress * 360))
                        }
                        
                        Text(timerModel.timerStringValue)
                            .font(.system(size: 45, weight: .light))
                            .rotationEffect(.init(degrees: 90))
                            .animation(.none, value: timerModel.progress)
                    }
                    .padding(60)
                    .frame(height: proxy.size.width)
                    .rotationEffect(.init(degrees: -90))
                    .animation(.easeInOut, value: timerModel.progress)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    
                    Button {
                        if timerModel.isStarted {
                            timerModel.stopTimer()
                            // Cancelling All Notifications
                            UNUserNotificationCenter.current()
                                .removeAllPendingNotificationRequests()
                        } else {
                            timerModel.addNewTimer = true
                        }
                    } label: {
                        Image(systemName: !timerModel.isStarted ? "timer" : "stop.fill")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                            .frame(width: 80, height: 80)
                            .background {
                                Circle()
                                    .fill(Color("PurpleAsset"))
                            }
                            .shadow(color: Color("PurpleAsset"), radius: 8, x: 0, y: 0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .padding()
        .background {
            Color("BGAsset") .ignoresSafeArea()
        }
        .overlay(content: {
            ZStack {
                Color.black
                    .opacity(timerModel.addNewTimer ? 0.25 : 0)
                    .onTapGesture {
                        timerModel.hours = 0
                        timerModel.minutes = 0
                        timerModel.seconds = 0
                        timerModel.addNewTimer = false
                    }
                NewTimerView()
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .offset(y: timerModel.addNewTimer ? 0 : 400)
            }
            .animation(.easeInOut, value: timerModel.addNewTimer)
        })
        .preferredColorScheme(.dark)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if timerModel.isStarted {
                timerModel.updateTimer()
            }
        }
        .alert("Timer Finished", isPresented: $timerModel.isFinished) {
            Button("Start New", role: .cancel) {
                timerModel.stopTimer()
                timerModel.addNewTimer = true
            }
            Button("Close", role: .destructive) {
                timerModel.stopTimer()
            }
        }
    }
    
    // New Timer Button Sheet
    @ViewBuilder
    func NewTimerView() -> some View {
        VStack(spacing: 15) {
            Text("Add Timer")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .padding(.top, 10)
            
            HStack(spacing: 15) {
                Text("\(timerModel.hours) hr")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background {
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 23, hint: "hr") { value in
                            timerModel.hours = value
                        }
                    }
                
                Text("\(timerModel.minutes) min")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background {
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 59, hint: "min") { value in
                            timerModel.minutes = value
                        }
                    }
                
                Text("\(timerModel.seconds) sec")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background {
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 59, hint: "sec") { value in
                            timerModel.seconds = value
                        }
                    }

            }
            .padding(.top, 20)
            
            Button {
                timerModel.startTimer()
            } label: {
                Text("Save")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 100)
                    .padding(.vertical)
                    .background {
                        Capsule()
                            .fill(Color("PurpleAsset"))
                    }
            }
            .disabled(timerModel.seconds == 0 && timerModel.minutes == 0 && timerModel.hours == 0)
            .opacity(timerModel.seconds == 0 ? 0.5 : 1)
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color("BGAsset"))
                .ignoresSafeArea()
        }
    }
    
    // Reusable Context Menu Options
    @ViewBuilder
    func ContextMenuOptions(maxValue: Int, hint: String, onClick: @escaping
    (Int)-> ()) -> some View {
        ForEach(0...maxValue, id: \.self) {value in
            Button("\(value) \(hint)") {
                onClick(value)
            }
        }
    }
}
#Preview {
    ContentView()
        .environmentObject(TimerModel())
}
