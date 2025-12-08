//
//  User.swift
//  LangSwap
//
//  Core user model for language exchange
//
//  PROFILE STATUS FLOW:
//  --------------------
//  profileStatus controls user visibility and app access:
//
//  1. "pending"   - New account awaiting admin approval (SignUpView.swift)
//                   User sees: PendingApprovalView
//                   Hidden from: Other users in Discover, Search
//
//  2. "active"    - Approved and visible to others
//                   User sees: MainTabView (full app access)
//                   Set by: AdminModerationDashboard.approveProfile()
//
//  3. "rejected"  - Rejected, user must fix issues
//                   User sees: ProfileRejectionFeedbackView
//                   Set by: AdminModerationDashboard.rejectProfile()
//                   Properties: profileStatusReason, profileStatusReasonCode, profileStatusFixInstructions
//
//  4. "flagged"   - Under extended moderator review
//                   User sees: FlaggedAccountView
//                   Set by: AdminModerationDashboard.flagProfile()
//                   Hidden from: Other users during review
//
//  5. "suspended" - Temporarily blocked (with end date)
//                   User sees: SuspendedAccountView
//                   Properties: isSuspended, suspendedAt, suspendedUntil, suspendReason
//
//  6. "banned"    - Permanently blocked
//                   User sees: BannedAccountView
//                   Properties: isBanned, bannedAt, banReason
//
//  Routing handled by: ContentView.swift (updateAuthenticationState)
//  Filtering handled by: UserService.swift, etc.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable, Equatable {
    @DocumentID var id: String?

    // Manual ID for test data (bypasses @DocumentID restrictions)
    // This is used when creating test users in DEBUG mode
    private var _manualId: String?

    // Computed property that returns manual ID if set, otherwise @DocumentID value
    var effectiveId: String? {
        _manualId ?? id
    }

    // Equatable implementation - compare by id
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.effectiveId == rhs.effectiveId
    }

    // Basic Info
    var email: String
    var fullName: String
    var age: Int
    var bio: String

    // Location
    var location: String
    var country: String
    var latitude: Double?
    var longitude: Double?
    var timezone: String? // For scheduling language exchange sessions

    // Profile Content
    var photos: [String]
    var profileImageURL: String

    // MARK: - Language Exchange Fields

    // Native Languages (languages they can teach)
    var nativeLanguages: [LanguageProficiency] = []

    // Learning Languages (languages they want to learn)
    var learningLanguages: [LanguageProficiency] = []

    // Learning Goals
    var learningGoals: [String] = [] // LearningGoal raw values

    // Preferred Practice Methods
    var practiceMethodPreferences: [String] = [] // PracticeMethod raw values

    // Availability
    var availabilities: [String] = [] // Availability raw values

    // Conversation Topics
    var conversationTopics: [String] = [] // ConversationTopic raw values

    // Timestamps
    var timestamp: Date
    var lastActive: Date
    var isOnline: Bool = false

    // Premium & Verification
    var isPremium: Bool
    var isVerified: Bool = false
    var premiumTier: String?
    var subscriptionExpiryDate: Date?

    // ID Verification Rejection (when ID verification is rejected)
    var idVerificationRejected: Bool = false
    var idVerificationRejectedAt: Date?
    var idVerificationRejectionReason: String?

    // Admin Access (for moderation dashboard)
    var isAdmin: Bool = false

    // Profile Status (for content moderation quarantine)
    // "pending" = new account, not shown in Discover until approved by admin
    // "active" = approved, visible to other users
    // "rejected" = rejected, user must fix issues
    // "suspended" = temporarily or permanently blocked
    // "flagged" = under review by moderators
    var profileStatus: String = "pending"
    var profileStatusReason: String?           // User-friendly message
    var profileStatusReasonCode: String?       // Machine-readable code (e.g., "incomplete_profile")
    var profileStatusFixInstructions: String?  // Detailed fix instructions for user
    var profileStatusUpdatedAt: Date?

    // Suspension Info (set by admin when suspending user)
    var isSuspended: Bool = false
    var suspendedAt: Date?
    var suspendedUntil: Date?
    var suspendReason: String?

    // Ban Info (permanent ban set by admin)
    var isBanned: Bool = false
    var bannedAt: Date?
    var banReason: String?

    // Warnings (accumulated from reports)
    var warningCount: Int = 0
    var hasUnreadWarning: Bool = false         // Show warning notice to user
    var lastWarningReason: String?             // Most recent warning reason

    // Preferences
    var maxDistance: Int = 0 // 0 = worldwide (for language exchange, distance is less important)
    var showMeInSearch: Bool = true

    // Stats
    var connectionsRequested: Int = 0
    var connectionsReceived: Int = 0
    var partnerCount: Int = 0
    var profileViews: Int = 0

    // Consumables (Premium Features)
    var superConnectsRemaining: Int = 0
    var boostsRemaining: Int = 0

    // Daily Limits (Free Users)
    var connectionsRemainingToday: Int = 50  // Free users get 50 connection requests/day
    var lastConnectionResetDate: Date = Date()

    // Boost Status
    var isBoostActive: Bool = false
    var boostExpiryDate: Date?

    // Notifications
    var fcmToken: String?
    var notificationsEnabled: Bool = true

    // Profile Prompts (adapted for language learning)
    var prompts: [ProfilePrompt] = []

    // Referral System
    var referralStats: ReferralStats = ReferralStats()
    var referredByCode: String?  // Code used during signup

    // PERFORMANCE: Lowercase fields for efficient Firestore prefix matching
    // These should be updated whenever fullName/country changes
    // See: UserService.searchUsers() for usage
    var fullNameLowercase: String = ""
    var countryLowercase: String = ""
    var locationLowercase: String = ""

    // Helper computed property for backward compatibility
    var name: String {
        get { fullName }
        set { fullName = newValue }
    }

    // Update lowercase fields when main fields change
    mutating func updateSearchFields() {
        fullNameLowercase = fullName.lowercased()
        countryLowercase = country.lowercased()
        locationLowercase = location.lowercased()
    }

    // MARK: - Language Exchange Helper Methods

    /// Get all languages user can teach (native or high proficiency)
    var teachableLanguages: [LanguageProficiency] {
        return nativeLanguages.filter { $0.level >= .b2 }
    }

    /// Get display string for native languages
    var nativeLanguagesDisplay: String {
        return nativeLanguages.map { $0.displayName }.joined(separator: ", ")
    }

    /// Get display string for learning languages
    var learningLanguagesDisplay: String {
        return learningLanguages.map { $0.displayName }.joined(separator: ", ")
    }

    /// Check if user has complementary languages with another user
    func hasComplementaryLanguages(with other: User) -> Bool {
        // Check if my native languages match their learning languages
        let myNativeLangs = Set(nativeLanguages.map { $0.language })
        let theirLearningLangs = Set(other.learningLanguages.map { $0.language })
        let iCanTeachThem = !myNativeLangs.intersection(theirLearningLangs).isEmpty

        // Check if their native languages match my learning languages
        let theirNativeLangs = Set(other.nativeLanguages.map { $0.language })
        let myLearningLangs = Set(learningLanguages.map { $0.language })
        let theyCanTeachMe = !theirNativeLangs.intersection(myLearningLangs).isEmpty

        return iCanTeachThem && theyCanTeachMe
    }

    /// Get learning goals as enum array
    var learningGoalsEnum: [LearningGoal] {
        return learningGoals.compactMap { LearningGoal(rawValue: $0) }
    }

    /// Get practice methods as enum array
    var practiceMethodsEnum: [PracticeMethod] {
        return practiceMethodPreferences.compactMap { PracticeMethod(rawValue: $0) }
    }

    /// Get availabilities as enum array
    var availabilitiesEnum: [Availability] {
        return availabilities.compactMap { Availability(rawValue: $0) }
    }

    /// Get conversation topics as enum array
    var conversationTopicsEnum: [ConversationTopic] {
        return conversationTopics.compactMap { ConversationTopic(rawValue: $0) }
    }

    // Custom encoding to handle nil values properly for Firebase
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(age, forKey: .age)
        try container.encode(bio, forKey: .bio)
        try container.encode(location, forKey: .location)
        try container.encode(country, forKey: .country)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encodeIfPresent(timezone, forKey: .timezone)
        try container.encode(photos, forKey: .photos)
        try container.encode(profileImageURL, forKey: .profileImageURL)

        // Language Exchange Fields
        try container.encode(nativeLanguages, forKey: .nativeLanguages)
        try container.encode(learningLanguages, forKey: .learningLanguages)
        try container.encode(learningGoals, forKey: .learningGoals)
        try container.encode(practiceMethodPreferences, forKey: .practiceMethodPreferences)
        try container.encode(availabilities, forKey: .availabilities)
        try container.encode(conversationTopics, forKey: .conversationTopics)

        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(lastActive, forKey: .lastActive)
        try container.encode(isOnline, forKey: .isOnline)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(isVerified, forKey: .isVerified)
        try container.encode(isAdmin, forKey: .isAdmin)
        try container.encodeIfPresent(premiumTier, forKey: .premiumTier)
        try container.encodeIfPresent(subscriptionExpiryDate, forKey: .subscriptionExpiryDate)
        try container.encode(idVerificationRejected, forKey: .idVerificationRejected)
        try container.encodeIfPresent(idVerificationRejectedAt, forKey: .idVerificationRejectedAt)
        try container.encodeIfPresent(idVerificationRejectionReason, forKey: .idVerificationRejectionReason)
        try container.encode(profileStatus, forKey: .profileStatus)
        try container.encodeIfPresent(profileStatusReason, forKey: .profileStatusReason)
        try container.encodeIfPresent(profileStatusReasonCode, forKey: .profileStatusReasonCode)
        try container.encodeIfPresent(profileStatusFixInstructions, forKey: .profileStatusFixInstructions)
        try container.encodeIfPresent(profileStatusUpdatedAt, forKey: .profileStatusUpdatedAt)
        try container.encode(isSuspended, forKey: .isSuspended)
        try container.encodeIfPresent(suspendedAt, forKey: .suspendedAt)
        try container.encodeIfPresent(suspendedUntil, forKey: .suspendedUntil)
        try container.encodeIfPresent(suspendReason, forKey: .suspendReason)
        try container.encode(isBanned, forKey: .isBanned)
        try container.encodeIfPresent(bannedAt, forKey: .bannedAt)
        try container.encodeIfPresent(banReason, forKey: .banReason)
        try container.encode(warningCount, forKey: .warningCount)
        try container.encode(hasUnreadWarning, forKey: .hasUnreadWarning)
        try container.encodeIfPresent(lastWarningReason, forKey: .lastWarningReason)
        try container.encode(maxDistance, forKey: .maxDistance)
        try container.encode(showMeInSearch, forKey: .showMeInSearch)
        try container.encode(connectionsRequested, forKey: .connectionsRequested)
        try container.encode(connectionsReceived, forKey: .connectionsReceived)
        try container.encode(partnerCount, forKey: .partnerCount)
        try container.encode(profileViews, forKey: .profileViews)
        try container.encodeIfPresent(fcmToken, forKey: .fcmToken)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(prompts, forKey: .prompts)
        try container.encode(referralStats, forKey: .referralStats)
        try container.encodeIfPresent(referredByCode, forKey: .referredByCode)

        // Encode lowercase search fields
        try container.encode(fullNameLowercase, forKey: .fullNameLowercase)
        try container.encode(countryLowercase, forKey: .countryLowercase)
        try container.encode(locationLowercase, forKey: .locationLowercase)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case email, fullName, age, bio
        case location, country, latitude, longitude, timezone
        case photos, profileImageURL
        case nativeLanguages, learningLanguages, learningGoals
        case practiceMethodPreferences, availabilities, conversationTopics
        case timestamp, lastActive, isOnline
        case isPremium, isVerified, isAdmin, premiumTier, subscriptionExpiryDate
        case idVerificationRejected, idVerificationRejectedAt, idVerificationRejectionReason
        case profileStatus, profileStatusReason, profileStatusReasonCode, profileStatusFixInstructions, profileStatusUpdatedAt
        case isSuspended, suspendedAt, suspendedUntil, suspendReason
        case isBanned, bannedAt, banReason
        case warningCount, hasUnreadWarning, lastWarningReason
        case maxDistance, showMeInSearch
        case connectionsRequested, connectionsReceived, partnerCount, profileViews
        case fcmToken, notificationsEnabled
        case prompts
        case referralStats, referredByCode
        // Performance: Lowercase search fields
        case fullNameLowercase, countryLowercase, locationLowercase
        // Premium consumables
        case superConnectsRemaining, boostsRemaining
        case connectionsRemainingToday, lastConnectionResetDate
        case isBoostActive, boostExpiryDate
    }

    // Initialize from dictionary (for legacy code)
    init(dictionary: [String: Any]) {
        let dictId = dictionary["id"] as? String
        self.id = dictId
        self._manualId = dictId  // Also set manual ID for effectiveId to work
        self.email = dictionary["email"] as? String ?? ""
        self.fullName = dictionary["fullName"] as? String ?? dictionary["name"] as? String ?? ""
        self.age = dictionary["age"] as? Int ?? 18
        self.bio = dictionary["bio"] as? String ?? ""
        self.location = dictionary["location"] as? String ?? ""
        self.country = dictionary["country"] as? String ?? ""
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double
        self.timezone = dictionary["timezone"] as? String
        self.photos = dictionary["photos"] as? [String] ?? []
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""

        // Language Exchange Fields
        if let nativeLangsData = dictionary["nativeLanguages"] as? [[String: Any]] {
            self.nativeLanguages = nativeLangsData.compactMap { langDict in
                guard let language = langDict["language"] as? String,
                      let levelStr = langDict["level"] as? String,
                      let level = ProficiencyLevel(rawValue: levelStr) else {
                    return nil
                }
                let id = langDict["id"] as? String ?? UUID().uuidString
                return LanguageProficiency(id: id, language: language, level: level)
            }
        } else {
            self.nativeLanguages = []
        }

        if let learningLangsData = dictionary["learningLanguages"] as? [[String: Any]] {
            self.learningLanguages = learningLangsData.compactMap { langDict in
                guard let language = langDict["language"] as? String,
                      let levelStr = langDict["level"] as? String,
                      let level = ProficiencyLevel(rawValue: levelStr) else {
                    return nil
                }
                let id = langDict["id"] as? String ?? UUID().uuidString
                return LanguageProficiency(id: id, language: language, level: level)
            }
        } else {
            self.learningLanguages = []
        }

        self.learningGoals = dictionary["learningGoals"] as? [String] ?? []
        self.practiceMethodPreferences = dictionary["practiceMethodPreferences"] as? [String] ?? []
        self.availabilities = dictionary["availabilities"] as? [String] ?? []
        self.conversationTopics = dictionary["conversationTopics"] as? [String] ?? []

        if let timestamp = dictionary["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        } else {
            self.timestamp = Date()
        }

        if let lastActive = dictionary["lastActive"] as? Timestamp {
            self.lastActive = lastActive.dateValue()
        } else {
            self.lastActive = Date()
        }

        self.isOnline = dictionary["isOnline"] as? Bool ?? false
        self.isPremium = dictionary["isPremium"] as? Bool ?? false
        self.isVerified = dictionary["isVerified"] as? Bool ?? false
        self.isAdmin = dictionary["isAdmin"] as? Bool ?? false
        self.premiumTier = dictionary["premiumTier"] as? String

        if let expiryDate = dictionary["subscriptionExpiryDate"] as? Timestamp {
            self.subscriptionExpiryDate = expiryDate.dateValue()
        }

        // ID Verification rejection info
        self.idVerificationRejected = dictionary["idVerificationRejected"] as? Bool ?? false
        if let rejectedAt = dictionary["idVerificationRejectedAt"] as? Timestamp {
            self.idVerificationRejectedAt = rejectedAt.dateValue()
        }
        self.idVerificationRejectionReason = dictionary["idVerificationRejectionReason"] as? String

        // Profile Status (for moderation quarantine)
        self.profileStatus = dictionary["profileStatus"] as? String ?? "pending"
        self.profileStatusReason = dictionary["profileStatusReason"] as? String
        self.profileStatusReasonCode = dictionary["profileStatusReasonCode"] as? String
        self.profileStatusFixInstructions = dictionary["profileStatusFixInstructions"] as? String
        if let statusUpdatedAt = dictionary["profileStatusUpdatedAt"] as? Timestamp {
            self.profileStatusUpdatedAt = statusUpdatedAt.dateValue()
        }

        // Suspension info
        self.isSuspended = dictionary["isSuspended"] as? Bool ?? false
        if let suspendedAtTs = dictionary["suspendedAt"] as? Timestamp {
            self.suspendedAt = suspendedAtTs.dateValue()
        }
        if let suspendedUntilTs = dictionary["suspendedUntil"] as? Timestamp {
            self.suspendedUntil = suspendedUntilTs.dateValue()
        }
        self.suspendReason = dictionary["suspendReason"] as? String

        self.isBanned = dictionary["isBanned"] as? Bool ?? false
        if let bannedAtTs = dictionary["bannedAt"] as? Timestamp {
            self.bannedAt = bannedAtTs.dateValue()
        }
        self.banReason = dictionary["banReason"] as? String

        // Warnings
        self.warningCount = dictionary["warningCount"] as? Int ?? 0
        self.hasUnreadWarning = dictionary["hasUnreadWarning"] as? Bool ?? false
        self.lastWarningReason = dictionary["lastWarningReason"] as? String

        self.maxDistance = dictionary["maxDistance"] as? Int ?? 0
        self.showMeInSearch = dictionary["showMeInSearch"] as? Bool ?? true

        self.connectionsRequested = dictionary["connectionsRequested"] as? Int ?? 0
        self.connectionsReceived = dictionary["connectionsReceived"] as? Int ?? 0
        self.partnerCount = dictionary["partnerCount"] as? Int ?? 0
        self.profileViews = dictionary["profileViews"] as? Int ?? 0

        self.fcmToken = dictionary["fcmToken"] as? String
        self.notificationsEnabled = dictionary["notificationsEnabled"] as? Bool ?? true

        // Profile Prompts
        if let promptsData = dictionary["prompts"] as? [[String: Any]] {
            self.prompts = promptsData.compactMap { promptDict in
                guard let question = promptDict["question"] as? String,
                      let answer = promptDict["answer"] as? String else {
                    return nil
                }
                let id = promptDict["id"] as? String ?? UUID().uuidString
                return ProfilePrompt(id: id, question: question, answer: answer)
            }
        } else {
            self.prompts = []
        }

        // Referral System
        if let referralStatsDict = dictionary["referralStats"] as? [String: Any] {
            self.referralStats = ReferralStats(dictionary: referralStatsDict)
        } else {
            self.referralStats = ReferralStats()
        }
        self.referredByCode = dictionary["referredByCode"] as? String

        // Initialize lowercase search fields (for backward compatibility with old data)
        self.fullNameLowercase = (dictionary["fullNameLowercase"] as? String) ?? fullName.lowercased()
        self.countryLowercase = (dictionary["countryLowercase"] as? String) ?? country.lowercased()
        self.locationLowercase = (dictionary["locationLowercase"] as? String) ?? location.lowercased()

        // Premium consumables
        self.superConnectsRemaining = dictionary["superConnectsRemaining"] as? Int ?? 0
        self.boostsRemaining = dictionary["boostsRemaining"] as? Int ?? 0
        self.connectionsRemainingToday = dictionary["connectionsRemainingToday"] as? Int ?? 50
        if let resetDate = dictionary["lastConnectionResetDate"] as? Timestamp {
            self.lastConnectionResetDate = resetDate.dateValue()
        }
        self.isBoostActive = dictionary["isBoostActive"] as? Bool ?? false
        if let boostExpiry = dictionary["boostExpiryDate"] as? Timestamp {
            self.boostExpiryDate = boostExpiry.dateValue()
        }
    }

    // Standard initializer
    init(
        id: String? = nil,
        email: String,
        fullName: String,
        age: Int,
        bio: String = "",
        location: String,
        country: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        timezone: String? = nil,
        nativeLanguages: [LanguageProficiency] = [],
        learningLanguages: [LanguageProficiency] = [],
        photos: [String] = [],
        profileImageURL: String = "",
        timestamp: Date = Date(),
        isPremium: Bool = false,
        isVerified: Bool = false,
        lastActive: Date = Date(),
        maxDistance: Int = 0
    ) {
        self.id = id
        self._manualId = id  // Store manual ID for test users
        self.email = email
        self.fullName = fullName
        self.age = age
        self.bio = bio
        self.location = location
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.nativeLanguages = nativeLanguages
        self.learningLanguages = learningLanguages
        self.photos = photos
        self.profileImageURL = profileImageURL
        self.timestamp = timestamp
        self.isPremium = isPremium
        self.isVerified = isVerified
        self.lastActive = lastActive
        self.maxDistance = maxDistance

        // Initialize lowercase search fields
        self.fullNameLowercase = fullName.lowercased()
        self.countryLowercase = country.lowercased()
        self.locationLowercase = location.lowercased()
    }
}

