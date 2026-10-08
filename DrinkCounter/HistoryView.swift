//
//  HistoryView.swift
//  SipShip
//
//  Created by Sebastien Lato on 2026-02-13.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var store: DrinkStore {
        DrinkStore(context: modelContext)
    }

    private var daysWithDrinks: [DayCount] {
        let events = store.allEvents(descending: true)
        let grouped = Dictionary(grouping: events) { event in
            store.startOfDay(for: event.date)
        }
        return grouped
            .map { DayCount(date: $0.key, count: $0.value.count) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            if daysWithDrinks.isEmpty {
                Text("No drinks logged yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(daysWithDrinks) { day in
                    NavigationLink {
                        DayDetailView(date: day.date)
                    } label: {
                        HStack {
                            Text(day.date, style: .date)
                                .font(.headline)
                            Spacer()
                            Text("\(day.count)")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityLabel("\(day.date.formatted(date: .abbreviated, time: .omitted)), \(day.count) drinks")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("History")
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: daysWithDrinks.map { $0.count })
    }
}
