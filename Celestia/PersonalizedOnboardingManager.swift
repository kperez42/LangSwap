//
//  PersonalizedOnboardingManager.swift
//  LangSwap
//
//  Manages personalized onboarding paths based on language learning goals
//  Adapts the onboarding experience to match user language exchange intentions
//

import Foundation
import SwiftUI

/// Manages personalized onboarding experiences based on language learning goals
@MainActor
class PersonalizedOnboardingManager: ObservableObject {

    static let shared = PersonalizedOnboardingManager()

    @Published var selectedGoal: LanguageGoal?
    @Published var recommendedPath: OnboardingPath?
    @Published var customizations: [String: Any] = [:]

    private let userDefaultsKey = "selected_onboarding_goal"

    // MARK: - Models

    enum LanguageGoal: String, Codable, CaseIterable {
        case conversationFluency = "conversation_fluency"
        case examPreparation = "exam_preparation"
        case businessProfessional = "business_professional"
        case travelCultural = "travel_cultural"
        case academicStudy = "academic_study"

        var displayName: String {
            switch self {
            case .conversationFluency: return "Conversation Fluency"
            case .examPreparation: return "Exam Preparation"
            case .businessProfessional: return "Business/Professional"
            case .travelCultural: return "Travel & Culture"
            case .academicStudy: return "Academic Study"
            }
        }

        var icon: String {
            switch self {
            case .conversationFluency: return "bubble.left.and.bubble.right.fill"
            case .examPreparation: return "doc.text.fill"
            case .businessProfessional: return "briefcase.fill"
            case .travelCultural: return "airplane"
            case .academicStudy: return "graduationcap.fill"
            }
        }

        var description: String {
            switch self {
            case .conversationFluency:
                return "Practice speaking naturally with native speakers"
            case .examPreparation:
                return "Prepare for TOEFL, IELTS, DELE, JLPT, HSK, etc."
            case .businessProfessional:
                return "Learn professional vocabulary and communication"
            case .travelCultural:
                return "Learn practical phrases and cultural insights"
            case .academicStudy:
                return "Improve academic reading and writing skills"
            }
        }

        var color: Color {
            switch self {
            case .conversationFluency: return .blue
            case .examPreparation: return .purple
            case .businessProfessional: return .indigo
            case .travelCultural: return .teal
            case .academicStudy: return .green
            }
        }
    }

    struct OnboardingPath {
        let goal: LanguageGoal
        let steps: [OnboardingPathStep]
        let focusAreas: [FocusArea]
        let recommendedFeatures: [String]
        let tutorialPriority: [String] // Tutorial IDs in priority order

        enum FocusArea: String {
            case languageSelection = "language_selection"
            case proficiencyLevel = "proficiency_level"
            case learningGoals = "learning_goals"
            case practiceSchedule = "practice_schedule"
            case topicInterests = "topic_interests"
            case verificationTrust = "verification_trust"
        }
    }

    struct OnboardingPathStep {
        let id: String
        let title: String
        let description: String
        let importance: StepImportance
        let tips: [String]

        enum StepImportance {
            case critical
            case recommended
            case optional
        }
    }

    // MARK: - Initialization

    init() {
        loadSavedGoal()
    }

    // MARK: - Goal Selection

    func selectGoal(_ goal: LanguageGoal) {
        selectedGoal = goal
        recommendedPath = generatePath(for: goal)
        saveGoal()

        // Track analytics
        AnalyticsManager.shared.logEvent(.onboardingStepCompleted, parameters: [
            "step": "goal_selection",
            "goal": goal.rawValue,
            "goal_name": goal.displayName
        ])

        Logger.shared.info("User selected language learning goal: \(goal.displayName)", category: .onboarding)
    }

    // MARK: - Path Generation

    private func generatePath(for goal: LanguageGoal) -> OnboardingPath {
        switch goal {
        case .conversationFluency:
            return createConversationFluencyPath()
        case .examPreparation:
            return createExamPreparationPath()
        case .businessProfessional:
            return createBusinessProfessionalPath()
        case .travelCultural:
            return createTravelCulturalPath()
        case .academicStudy:
            return createAcademicStudyPath()
        }
    }

