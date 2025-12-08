//
//  ProfileQualityScorer.swift
//  LangSwap
//
//  Real-time profile quality scoring with actionable tips
//  Helps users create high-quality profiles that get more language exchange partners
//

import Foundation
import SwiftUI

/// Profile quality scoring system with real-time feedback
@MainActor
class ProfileQualityScorer: ObservableObject {

    static let shared = ProfileQualityScorer()

    @Published var currentScore: Int = 0
    @Published var maxScore: Int = 100
    @Published var qualityTips: [ProfileQualityTip] = []
    @Published var completedSteps: Set<String> = []

    // MARK: - Quality Metrics

    struct ProfileMetrics {
        var hasName: Bool = false
        var hasAge: Bool = false
        var hasBio: Bool = false
        var bioLength: Int = 0
        var hasLocation: Bool = false
        var photoCount: Int = 0

        // Language Exchange Specific
        var hasNativeLanguages: Bool = false
        var nativeLanguageCount: Int = 0
        var hasLearningLanguages: Bool = false
        var learningLanguageCount: Int = 0
        var hasLearningGoals: Bool = false
        var learningGoalCount: Int = 0
        var hasPracticeMethods: Bool = false
        var practiceMethodCount: Int = 0
        var hasAvailability: Bool = false
        var hasConversationTopics: Bool = false
        var conversationTopicCount: Int = 0
        var hasTimezone: Bool = false

        var hasVerifiedPhoto: Bool = false
        var bioHasEmoji: Bool = false
        var bioWordCount: Int = 0
    }

    // MARK: - Quality Tip Model

    struct ProfileQualityTip: Identifiable {
        let id = UUID()
        let category: TipCategory
        let title: String
        let message: String
        let impact: ImpactLevel
        let isCompleted: Bool
        let points: Int
        let actionIcon: String

        enum TipCategory: String {
            case photos = "Photos"
            case bio = "Bio"
            case languages = "Languages"
            case learningPreferences = "Learning"
            case verification = "Verification"
            case completeness = "Completeness"
        }

        enum ImpactLevel {
            case critical  // Red - must do
            case high      // Orange - should do
            case medium    // Yellow - nice to have
            case low       // Green - bonus

            var color: Color {
                switch self {
                case .critical: return .red
                case .high: return .orange
                case .medium: return .yellow
                case .low: return .green
                }
            }

            var icon: String {
                switch self {
                case .critical: return "exclamationmark.triangle.fill"
                case .high: return "exclamationmark.circle.fill"
                case .medium: return "info.circle.fill"
                case .low: return "star.fill"
                }
            }
        }
    }

    // MARK: - Score Calculation

