//
//  DrinkViewModel.swift
//  SipShip
//
//  Created by Sebastien Lato on 2026-02-13.
//

import SwiftUI
import UIKit
import Combine

@MainActor
final class DrinkViewModel: ObservableObject {
    enum Scope: String, CaseIterable, Identifiable {
        case today
        case week
        case lifetime

        var id: String { rawValue }

        var title: String {
            switch self {
            case .today: return "Today"
            case .week: return "Week"
            case .lifetime: return "Lifetime"
            }
        }
    }

    @AppStorage("drinkCount") var drinkCount: Int = 0 {
        willSet { objectWillChange.send() }
    }

    @AppStorage("lastMessage") var lastMessage: String = "Ready for liftoff. Tap + Drink to log your first sip." {
        willSet { objectWillChange.send() }
    }

    @AppStorage("lastWaterWarningShownAtCount") var lastWaterWarningShownAtCount: Int = 0 {
        willSet { objectWillChange.send() }
    }

    @AppStorage("selectedScope") private var selectedScopeRaw: String = Scope.today.rawValue

    @Published var messageChangeToken: Int = 0
    @Published var hydrationBannerToken: Int = 0
    @Published var todayCount: Int = 0
    @Published var weekCount: Int = 0
    @Published var lifetimeCount: Int = 0
    @Published var last7Days: [DayCount] = []
    @Published var selectedScope: Scope = .today {
        didSet {
            selectedScopeRaw = selectedScope.rawValue
            refreshCounts()
        }
    }

    private var store: DrinkStore?
    private let calendar = Calendar.current

    init() {
        if let scope = Scope(rawValue: selectedScopeRaw) {
            selectedScope = scope
        }
    }

    var selectedScopeCount: Int {
        switch selectedScope {
        case .today: return todayCount
        case .week: return weekCount
        case .lifetime: return lifetimeCount
        }
    }

    var stage: Stage {
        Stage.from(count: selectedScopeCount)
    }

    var shouldShowHydrationWarning: Bool {
        selectedScopeCount >= 4 && selectedScopeCount % 4 == 0 && lastWaterWarningShownAtCount == selectedScopeCount
    }

    func attachStore(_ store: DrinkStore) {
        self.store = store
        refreshCounts()
    }

    func increment() {
        guard let store else { return }
        do {
            try store.addEvent(date: Date())
        } catch {
            return
        }

        refreshCounts()
        let shouldWarnHydration = selectedScopeCount >= 4 && selectedScopeCount % 4 == 0 && selectedScopeCount != lastWaterWarningShownAtCount
        if shouldWarnHydration {
            lastWaterWarningShownAtCount = selectedScopeCount
            hydrationBannerToken += 1
            triggerHaptic(style: .heavy)
        } else {
            triggerHaptic(style: .medium)
        }

        let todayStage = Stage.from(count: todayCount)
        let includeHydration = shouldWarnHydration || Bool.random()
        lastMessage = QuipGenerator.makeQuip(stage: todayStage, count: todayCount, includeHydration: includeHydration)
        messageChangeToken += 1
    }

    func decrement() {
        guard let store else { return }
        guard let interval = intervalForSelectedScope() else {
            if let event = store.mostRecentEvent(in: nil) {
                try? store.delete(event)
                refreshCounts()
                triggerHaptic(style: .light)
            }
            return
        }

        if let event = store.mostRecentEvent(in: interval) {
            try? store.delete(event)
            refreshCounts()
            triggerHaptic(style: .light)
        }
    }

    func resetSelectedScope() {
        guard let store else { return }
        if let interval = intervalForSelectedScope() {
            try? store.deleteEvents(in: interval)
        } else {
            try? store.deleteAll()
        }
        lastWaterWarningShownAtCount = 0
        lastMessage = "Reset complete. Fresh mission, clean slate."
        messageChangeToken += 1
        refreshCounts()
        triggerHaptic(style: .soft)
    }

    func refreshCounts() {
        guard let store else { return }
        let now = Date()
        let todayInterval = store.dayInterval(for: now)
        let weekInterval = store.weekInterval(containing: now)

        todayCount = store.count(in: todayInterval)
        weekCount = store.count(in: weekInterval)
        lifetimeCount = store.countAll()
        last7Days = makeLast7Days(store: store, from: now)

        drinkCount = selectedScopeCount
    }

    private func makeLast7Days(store: DrinkStore, from date: Date) -> [DayCount] {
        let todayStart = store.startOfDay(for: date)
        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: todayStart) else { return nil }
            let interval = store.dayInterval(for: day)
            let count = store.count(in: interval)
            return DayCount(date: day, count: count)
        }.reversed()
    }

    private func intervalForSelectedScope() -> DateInterval? {
        guard let store else { return nil }
        let now = Date()
        switch selectedScope {
        case .today:
            return store.dayInterval(for: now)
        case .week:
            return store.weekInterval(containing: now)
        case .lifetime:
            return nil
        }
    }

    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
