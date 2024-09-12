//
//  ContentView.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-02.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerModel: TimerModel
    
    var body: some View {
        NavigationView {
            TimerSetUpView()
                .environmentObject(timerModel)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerModel())
}
