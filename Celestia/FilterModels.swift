//
//  FilterModels.swift
//  LangSwap
//
//  Data models for language exchange search and filtering
//

import Foundation
import CoreLocation

// MARK: - Proficiency Level (CEFR Standard)

enum ProficiencyLevel: String, Codable, CaseIterable, Comparable {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"
    case b2 = "B2"
    case c1 = "C1"
    case c2 = "C2"
    case native = "native"

    var displayName: String {
        switch self {
        case .a1: return "A1 - Beginner"
        case .a2: return "A2 - Elementary"
        case .b1: return "B1 - Intermediate"
        case .b2: return "B2 - Upper Intermediate"
        case .c1: return "C1 - Advanced"
        case .c2: return "C2 - Proficient"
        case .native: return "Native Speaker"
        }
    }

    var shortName: String {
        return rawValue
    }

    var description: String {
        switch self {
        case .a1: return "Can understand basic phrases"
        case .a2: return "Can handle simple conversations"
        case .b1: return "Can discuss familiar topics"
        case .b2: return "Can interact with fluency"
        case .c1: return "Can express ideas fluently"
        case .c2: return "Can understand virtually everything"
        case .native: return "Native or bilingual proficiency"
        }
    }

    var icon: String {
        switch self {
        case .a1: return "1.circle"
        case .a2: return "2.circle"
        case .b1: return "3.circle"
        case .b2: return "4.circle"
        case .c1: return "5.circle"
        case .c2: return "6.circle"
        case .native: return "star.circle.fill"
        }
    }

    var sortOrder: Int {
        switch self {
        case .a1: return 0
        case .a2: return 1
        case .b1: return 2
        case .b2: return 3
        case .c1: return 4
        case .c2: return 5
        case .native: return 6
        }
    }

    static func < (lhs: ProficiencyLevel, rhs: ProficiencyLevel) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}

// MARK: - Learning Goal

enum LearningGoal: String, Codable, CaseIterable {
    case conversationPractice = "conversation_practice"
    case businessLanguage = "business_language"
    case academicWriting = "academic_writing"
    case travelPhrases = "travel_phrases"
    case examPrep = "exam_prep"
    case culturalExchange = "cultural_exchange"
    case pronunciationHelp = "pronunciation_help"
    case grammarPractice = "grammar_practice"
    case vocabularyBuilding = "vocabulary_building"
    case listeningComprehension = "listening_comprehension"
    case readingPractice = "reading_practice"
    case writingFeedback = "writing_feedback"

    var displayName: String {
        switch self {
        case .conversationPractice: return "Conversation Practice"
        case .businessLanguage: return "Business Language"
        case .academicWriting: return "Academic Writing"
        case .travelPhrases: return "Travel Phrases"
        case .examPrep: return "Exam Prep (TOEFL, IELTS, DELE, JLPT, HSK)"
        case .culturalExchange: return "Cultural Exchange"
        case .pronunciationHelp: return "Pronunciation Help"
        case .grammarPractice: return "Grammar Practice"
        case .vocabularyBuilding: return "Vocabulary Building"
        case .listeningComprehension: return "Listening Comprehension"
        case .readingPractice: return "Reading Practice"
        case .writingFeedback: return "Writing Feedback"
        }
    }

    var icon: String {
        switch self {
        case .conversationPractice: return "bubble.left.and.bubble.right"
        case .businessLanguage: return "briefcase"
        case .academicWriting: return "graduationcap"
        case .travelPhrases: return "airplane"
        case .examPrep: return "doc.text"
        case .culturalExchange: return "globe"
        case .pronunciationHelp: return "waveform"
        case .grammarPractice: return "textformat"
        case .vocabularyBuilding: return "text.book.closed"
        case .listeningComprehension: return "ear"
        case .readingPractice: return "book"
        case .writingFeedback: return "pencil.and.outline"
        }
    }

