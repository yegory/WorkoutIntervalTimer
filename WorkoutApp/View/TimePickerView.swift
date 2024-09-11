//
//  SecondPickerView.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-03.
//
import SwiftUI

struct TimePickerView: View {
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var selectedSecond: Int
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            
            Text("Select Time")
                .font(.title2)
                .padding(.top)

            HStack(spacing: 0) {
                // Hour Picker
                HStack {
                    Picker("Hours", selection: $selectedHour) {
                        ForEach(0...23, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .background(Color.clear)
                    
                    Text("hr")
                        .font(.title3)
                }
                
                // Minute Picker
                HStack {
                    Picker("Minutes", selection: $selectedMinute) {
                        ForEach(0...59, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .background(Color.clear)
                    
                    Text("min")
                        .font(.title2)
                }
                
                // Second Picker
                HStack {
                    Picker("Seconds", selection: $selectedSecond) {
                        ForEach(0...59, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .background(Color.clear)
                    
                    Text("sec")
                        .font(.title2)
                }
            }

            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.title2)
            .padding()
        }
        .padding()
        .background{
            Color("BGAsset")
                .ignoresSafeArea()
        }
    }
}

#Preview {
    TimePickerView(
        selectedHour: .constant(1),
        selectedMinute: .constant(30),
        selectedSecond: .constant(45)
    )
}
