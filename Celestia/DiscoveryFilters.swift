//
//  DiscoveryFilters.swift
//  LangSwap
//
//  Language exchange partner discovery filter preferences
//

import Foundation

@MainActor
class DiscoveryFilters: ObservableObject {
    static let shared = DiscoveryFilters()

    // MARK: - Language Filters
    @Published var teachingLanguages: Set<String> = [] // Languages I want to learn (partner should teach)
    @Published var learningLanguages: Set<String> = [] // Languages I can teach (partner should learn)
    @Published var minProficiencyLevel: ProficiencyLevel? = nil
    @Published var maxProficiencyLevel: ProficiencyLevel? = nil
    @Published var complementaryMatchOnly: Bool = true // Only show users with complementary language pairs

    // MARK: - Learning Preferences
    @Published var learningGoals: Set<String> = [] // LearningGoal raw values
    @Published var practiceMethodPreferences: Set<String> = [] // PracticeMethod raw values
    @Published var availabilities: Set<String> = [] // Availability raw values
    @Published var conversationTopics: Set<String> = [] // ConversationTopic raw values

    // MARK: - Basic Filters
    @Published var showVerifiedOnly: Bool = false
    @Published var maxDistance: Double = 0 // 0 = worldwide (default for language exchange)
    @Published var activeInLastDays: Int? = nil // nil = any, or 7, 30, 90

    private init() {
        loadFromUserDefaults()
    }

    // MARK: - Filter Logic

    func matchesFilters(user: User, currentUser: User?) -> Bool {
        // Skip self
        if let currentUser = currentUser, user.effectiveId == currentUser.effectiveId {
            return false
        }

        // Verification filter
        if showVerifiedOnly && !user.isVerified {
            return false
        }

        // Complementary language matching (most important for language exchange)
        if complementaryMatchOnly, let currentUser = currentUser {
            if !hasComplementaryLanguages(currentUser: currentUser, otherUser: user) {
                return false
            }
        }

        // Teaching languages filter (languages I want to learn from partner)
        if !teachingLanguages.isEmpty {
            let userNativeLangs = Set(user.nativeLanguages.map { $0.language })
            if teachingLanguages.intersection(userNativeLangs).isEmpty {
                return false
            }
        }

        // Learning languages filter (languages partner wants to learn from me)
        if !learningLanguages.isEmpty {
            let userLearningLangs = Set(user.learningLanguages.map { $0.language })
            if learningLanguages.intersection(userLearningLangs).isEmpty {
                return false
            }
        }

        // Proficiency level filter (for their teaching languages)
        if let minLevel = minProficiencyLevel {
            let hasQualifiedTeacher = user.nativeLanguages.contains { $0.level >= minLevel }
            if !hasQualifiedTeacher {
                return false
            }
        }

        // Learning goals filter
        if !learningGoals.isEmpty {
            let userGoals = Set(user.learningGoals)
            if learningGoals.intersection(userGoals).isEmpty {
                return false
            }
        }

        // Practice method filter
        if !practiceMethodPreferences.isEmpty {
            let userMethods = Set(user.practiceMethodPreferences)
            if practiceMethodPreferences.intersection(userMethods).isEmpty {
                return false
            }
        }

        // Availability filter
        if !availabilities.isEmpty {
            let userAvailabilities = Set(user.availabilities)
            if availabilities.intersection(userAvailabilities).isEmpty {
                return false
            }
        }

        // Conversation topics filter
        if !conversationTopics.isEmpty {
            let userTopics = Set(user.conversationTopics)
            if conversationTopics.intersection(userTopics).isEmpty {
                return false
            }
        }

        // Activity filter
        if let daysLimit = activeInLastDays {
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -daysLimit, to: Date()) ?? Date()
            if user.lastActive < cutoffDate {
                return false
            }
        }

        // Distance filter (only if specified, 0 = worldwide)
        if maxDistance > 0,
           let currentUser = currentUser,
           let currentLat = currentUser.latitude,
           let currentLon = currentUser.longitude,
           let userLat = user.latitude,
           let userLon = user.longitude {
            let distance = calculateDistance(
                from: (currentLat, currentLon),
                to: (userLat, userLon)
            )
            if distance > maxDistance {
                return false
            }
        }

