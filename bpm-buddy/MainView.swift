//
//  ContentView.swift
//  bpm-buddy
//
//  Created by Carlo Namoca on 2024-04-08.
//

import SwiftUI

struct MainView: View {
    
    @State private var bpm: Float = 0
    @State private var lastBpm: Float = 0
    @State private var tapTimes: [Date] = []
    @State private var tapLocation: CGPoint = .zero
    @State private var circles: [AnimatingCircle] = []
    @State private var lastDragValue: CGFloat = 0
    @State private var isLocked: Bool = false
    @State private var showSettings: Bool = false
    
    @StateObject private var metronomeManager = MetronomeManager(bpm: 120)
    
    @AppStorage("lockButton") var lockButton: Bool = true
    @AppStorage("metronomeButton") var metronomeButton: Bool = true
    @AppStorage("halfButton") var halfButton: Bool = true
    @AppStorage("doubleButton") var doubleButton: Bool = true
    @AppStorage("theme") var selectedTheme: ColorTheme.RawValue = ColorTheme.basic.rawValue
    
    
    private let frictionFactor: CGFloat = 10.0 // Friction factor to control swipe sensitivity
    private let minBPM: Float = 0
    private let maxBPM: Float = 999
    
    var body: some View {
        ZStack {
            
            let currentTheme = ColorTheme(rawValue: selectedTheme) ?? .basic
            
            currentTheme.primaryColor
                .ignoresSafeArea()
            
            ForEach(circles) { _ in
                CircleView(color: currentTheme.secondaryColor)
            }
            
            VStack {
                Text(String(format: "%.1f", bpm))
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(currentTheme.accentColor)
                Text(String(format: "%.1f", lastBpm))
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(currentTheme.accentColor)
            }
            
            Color.clear
                .contentShape(Rectangle())
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    addCircle()
                    calculateBPM()
                }
                .gesture(swipeGesture)
            
            // Side Buttons
            VStack {
                
                HStack {
                    
                    Spacer()
                    
                    UtilityButton(bgColor: .clear) {
                        // Make sure these buttons are off
                        isLocked = false
                        if metronomeManager.isRunning {
                            metronomeManager.toggleMetronome()
                        }
                        // Toggle settings view
                        showSettings.toggle()
                    } content: {
                        Circle()
                            .fill(.clear)
                            .frame(height: 50)
                            .overlay(
                                Image(systemName: "gearshape.fill")
                                    .foregroundStyle(currentTheme.accentColor)
                                    .frame(height: 40)
                            )
                    }
                }
                
                
                Spacer()
                
                HStack(spacing: 16) {
                    
                    if lockButton {
                        UtilityButton(bgColor: currentTheme.secondaryColor) {
                            isLocked.toggle()
                        } content: {
                            Circle()
                                .fill(isLocked ? currentTheme.secondaryColor : .gray)
                                .frame(height: 50)
                                .overlay(
                                    Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                                        .foregroundStyle(isLocked ? currentTheme.accentColor : .white)
                                        .frame(height: 40)
                                )
                        }
                    }
                    
                    if metronomeButton {
                        UtilityButton(bgColor: currentTheme.secondaryColor) {
                            if metronomeManager.isRunning {
                                // If the metronome is currently running, stop it.
                                metronomeManager.toggleMetronome()
                            } else {
                                // If the metronome is not running, adjust BPM (if needed) and start it.
                                metronomeManager.adjustBPM(to: Double(bpm))
                            }
                        } content: {
                            Circle()
                                .fill(metronomeManager.isRunning ? currentTheme.secondaryColor : .gray)
                                .frame(height: 50)
                                .overlay(
                                    Image(systemName: "metronome.fill")
                                        .foregroundStyle(metronomeManager.isRunning ? currentTheme.accentColor : .white)
                                        .frame(height: 40)
                                )
                        }
                    }
                    
                    if halfButton {
                        UtilityButton(bgColor: currentTheme.secondaryColor) {
                            adjustBPM(by: 0.5)
                        } content: {
                            Text("1/2x")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(currentTheme.accentColor)
                        }
                    }
                    
                    if doubleButton {
                        UtilityButton(bgColor: currentTheme.secondaryColor) {
                            adjustBPM(by: 2)
                        } content: {
                            Text("2x")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(currentTheme.accentColor)
                        }
                    }
                    
                }
            }
            .padding()
        }
        .sheet(isPresented: $showSettings, content: {
            SettingsView(showSettings: $showSettings)
        })
        
    }
    
    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let dragDifference = (lastDragValue - value.translation.height) / frictionFactor
                if abs(dragDifference) > 1 { // Adjust this threshold as needed
                    let newBPM = bpm + Float(dragDifference) * 0.1 // Calculate new BPM based on drag
                    bpm = min(max(newBPM, minBPM), maxBPM)
                    lastDragValue = value.translation.height
                    triggerHaptics()
                }
            }
            .onEnded { _ in
                lastDragValue = 0 // Reset the drag value after the gesture ends
            }
    }
    
    // MARK: - Private functions
    private func adjustBPM(by factor: Float) {
        if metronomeManager.isRunning { metronomeManager.toggleMetronome() }
        bpm *= factor
    }
    
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
                
                // Lock mechanism for temporarily saving previous bpm
                if !isLocked { lastBpm = bpm }
                
                tapTimes = [tapTimes.last!]
            }
        }
        
        // Proceed with BPM calculation if we have at least 3 taps
        if tapTimes.count >= 3 {
            let intervals = zip(tapTimes, tapTimes.dropFirst()).map { $1.timeIntervalSince($0) }
            if let averageInterval = intervals.dropFirst().reduce(0, +) / Double(intervals.count - 1) as Double? {
                let newBPM = Float(60.0 / averageInterval)
                bpm = max(min(newBPM, 999), 0)
                
                // Reset metronome
                if metronomeManager.isRunning {
                    metronomeManager.toggleMetronome()
                }
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
