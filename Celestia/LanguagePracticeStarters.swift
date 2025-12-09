//
//  LanguagePracticeStarters.swift
//  LangSwap
//
//  Conversation starters and language practice tools for chat
//

import SwiftUI

// MARK: - Conversation Starter Data

struct ConversationStarter: Identifiable, Hashable {
    let id = UUID()
    let category: StarterCategory
    let text: String
    let difficulty: LanguageLevel

    enum StarterCategory: String, CaseIterable {
        case greeting = "Greetings"
        case introduction = "Introductions"
        case hobbies = "Hobbies & Interests"
        case travel = "Travel"
        case food = "Food & Culture"
        case work = "Work & Study"
        case weather = "Weather & Seasons"
        case opinions = "Opinions & Debates"

        var icon: String {
            switch self {
            case .greeting: return "hand.wave.fill"
            case .introduction: return "person.fill"
            case .hobbies: return "heart.fill"
            case .travel: return "airplane"
            case .food: return "fork.knife"
            case .work: return "briefcase.fill"
            case .weather: return "cloud.sun.fill"
            case .opinions: return "bubble.left.and.bubble.right.fill"
            }
        }

        var color: Color {
            switch self {
            case .greeting: return .blue
            case .introduction: return .teal
            case .hobbies: return .pink
            case .travel: return .orange
            case .food: return .red
            case .work: return .purple
            case .weather: return .cyan
            case .opinions: return .green
            }
        }
    }

    enum LanguageLevel: String, CaseIterable {
        case beginner = "A1-A2"
        case intermediate = "B1-B2"
        case advanced = "C1-C2"

        var color: Color {
            switch self {
            case .beginner: return .green
            case .intermediate: return .orange
            case .advanced: return .red
            }
        }
    }
}

// MARK: - Starter Data Provider

struct ConversationStarterProvider {
    static let starters: [ConversationStarter] = [
        // Greetings - Beginner
        ConversationStarter(category: .greeting, text: "Hi! How are you today?", difficulty: .beginner),
        ConversationStarter(category: .greeting, text: "Good morning/afternoon! How's your day going?", difficulty: .beginner),
        ConversationStarter(category: .greeting, text: "Nice to meet you! Where are you from?", difficulty: .beginner),

        // Introductions - Beginner
        ConversationStarter(category: .introduction, text: "How long have you been learning [language]?", difficulty: .beginner),
        ConversationStarter(category: .introduction, text: "What made you want to learn [language]?", difficulty: .beginner),
        ConversationStarter(category: .introduction, text: "Tell me about yourself in a few sentences.", difficulty: .beginner),

        // Hobbies - Beginner to Intermediate
        ConversationStarter(category: .hobbies, text: "What do you like to do in your free time?", difficulty: .beginner),
        ConversationStarter(category: .hobbies, text: "Do you have any hobbies you're passionate about?", difficulty: .intermediate),
        ConversationStarter(category: .hobbies, text: "Have you picked up any new hobbies recently?", difficulty: .intermediate),

        // Travel - Intermediate
        ConversationStarter(category: .travel, text: "What's the most interesting place you've visited?", difficulty: .intermediate),
        ConversationStarter(category: .travel, text: "If you could travel anywhere, where would you go?", difficulty: .intermediate),
        ConversationStarter(category: .travel, text: "Tell me about a memorable travel experience.", difficulty: .intermediate),

        // Food & Culture - Intermediate
        ConversationStarter(category: .food, text: "What's your favorite traditional dish from your country?", difficulty: .intermediate),
        ConversationStarter(category: .food, text: "Have you tried any dishes from [country]?", difficulty: .intermediate),
        ConversationStarter(category: .food, text: "What's the strangest food you've ever tried?", difficulty: .intermediate),

        // Work & Study - Intermediate
        ConversationStarter(category: .work, text: "What do you do for work or study?", difficulty: .intermediate),
        ConversationStarter(category: .work, text: "What are your goals for learning this language?", difficulty: .intermediate),
        ConversationStarter(category: .work, text: "How do you practice the language outside of classes?", difficulty: .intermediate),

        // Weather - Beginner
        ConversationStarter(category: .weather, text: "What's the weather like where you are?", difficulty: .beginner),
        ConversationStarter(category: .weather, text: "What's your favorite season and why?", difficulty: .beginner),

        // Opinions - Advanced
        ConversationStarter(category: .opinions, text: "What do you think is the best way to learn a new language?", difficulty: .advanced),
        ConversationStarter(category: .opinions, text: "How has learning a new language changed your perspective?", difficulty: .advanced),
        ConversationStarter(category: .opinions, text: "What cultural differences have surprised you the most?", difficulty: .advanced)
    ]

