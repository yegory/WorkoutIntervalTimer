//
//  ProgressBarView.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-19.
//

import SwiftUI

struct ProgressBarView: View {
    
    var width: CGFloat = 300
    var height: CGFloat = 50
    var percent: CGFloat = 70
    var backgroundColor = Color("DarkVioletAsset")
    var colorFrom = Color("VioletAsset")
    var colorTo = Color("BrightVioletAsset")
    var multiplier: CGFloat {
        width / 100
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height, style: .continuous)
                .frame(width: width, height: height)
                .foregroundColor(backgroundColor.opacity(0.85))
            
            RoundedRectangle(cornerRadius: height, style: .continuous)
                .frame(width: percent * multiplier, height: height)
                .background(
                    LinearGradient(gradient: Gradient(colors: [colorFrom, colorTo]), 
                                   startPoint: .leading,
                                   endPoint: .trailing
                                  )
                        .clipShape(RoundedRectangle(cornerRadius: height, style: .continuous))
                )
                .foregroundColor(.clear)
        }
    }
}

#Preview {
    ProgressBarView()
}