    var description: String {
        switch self {
        case .conversationPractice: return "Improve everyday speaking skills"
        case .businessLanguage: return "Professional vocabulary & communication"
        case .academicWriting: return "Academic papers & formal writing"
        case .travelPhrases: return "Practical phrases for traveling"
        case .examPrep: return "Prepare for language proficiency exams"
        case .culturalExchange: return "Learn about culture & traditions"
        case .pronunciationHelp: return "Improve accent & pronunciation"
        case .grammarPractice: return "Master grammar rules & structures"
        case .vocabularyBuilding: return "Expand your word knowledge"
        case .listeningComprehension: return "Understand native speakers better"
        case .readingPractice: return "Improve reading speed & comprehension"
        case .writingFeedback: return "Get feedback on your writing"
        }
    }
}

// MARK: - Practice Method

enum PracticeMethod: String, Codable, CaseIterable {
    case videoCall = "video_call"
    case voiceCall = "voice_call"
    case textChat = "text_chat"
    case inPerson = "in_person"
    case voiceMessage = "voice_message"

    var displayName: String {
        switch self {
        case .videoCall: return "Video Call"
        case .voiceCall: return "Voice Call"
        case .textChat: return "Text Chat"
        case .inPerson: return "In-Person Meetup"
        case .voiceMessage: return "Voice Messages"
        }
    }

    var icon: String {
        switch self {
        case .videoCall: return "video"
        case .voiceCall: return "phone"
        case .textChat: return "message"
        case .inPerson: return "person.2"
        case .voiceMessage: return "mic"
        }
    }
}

// MARK: - Availability

enum Availability: String, Codable, CaseIterable {
    case mornings = "mornings"
    case afternoons = "afternoons"
    case evenings = "evenings"
    case weekdays = "weekdays"
    case weekends = "weekends"
    case flexible = "flexible"

    var displayName: String {
        switch self {
        case .mornings: return "Mornings"
        case .afternoons: return "Afternoons"
        case .evenings: return "Evenings"
        case .weekdays: return "Weekdays"
        case .weekends: return "Weekends"
        case .flexible: return "Flexible"
        }
    }

    var icon: String {
        switch self {
        case .mornings: return "sunrise"
        case .afternoons: return "sun.max"
        case .evenings: return "moon"
        case .weekdays: return "calendar"
        case .weekends: return "calendar.badge.clock"
        case .flexible: return "clock"
        }
    }
}

// MARK: - Conversation Topic

enum ConversationTopic: String, Codable, CaseIterable {
    case currentEvents = "current_events"
    case movies = "movies"
    case music = "music"
    case books = "books"
    case sports = "sports"
    case technology = "technology"
    case food = "food"
    case travel = "travel"
    case art = "art"
    case science = "science"
    case history = "history"
    case politics = "politics"
    case gaming = "gaming"
    case fashion = "fashion"
    case fitness = "fitness"
    case nature = "nature"
    case business = "business"
    case philosophy = "philosophy"

    var displayName: String {
        switch self {
        case .currentEvents: return "Current Events"
        case .movies: return "Movies & TV"
        case .music: return "Music"
        case .books: return "Books & Literature"
        case .sports: return "Sports"
        case .technology: return "Technology"
        case .food: return "Food & Cooking"
        case .travel: return "Travel"
        case .art: return "Art & Design"
        case .science: return "Science"
        case .history: return "History"
        case .politics: return "Politics"
        case .gaming: return "Gaming"
        case .fashion: return "Fashion"
        case .fitness: return "Fitness & Health"
        case .nature: return "Nature & Environment"
        case .business: return "Business & Career"
        case .philosophy: return "Philosophy"
        }
    }

    var icon: String {
        switch self {
        case .currentEvents: return "newspaper"
        case .movies: return "film"
        case .music: return "music.note"
        case .books: return "book"
        case .sports: return "sportscourt"
        case .technology: return "laptopcomputer"
        case .food: return "fork.knife"
        case .travel: return "airplane"
        case .art: return "paintpalette"
        case .science: return "atom"
        case .history: return "building.columns"
        case .politics: return "building.2"
        case .gaming: return "gamecontroller"
        case .fashion: return "tshirt"
        case .fitness: return "figure.run"
        case .nature: return "leaf"
        case .business: return "briefcase"
        case .philosophy: return "brain"
        }
    }
}