// MARK: - User Factory Methods

extension User {
    /// Factory method to create a minimal User object for notifications
    /// Validates required fields before creating
    static func createMinimal(
        id: String,
        fullName: String,
        from data: [String: Any]
    ) throws -> User {
        // Validate required fields
        guard let email = data["email"] as? String, !email.isEmpty else {
            throw UserCreationError.missingRequiredField("email")
        }

        guard let age = data["age"] as? Int, age >= AppConstants.Limits.minAge, age <= AppConstants.Limits.maxAge else {
            throw UserCreationError.invalidField("age", "Must be between \(AppConstants.Limits.minAge) and \(AppConstants.Limits.maxAge)")
        }

        // Create with validated data and safe defaults
        return User(
            id: id,
            email: email,
            fullName: fullName,
            age: age,
            location: data["location"] as? String ?? "",
            country: data["country"] as? String ?? ""
        )
    }

    /// Factory method to create User from Firestore data with validation
    static func fromFirestore(id: String, data: [String: Any]) throws -> User {
        // Validate all required fields
        guard let email = data["email"] as? String, !email.isEmpty else {
            throw UserCreationError.missingRequiredField("email")
        }

        guard let fullName = data["fullName"] as? String, !fullName.isEmpty else {
            throw UserCreationError.missingRequiredField("fullName")
        }

        guard let age = data["age"] as? Int, age >= AppConstants.Limits.minAge, age <= AppConstants.Limits.maxAge else {
            throw UserCreationError.invalidField("age", "Must be between \(AppConstants.Limits.minAge) and \(AppConstants.Limits.maxAge)")
        }

        // Create with validated data
        return User(
            id: id,
            email: email,
            fullName: fullName,
            age: age,
            location: data["location"] as? String ?? "",
            country: data["country"] as? String ?? ""
        )
    }
}

// MARK: - User Creation Errors

enum UserCreationError: LocalizedError {
    case missingRequiredField(String)
    case invalidField(String, String)

    var errorDescription: String? {
        switch self {
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidField(let field, let reason):
            return "Invalid field '\(field)': \(reason)"
        }
    }
}
