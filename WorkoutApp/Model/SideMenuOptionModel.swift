//
//  SideMenuOptionModel.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-19.
//

import Foundation

enum SideMenuOptionModel: Int, CaseIterable {
    case dashboard
    case timer
    case performance
    case exercises
    case notification
    
    var title: String {
        switch self {
            case .dashboard:        return "DashBoard"
            case .timer:            return "Timer"
            case .performance:      return "Performance"
            case .exercises:        return "Exercises"
            case .notification:     return "Notifications"
        }
    }
    
    var systemImageName: String {
        switch self {
            case .dashboard:        return "filemenu.and.cursorarrow"
            case .timer:            return "timer"
            case .performance:      return "chart.bar"
            case .exercises:        return "figure.strengthtraining.traditional"
            case .notification:     return "bell"
        }
    }
}

extension SideMenuOptionModel: Identifiable {
    var id: Int { return self.rawValue}
}
