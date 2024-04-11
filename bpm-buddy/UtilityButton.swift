//
//  UtilityButton.swift
//  bpm-buddy
//
//  Created by Carlo Namoca on 2024-04-09.
//

import SwiftUI

struct UtilityButton<Label>: View where Label: View {
    
    var bgColor: Color
    var action: () -> Void
    var content: () -> Label
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(bgColor)
                .frame(height: 50)
                .opacity(0.8)
                .overlay(content())
        }
    }
}