        return true
    }

    // MARK: - Language Matching

    /// Check if two users have complementary language pairs
    private func hasComplementaryLanguages(currentUser: User, otherUser: User) -> Bool {
        // Get language sets
        let myNativeLangs = Set(currentUser.nativeLanguages.map { $0.language })
        let myLearningLangs = Set(currentUser.learningLanguages.map { $0.language })
        let theirNativeLangs = Set(otherUser.nativeLanguages.map { $0.language })
        let theirLearningLangs = Set(otherUser.learningLanguages.map { $0.language })

        // Check if I can teach them (my native matches their learning)
        let iCanTeachThem = !myNativeLangs.intersection(theirLearningLangs).isEmpty

        // Check if they can teach me (their native matches my learning)
        let theyCanTeachMe = !theirNativeLangs.intersection(myLearningLangs).isEmpty

        return iCanTeachThem && theyCanTeachMe
    }

    /// Calculate language match score (0-100)
    func calculateLanguageMatchScore(currentUser: User, otherUser: User) -> Double {
        var score: Double = 0

        // Get language sets
        let myNativeLangs = Set(currentUser.nativeLanguages.map { $0.language })
        let myLearningLangs = Set(currentUser.learningLanguages.map { $0.language })
        let theirNativeLangs = Set(otherUser.nativeLanguages.map { $0.language })
        let theirLearningLangs = Set(otherUser.learningLanguages.map { $0.language })

        // Complementary language bonus (40 points max)
        let iCanTeach = myNativeLangs.intersection(theirLearningLangs).count
        let theyCanTeach = theirNativeLangs.intersection(myLearningLangs).count
        score += Double(min(iCanTeach, 2) * 10) // Up to 20 points
        score += Double(min(theyCanTeach, 2) * 10) // Up to 20 points

        // Shared learning goals (20 points max)
        let myGoals = Set(currentUser.learningGoals)
        let theirGoals = Set(otherUser.learningGoals)
        let sharedGoals = myGoals.intersection(theirGoals).count
        score += Double(min(sharedGoals, 4) * 5)

        // Shared practice methods (15 points max)
        let myMethods = Set(currentUser.practiceMethodPreferences)
        let theirMethods = Set(otherUser.practiceMethodPreferences)
        let sharedMethods = myMethods.intersection(theirMethods).count
        score += Double(min(sharedMethods, 3) * 5)

        // Availability overlap (15 points max)
        let myAvailability = Set(currentUser.availabilities)
        let theirAvailability = Set(otherUser.availabilities)
        let sharedAvailability = myAvailability.intersection(theirAvailability).count
        score += Double(min(sharedAvailability, 3) * 5)

        // Shared conversation topics (10 points max)
        let myTopics = Set(currentUser.conversationTopics)
        let theirTopics = Set(otherUser.conversationTopics)
        let sharedTopics = myTopics.intersection(theirTopics).count
        score += Double(min(sharedTopics, 5) * 2)

        return min(score, 100)
    }

    private func calculateDistance(from: (lat: Double, lon: Double), to: (lat: Double, lon: Double)) -> Double {
        // Validate coordinates
        guard isValidLatitude(from.lat), isValidLongitude(from.lon),
              isValidLatitude(to.lat), isValidLongitude(to.lon) else {
            Logger.shared.warning("Invalid coordinates: from(\(from.lat), \(from.lon)) to(\(to.lat), \(to.lon))", category: .matching)
            return Double.infinity
        }

        let earthRadiusMiles = 3958.8

        let lat1 = from.lat * .pi / 180
        let lon1 = from.lon * .pi / 180
        let lat2 = to.lat * .pi / 180
        let lon2 = to.lon * .pi / 180

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))

        let distance = earthRadiusMiles * c

        guard distance.isFinite, distance >= 0 else {
            return Double.infinity
        }

        return distance
    }

    private func isValidLatitude(_ lat: Double) -> Bool {
        return lat >= -90 && lat <= 90 && lat.isFinite
    }

    private func isValidLongitude(_ lon: Double) -> Bool {
        return lon >= -180 && lon <= 180 && lon.isFinite
    }

    // MARK: - Persistence

    func saveToUserDefaults() {
        UserDefaults.standard.set(Array(teachingLanguages), forKey: "teachingLanguages")
        UserDefaults.standard.set(Array(learningLanguages), forKey: "learningLanguages")
        UserDefaults.standard.set(minProficiencyLevel?.rawValue, forKey: "minProficiencyLevel")
        UserDefaults.standard.set(maxProficiencyLevel?.rawValue, forKey: "maxProficiencyLevel")
        UserDefaults.standard.set(complementaryMatchOnly, forKey: "complementaryMatchOnly")

        UserDefaults.standard.set(Array(learningGoals), forKey: "filterLearningGoals")
        UserDefaults.standard.set(Array(practiceMethodPreferences), forKey: "filterPracticeMethods")
        UserDefaults.standard.set(Array(availabilities), forKey: "filterAvailabilities")
        UserDefaults.standard.set(Array(conversationTopics), forKey: "filterConversationTopics")

        UserDefaults.standard.set(showVerifiedOnly, forKey: "showVerifiedOnly")
        UserDefaults.standard.set(maxDistance, forKey: "maxDistance")
        UserDefaults.standard.set(activeInLastDays, forKey: "activeInLastDays")
    }

    private func loadFromUserDefaults() {
        if let langs = UserDefaults.standard.array(forKey: "teachingLanguages") as? [String] {
            teachingLanguages = Set(langs)
        }
        if let langs = UserDefaults.standard.array(forKey: "learningLanguages") as? [String] {
            learningLanguages = Set(langs)
        }
        if let levelStr = UserDefaults.standard.string(forKey: "minProficiencyLevel") {
            minProficiencyLevel = ProficiencyLevel(rawValue: levelStr)
        }
        if let levelStr = UserDefaults.standard.string(forKey: "maxProficiencyLevel") {
            maxProficiencyLevel = ProficiencyLevel(rawValue: levelStr)
        }
        complementaryMatchOnly = UserDefaults.standard.bool(forKey: "complementaryMatchOnly")

        if let goals = UserDefaults.standard.array(forKey: "filterLearningGoals") as? [String] {
            learningGoals = Set(goals)
        }
        if let methods = UserDefaults.standard.array(forKey: "filterPracticeMethods") as? [String] {
            practiceMethodPreferences = Set(methods)
        }
        if let avail = UserDefaults.standard.array(forKey: "filterAvailabilities") as? [String] {
            availabilities = Set(avail)
        }
        if let topics = UserDefaults.standard.array(forKey: "filterConversationTopics") as? [String] {
            conversationTopics = Set(topics)
        }

        showVerifiedOnly = UserDefaults.standard.bool(forKey: "showVerifiedOnly")
        if let distance = UserDefaults.standard.object(forKey: "maxDistance") as? Double {
            maxDistance = distance
        }
        activeInLastDays = UserDefaults.standard.object(forKey: "activeInLastDays") as? Int
    }

    func resetFilters() {
        teachingLanguages.removeAll()
        learningLanguages.removeAll()
        minProficiencyLevel = nil
        maxProficiencyLevel = nil
        complementaryMatchOnly = true

        learningGoals.removeAll()
        practiceMethodPreferences.removeAll()
        availabilities.removeAll()
        conversationTopics.removeAll()

        showVerifiedOnly = false
        maxDistance = 0
        activeInLastDays = nil

        saveToUserDefaults()
    }

    var hasActiveFilters: Bool {
        return !teachingLanguages.isEmpty ||
               !learningLanguages.isEmpty ||
               minProficiencyLevel != nil ||
               maxProficiencyLevel != nil ||
               !complementaryMatchOnly ||
               !learningGoals.isEmpty ||
               !practiceMethodPreferences.isEmpty ||
               !availabilities.isEmpty ||
               !conversationTopics.isEmpty ||
               showVerifiedOnly ||
               maxDistance > 0 ||
               activeInLastDays != nil
    }
}