    private func createConversationFluencyPath() -> OnboardingPath {
        OnboardingPath(
            goal: .conversationFluency,
            steps: [
                OnboardingPathStep(
                    id: "language_profile",
                    title: "Set Up Your Language Profile",
                    description: "Tell us what languages you speak and what you want to learn",
                    importance: .critical,
                    tips: [
                        "Add all languages you can speak fluently",
                        "Select the languages you're learning",
                        "Be honest about your proficiency levels"
                    ]
                ),
                OnboardingPathStep(
                    id: "conversation_topics",
                    title: "Choose Conversation Topics",
                    description: "Select topics you enjoy discussing",
                    importance: .critical,
                    tips: [
                        "Pick topics you're genuinely interested in",
                        "Variety helps keep conversations engaging",
                        "You can always update these later"
                    ]
                ),
                OnboardingPathStep(
                    id: "practice_schedule",
                    title: "Set Your Availability",
                    description: "When are you available for language practice?",
                    importance: .recommended,
                    tips: [
                        "Consider time zone differences with partners",
                        "Regular practice leads to faster improvement",
                        "Even 15-30 minutes daily helps"
                    ]
                )
            ],
            focusAreas: [.languageSelection, .topicInterests, .practiceSchedule],
            recommendedFeatures: ["Voice Messages", "Video Calls", "Text Chat"],
            tutorialPriority: ["language_setup", "finding_partners", "messaging", "practice_tips"]
        )
    }

    private func createExamPreparationPath() -> OnboardingPath {
        OnboardingPath(
            goal: .examPreparation,
            steps: [
                OnboardingPathStep(
                    id: "exam_details",
                    title: "Set Your Language Goals",
                    description: "Tell us which exam you're preparing for",
                    importance: .critical,
                    tips: [
                        "Specify the exam (TOEFL, IELTS, DELE, JLPT, HSK)",
                        "Share your target score or level",
                        "Mention your exam timeline"
                    ]
                ),
                OnboardingPathStep(
                    id: "current_level",
                    title: "Assess Your Current Level",
                    description: "Be honest about where you are now",
                    importance: .critical,
                    tips: [
                        "Use CEFR levels (A1-C2) as reference",
                        "Partners can help you prepare better if they know your level",
                        "It's okay to start at any level"
                    ]
                ),
                OnboardingPathStep(
                    id: "practice_areas",
                    title: "Identify Weak Areas",
                    description: "What do you need the most help with?",
                    importance: .recommended,
                    tips: [
                        "Speaking is often the hardest part of exams",
                        "Find partners who can help with specific sections",
                        "Regular practice is key to improvement"
                    ]
                )
            ],
            focusAreas: [.proficiencyLevel, .learningGoals, .practiceSchedule],
            recommendedFeatures: ["Study Partners", "Speaking Practice", "Writing Feedback"],
            tutorialPriority: ["language_setup", "finding_partners", "practice_tips", "messaging"]
        )
    }

    private func createBusinessProfessionalPath() -> OnboardingPath {
        OnboardingPath(
            goal: .businessProfessional,
            steps: [
                OnboardingPathStep(
                    id: "professional_profile",
                    title: "Create Your Language Profile",
                    description: "Highlight your professional language needs",
                    importance: .critical,
                    tips: [
                        "Mention your industry or field",
                        "Share what professional skills you want to develop",
                        "Include your current proficiency level"
                    ]
                ),
                OnboardingPathStep(
                    id: "business_topics",
                    title: "Select Business Topics",
                    description: "What professional areas do you want to practice?",
                    importance: .critical,
                    tips: [
                        "Meetings, presentations, negotiations",
                        "Email and written communication",
                        "Industry-specific vocabulary"
                    ]
                ),
                OnboardingPathStep(
                    id: "verify_profile",
                    title: "Verify Your Profile",
                    description: "Build trust with other professionals",
                    importance: .recommended,
                    tips: [
                        "Verification increases response rates",
                        "Professional partners appreciate authenticity",
                        "Takes less than 2 minutes"
                    ]
                )
            ],
            focusAreas: [.languageSelection, .learningGoals, .verificationTrust],
            recommendedFeatures: ["Professional Mode", "Video Calls", "Voice Messages"],
            tutorialPriority: ["language_setup", "finding_partners", "messaging", "verification"]
        )
    }

    private func createTravelCulturalPath() -> OnboardingPath {
        OnboardingPath(
            goal: .travelCultural,
            steps: [
                OnboardingPathStep(
                    id: "travel_languages",
                    title: "Set Your Language Goals",
                    description: "What languages do you want to practice for travel?",
                    importance: .critical,
                    tips: [
                        "Focus on practical, everyday phrases",
                        "Learn about local customs and etiquette",
                        "Connect with native speakers before you travel"
                    ]
                ),
                OnboardingPathStep(
                    id: "cultural_interests",
                    title: "Share Your Interests",
                    description: "What aspects of the culture interest you?",
                    importance: .recommended,
                    tips: [
                        "Food, music, history, traditions",
                        "Local recommendations from natives",
                        "Authentic cultural exchange"
                    ]
                ),
                OnboardingPathStep(
                    id: "travel_plans",
                    title: "Share Your Plans",
                    description: "Let partners know about your travel goals",
                    importance: .optional,
                    tips: [
                        "Mention countries or regions you want to visit",
                        "Find partners from those areas",
                        "Learn from real local experiences"
                    ]
                )
            ],
            focusAreas: [.languageSelection, .topicInterests, .practiceSchedule],
            recommendedFeatures: ["Cultural Exchange", "Text Chat", "Voice Messages"],
            tutorialPriority: ["language_setup", "finding_partners", "messaging", "cultural_tips"]
        )
    }

