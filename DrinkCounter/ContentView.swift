//
//  ContentView.swift
//  SipShip
//
//  Created by Sebastien Lato on 2026-02-13.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = DrinkViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var emojiPulse = false
    @State private var hydrationPulse = false
    @State private var didAttachStore = false
    @State private var showResetConfirmation = false

    var body: some View {
        let stage = viewModel.stage

        NavigationStack {
            ZStack {
                LinearGradient(colors: stage.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .animation(reduceMotion ? .none : .easeInOut(duration: 0.8), value: stage.id)
                    .ignoresSafeArea()

                if stage.sparkleIntensity > 0 {
                    SparkleField(intensity: stage.sparkleIntensity, reduceMotion: reduceMotion)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }

                GeometryReader { proxy in
                    ScrollView(.vertical) {
                        VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text("SipShip 🚀")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.9))

                            Text(stage.emoji)
                                .font(.system(size: 120))
                                .minimumScaleFactor(0.5)
                                .scaleEffect(emojiPulse ? 1.08 : 1.0)
                                .rotationEffect(.degrees(emojiPulse ? 4 : 0))
                                .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.6), value: emojiPulse)
                                .accessibilityLabel("Mood: \(stage.title)")

                            Text(stage.title)
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.white)

                            Text("Drinks (\(viewModel.selectedScope.title)): \(viewModel.selectedScopeCount)")
                                .font(.title.weight(.bold))
                                .foregroundStyle(.white.opacity(0.95))
                        }
                        .padding(.top, 16)
                        .onChange(of: viewModel.selectedScopeCount) {
                            guard !reduceMotion else { return }
                            emojiPulse.toggle()
                        }

                        Picker("Scope", selection: $viewModel.selectedScope) {
                            ForEach(DrinkViewModel.Scope.allCases) { scope in
                                Text(scope.title).tag(scope)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityLabel("Select scope")

                        GlassCard(title: "Tracker") {
                            VStack(spacing: 14) {
                                HStack(spacing: 12) {
                                    MetricChip(title: "Today", value: viewModel.todayCount)
                                    MetricChip(title: "This Week", value: viewModel.weekCount)
                                }

                                SevenDayBarChart(days: viewModel.last7Days)
                            }
                        }
                        .accessibilityLabel("Tracker card")

                        HStack(spacing: 12) {
                            Button("- Drink") {
                                viewModel.decrement()
                            }
                            .buttonStyle(SipButtonStyle(tint: Color.black.opacity(0.45)))
                            .accessibilityLabel("Remove a drink")

                            Button("+ Drink") {
                                viewModel.increment()
                            }
                            .buttonStyle(SipButtonStyle(tint: Color(red: 0.29, green: 0.55, blue: 1.0)))
                            .accessibilityLabel("Add a drink")
                        }

                        Button("Reset") {
                            if viewModel.selectedScope == .lifetime {
                                showResetConfirmation = true
                            } else {
                                viewModel.resetSelectedScope()
                            }
                        }
                        .buttonStyle(SipButtonStyle(tint: Color.gray.opacity(0.55)))
                        .accessibilityLabel("Reset drink count")

                        GlassCard(title: "Hydration") {
                            VStack(alignment: .leading, spacing: 8) {
                                if viewModel.shouldShowHydrationWarning {
                                    Text("Time for a glass of water 💧")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(.white)
                                        .transition(.move(edge: .top).combined(with: .opacity))
                                } else {
                                    Text("Keep a water buddy nearby for smooth sailing.")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.white.opacity(0.9))
                                }

                                Text("Hydration keeps the mission comfy.")
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                        .scaleEffect(hydrationPulse ? 1.02 : 1.0)
                        .shadow(color: Color.white.opacity(hydrationPulse ? 0.25 : 0.0), radius: 20, x: 0, y: 0)
                        .animation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.7), value: hydrationPulse)
                        .accessibilityLabel("Hydration card")
                        .onChange(of: viewModel.hydrationBannerToken) {
                            guard !reduceMotion else { return }
                            hydrationPulse = true
                            Task { @MainActor in
                                try? await Task.sleep(nanoseconds: 700_000_000)
                                hydrationPulse = false
                            }
                        }

                        GlassCard(title: "Quip") {
                            ZStack(alignment: .topTrailing) {
                                Text(viewModel.lastMessage)
                                    .font(.body)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .accessibilityLabel("Quip: \(viewModel.lastMessage)")

                                if !reduceMotion {
                                    SparkleBurst(trigger: viewModel.messageChangeToken)
                                        .offset(x: 12, y: -8)
                                }
                            }
                        }
                        .accessibilityLabel("Quip card")

                        Text("Drink responsibly. Consider water, food, and safe transport.")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 24)
                            .accessibilityLabel("Drink responsibly. Consider water, food, and safe transport.")
                    }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .frame(width: proxy.size.width, alignment: .center)
                    }
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
                    .clipped()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("History") {
                        HistoryView()
                    }
                    .accessibilityLabel("Open history")
                }
            }
            .confirmationDialog("Reset Lifetime?", isPresented: $showResetConfirmation) {
                Button("Delete All Events", role: .destructive) {
                    viewModel.resetSelectedScope()
                }
            }
            .task {
                if !didAttachStore {
                    viewModel.attachStore(DrinkStore(context: modelContext))
                    didAttachStore = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