// MARK: - Language (Extended for Language Exchange)

enum Language: String, Codable, CaseIterable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    case arabic = "ar"
    case russian = "ru"
    case hindi = "hi"
    case dutch = "nl"
    case polish = "pl"
    case turkish = "tr"
    case swedish = "sv"
    case norwegian = "no"
    case danish = "da"
    case finnish = "fi"
    case greek = "el"
    case hebrew = "he"
    case thai = "th"
    case vietnamese = "vi"
    case indonesian = "id"
    case malay = "ms"
    case tagalog = "tl"
    case czech = "cs"
    case romanian = "ro"
    case hungarian = "hu"
    case ukrainian = "uk"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .chinese: return "Chinese (Mandarin)"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .arabic: return "Arabic"
        case .russian: return "Russian"
        case .hindi: return "Hindi"
        case .dutch: return "Dutch"
        case .polish: return "Polish"
        case .turkish: return "Turkish"
        case .swedish: return "Swedish"
        case .norwegian: return "Norwegian"
        case .danish: return "Danish"
        case .finnish: return "Finnish"
        case .greek: return "Greek"
        case .hebrew: return "Hebrew"
        case .thai: return "Thai"
        case .vietnamese: return "Vietnamese"
        case .indonesian: return "Indonesian"
        case .malay: return "Malay"
        case .tagalog: return "Tagalog"
        case .czech: return "Czech"
        case .romanian: return "Romanian"
        case .hungarian: return "Hungarian"
        case .ukrainian: return "Ukrainian"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .portuguese: return "🇵🇹"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .arabic: return "🇸🇦"
        case .russian: return "🇷🇺"
        case .hindi: return "🇮🇳"
        case .dutch: return "🇳🇱"
        case .polish: return "🇵🇱"
        case .turkish: return "🇹🇷"
        case .swedish: return "🇸🇪"
        case .norwegian: return "🇳🇴"
        case .danish: return "🇩🇰"
        case .finnish: return "🇫🇮"
        case .greek: return "🇬🇷"
        case .hebrew: return "🇮🇱"
        case .thai: return "🇹🇭"
        case .vietnamese: return "🇻🇳"
        case .indonesian: return "🇮🇩"
        case .malay: return "🇲🇾"
        case .tagalog: return "🇵🇭"
        case .czech: return "🇨🇿"
        case .romanian: return "🇷🇴"
        case .hungarian: return "🇭🇺"
        case .ukrainian: return "🇺🇦"
        }
    }

    var nativeName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        case .chinese: return "中文"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .arabic: return "العربية"
        case .russian: return "Русский"
        case .hindi: return "हिन्दी"
        case .dutch: return "Nederlands"
        case .polish: return "Polski"
        case .turkish: return "Türkçe"
        case .swedish: return "Svenska"
        case .norwegian: return "Norsk"
        case .danish: return "Dansk"
        case .finnish: return "Suomi"
        case .greek: return "Ελληνικά"
        case .hebrew: return "עברית"
        case .thai: return "ไทย"
        case .vietnamese: return "Tiếng Việt"
        case .indonesian: return "Bahasa Indonesia"
        case .malay: return "Bahasa Melayu"
        case .tagalog: return "Tagalog"
        case .czech: return "Čeština"
        case .romanian: return "Română"
        case .hungarian: return "Magyar"
        case .ukrainian: return "Українська"
        }
    }
}

// MARK: - Language Proficiency Entry

struct LanguageProficiency: Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString
    var language: String // Language raw value
    var level: ProficiencyLevel

    init(id: String = UUID().uuidString, language: String, level: ProficiencyLevel) {
        self.id = id
        self.language = language
        self.level = level
    }

    init(language: Language, level: ProficiencyLevel) {
        self.id = UUID().uuidString
        self.language = language.rawValue
        self.level = level
    }

    var languageEnum: Language? {
        return Language(rawValue: language)
    }

    var displayName: String {
        let langName = languageEnum?.displayName ?? language
        return "\(langName) (\(level.shortName))"
    }
}

// MARK: - Search Filter (Language Exchange)

