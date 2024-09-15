//
//  SoundManager.swift
//  WorkoutApp
//
//  Created by Yegor Yeryomenko on 2024-09-11.
//
import AVFoundation

class SoundManager: NSObject, AVAudioPlayerDelegate {
    static let instance = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private let soundFiles: [String: (normal: String, loud: String)] = [
        "BEEP": ("prepare_beeps_pan_trim", "prepare_beeps_pan_trim"),
        "BLIP": ("blip_normal", "blip_loud"),
        "ARCHIVE": ("archive_normal", "archive_loud"),
        "ROUND_INCOMING": ("round_incoming_normal", "round_incoming_loud"),
        "NEW_ROUND": ("xylophone_normal", "xylophone_loud")
    ]
    
    public var isLoud: Bool = false
    
    private override init() {
        super.init() // Call the NSObject initializer
        prepareAudioSession()
    }
    
    private func prepareAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to prepare audio session: \(error.localizedDescription)")
        }
    }
    
    private func preloadSound(soundName: String, soundExtension: String = "mp3", completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let url = Bundle.main.url(forResource: soundName, withExtension: soundExtension) else {
                print("Sound file not found for preloading: \(soundName).\(soundExtension)")
                return
            }
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer?.prepareToPlay()
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                print("Failed to preload sound: \(error.localizedDescription)")
            }
        }
    }
    
    func playSound(forKey key: String, soundExtension: String = "mp3") {
        guard let soundFile = soundFiles[key] else {
            print("Sound key not found: \(key)")
            return
        }
        
        let soundName = isLoud ? soundFile.loud : soundFile.normal
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let player = self.audioPlayer, player.url?.lastPathComponent == "\(soundName).\(soundExtension)" {
                player.play()
            } else {
                guard let url = Bundle.main.url(forResource: soundName, withExtension: soundExtension) else {
                    print("Sound file not found: \(soundName).\(soundExtension)")
                    return
                }
                
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer?.delegate = self
                    self.audioPlayer?.play()
                } catch {
                    print("Failed to play sound: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Play specific sounds using the new `playSound` method
    func playPrepareBeeps() {
        playSound(forKey: "BEEP")
    }
    
    func playBlip() {
        playSound(forKey: "BLIP")
    }
    
    func playStartFinishTimer() {
        playSound(forKey: "ARCHIVE")
    }
    
    func playRoundIncoming() {
        playSound(forKey: "ROUND_INCOMING")
    }
    
    func playNewRound() {
        playSound(forKey: "NEW_ROUND")
    }
    
    func preloadPrepareBeeps() {
        preloadSound(soundName: soundFiles["BEEP"]!.normal) { [weak self] in
            self?.stopSound()
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
        deactivateAudioSession()
    }
    
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        deactivateAudioSession()
    }
}
