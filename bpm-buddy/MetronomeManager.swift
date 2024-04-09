//
//  MetronomeManager.swift
//  bpm-buddy
//
//  Created by Carlo Namoca on 2024-04-09.
//

import Foundation

class MetronomeManager: ObservableObject {
    private var timer: Timer?
    private var bpm: Double
    @Published var isRunning = false

    init(bpm: Double) {
        self.bpm = bpm
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
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func tick() {
        // This method gets called on each metronome tick.
        // Use it to update UI or play a sound.
        print("Metronome Tick - BPM: \(bpm)")
    }

    // Adjust BPM and restart metronome if it's running
    func adjustBPM(to newBPM: Double) {
        bpm = newBPM
        startMetronome()
    }
}
