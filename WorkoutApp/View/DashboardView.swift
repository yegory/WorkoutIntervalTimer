//
//  DashboardView.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-19.
//

// Placeholder for the DashboardView
// Final Dashboard should hopefully contain some useful statistics along with quick links to common app functionality
// E.g. Start timer 10 sets of 10 with 1:30 rest
// E.g. add new exercise
// E.g. Schedule workouts
// Some widgets to show how many workouts you did this year/month, cumulative statistics for common exercises

import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Welcome back, Yegor!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color("BlueAsset"))

            // Current time and day of the week
            Text(currentTimeAndDate)
                .font(.title2)
                .foregroundColor(Color("TealAsset"))

            // Days until New Year
            Text("Days until New Year: \(daysUntilNewYear)")
                .font(.headline)
                .foregroundColor(Color("BlueAsset"))

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground)) // Adaptive background
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    // Combined string for current time and date
    private var currentTimeAndDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a 'on a' EEEE; dd-MM-yy" // Format: "It's 5 PM on a Thursday; 19-09-24"
        return "It's " + formatter.string(from: Date())
    }

    private var daysUntilNewYear: Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let newYearDate = calendar.date(from: DateComponents(year: currentYear + 1, month: 1, day: 1))!
        let days = calendar.dateComponents([.day], from: Date(), to: newYearDate).day ?? 0
        return days
    }
}

#Preview {
    DashboardView()
}
