//
//  SafeExchangeTipsView.swift
//  LangSwap
//
//  Safety tips and resources for language exchange
//

import SwiftUI

struct SafeExchangeTipsView: View {
    @State private var selectedCategory: TipCategory = .beforeMeeting

    var body: some View {
        VStack(spacing: 0) {
            // Category Picker
            categoryPicker

            // Tips List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(SafetyTip.tips(for: selectedCategory)) { tip in
                        SafetyTipCard(tip: tip)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Safe Exchange Tips")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TipCategory.allCases, id: \.self) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Category Tab

struct CategoryTab: View {
    let category: TipCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title3)

                Text(category.title)
                    .font(.caption.bold())
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [.blue, .teal],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(isSelected ? 0.15 : 0.05), radius: 5, y: 2)
        }
    }
}

// MARK: - Safety Tip Card

struct SafetyTipCard: View {
    let tip: SafetyTip

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and Title
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tip.priority.color.opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image(systemName: tip.icon)
                        .font(.title3)
                        .foregroundColor(tip.priority.color)
                }

                Text(tip.title)
                    .font(.headline)

                Spacer()

                if tip.priority == .critical {
                    Text("IMPORTANT")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(6)
                }
            }

            // Description
            Text(tip.description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Action items if present
            if !tip.actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tip.actionItems, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)

                            Text(item)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(12)
                .background(Color.green.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Models

enum TipCategory: CaseIterable {
    case beforeMeeting
    case videoCalls
    case inPersonMeetups
    case privacySafety
    case resources

    var title: String {
        switch self {
        case .beforeMeeting: return "Getting Started"
        case .videoCalls: return "Video Calls"
        case .inPersonMeetups: return "In-Person"
        case .privacySafety: return "Privacy"
        case .resources: return "Resources"
        }
    }

    var icon: String {
        switch self {
        case .beforeMeeting: return "person.badge.clock"
        case .videoCalls: return "video.fill"
        case .inPersonMeetups: return "person.2.fill"
        case .privacySafety: return "lock.shield.fill"
        case .resources: return "link"
        }
    }
}

enum TipPriority {
    case critical
    case important
    case helpful

    var color: Color {
        switch self {
        case .critical: return .red
        case .important: return .orange
        case .helpful: return .blue
        }
    }
}

struct SafetyTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let priority: TipPriority
    let actionItems: [String]

    static func tips(for category: TipCategory) -> [SafetyTip] {
        switch category {
        case .beforeMeeting:
            return [
                SafetyTip(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Get to Know Them First",
                    description: "Chat with your language partner for a while before sharing personal information or meeting in person.",
                    priority: .important,
                    actionItems: [
                        "Have several conversations first",
                        "Keep initial chats on the platform",
                        "Verify their language skills through conversation"
                    ]
                ),
                SafetyTip(
                    icon: "checkmark.shield.fill",
                    title: "Look for Verified Profiles",
                    description: "Verified profiles indicate users have confirmed their identity, making interactions safer.",
                    priority: .important,
                    actionItems: [
                        "Check for verification badges",
                        "Review their profile completeness",
                        "Look for consistent information"
                    ]
                ),
                SafetyTip(
                    icon: "clock.fill",
                    title: "Start with Text Chat",
                    description: "Begin with text conversations to assess language compatibility and build comfort before video calls.",
                    priority: .helpful,
                    actionItems: [
                        "Practice writing first",
                        "Assess their communication style",
                        "Build rapport gradually"
                    ]
                ),
                SafetyTip(
                    icon: "flag.fill",
                    title: "Report Suspicious Behavior",
                    description: "If someone seems fake or behaves inappropriately, report them to help keep the community safe.",
                    priority: .important,
                    actionItems: [
                        "Use the report feature",
                        "Block users who make you uncomfortable",
                        "Trust your instincts"
                    ]
                )
            ]

        case .videoCalls:
            return [
                SafetyTip(
                    icon: "video.fill",
                    title: "Use In-App Video Calling",
                    description: "Use LangSwap's built-in video features when available, or established platforms like Zoom or Google Meet.",
                    priority: .important,
                    actionItems: [
                        "Don't share personal meeting links",
                        "Use waiting rooms for extra security",
                        "Keep your background neutral"
                    ]
                ),
                SafetyTip(
                    icon: "eye.slash.fill",
                    title: "Mind Your Background",
                    description: "Before video calls, check what's visible behind you. Avoid showing personal documents or identifiable locations.",
                    priority: .helpful,
                    actionItems: [
                        "Use a virtual background if needed",
                        "Remove personal items from view",
                        "Check your screen before sharing"
                    ]
                ),
                SafetyTip(
                    icon: "mic.slash.fill",
                    title: "Control Your Audio/Video",
                    description: "Know how to quickly mute or turn off your camera if needed during calls.",
                    priority: .helpful,
                    actionItems: [
                        "Learn the mute shortcut",
                        "Test your setup beforehand",
                        "Have a backup plan if tech fails"
                    ]
                ),
                SafetyTip(
                    icon: "rectangle.and.pencil.and.ellipsis",
                    title: "Record Only with Consent",
                    description: "Never record video calls without explicit permission from your language partner.",
                    priority: .critical,
                    actionItems: [
                        "Always ask before recording",
                        "Respect privacy preferences",
                        "Delete recordings when requested"
                    ]
                )
            ]

        case .inPersonMeetups:
            return [
                SafetyTip(
                    icon: "building.2.fill",
                    title: "Meet in Public Places",
                    description: "For in-person language exchanges, choose busy public locations like cafes, libraries, or language exchange events.",
                    priority: .critical,
                    actionItems: [
                        "Choose busy cafes or libraries",
                        "Attend organized language events",
                        "Stay in well-lit, populated areas"
                    ]
                ),
                SafetyTip(
                    icon: "person.2.fill",
                    title: "Tell Someone Your Plans",
                    description: "Always let a friend or family member know where you're going and who you're meeting.",
                    priority: .critical,
                    actionItems: [
                        "Share your location with a friend",
                        "Set up check-in times",
                        "Share your partner's profile info"
                    ]
                ),
                SafetyTip(
                    icon: "car.fill",
                    title: "Arrange Your Own Transport",
                    description: "Use your own transportation to and from meetups. Don't accept rides from people you just met.",
                    priority: .critical,
                    actionItems: [
                        "Drive yourself or use rideshare",
                        "Don't share your home address",
                        "Have an exit strategy"
                    ]
                ),
                SafetyTip(
                    icon: "iphone",
                    title: "Keep Your Phone Charged",
                    description: "Ensure your phone is charged and you have a way to contact someone if needed.",
                    priority: .important,
                    actionItems: [
                        "Bring a portable charger",
                        "Keep emergency contacts handy",
                        "Know the local emergency numbers"
                    ]
                )
            ]

        case .privacySafety:
            return [
                SafetyTip(
                    icon: "lock.shield.fill",
                    title: "Protect Personal Information",
                    description: "Don't share sensitive information like your home address, workplace, or financial details with new language partners.",
                    priority: .critical,
                    actionItems: [
                        "Keep your address private",
                        "Don't share financial information",
                        "Be vague about daily routines"
                    ]
                ),
                SafetyTip(
                    icon: "at",
                    title: "Use Your LangSwap Username",
                    description: "Keep conversations on the platform initially. Share personal contact info only after building trust.",
                    priority: .important,
                    actionItems: [
                        "Use in-app messaging first",
                        "Don't rush to share social media",
                        "Build trust before exchanging contacts"
                    ]
                ),
                SafetyTip(
                    icon: "dollarsign.circle.fill",
                    title: "Never Send Money",
                    description: "Language exchange should be free. Never send money to someone you've met online, regardless of the story.",
                    priority: .critical,
                    actionItems: [
                        "Never send money or gift cards",
                        "Report anyone asking for money",
                        "Block and report scam attempts"
                    ]
                ),
                SafetyTip(
                    icon: "hand.raised.fill",
                    title: "Trust Your Instincts",
                    description: "If something feels wrong, it probably is. You can end any conversation or block anyone at any time.",
                    priority: .important,
                    actionItems: [
                        "It's okay to stop responding",
                        "Block users who make you uncomfortable",
                        "Report suspicious behavior"
                    ]
                )
            ]

        case .resources:
            return [
                SafetyTip(
                    icon: "envelope.fill",
                    title: "Contact LangSwap Support",
                    description: "If you experience any issues or concerns, reach out to our support team.",
                    priority: .helpful,
                    actionItems: [
                        "Email: support@langswap.app",
                        "Use in-app help center",
                        "Report through the app"
                    ]
                ),
                SafetyTip(
                    icon: "phone.fill",
                    title: "Emergency Services",
                    description: "In immediate danger, always contact your local emergency services.",
                    priority: .critical,
                    actionItems: [
                        "911 (US/Canada)",
                        "112 (EU)",
                        "Know your local emergency number"
                    ]
                ),
                SafetyTip(
                    icon: "globe",
                    title: "Online Safety Resources",
                    description: "Learn more about staying safe online from trusted resources.",
                    priority: .helpful,
                    actionItems: [
                        "staysafeonline.org",
                        "getsafeonline.org",
                        "connectsafely.org"
                    ]
                ),
                SafetyTip(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Community Guidelines",
                    description: "Familiarize yourself with our community guidelines to ensure a positive experience for everyone.",
                    priority: .helpful,
                    actionItems: [
                        "Read our Terms of Service",
                        "Review Community Guidelines",
                        "Understand reporting procedures"
                    ]
                )
            ]
        }
    }
}

#Preview {
    NavigationStack {
        SafeExchangeTipsView()
    }
}
