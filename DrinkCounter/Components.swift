//
//  Components.swift
//  SipShip
//
//  Created by Sebastien Lato on 2026-02-13.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)

            content
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
        .accessibilityElement(children: .contain)
    }
}

struct SipButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .padding(.vertical, 12)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(tint.gradient)
            )
            .foregroundStyle(.white)
            .shadow(color: tint.opacity(0.35), radius: 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct MetricChip: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }
}

struct SevenDayBarChart: View {
    let days: [DayCount]

    private var maxValue: Int {
        max(days.map { $0.count }.max() ?? 1, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(days) { day in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.white.opacity(0.85))
                        .frame(height: barHeight(for: day.count))
                        .accessibilityHidden(true)
                    Text(day.date.formatted(.dateTime.weekday(.narrow)))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(day.date.formatted(.dateTime.weekday(.wide))), \(day.count) drinks")
            }
        }
        .frame(height: 110)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Last seven days drink counts")
    }

    private func barHeight(for value: Int) -> CGFloat {
        let ratio = CGFloat(value) / CGFloat(maxValue)
        return max(12, ratio * 70)
    }
}

struct SparkleField: View {
    let intensity: Double
    let reduceMotion: Bool

    private let sparkles: [Sparkle] = {
        var generator = SeededGenerator(seed: 42)
        return (0..<28).map { index in
            Sparkle(
                id: index,
                x: Double.random(in: 0.05...0.95, using: &generator),
                y: Double.random(in: 0.05...0.95, using: &generator),
                size: Double.random(in: 1.0...3.2, using: &generator),
                phase: Double.random(in: 0.0...Double.pi * 2, using: &generator)
            )
        }
    }()

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                guard intensity > 0 else { return }
                let time = timeline.date.timeIntervalSinceReferenceDate
                for sparkle in sparkles {
                    let flicker = reduceMotion ? 0.8 : (0.6 + 0.4 * sin(time * 2.0 + sparkle.phase))
                    let alpha = max(0.0, flicker) * intensity
                    let rect = CGRect(
                        x: sparkle.x * size.width,
                        y: sparkle.y * size.height,
                        width: sparkle.size,
                        height: sparkle.size
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(alpha)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct SparkleBurst: View {
    let trigger: Int
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 6, height: 6)
                    .offset(x: burstOffset(index: index).x, y: burstOffset(index: index).y)
            }
        }
        .scaleEffect(animate ? 1.0 : 0.2)
        .opacity(animate ? 0.0 : 1.0)
        .animation(.easeOut(duration: 0.6), value: animate)
        .onAppear { fire() }
        .onChange(of: trigger) {
            fire()
        }
        .allowsHitTesting(false)
    }

    private func fire() {
        animate = false
        withAnimation(.easeOut(duration: 0.6)) {
            animate = true
        }
    }

    private func burstOffset(index: Int) -> CGPoint {
        let angle = Double(index) / 10.0 * Double.pi * 2.0
        let radius = 26.0
        return CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
    }
}

struct DayCount: Identifiable {
    let date: Date
    let count: Int

    var id: Date { date }
}

private struct Sparkle: Identifiable {
    let id: Int
    let x: Double
    let y: Double
    let size: Double
    let phase: Double
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}
