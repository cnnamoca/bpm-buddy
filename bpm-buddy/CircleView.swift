//
//  CircleView.swift
//  bpm-buddy
//
//  Created by Carlo Namoca on 2024-04-09.
//

import SwiftUI

struct CircleView: View {

    @State private var showCircle: Bool = true
    @State private var circleScale: CGFloat = 0.0
    var color: Color

    var body: some View {
        Circle()
            .frame(width: 300, height: 300)
            .foregroundColor(color)
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
