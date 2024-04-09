//
//  UtilityButton.swift
//  bpm-buddy
//
//  Created by Carlo Namoca on 2024-04-09.
//

import SwiftUI

struct UtilityButton: View {
    
    var title: String
    var bgColor: Color
    var textColor: Color
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Circle()
                .fill(bgColor)
                .frame(height: 50)
                .opacity(0.8)
                .overlay(
                    Text(title)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(textColor)
                )
            
        }
    }
}
