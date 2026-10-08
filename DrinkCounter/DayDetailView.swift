//
//  DayDetailView.swift
//  SipShip
//
//  Created by Sebastien Lato on 2026-02-13.
//

import SwiftUI
import SwiftData

struct DayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let date: Date

    private var store: DrinkStore {
        DrinkStore(context: modelContext)
    }

    private var events: [DrinkEvent] {
        let interval = store.dayInterval(for: date)
        return store.events(in: interval, descending: true)
    }

    var body: some View {
        List {
            if events.isEmpty {
                Text("No drinks logged.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(events, id: \.id) { event in
                    HStack {
                        Text(event.date, style: .time)
                            .font(.headline)
                        Spacer()
                        Text(event.date.formatted(date: .omitted, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Drink at \(event.date.formatted(date: .omitted, time: .shortened))")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
    }
}