    func calculateScore(for metrics: ProfileMetrics) -> (score: Int, tips: [ProfileQualityTip]) {
        var score = 0
        var tips: [ProfileQualityTip] = []

        // 1. Name (5 points - critical)
        if metrics.hasName {
            score += 5
        } else {
            tips.append(ProfileQualityTip(
                category: .completeness,
                title: "Add Your Name",
                message: "Language partners want to know who they're practicing with",
                impact: .critical,
                isCompleted: false,
                points: 5,
                actionIcon: "person.fill"
            ))
        }

        // 2. Age (5 points - critical)
        if metrics.hasAge {
            score += 5
        } else {
            tips.append(ProfileQualityTip(
                category: .completeness,
                title: "Add Your Age",
                message: "Helps partners find age-appropriate exchange partners",
                impact: .critical,
                isCompleted: false,
                points: 5,
                actionIcon: "calendar"
            ))
        }

        // 3. Native Languages (20 points - critical for language exchange!)
        if metrics.hasNativeLanguages {
            if metrics.nativeLanguageCount >= 2 {
                score += 20
            } else {
                score += 15
                tips.append(ProfileQualityTip(
                    category: .languages,
                    title: "Add More Languages You Speak",
                    message: "Add all languages you can help others learn",
                    impact: .medium,
                    isCompleted: false,
                    points: 5,
                    actionIcon: "globe"
                ))
            }
        } else {
            tips.append(ProfileQualityTip(
                category: .languages,
                title: "Add Languages You Speak",
                message: "This is essential! Partners need to know what you can teach",
                impact: .critical,
                isCompleted: false,
                points: 20,
                actionIcon: "person.wave.2.fill"
            ))
        }

        // 4. Learning Languages (20 points - critical for language exchange!)
        if metrics.hasLearningLanguages {
            if metrics.learningLanguageCount >= 2 {
                score += 20
            } else {
                score += 15
                tips.append(ProfileQualityTip(
                    category: .languages,
                    title: "Add More Learning Languages",
                    message: "Add all languages you want to practice",
                    impact: .medium,
                    isCompleted: false,
                    points: 5,
                    actionIcon: "book"
                ))
            }
        } else {
            tips.append(ProfileQualityTip(
                category: .languages,
                title: "Add Languages You're Learning",
                message: "Essential for finding the right exchange partners!",
                impact: .critical,
                isCompleted: false,
                points: 20,
                actionIcon: "book.fill"
            ))
        }

        // 5. Bio (15 points total)
        if metrics.hasBio {
            if metrics.bioLength >= 50 {
                score += 10

                if metrics.bioLength >= 150 {
                    score += 5
                } else {
                    tips.append(ProfileQualityTip(
                        category: .bio,
                        title: "Expand Your Bio",
                        message: "Share more about your learning journey (150+ chars)",
                        impact: .medium,
                        isCompleted: false,
                        points: 5,
                        actionIcon: "text.alignleft"
                    ))
                }
            } else {
                score += 5
                tips.append(ProfileQualityTip(
                    category: .bio,
                    title: "Write a Better Bio",
                    message: "Add at least 50 characters about your language learning goals",
                    impact: .high,
                    isCompleted: false,
                    points: 10,
                    actionIcon: "text.bubble.fill"
                ))
            }
        } else {
            tips.append(ProfileQualityTip(
                category: .bio,
                title: "Add a Bio",
                message: "Tell partners about your learning journey and goals!",
                impact: .high,
                isCompleted: false,
                points: 15,
                actionIcon: "text.bubble.fill"
            ))
        }

        // 6. Photos (10 points)
        if metrics.photoCount >= 1 {
            score += 10
        } else {
            tips.append(ProfileQualityTip(
                category: .photos,
                title: "Add a Photo",
                message: "Photos help build trust with language partners",
                impact: .high,
                isCompleted: false,
                points: 10,
                actionIcon: "photo.circle.fill"
            ))
        }

        // 7. Learning Goals (10 points)
        if metrics.hasLearningGoals {
            if metrics.learningGoalCount >= 2 {
                score += 10
            } else {
                score += 7
                tips.append(ProfileQualityTip(
                    category: .learningPreferences,
                    title: "Add More Learning Goals",
                    message: "Select multiple goals to find better matches",
                    impact: .low,
                    isCompleted: false,
                    points: 3,
                    actionIcon: "target"
                ))
            }
        } else {
            tips.append(ProfileQualityTip(
                category: .learningPreferences,
                title: "Add Learning Goals",
                message: "What do you want to achieve? (Conversation, business, travel, etc.)",
                impact: .medium,
                isCompleted: false,
                points: 10,
                actionIcon: "target"
            ))
        }

        // 8. Practice Methods (5 points)
        if metrics.hasPracticeMethods {
            score += 5
        } else {
            tips.append(ProfileQualityTip(
                category: .learningPreferences,
                title: "Add Practice Methods",
                message: "How do you prefer to practice? (Video call, text, in-person)",
                impact: .medium,
                isCompleted: false,
                points: 5,
                actionIcon: "bubble.left.and.bubble.right"
            ))
        }

        // 9. Availability (3 points)
        if metrics.hasAvailability {
            score += 3
        } else {
            tips.append(ProfileQualityTip(
                category: .learningPreferences,
                title: "Add Availability",
                message: "When are you free to practice?",
                impact: .low,
                isCompleted: false,
                points: 3,
                actionIcon: "clock"
            ))
        }

        // 10. Conversation Topics (2 points)
        if metrics.hasConversationTopics {
            score += 2
        } else {
            tips.append(ProfileQualityTip(
                category: .learningPreferences,
                title: "Add Conversation Topics",
                message: "What do you enjoy talking about?",
                impact: .low,
                isCompleted: false,
                points: 2,
                actionIcon: "text.bubble"
            ))
        }

        // 11. Verification (5 points - bonus)
        if metrics.hasVerifiedPhoto {
            score += 5
        } else {
            tips.append(ProfileQualityTip(
                category: .verification,
                title: "Verify Your Profile",
                message: "Verified profiles get 2x more connections",
                impact: .medium,
                isCompleted: false,
                points: 5,
                actionIcon: "checkmark.seal.fill"
            ))
        }

        // Sort tips by impact (critical first)
        tips.sort { tip1, tip2 in
            if tip1.impact == tip2.impact {
                return tip1.points > tip2.points
            }

            let impactOrder: [ProfileQualityTip.ImpactLevel] = [.critical, .high, .medium, .low]
            guard let index1 = impactOrder.firstIndex(of: tip1.impact),
                  let index2 = impactOrder.firstIndex(of: tip2.impact) else {
                return false
            }
            return index1 < index2
        }

        return (min(score, 100), tips)
    }

