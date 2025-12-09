//
//  LanguageMatchIndicator.swift
//  LangSwap
//
//  Quick language match indicators for discovery cards
//

import SwiftUI

// MARK: - Quick Match Badge

/// A compact badge showing language compatibility at a glance
struct LanguageMatchBadge: View {
    let matchType: MatchType
    let primaryLanguage: String?

    enum MatchType {
        case perfect       // Both can teach each other
        case canTeach      // Current user can teach them
        case canLearn      // Current user can learn from them
        case none          // No direct match

        var icon: String {
            switch self {
            case .perfect: return "arrow.left.arrow.right"
            case .canTeach: return "arrow.right"
            case .canLearn: return "arrow.left"
            case .none: return "minus"
            }
        }

        var color: Color {
            switch self {
            case .perfect: return .green
            case .canTeach: return .teal
            case .canLearn: return .blue
            case .none: return .gray
            }
        }

        var label: String {
            switch self {
            case .perfect: return "Perfect Match"
            case .canTeach: return "You can help"
            case .canLearn: return "Can help you"
            case .none: return "No match"
            }
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: matchType.icon)
                .font(.caption2)

            if let language = primaryLanguage {
                Text(language)
                    .font(.caption2)
                    .fontWeight(.semibold)
            } else {
                Text(matchType.label)
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(matchType.color.opacity(0.15))
        .foregroundColor(matchType.color)
        .cornerRadius(12)
    }
}

// MARK: - Language Exchange Summary

/// Shows a quick summary of language exchange potential
struct LanguageExchangeSummary: View {
    let currentUser: User
    let otherUser: User

    private var exchangeInfo: ExchangeInfo {
        calculateExchange()
    }

    struct ExchangeInfo {
        let youTeach: [String]
        let theyTeach: [String]
        let matchType: LanguageMatchBadge.MatchType
    }

    var body: some View {
        VStack(spacing: 8) {
            // Match badge
            LanguageMatchBadge(
                matchType: exchangeInfo.matchType,
                primaryLanguage: primaryLanguage
            )

            // Details (compact)
            if !exchangeInfo.youTeach.isEmpty || !exchangeInfo.theyTeach.isEmpty {
                HStack(spacing: 16) {
                    if !exchangeInfo.youTeach.isEmpty {
                        ExchangeDetail(
                            direction: "You →",
                            languages: exchangeInfo.youTeach,
                            color: .teal
                        )
                    }

                    if !exchangeInfo.theyTeach.isEmpty {
                        ExchangeDetail(
                            direction: "← They",
                            languages: exchangeInfo.theyTeach,
                            color: .blue
                        )
                    }
                }
            }
        }
    }

    private var primaryLanguage: String? {
        if !exchangeInfo.youTeach.isEmpty && !exchangeInfo.theyTeach.isEmpty {
            return nil // Show "Perfect Match" label instead
        } else if let first = exchangeInfo.youTeach.first {
            return first
        } else if let first = exchangeInfo.theyTeach.first {
            return first
        }
        return nil
    }

    private func calculateExchange() -> ExchangeInfo {
        var youTeach: [String] = []
        var theyTeach: [String] = []

        // What you can teach (your native languages they're learning)
        for native in currentUser.nativeLanguages {
            for learning in otherUser.learningLanguages {
                if native.language.lowercased() == learning.language.lowercased() {
                    youTeach.append(native.language)
                }
            }
        }

        // What they can teach (their native languages you're learning)
        for learning in currentUser.learningLanguages {
            for native in otherUser.nativeLanguages {
                if learning.language.lowercased() == native.language.lowercased() {
                    theyTeach.append(native.language)
                }
            }
        }

        let matchType: LanguageMatchBadge.MatchType
        if !youTeach.isEmpty && !theyTeach.isEmpty {
            matchType = .perfect
        } else if !youTeach.isEmpty {
            matchType = .canTeach
        } else if !theyTeach.isEmpty {
            matchType = .canLearn
        } else {
            matchType = .none
        }

        return ExchangeInfo(youTeach: youTeach, theyTeach: theyTeach, matchType: matchType)
    }
}

struct ExchangeDetail: View {
    let direction: String
    let languages: [String]
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(direction)
                .font(.caption2)
                .foregroundColor(.secondary)

            Text(languages.prefix(2).joined(separator: ", "))
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(color)

