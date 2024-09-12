////
////  AppDelegate.swift
////  WorkoutApp
////
////  Created by Yegor Yeryomenko on 2024-09-12.
////
//
//import SwiftUI
//import AVFoundation
//
//@main
//struct WorkoutApp: App {
//    // Connect the AppDelegate
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    
//    // Create the TimerModel instance here
//    @StateObject var timerModel = TimerModel()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView() // Root view
//                .environmentObject(timerModel) // Inject TimerModel as an environment object
//        }
//    }
//}
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("Failed to set audio session category: \(error.localizedDescription)")
//        }
//        return true
//    }
//}