struct SearchFilter: Codable, Equatable {

    // MARK: - Location
    var distanceRadius: Int = 100 // miles (1-unlimited, 0 = worldwide)
    var location: CLLocationCoordinate2D?
    var useCurrentLocation: Bool = true
    var timezone: String? // For scheduling compatibility

    // MARK: - Language Matching
    var teachingLanguages: [String] = [] // Languages user wants to learn from others
    var learningLanguages: [String] = [] // Languages user wants to teach others
    var minProficiencyLevel: ProficiencyLevel? // Minimum level of partner's teaching language
    var maxProficiencyLevel: ProficiencyLevel? // Maximum level (for beginners who want patient partners)

    // MARK: - Learning Preferences
    var learningGoals: [LearningGoal] = []
    var practiceMethodPreferences: [PracticeMethod] = []
    var availabilities: [Availability] = []
    var conversationTopics: [ConversationTopic] = []

    // MARK: - User Preferences
    var verifiedOnly: Bool = false
    var withPhotosOnly: Bool = false
    var activeInLastDays: Int? // nil = any, or 1, 7, 30
    var newUsers: Bool = false // Joined in last 30 days

    // MARK: - Metadata
    var id: String = UUID().uuidString
    var createdAt: Date = Date()
    var lastUsed: Date = Date()

    // MARK: - Helper Methods

    /// Check if filter is default (no custom filtering)
    var isDefault: Bool {
        return distanceRadius == 100 &&
               teachingLanguages.isEmpty &&
               learningLanguages.isEmpty &&
               minProficiencyLevel == nil &&
               learningGoals.isEmpty &&
               practiceMethodPreferences.isEmpty &&
               availabilities.isEmpty &&
               conversationTopics.isEmpty &&
               !verifiedOnly
    }

    /// Count active filters
    var activeFilterCount: Int {
        var count = 0

        if distanceRadius != 100 { count += 1 }
        if !teachingLanguages.isEmpty { count += 1 }
        if !learningLanguages.isEmpty { count += 1 }
        if minProficiencyLevel != nil { count += 1 }
        if !learningGoals.isEmpty { count += 1 }
        if !practiceMethodPreferences.isEmpty { count += 1 }
        if !availabilities.isEmpty { count += 1 }
        if !conversationTopics.isEmpty { count += 1 }
        if verifiedOnly { count += 1 }
        if activeInLastDays != nil { count += 1 }
        if newUsers { count += 1 }

        return count
    }

    /// Reset to default
    mutating func reset() {
        self = SearchFilter()
    }
}

// MARK: - Filter Preset

struct FilterPreset: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var filter: SearchFilter
    var createdAt: Date
    var lastUsed: Date
    var usageCount: Int

    init(
        id: String = UUID().uuidString,
        name: String,
        filter: SearchFilter,
        createdAt: Date = Date(),
        lastUsed: Date = Date(),
        usageCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.filter = filter
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.usageCount = usageCount
    }
}

// MARK: - Search History Entry

struct SearchHistoryEntry: Codable, Identifiable, Equatable {
    let id: String
    let filter: SearchFilter
    let timestamp: Date
    let resultsCount: Int

    init(
        id: String = UUID().uuidString,
        filter: SearchFilter,
        timestamp: Date = Date(),
        resultsCount: Int
    ) {
        self.id = id
        self.filter = filter
        self.timestamp = timestamp
        self.resultsCount = resultsCount
    }
}

// MARK: - CLLocationCoordinate2D Extension

extension CLLocationCoordinate2D: @retroactive Codable, @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }


    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Language Exchange Matching Score

struct LanguageMatchScore {
    let user: User
    let score: Double
    let matchingLanguages: [String] // Languages they can teach that you want to learn
    let complementaryLanguages: [String] // Languages you can teach that they want to learn
    let sharedTopics: [ConversationTopic]
    let sharedGoals: [LearningGoal]
    let sharedMethods: [PracticeMethod]

    var isComplementaryMatch: Bool {
        return !matchingLanguages.isEmpty && !complementaryLanguages.isEmpty
    }
}
