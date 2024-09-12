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
    
    var body: some View {
        VStack(spacing: 30) {
            
            HStack(spacing: 0) {
                // Hour Picker
                HStack {
                    Picker("Hours", selection: $selectedHour) {
                        ForEach(0...23, id: \.self) { value in
                            Text("\(value)").tag(value)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .background(Color.black) // Dark background for the picker
                    .clipped()
                    
                    Text("hr")
                        .font(.title3)
                        .foregroundColor(.white) // White text
                }
                
                // Minute Picker
                HStack {
                    Picker("Minutes", selection: $selectedMinute) {
                        ForEach(0...59, id: \.self) { value in
                            Text("\(value)").tag(value)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .background(Color.black) // Dark background for the picker
                    .clipped()
                    
                    Text("min")
                        .font(.title2)
                        .foregroundColor(.white) // White text
                }
                
                // Second Picker
                HStack {
                    Picker("Seconds", selection: $selectedSecond) {
                        ForEach(0...59, id: \.self) { value in
                            Text("\(value)").tag(value)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .background(Color.black) // Dark background for the picker
                    .clipped()
                    
                    Text("sec")
                        .font(.title2)
                        .foregroundColor(.white) // White text
                }
            }
        }
        .padding()
        .background(Color.black) // Dark background for the entire view
        .clipShape(RoundedRectangle(cornerRadius: 10)) // Optional: rounded corners for a cleaner look
    }
}

#Preview {
    TimePickerView(
        selectedHour: .constant(1),
        selectedMinute: .constant(30),
        selectedSecond: .constant(45)
    )
}
