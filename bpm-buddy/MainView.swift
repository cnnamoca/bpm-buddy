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
    @State private var tapLocation: CGPoint = .zero
    @State private var circles: [AnimatingCircle] = []
    
    var body: some View {
        ZStack {
            VStack {
                Text("TAP")
                Text(String(format: "%.1f BPM", bpm))
            }
            
            Color.clear
                .contentShape(Rectangle())
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    addCircle()
                    calculateBPM()
                }
            
            ForEach(circles) { _ in
                CircleView()
            }
        }
    }
    
    private func addCircle() {
        let newCircle = AnimatingCircle()
        circles.append(newCircle)
        // Optionally, remove circle after animation if you don't want them to accumulate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
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
            if interval > 1.0 {
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

struct CircleView: View {
    @State private var showCircle: Bool = true
    @State private var circleScale: CGFloat = 0.0

    var body: some View {
        Circle()
            .frame(width: 300, height: 300)
            .foregroundColor(.pink)
            .scaleEffect(circleScale)
            .opacity(showCircle ? 0.4 : 0.0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    circleScale = 2.0
                    showCircle = false
                }
            }
    }
}

struct AnimatingCircle: Identifiable {
    let id: UUID = UUID()
}

#Preview {
    MainView()
}
