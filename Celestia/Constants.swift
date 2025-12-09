//
//  Constants.swift
//  LangSwap
//
//  Centralized constants for the language exchange app
//

import Foundation
import SwiftUI

enum AppConstants {
    // MARK: - App Info
    enum App {
        static let name = "LangSwap"
        static let tagline = "Practice Languages with Native Speakers"
        static let description = "Connect with language learners worldwide for mutual language exchange"
        static let category = "Education"
    }

    // MARK: - API Configuration
    enum API {
        static let baseURL = "https://api.langswap.app"
        static let timeout: TimeInterval = 30
        static let retryAttempts = 3
    }

    // MARK: - Content Limits
    enum Limits {
        static let maxBioLength = 500
        static let maxMessageLength = 1000
        static let maxConnectionMessage = 300
        static let maxConversationTopics = 10
        static let maxLanguages = 10
        static let maxPhotos = 6
        static let minAge = 18
        static let maxAge = 99
        static let minPasswordLength = 8
        static let maxNameLength = 50
    }

    // MARK: - Pagination
    enum Pagination {
        static let usersPerPage = 20
        static let messagesPerPage = 50
        static let partnersPerPage = 30
        static let connectionsPerPage = 20
    }

    // MARK: - Premium Pricing
    enum Premium {
        static let monthlyPrice = 9.99
        static let sixMonthPrice = 49.99
        static let yearlyPrice = 79.99

        // Features
        static let freeConnectionsPerDay = 50
        static let premiumUnlimitedConnections = true
        static let premiumSeeWhoLiked = true
        static let premiumBoostProfile = true
    }

    // MARK: - Colors (Language Exchange Theme)
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.teal
        static let accent = Color.cyan
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red

        static let gradientStart = Color.blue
        static let gradientEnd = Color.teal

        static func primaryGradient() -> LinearGradient {
            LinearGradient(
                colors: [gradientStart, gradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static func accentGradient() -> LinearGradient {
            LinearGradient(
                colors: [Color.blue, Color.teal],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    // MARK: - Animation Durations
    enum Animation {
        static let quick: TimeInterval = 0.2
        static let standard: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5
        static let splash: TimeInterval = 2.0
    }

    // MARK: - Layout
    enum Layout {
        static let cornerRadius: CGFloat = 16
        static let smallCornerRadius: CGFloat = 10
        static let largeCornerRadius: CGFloat = 20
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
    }

    // MARK: - Image Sizes
    enum ImageSize {
        static let thumbnail: CGFloat = 50
        static let small: CGFloat = 70
        static let medium: CGFloat = 100
        static let large: CGFloat = 150
        static let profile: CGFloat = 130
        static let hero: CGFloat = 400
    }

    // MARK: - Feature Flags
    enum Features {
        static let voiceMessagesEnabled = true
        static let videoCallsEnabled = true // For language practice
        static let storiesEnabled = false
        static let groupChatsEnabled = false
        static let gifSupportEnabled = true
        static let locationTrackingEnabled = false // Less important for language exchange
        static let timezoneMatchingEnabled = true // Important for scheduling
    }

    // MARK: - Firebase Collections
    enum Collections {
        static let users = "users"
        static let partners = "matches" // Language exchange partners
        static let messages = "messages"
        static let connections = "likes" // Connection requests
        static let reports = "reports"
        static let blockedUsers = "blocked_users"
        static let analytics = "analytics"
    }

    // MARK: - Storage Paths
    enum StoragePaths {
        static let profileImages = "profile_images"
        static let chatImages = "chat_images"
        static let userPhotos = "user_photos"
        static let voiceMessages = "voice_messages"
        static let videoMessages = "video_messages"
    }

    // MARK: - Rate Limiting
    enum RateLimit {
        static let messageInterval: TimeInterval = 0.5
        static let connectionInterval: TimeInterval = 1.0
        static let searchInterval: TimeInterval = 0.3
        static let maxMessagesPerMinute = 30
        static let maxConnectionsPerDay = 50 // Free users get 50 connections per day
        static let maxDailyMessagesForFreeUsers = 50 // More generous for language practice
    }

    // MARK: - Cache
    enum Cache {
        static let maxImageCacheSize = 100
        static let imageCacheDuration: TimeInterval = 3600 // 1 hour
        static let userDataCacheDuration: TimeInterval = 300 // 5 minutes
    }

    // MARK: - Notifications
    enum Notifications {
        static let newPartnerTitle = "New Language Partner!"
        static let newMessageTitle = "New Message"
        static let newConnectionTitle = "Someone wants to connect!"
        static let practiceReminderTitle = "Time to Practice!"
    }

    // MARK: - Analytics Events
    enum AnalyticsEvents {
        static let appLaunched = "app_launched"
        static let userSignedUp = "user_signed_up"
        static let userSignedIn = "user_signed_in"
        static let profileViewed = "profile_viewed"
        static let partnerConnected = "partner_connected"
        static let messageSent = "message_sent"
        static let connectionSent = "connection_sent"
        static let connectionRequested = "connection_requested"
        static let profilePassed = "profile_passed"
        static let profileEdited = "profile_edited"
        static let premiumViewed = "premium_viewed"
        static let premiumPurchased = "premium_purchased"
        static let languageAdded = "language_added"
        static let practiceSessionStarted = "practice_session_started"
    }

    // MARK: - Error Messages
    enum ErrorMessages {
        static let networkError = "Please check your internet connection and try again."
        static let genericError = "Something went wrong. Please try again."
        static let authError = "Authentication failed. Please try again."
        static let invalidEmail = "Please enter a valid email address."
        static let weakPassword = "Password must be at least 8 characters with numbers and letters."
        static let passwordMismatch = "Passwords do not match."
        static let accountNotFound = "No account found with this email."
        static let emailInUse = "This email is already registered."
        static let invalidAge = "You must be at least 18 years old."
        static let bioTooLong = "Bio must be less than 500 characters."
        static let messageTooLong = "Message must be less than 1000 characters."
        static let noLanguagesAdded = "Please add at least one language you speak and one you're learning."
    }

    // MARK: - URLs
    enum URLs {
        static let privacyPolicy = "https://langswap.app/privacy"
        static let termsOfService = "https://langswap.app/terms"
        static let support = "mailto:support@langswap.app"
        static let website = "https://langswap.app"
        static let instagramURL = "https://instagram.com/langswapapp"
        static let twitterURL = "https://twitter.com/langswapapp"
    }

    // MARK: - Debug
    enum Debug {
        #if DEBUG
        static let loggingEnabled = true
        static let showDebugInfo = true
        #else
        static let loggingEnabled = false
        static let showDebugInfo = false
        #endif
    }
}

// MARK: - Convenience Extensions

extension AppConstants {
    static func log(_ message: String, category: String = "General") {
        if Debug.loggingEnabled {
            print("[\(category)] \(message)")
        }
    }

    static func logError(_ error: Error, context: String = "") {
        if Debug.loggingEnabled {
            print("[\(context)] Error: \(error.localizedDescription)")
        }
    }
}
