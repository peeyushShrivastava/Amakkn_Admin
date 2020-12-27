//
//  Audio.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import UIKit
import Foundation
import AVFoundation

class AppAudio: NSObject {
    static let manager = AppAudio()
    private var objPlayer: AVAudioPlayer?

    private override init() { }

    func play(_ audioFile: String) {
        guard let url = Bundle.main.url(forResource: audioFile, withExtension: "caf") else { return }

        do {
            try  AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)

            try AVAudioSession.sharedInstance().setActive(true)

            objPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            objPlayer?.delegate = self

            guard let aPlayer = objPlayer else { return }

            aPlayer.play()
        } catch _ { }
    }
}

// MARK: - AVAudioPlayer Delegate
extension AppAudio: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch _ { }
    }
}
