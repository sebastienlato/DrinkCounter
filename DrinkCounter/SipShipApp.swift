//
//  SipShipApp.swift
//  SipShip
//
//  Created by Sebastien Lato on 2026-02-13.
//

import SwiftUI
import SwiftData

@main
struct SipShipApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: DrinkEvent.self)
    }
}