            if languages.count > 2 {
                Text("+\(languages.count - 2)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Quick Language Preview

/// Shows top languages for a user in a compact format
struct QuickLanguagePreview: View {
    let nativeLanguages: [LanguageProficiency]
    let learningLanguages: [LanguageProficiency]

    var body: some View {
        HStack(spacing: 12) {
            // Native (speaks)
            if !nativeLanguages.isEmpty {
                QuickLanguageGroup(
                    label: "Speaks",
                    languages: nativeLanguages,
                    color: .teal
                )
            }

            // Learning
            if !learningLanguages.isEmpty {
                QuickLanguageGroup(
                    label: "Learning",
                    languages: learningLanguages,
                    color: .blue
                )
            }
        }
    }
}

struct QuickLanguageGroup: View {
    let label: String
    let languages: [LanguageProficiency]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)

            HStack(spacing: 4) {
                ForEach(languages.prefix(3)) { lang in
                    if let language = lang.languageEnum {
                        Text(language.flag)
                            .font(.caption)
                    }
                }

                if languages.count > 3 {
                    Text("+\(languages.count - 3)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Language Tag Overlay

/// An overlay showing language info on discovery cards
struct LanguageTagOverlay: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Native languages with flags
            if !user.nativeLanguages.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)

                    ForEach(user.nativeLanguages.prefix(3)) { lang in
                        LanguageFlagPill(languageProficiency: lang)
                    }
                }
            }

            // Learning languages with flags
            if !user.learningLanguages.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "book.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)

                    ForEach(user.learningLanguages.prefix(3)) { lang in
                        LanguageFlagPill(languageProficiency: lang)
                    }
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct LanguageFlagPill: View {
    let languageProficiency: LanguageProficiency

    var body: some View {
        HStack(spacing: 2) {
            if let lang = languageProficiency.languageEnum {
                Text(lang.flag)
                    .font(.caption)
            }
            Text(languageProficiency.level.shortName)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(languageProficiency.level.color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
    }
}

// MARK: - Availability Indicator

/// Shows timezone and availability compatibility
struct AvailabilityIndicator: View {
    let userTimezone: String
    let currentUserTimezone: String

    var timezoneOffset: Int {
        // Simple calculation - would need proper timezone handling in production
        0
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.fill")
                .font(.caption2)

            Text(availabilityLabel)
                .font(.caption2)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(availabilityColor.opacity(0.15))
        .foregroundColor(availabilityColor)
        .cornerRadius(12)
    }

    private var availabilityLabel: String {
        let offset = abs(timezoneOffset)
        if offset <= 3 {
            return "Great timezone"
        } else if offset <= 6 {
            return "OK timezone"
        } else {
            return "\(offset)h difference"
        }
    }

    private var availabilityColor: Color {
        let offset = abs(timezoneOffset)
        if offset <= 3 {
            return .green
        } else if offset <= 6 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Complete Match Card Info

/// Full language match information for detail views
struct CompleteMatchInfo: View {
    let currentUser: User
    let otherUser: User

    var body: some View {
        VStack(spacing: 16) {
            // Language compatibility
            LanguageCompatibilityCard(currentUser: currentUser, otherUser: otherUser)

            // Their language details
            LanguageSectionCard(
                title: "They Speak",
                icon: "star.fill",
                iconColor: .teal,
                languages: otherUser.nativeLanguages,
                style: .native,
                emptyMessage: "No native languages listed"
            )

            LanguageSectionCard(
                title: "They're Learning",
                icon: "book.fill",
                iconColor: .blue,
                languages: otherUser.learningLanguages,
                style: .learning,
                emptyMessage: "No learning languages listed"
            )

            // Learning goals if available
            if !otherUser.learningGoals.isEmpty {
                LearningGoalsDisplay(goals: otherUser.learningGoals)
            }

            // Practice methods if available
            if !otherUser.practiceMethods.isEmpty {
                PracticeMethodsDisplay(methods: otherUser.practiceMethods)
            }
        }
    }
}

// MARK: - Previews

#Preview("Match Badges") {
    VStack(spacing: 12) {
        LanguageMatchBadge(matchType: .perfect, primaryLanguage: nil)
        LanguageMatchBadge(matchType: .canTeach, primaryLanguage: "Spanish")
        LanguageMatchBadge(matchType: .canLearn, primaryLanguage: "French")
        LanguageMatchBadge(matchType: .none, primaryLanguage: nil)
    }
    .padding()
}

#Preview("Availability") {
    VStack(spacing: 12) {
        AvailabilityIndicator(userTimezone: "America/New_York", currentUserTimezone: "America/Los_Angeles")
        AvailabilityIndicator(userTimezone: "Europe/London", currentUserTimezone: "America/New_York")
        AvailabilityIndicator(userTimezone: "Asia/Tokyo", currentUserTimezone: "America/New_York")
    }
    .padding()
}
