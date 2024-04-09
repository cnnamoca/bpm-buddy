//
//  ColourTheme.swift
//  bpm-buddy
//
//  Created by Carlo Namoca on 2024-04-09.
//

import Foundation
import SwiftUI

enum ColourTheme: String, CaseIterable {
    case classic
    case dark
    case light

    var primaryColor: Color {
        switch self {
        case .classic:
            return Color.red
        case .dark:
            return Color.black
        case .light:
            return Color.white
        }
    }

    var secondaryColor: Color {
        switch self {
        case .classic:
            return Color.green
        case .dark:
            return Color.gray
        case .light:
            return Color.blue
        }
    }

    var accentColor: Color {
        switch self {
        case .classic:
            return Color.blue
        case .dark:
            return Color.purple
        case .light:
            return Color.yellow
        }
    }
}