    // MARK: - User-Friendly Methods

    /// Updates score based on current user profile
    func updateScore(for user: User) {
        let metrics = ProfileMetrics(
            hasName: !user.fullName.isEmpty,
            hasAge: user.age > 0,
            hasBio: !user.bio.isEmpty,
            bioLength: user.bio.count,
            hasLocation: !user.location.isEmpty,
            photoCount: user.photos.count + (user.profileImageURL.isEmpty ? 0 : 1),
            hasNativeLanguages: !user.nativeLanguages.isEmpty,
            nativeLanguageCount: user.nativeLanguages.count,
            hasLearningLanguages: !user.learningLanguages.isEmpty,
            learningLanguageCount: user.learningLanguages.count,
            hasLearningGoals: !user.learningGoals.isEmpty,
            learningGoalCount: user.learningGoals.count,
            hasPracticeMethods: !user.practiceMethodPreferences.isEmpty,
            practiceMethodCount: user.practiceMethodPreferences.count,
            hasAvailability: !user.availabilities.isEmpty,
            hasConversationTopics: !user.conversationTopics.isEmpty,
            conversationTopicCount: user.conversationTopics.count,
            hasTimezone: user.timezone != nil && !user.timezone!.isEmpty,
            hasVerifiedPhoto: user.isVerified,
            bioHasEmoji: user.bio.containsEmoji,
            bioWordCount: user.bio.split(separator: " ").count
        )

        let result = calculateScore(for: metrics)
        currentScore = result.score
        qualityTips = result.tips
    }

    /// Get quality level description
    func getQualityLevel(for score: Int) -> (level: String, color: Color, message: String) {
        switch score {
        case 0..<30:
            return ("Incomplete", .red, "Complete your profile to find language partners")
        case 30..<50:
            return ("Basic", .orange, "Add more details to find better partners")
        case 50..<70:
            return ("Good", .yellow, "You're on the right track!")
        case 70..<85:
            return ("Great", .green, "Your profile looks great!")
        case 85..<100:
            return ("Excellent", .blue, "Almost perfect! Keep it up")
        case 100:
            return ("Perfect", .purple, "Your profile is amazing!")
        default:
            return ("Unknown", .gray, "")
        }
    }

    /// Get priority tip (most important to fix)
    func getPriorityTip() -> ProfileQualityTip? {
        return qualityTips.first
    }

    /// Get tips by category
    func getTips(for category: ProfileQualityTip.TipCategory) -> [ProfileQualityTip] {
        return qualityTips.filter { $0.category == category }
    }

    /// Calculate potential score increase
    func potentialScoreIncrease() -> Int {
        return qualityTips.reduce(0) { $0 + $1.points }
    }

    /// Get completion percentage
    func getCompletionPercentage() -> Double {
        return Double(currentScore) / Double(maxScore)
    }
}

// MARK: - String Extension

extension String {
    var containsEmoji: Bool {
        return unicodeScalars.contains { $0.properties.isEmoji }
    }
}

// MARK: - SwiftUI View for Profile Quality Card

struct ProfileQualityCard: View {
    @ObservedObject var scorer: ProfileQualityScorer
    let user: User

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Profile Quality")
                        .font(.headline)

                    let quality = scorer.getQualityLevel(for: scorer.currentScore)
                    Text(quality.level)
                        .font(.caption)
                        .foregroundColor(quality.color)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 60, height: 60)

                    Circle()
                        .trim(from: 0, to: scorer.getCompletionPercentage())
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: scorer.currentScore)

                    Text("\(scorer.currentScore)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }

            // Priority Tip
            if let priorityTip = scorer.getPriorityTip() {
                HStack(spacing: 12) {
                    Image(systemName: priorityTip.actionIcon)
                        .font(.title2)
                        .foregroundColor(priorityTip.impact.color)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(priorityTip.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(priorityTip.message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("+\(priorityTip.points)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding()
                .background(priorityTip.impact.color.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .onAppear {
            scorer.updateScore(for: user)
        }
    }
}