    private func createAcademicStudyPath() -> OnboardingPath {
        OnboardingPath(
            goal: .academicStudy,
            steps: [
                OnboardingPathStep(
                    id: "academic_profile",
                    title: "Create Your Language Profile",
                    description: "Tell us about your academic language goals",
                    importance: .critical,
                    tips: [
                        "Mention your field of study",
                        "Share your current academic level",
                        "Be specific about skills you want to improve"
                    ]
                ),
                OnboardingPathStep(
                    id: "academic_needs",
                    title: "Identify Your Needs",
                    description: "What academic skills do you want to develop?",
                    importance: .critical,
                    tips: [
                        "Reading academic papers",
                        "Writing essays and research",
                        "Academic presentations",
                        "Vocabulary for your field"
                    ]
                ),
                OnboardingPathStep(
                    id: "verify_profile",
                    title: "Verify Your Profile",
                    description: "Build credibility with other learners",
                    importance: .recommended,
                    tips: [
                        "Verification shows you're serious about learning",
                        "Academic partners value authenticity",
                        "Increases match quality"
                    ]
                )
            ],
            focusAreas: [.proficiencyLevel, .learningGoals, .verificationTrust],
            recommendedFeatures: ["Writing Feedback", "Reading Practice", "Study Groups"],
            tutorialPriority: ["language_setup", "finding_partners", "practice_tips", "verification"]
        )
    }

    // MARK: - Customizations

    func getCustomTips() -> [String] {
        guard let path = recommendedPath else { return [] }
        return path.steps.flatMap { $0.tips }
    }

    func shouldEmphasize(focusArea: OnboardingPath.FocusArea) -> Bool {
        guard let path = recommendedPath else { return false }
        return path.focusAreas.contains(focusArea)
    }

    func getPrioritizedTutorials() -> [String] {
        guard let path = recommendedPath else {
            return ["welcome", "language_setup", "finding_partners", "messaging"]
        }
        return path.tutorialPriority
    }

    func getRecommendedFeatures() -> [String] {
        return recommendedPath?.recommendedFeatures ?? []
    }

    // MARK: - Persistence

    private func saveGoal() {
        if let goal = selectedGoal,
           let encoded = try? JSONEncoder().encode(goal) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadSavedGoal() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let goal = try? JSONDecoder().decode(LanguageGoal.self, from: data) {
            selectedGoal = goal
            recommendedPath = generatePath(for: goal)
        }
    }
}

// MARK: - SwiftUI View for Goal Selection

struct OnboardingGoalSelectionView: View {
    @ObservedObject var manager = PersonalizedOnboardingManager.shared
    @Environment(\.dismiss) var dismiss

    let onGoalSelected: (PersonalizedOnboardingManager.LanguageGoal) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("What's your language goal?")
                    .font(.title)
                    .fontWeight(.bold)

                Text("This helps us find the best language partners for you")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)

            // Goal Options
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(PersonalizedOnboardingManager.LanguageGoal.allCases, id: \.self) { goal in
                        GoalCard(goal: goal, isSelected: manager.selectedGoal == goal) {
                            withAnimation(.spring(response: 0.3)) {
                                manager.selectGoal(goal)
                                HapticManager.shared.selection()
                            }
                        }
                    }
                }
                .padding(24)
            }

            // Continue Button
            if manager.selectedGoal != nil {
                Button {
                    if let goal = manager.selectedGoal {
                        onGoalSelected(goal)
                    }
                    dismiss()
                } label: {
                    HStack {
                        Text("Continue")
                            .fontWeight(.semibold)

                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.blue, .teal],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .transition(.opacity)
            }
        }
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.teal.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct GoalCard: View {
    let goal: PersonalizedOnboardingManager.LanguageGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(goal.color.opacity(0.15))
                            .frame(width: 50, height: 50)

                        Image(systemName: goal.icon)
                            .font(.title2)
                            .foregroundColor(goal.color)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? goal.color : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? goal.color.opacity(0.2) : .clear, radius: 8, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingGoalSelectionView { goal in
        print("Selected goal: \(goal.displayName)")
    }
}
