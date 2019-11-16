//
//  SoundManager.swift
//  UnHindr
//
//  Created by Jordan Kam on 2019-11-15.
//  Copyright © 2019 Sigma. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager {
    
    static var audioPlayer:AVAudioPlayer?
    
    enum SoundEffect {
    
    case flip
    case shuffle
    case match
    case nomatch
    
    
    }
    
    static func playSound(_ effect:SoundEffect) {
        
        var soundFilename = ""
        
        //determine which sound effect to play
        //set the appropriate file name
        switch effect {
            
        case .flip:
            soundFilename = "cardflip"
            
        case .shuffle:
            soundFilename = "shuffle"
            
        case .match:
            soundFilename = "dingcorrect"
            
        case .nomatch:
            soundFilename = "dingwrong"
            
        }
        
        //get the path to the sound file inside the bundle
        let bundlePath = Bundle.main.path(forResource: soundFilename, ofType: "wav")
        
        guard bundlePath != nil else {
            print("Couldnt find the sound file \(soundFilename) in the bundle")
            return
        }
        
        //create a URL object from this string path
        let soundURL = URL(fileURLWithPath: bundlePath!)
        
        do {
            //create an audio player object
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            
            //play the sound
            audioPlayer?.play()
        }
        catch {
            //could not create audio player object
            //log error
            print("Couldnt create the audio player object for sound file \(soundFilename)")
        }
        
        
        
    }
}
