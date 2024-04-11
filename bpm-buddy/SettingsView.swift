//
//  SettingsView.swift
//  bpm-buddy
//
//  Created by Carlo Namoca on 2024-04-11.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var isOn: Bool = false
    @Binding var showSettings: Bool
    @AppStorage("lockButton") var lockButton: Bool = true
    @AppStorage("metronomeButton") var metronomeButton: Bool = true
    @AppStorage("halfButton") var halfButton: Bool = true
    @AppStorage("doubleButton") var doubleButton: Bool = true
    @AppStorage("theme") var selectedTheme: ColorTheme.RawValue = ColorTheme.basic.rawValue
    
    var body: some View {
        List {
            Text("SETTINGS")
                .font(.system(size: 16, weight: .heavy))
                .frame(maxWidth: .infinity)
                .overlay(
                    HStack {
                        Spacer()
                        
                        UtilityButton(bgColor: .clear) {
                            showSettings.toggle()
                        } content: {
                            Circle()
                                .fill(.clear)
                                .frame(height: 50)
                                .overlay(
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color(uiColor: .systemGray))
                                        .frame(height: 40)
                                )
                        }
                    }
                )
                .listRowBackground(Color.clear)
            
            Section(header: Text("Buttons")) {
                Toggle(isOn: $lockButton) {
                    Text("Lock Previous BPM")
                        .font(.system(size: 16, weight: .light))
                }
                
                Toggle(isOn: $metronomeButton) {
                    Text("Metronome")
                        .font(.system(size: 16, weight: .light))
                }
                
                Toggle(isOn: $halfButton) {
                    Text("1/2x BPM")
                        .font(.system(size: 16, weight: .light))
                }
                
                Toggle(isOn: $doubleButton) {
                    Text("2x BPM")
                        .font(.system(size: 16, weight: .light))
                }
            }
            
            // Integrate the theme selection directly into the same List as a separate Section
            Section(header: Text("Theme")) {
                ForEach(ColorTheme.allCases, id: \.self) { theme in
                    HStack {
                        Text(theme.rawValue.capitalizingFirstLetter())
                            .font(.system(size: 16, weight: .light))
                        Spacer()
                        if theme.rawValue == selectedTheme {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle()) // This makes the entire row tappable, not just the text
                    .onTapGesture {
                        selectedTheme = theme.rawValue
                    }
                }
            }
        }
        
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
