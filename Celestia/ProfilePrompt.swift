//
//  ProfilePrompt.swift
//  LangSwap
//
//  Profile prompts for engaging language exchange profiles
//

import Foundation

struct ProfilePrompt: Codable, Identifiable, Equatable {
    var id: String
    var question: String
    var answer: String

    init(id: String = UUID().uuidString, question: String, answer: String) {
        self.id = id
        self.question = question
        self.answer = answer
    }

    func toDictionary() -> [String: String] {
        return [
            "id": id,
            "question": question,
            "answer": answer
        ]
    }
}

// MARK: - Available Prompts

struct PromptLibrary {
    static let allPrompts: [String] = [
        // Language Learning Journey
        "Why I started learning this language...",
        "My language learning story is...",
        "The hardest part of learning a new language is...",
        "My favorite way to practice is...",
        "A language learning milestone I'm proud of...",
        "What keeps me motivated to learn...",

        // Cultural Interests
        "I'm fascinated by this culture because...",
        "My favorite thing about the culture is...",
        "A cultural tradition I find interesting...",
        "My dream destination for this language is...",
        "A movie/show in my target language I love...",
        "Music I listen to in my target language...",

        // Conversation Starters
        "Let's talk about...",
        "A topic I never get tired of discussing...",
        "Ask me about...",
        "I can teach you about...",
        "I'd love to learn about...",
        "Something I want to understand better...",

        // Personality & Interests
        "My interests outside of language learning...",
        "When I'm not studying, you'll find me...",
        "My favorite books/authors are...",
        "I'm passionate about...",
        "A fun fact about me...",
        "My friends would describe me as...",

        // Learning Goals
        "My language learning goal for this year...",
        "I want to be fluent enough to...",
        "The reason I chose this language...",
        "Where I see myself in my language journey...",
        "Skills I want to improve most...",
        "An exam I'm preparing for...",

        // Exchange Preferences
        "The best language partner for me is...",
        "I learn best when...",
        "Topics I enjoy discussing in my target language...",
        "What I can offer as a language partner...",
        "My ideal practice session looks like...",
        "I prefer practicing through...",

        // Fun & Creative
        "A funny language mistake I made...",
        "The word in my target language I love most...",
        "Something that surprised me about learning languages...",
        "If I could speak any language instantly, it would be...",
        "My language learning hack is...",
        "The best advice for language learners...",

        // Background
        "Languages I already speak...",
        "My native language has taught me...",
        "Growing up, languages were...",
        "Travel experiences that inspired my learning...",
        "How I use languages in my daily life...",

        // Collaboration
        "Let's practice together by...",
        "I'm looking for partners who...",
        "Together we could...",
        "I'm excited to help you with...",
        "What I hope to gain from language exchange..."
    ]

    static let categories: [String: [String]] = [
        "Language Journey": [
            "Why I started learning this language...",
            "My language learning story is...",
            "A language learning milestone I'm proud of...",
            "What keeps me motivated to learn..."
        ],
        "Cultural Exchange": [
            "I'm fascinated by this culture because...",
            "My favorite thing about the culture is...",
            "A cultural tradition I find interesting...",
            "My dream destination for this language is..."
        ],
        "Conversation Topics": [
            "Let's talk about...",
            "A topic I never get tired of discussing...",
            "Ask me about...",
            "I can teach you about..."
        ],
        "Learning Goals": [
            "My language learning goal for this year...",
            "I want to be fluent enough to...",
            "Skills I want to improve most...",
            "Where I see myself in my language journey..."
        ],
        "About Me": [
            "My interests outside of language learning...",
            "When I'm not studying, you'll find me...",
            "My friends would describe me as...",
            "A fun fact about me..."
        ],
        "Exchange Partner": [
            "The best language partner for me is...",
            "My ideal practice session looks like...",
            "What I can offer as a language partner...",
            "I prefer practicing through..."
        ]
    ]

    static func randomPrompts(count: Int = 5) -> [String] {
        return Array(allPrompts.shuffled().prefix(count))
    }

    static func suggestedPrompts() -> [String] {
        // Return a curated mix of prompts
        return [
            "Why I started learning this language...",
            "The best language partner for me is...",
            "Let's talk about...",
            "My language learning goal for this year...",
            "What I can offer as a language partner..."
        ]
    }
}
