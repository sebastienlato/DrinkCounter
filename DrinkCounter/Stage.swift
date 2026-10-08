//
//  Stage.swift
//  SipShip
//
//  Created by Sebastien Lato on 2026-02-13.
//

import SwiftUI

enum Stage: Int, CaseIterable, Identifiable {
    case pure
    case warming
    case tipsy
    case goblin
    case wobbly
    case galaxy
    case alien
    case ufo

    var id: Int { rawValue }

    static func from(count: Int) -> Stage {
        switch count {
        case 0:
            return .pure
        case 1...2:
            return .warming
        case 3...4:
            return .tipsy
        case 5...6:
            return .goblin
        case 7...8:
            return .wobbly
        case 9...10:
            return .galaxy
        case 11...12:
            return .alien
        default:
            return .ufo
        }
    }

    var emoji: String {
        switch self {
        case .pure: return "😇"
        case .warming: return "🙂"
        case .tipsy: return "😏"
        case .goblin: return "🤪"
        case .wobbly: return "🥴"
        case .galaxy: return "🤯"
        case .alien: return "👽"
        case .ufo: return "🛸"
        }
    }

    var title: String {
        switch self {
        case .pure: return "Pure as Snow"
        case .warming: return "Warming Up"
        case .tipsy: return "Tipsy Wizard"
        case .goblin: return "Party Goblin"
        case .wobbly: return "Wobbly Mode"
        case .galaxy: return "Galaxy Brain"
        case .alien: return "Alien Social Hour"
        case .ufo: return "Out of This World"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .pure:
            return [Color(red: 0.75, green: 0.90, blue: 1.0), Color(red: 0.93, green: 0.98, blue: 1.0)]
        case .warming:
            return [Color(red: 0.96, green: 0.86, blue: 0.63), Color(red: 1.0, green: 0.74, blue: 0.80)]
        case .tipsy:
            return [Color(red: 0.96, green: 0.62, blue: 0.62), Color(red: 0.85, green: 0.62, blue: 0.96)]
        case .goblin:
            return [Color(red: 0.55, green: 0.89, blue: 0.60), Color(red: 0.33, green: 0.73, blue: 0.90)]
        case .wobbly:
            return [Color(red: 0.98, green: 0.78, blue: 0.44), Color(red: 0.96, green: 0.47, blue: 0.70)]
        case .galaxy:
            return [Color(red: 0.42, green: 0.40, blue: 0.96), Color(red: 0.18, green: 0.05, blue: 0.35)]
        case .alien:
            return [Color(red: 0.25, green: 0.78, blue: 0.74), Color(red: 0.12, green: 0.45, blue: 0.30)]
        case .ufo:
            return [Color(red: 0.16, green: 0.12, blue: 0.35), Color(red: 0.06, green: 0.04, blue: 0.16)]
        }
    }

    var sparkleIntensity: Double {
        switch self {
        case .galaxy: return 0.6
        case .alien: return 0.8
        case .ufo: return 1.0
        default: return 0.0
        }
    }
}
