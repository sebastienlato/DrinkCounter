//
//  QuipGenerator.swift
//  SipShip
//
//  Created by Sebastien Lato on 2026-02-13.
//

import Foundation

struct QuipGenerator {
    static func makeQuip(stage: Stage, count: Int, includeHydration: Bool) -> String {
        let mood = stageMood[stage] ?? "balanced"
        let opener = openers.randomElement() ?? "Update:"
        let subject = subjects.randomElement() ?? "Crew"
        let action = actions.randomElement() ?? "Cruising smoothly"
        let vibe = vibes.randomElement() ?? "Keep it light."
        let closer = closers.randomElement() ?? "Easy pace, good choices."
        let safety = safetyNotes.randomElement() ?? "Take breaks and keep it safe."
        let hydration = includeHydration ? " " + (hydrationNotes.randomElement() ?? "Hydration check: water is a win.") : ""

        let templates = [
            "\(opener) \(subject) is \(mood). \(action) \(vibe)\(hydration)",
            "Status check: \(subject) is \(mood). \(action) \(closer)\(hydration)",
            "\(opener) \(vibe) \(safety)\(hydration)",
            "Mission log \(count): \(subject) feels \(mood). \(action) \(safety)\(hydration)"
        ]

        return templates.randomElement() ?? "All systems nominal."
    }

    private static let stageMood: [Stage: String] = [
        .pure: "fresh and focused",
        .warming: "cozy and upbeat",
        .tipsy: "playfully tilted",
        .goblin: "sparkly and rowdy",
        .wobbly: "floaty and giggly",
        .galaxy: "cosmic and curious",
        .alien: "otherworldly and chatty",
        .ufo: "interstellar and untouchable"
    ]

    private static let openers = [
        "Captain's log:",
        "Ship note:",
        "Fun fact:",
        "Telemetry:",
        "Crew update:",
        "Navigation ping:",
        "Orbit report:",
        "Status pulse:"
    ]

    private static let subjects = [
        "The crew",
        "Your vibe",
        "This mission",
        "The dashboard",
        "The snack officer",
        "The co-pilot",
        "The party radar",
        "The comet crew"
    ]

    private static let actions = [
        "Gliding with style",
        "Keeping the tempo chill",
        "Staying in the fun lane",
        "Balancing laughs and calm",
        "Holding a steady orbit",
        "Cruising at safe speed",
        "Tuning the mood thrusters",
        "Choosing the scenic route",
        "Making room for snacks",
        "Plotting a cozy trajectory"
    ]

    private static let vibes = [
        "Tiny sips, big smiles.",
        "Smooth skies ahead.",
        "All good things in moderation.",
        "A little sparkle goes a long way.",
        "Comfort mode engaged.",
        "Keep it light and bright.",
        "Let the chill lead.",
        "Easy does it.",
        "Vibes are friendly.",
        "Steady and steady." 
    ]

    private static let closers = [
        "Easy pace, good choices.",
        "Hydration and snacks are heroes.",
        "Make room for a break.",
        "Slow and steady wins the stars.",
        "Kind pacing keeps the party nice.",
        "Keep the night gentle.",
        "Ride smart, ride safe.",
        "Call a ride if you need one."
    ]

    private static let safetyNotes = [
        "Food helps the engine.",
        "Water keeps the controls responsive.",
        "Take a stretch and breathe.",
        "Plan a safe ride home.",
        "Check in with your body.",
        "Breaks make the night better."
    ]

    private static let hydrationNotes = [
        "Hydration check: water is a win.",
        "Glass of water = instant buff.",
        "Water moment? Your future self says thanks.",
        "Splash some water into the mix.",
        "Sip water, keep the orbit smooth.",
        "Hydrate now for a happier tomorrow."
    ]
}
