//
//  SideMenuHeaderView.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-19.
//

import SwiftUI

struct SideMenuHeaderView: View {
    @Environment(\.colorScheme) var colorScheme // Detect light/dark mode

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .imageScale(.large)
                .foregroundStyle(colorScheme == .dark ? .white : .blue)
                .frame(width: 48, height: 48)
                .background(colorScheme == .dark ? Color.blue : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Yegor Y.")
                    .font(.subheadline)
                    .foregroundColor(.primary) // Adaptive text color
                
                Text("mail@gmail.com")
                    .font(.footnote)
                    .foregroundColor(.secondary) // Adaptive secondary text
            }
        }
    }
}

#Preview {
    SideMenuHeaderView()
}
