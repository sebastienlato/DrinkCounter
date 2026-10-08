//
//  DrinkStore.swift
//  SipShip
//
//  Created by Sebastien Lato on 2026-02-13.
//

import Foundation
import SwiftData

struct DrinkStore {
    let context: ModelContext
    private let calendar = Calendar.current

    func addEvent(date: Date = Date()) throws {
        context.insert(DrinkEvent(date: date))
        try context.save()
    }

    func countAll() -> Int {
        let descriptor = FetchDescriptor<DrinkEvent>()
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    func count(in interval: DateInterval) -> Int {
        let start = interval.start
        let end = interval.end
        let predicate = #Predicate<DrinkEvent> { event in
            event.date >= start && event.date < end
        }
        let descriptor = FetchDescriptor<DrinkEvent>(predicate: predicate)
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    func events(in interval: DateInterval, descending: Bool = true, limit: Int? = nil) -> [DrinkEvent] {
        let start = interval.start
        let end = interval.end
        let predicate = #Predicate<DrinkEvent> { event in
            event.date >= start && event.date < end
        }
        var descriptor = FetchDescriptor<DrinkEvent>(predicate: predicate, sortBy: [SortDescriptor(\.date, order: descending ? .reverse : .forward)])
        if let limit {
            descriptor.fetchLimit = limit
        }
        return (try? context.fetch(descriptor)) ?? []
    }

    func mostRecentEvent(in interval: DateInterval?) -> DrinkEvent? {
        if let interval {
            return events(in: interval, descending: true, limit: 1).first
        } else {
            var descriptor = FetchDescriptor<DrinkEvent>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            descriptor.fetchLimit = 1
            return (try? context.fetch(descriptor))?.first
        }
    }

    func allEvents(descending: Bool = true) -> [DrinkEvent] {
        let descriptor = FetchDescriptor<DrinkEvent>(sortBy: [SortDescriptor(\.date, order: descending ? .reverse : .forward)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func delete(_ event: DrinkEvent) throws {
        context.delete(event)
        try context.save()
    }

    func deleteEvents(in interval: DateInterval) throws {
        let events = events(in: interval, descending: false)
        events.forEach { context.delete($0) }
        try context.save()
    }

    func deleteAll() throws {
        let descriptor = FetchDescriptor<DrinkEvent>()
        let events = (try? context.fetch(descriptor)) ?? []
        events.forEach { context.delete($0) }
        try context.save()
    }

    func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    func dayInterval(for date: Date) -> DateInterval {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        return DateInterval(start: start, end: end)
    }

    func weekInterval(containing date: Date) -> DateInterval {
        calendar.dateInterval(of: .weekOfYear, for: date) ?? DateInterval(start: date, end: date)
    }
}
