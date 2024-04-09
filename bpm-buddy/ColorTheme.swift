//
//  ColorTheme.swift
//  bpm-buddy
//
//  Created by Carlo Namoca on 2024-04-09.
//

import Foundation
import SwiftUI

enum ColorTheme: String, CaseIterable {
    case grass
    case sakura
    case utility
    case egg
    case piano

    var primaryColor: Color {
        switch self {
        case .grass:
            return Color(hex: "#DDE392")
        case .sakura:
            return Color(hex: "#F7EBEC")
        case .utility:
            return Color(hex: "#7E8287")
        case .egg:
            return Color(hex: "#423E37")
        case .piano:
            return Color(hex: "#DCDCDD")
        }
    }

    var secondaryColor: Color {
        switch self {
        case .grass:
            return Color(hex: "#AFBE8F")
        case .sakura:
            return Color(hex: "#DDBDD5")
        case .utility:
            return Color(hex: "#F86624")
        case .egg:
            return Color(hex: "#E3B23C")
        case .piano:
            return Color(hex: "#C5C3C6")
        }
    }

    var accentColor: Color {
        switch self {
        case .grass:
            return Color(hex: "#7D8570")
        case .sakura:
            return Color(hex: "#AC9FBB")
        case .utility:
            return Color(hex: "#272932")
        case .egg:
            return Color(hex: "#EDEBD7")
        case .piano:
            return Color(hex: "#46494C")
        }
    }
}

import SwiftUI

extension Color {
    init(hex: String, alpha: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (UInt64(alpha * 15), (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (UInt64(alpha * 255), int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0) // Default to yellow if incorrect hex format
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
