//
//  DrinkEvent.swift
//  SipShip
//
//  Created by Sebastien Lato on 2026-02-13.
//

import Foundation
import SwiftData

@Model
final class DrinkEvent {
    var id: UUID
    var date: Date

    init(date: Date) {
        self.id = UUID()
        self.date = date
    }
}
