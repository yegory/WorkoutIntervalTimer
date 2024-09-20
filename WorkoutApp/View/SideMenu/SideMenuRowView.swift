//
//  SideMenuRowView.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-19.
//

import SwiftUI

struct SideMenuRowView: View {
    let option: SideMenuOptionModel
    @Binding var selectedOption: SideMenuOptionModel?
    
    private var isSelected: Bool {
        selectedOption == option
    }
    
    @Environment(\.colorScheme) var colorScheme // Detect light/dark mode
    
    var body: some View {
        HStack {
            Image(systemName: option.systemImageName)
                .imageScale(.small)
                .foregroundColor(isSelected ? .blue : .primary) // Adaptive icon color
            
            Text(option.title)
                .font(.subheadline)
                .foregroundColor(isSelected ? .blue : .primary) // Adaptive text color
            
            Spacer()
        }
        .padding(.leading)
        .frame(width: 216, height: 44)
        .background(isSelected ? Color.blue.opacity(0.15) : Color.clear) // Highlight for selected
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    SideMenuRowView(option: .dashboard, selectedOption: .constant(.dashboard)) // selected option == option
}
