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
    private let BEEP: String = "prepare_beeps_pan_trim"
    private let BLIP: String = "blip_normal"
    private let BLIP_LOUD: String = "blip_loud"
    private let ARCHIVE: String = "archive_normal"
    private let ARCHIVE_LOUD: String = "archive_loud"
    private let ROUND_INCOMING: String = "round_incoming_normal"
    private let ROUND_INCOMING_LOUD: String = "round_incoming_loud"
    
    
    private override init() {
        super.init() // Call the NSObject initializer
        prepareAudioSession()
    }
    
    // Prepare the audio session in advance
    private func prepareAudioSession() {
        do {
            // Prepare the audio session with duckOthers so other audio doesn't interrupt
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to prepare audio session: \(error.localizedDescription)")
        }
    }
    
    // Preload the sound so it doesn't cause delays on the first play
    private func preloadSound(soundName: String, soundExtension: String = "mp3", completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let url = Bundle.main.url(forResource: soundName, withExtension: soundExtension) else {
                print("Sound file not found for preloading: \(soundName).\(soundExtension)")
                return
            }
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer?.prepareToPlay() // Preload and prepare the player
                DispatchQueue.main.async {
                    completion() // Call the completion handler after preparation
                }
            } catch {
                print("Failed to preload sound: \(error.localizedDescription)")
            }
        }
    }
    
    // Play a preloaded sound (ensures there's no delay when the sound starts)
    func playSound(soundName: String, soundExtension: String = "mp3") {
        DispatchQueue.global(qos: .userInitiated).async {
            if let player = self.audioPlayer, player.url?.lastPathComponent == "\(soundName).\(soundExtension)" {
                player.play() // Play the preloaded sound
            } else {
                // If not preloaded, load and play sound
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
    
    // Play the prepare beeps (using preloaded sound)
    func playPrepareBeeps() {
        playSound(soundName: BEEP)
    }
    
    func playBlip(loud: Bool = false) {
        if loud { playSound(soundName: BLIP_LOUD) }
        else { playSound(soundName: BLIP) }
    }
    
    func playArchive(loud: Bool = false) {
        if loud { playSound(soundName: ARCHIVE_LOUD) }
        else { playSound(soundName: ARCHIVE) }
    }
    
    func playRoundIncoming(loud: Bool = false) {
        if loud { playSound(soundName: ROUND_INCOMING_LOUD) }
        else { playSound(soundName: ROUND_INCOMING) }
    }
    
    // Play the prepare beeps (using preloaded sound)
    func preloadPrepareBeeps() {
        preloadSound(soundName: BEEP) { [weak self] in
            // Stop the sound after it has been prepared
            self?.stopSound()
        }
    }
    
    // Stop playing the current sound
    func stopSound() {
        audioPlayer?.stop()
        deactivateAudioSession()
    }
    
    // Deactivate audio session when done
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    // AVAudioPlayerDelegate method to detect when the sound finishes playing
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        deactivateAudioSession() // Restore the audio session when playback finishes
    }
}
