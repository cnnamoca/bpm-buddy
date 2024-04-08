//
//  ContentView.swift
//  bpm-buddy
//
//  Created by Carlo Namoca on 2024-04-08.
//

import SwiftUI

struct MainView: View {
    
    @State var bpm: Float = 0
    @State private var tapTimes: [Date] = []
    
    var body: some View {
        ZStack {
            
            VStack {
                Text("TAP")
                Text(String(format: "%.1f BPM", bpm))
            }
            
            // Full-screen transparent overlay that captures taps
            Color.clear
                .contentShape(Rectangle())
                .edgesIgnoringSafeArea(.all)
                .gesture(tapGesture)
            
        }
    }
    
    var tapGesture: some Gesture {
        TapGesture()
            .onEnded { _ in
                print("Overlay tapped")
                calculateBPM()
            }
    }
    
    private func calculateBPM() {
        let now = Date()
        
        // Add the current tap time to the record
        tapTimes.append(now)
        
        // Check if the last interval is too long; if so, start anew
        if tapTimes.count > 1 {
            let interval = now.timeIntervalSince(tapTimes[tapTimes.count - 2])
            if interval > 2.0 {
                tapTimes = [tapTimes.last!]
            }
        }
        
        // Proceed with BPM calculation if we have at least 3 taps
        if tapTimes.count >= 3 {
            let intervals = zip(tapTimes, tapTimes.dropFirst()).map { $1.timeIntervalSince($0) }
            if let averageInterval = intervals.dropFirst().reduce(0, +) / Double(intervals.count - 1) as Double? {
                bpm = Float(60.0 / averageInterval)
            }
        }
        
        // Trigger haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    MainView()
}