    static func starters(for category: ConversationStarter.StarterCategory) -> [ConversationStarter] {
        starters.filter { $0.category == category }
    }

    static func starters(for level: ConversationStarter.LanguageLevel) -> [ConversationStarter] {
        starters.filter { $0.difficulty == level }
    }

    static func randomStarter(for level: ConversationStarter.LanguageLevel? = nil) -> ConversationStarter {
        if let level = level {
            return starters(for: level).randomElement() ?? starters.randomElement()!
        }
        return starters.randomElement()!
    }
}

// MARK: - Conversation Starters View

struct ConversationStartersView: View {
    @Binding var messageText: String
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategory: ConversationStarter.StarterCategory?
    @State private var selectedLevel: ConversationStarter.LanguageLevel?

    var filteredStarters: [ConversationStarter] {
        ConversationStarterProvider.starters.filter { starter in
            let categoryMatch = selectedCategory == nil || starter.category == selectedCategory
            let levelMatch = selectedLevel == nil || starter.difficulty == selectedLevel
            return categoryMatch && levelMatch
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "text.bubble.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.teal)

                        Text("Conversation Starters")
                            .font(.title2.bold())

                        Text("Tap any prompt to add it to your message")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    // Category Filter
                    categoryFilter

                    // Level Filter
                    levelFilter

                    // Starters List
                    LazyVStack(spacing: 12) {
                        ForEach(filteredStarters) { starter in
                            StarterCard(starter: starter) {
                                messageText = starter.text
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Conversation Starters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedCategory == nil,
                    color: .gray
                ) {
                    selectedCategory = nil
                }

                ForEach(ConversationStarter.StarterCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        color: category.color
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var levelFilter: some View {
        HStack(spacing: 8) {
            Text("Level:")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ForEach(ConversationStarter.LanguageLevel.allCases, id: \.self) { level in
                Button {
                    selectedLevel = selectedLevel == level ? nil : level
                } label: {
                    Text(level.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedLevel == level ? level.color : Color.gray.opacity(0.2))
                        .foregroundColor(selectedLevel == level ? .white : .primary)
                        .cornerRadius(16)
                }
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color.gray.opacity(0.15))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct StarterCard: View {
    let starter: ConversationStarter
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(starter.category.color.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: starter.category.icon)
                        .font(.title3)
                        .foregroundColor(starter.category.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(starter.text)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        Text(starter.category.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text(starter.difficulty.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(starter.difficulty.color)
                    }
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(.teal)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

// MARK: - Quick Starter Button (for Chat Input)

struct QuickStarterButton: View {
    @Binding var messageText: String
    @State private var showStarters = false

    var body: some View {
        Button {
            showStarters = true
        } label: {
            Image(systemName: "lightbulb.fill")
                .font(.title3)
                .foregroundColor(.teal)
        }
        .sheet(isPresented: $showStarters) {
            ConversationStartersView(messageText: $messageText)
        }
    }
}

// MARK: - Practice Tip Banner

struct PracticeTipBanner: View {
    let tip: String
    @State private var isVisible = true

    static let tips = [
        "Try to use new vocabulary words in your conversation today!",
        "Don't be afraid to make mistakes - that's how we learn!",
        "Ask your partner to correct your grammar if needed.",
        "Practice speaking out loud, even when typing.",
        "Take notes of new words you learn during your chat.",
        "Try to have a 10-minute conversation in your target language.",
        "Ask questions to keep the conversation flowing.",
        "Use voice messages to practice pronunciation."
    ]

    static var randomTip: String {
        tips.randomElement() ?? tips[0]
    }

    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)

                Text(tip)
                    .font(.caption)
                    .foregroundColor(.primary)

                Spacer()

                Button {
                    withAnimation {
                        isVisible = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Previews

#Preview("Conversation Starters") {
    ConversationStartersView(messageText: .constant(""))
}

#Preview("Practice Tip") {
    PracticeTipBanner(tip: PracticeTipBanner.randomTip)
        .padding()
}
