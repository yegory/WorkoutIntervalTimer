//
//  SoundManager.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-11.
//

import SwiftUI
import AVKit

class SoundManager {
    static let instance = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    func playSound(soundName: String, soundExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: soundExtension) else {
            print("Sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
    }
    
    func playPrepareBeeps() {
        SoundManager.instance.playSound(soundName: "prepare_beeps")
    }
}
