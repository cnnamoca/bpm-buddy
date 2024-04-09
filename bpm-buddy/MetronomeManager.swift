//
//  MetronomeManager.swift
//  bpm-buddy
//
//  Created by Carlo Namoca on 2024-04-09.
//

import Foundation
import AVFoundation

class MetronomeManager: ObservableObject {
    private var timer: Timer?
    private var bpm: Double
    private var player: AVAudioPlayer?
    @Published var isRunning = false

    init(bpm: Double) {
        self.bpm = bpm
        
        guard let url = Bundle.main.url(forResource: "metronome", withExtension: "wav") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            player?.prepareToPlay()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func toggleMetronome() {
        if isRunning {
            stopMetronome()
        } else {
            startMetronome()
        }
    }

    private func startMetronome() {
        isRunning = true
        let interval = 60.0 / bpm
        // Ensure timer is operated on the main thread because it updates the UI
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.tick()
            }
        }
    }

    private func stopMetronome() {
        player?.stop()
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func tick() {
        print("Metronome Tick - BPM: \(bpm)")
        player?.currentTime = 0
        player?.play()
    }

    // Adjust BPM and restart metronome if it's running
    func adjustBPM(to newBPM: Double) {
        bpm = newBPM
        startMetronome()
    }
}
