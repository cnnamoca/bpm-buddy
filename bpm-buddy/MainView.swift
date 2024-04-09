//
//  ContentView.swift
//  bpm-buddy
//
//  Created by Carlo Namoca on 2024-04-08.
//

import SwiftUI

struct MainView: View {
    
    @State var bpm: Float = 0
    @State var lastBpm: Float = 0
    @State private var tapTimes: [Date] = []
    @State private var tapLocation: CGPoint = .zero
    @State private var circles: [AnimatingCircle] = []
    @State private var lastDragValue: CGFloat = 0
    
    // Friction factor to control swipe sensitivity
    private let frictionFactor: CGFloat = 10.0
    
    var body: some View {
        ZStack {
            
            ForEach(circles) { _ in
                CircleView()
            }
            
            VStack {
                Text(String(format: "%.1f", bpm))
                    .font(.system(size: 80, weight: .bold))
                Text(String(format: "%.1f", lastBpm))
                    .font(.system(size: 40, weight: .medium))
            }
            
            Color.clear
                .contentShape(Rectangle())
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    addCircle()
                    calculateBPM()
                }
                .gesture(swipeGesture)
            
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    
                    Spacer()
                    
                    UtilityButton(title: "1/2x") {
                        bpm = bpm/2
                    }
                    
                    UtilityButton(title: "2x") {
                        bpm = bpm*2
                    }
                }
            }
        }
        
    }
    
    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let dragDifference = (lastDragValue - value.translation.height) / frictionFactor
                if abs(dragDifference) > 1 { // Adjust this threshold as needed
                    bpm += Float(dragDifference) * 0.1 // Adjust BPM based on scaled drag difference
                    lastDragValue = value.translation.height
                    triggerHaptics()
                }
                
            }
            .onEnded { _ in
                lastDragValue = 0 // Reset the drag value after the gesture ends
            }
    }
    
    private struct UtilityButton: View {
        
        var title: String
        var action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                Circle()
                    .fill(.pink)
                    .frame(height: 50)
                    .opacity(0.8)
                    .overlay(
                        Text(title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    )
                
            }
        }
    }
    
    // MARK: - Private functions
    private func addCircle() {
        let newCircle = AnimatingCircle()
        circles.append(newCircle)
        // Remove circle after animation so they don't accumulate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            circles.removeAll { $0.id == newCircle.id }
        }
    }
    
    private func calculateBPM() {
        let now = Date()
        
        // Add the current tap time to the record
        tapTimes.append(now)
        
        // Check if the last interval is too long; if so, start anew
        if tapTimes.count > 1 {
            let interval = now.timeIntervalSince(tapTimes[tapTimes.count - 2])
            if interval > 2 {
                lastBpm = bpm
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
        
        // Vibrate on that ish
        triggerHaptics()
    }
    
    private func triggerHaptics() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    MainView()
}
