//
//  SideMenuView.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-19.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @Binding var selectedTab: Int
    @State private var selectedOption: SideMenuOptionModel?
    
    @Environment(\.colorScheme) var colorScheme // Detect light/dark mode
    
    var body: some View {
        ZStack {
            if isShowing {
                Color.black.opacity(0.3) // Use black with opacity for overlay
                    .ignoresSafeArea()
                    .onTapGesture { isShowing.toggle() }
                
                HStack {
                    VStack(alignment: .leading, spacing: 32) {
                        SideMenuHeaderView()
                        
                        VStack {
                            ForEach(SideMenuOptionModel.allCases) { option in
                                Button(action: {
                                    onOptionTapped(option)
                                }, label: {
                                    SideMenuRowView(option: option, selectedOption: $selectedOption)
                                })
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .frame(width: 270, alignment: .leading)
                    .background(colorScheme == .dark ? Color.black : Color.white) // Adaptive background color
                    .cornerRadius(10) // Add some rounding for aesthetics
                    
                    Spacer() // shove the SideMenu to the left
                }
                .transition(.move(edge: .leading)) // slide out from the left
            }
        }
        .animation(.easeInOut, value: isShowing)
    }
    
    private func onOptionTapped(_ option: SideMenuOptionModel) {
        selectedOption = option
        selectedTab = option.rawValue
        isShowing = false
    }
}

#Preview {
    SideMenuView(isShowing: .constant(true), selectedTab: .constant(0))
}
