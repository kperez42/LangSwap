//
//  SafetyCenter.swift
//  LangSwap
//
//  Safety Center for language exchange platform - verification, reporting, and protection
//

import SwiftUI
import FirebaseFirestore

// MARK: - Safety Center View

struct SafetyCenterView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = SafetyCenterViewModel()
    @StateObject private var safetyManager = SafetyManager.shared
    @StateObject private var emergencyManager = EmergencyContactManager.shared
    @StateObject private var verificationService = VerificationService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Safety Score Header
                    safetyScoreHeader

                    // Quick Actions
                    quickActionsSection

                    // Verification Status
                    verificationSection

                    // Emergency Contacts
                    emergencyContactsSection

                    // Date Safety
                    dateSafetySection

                    // Safety Tools
                    safetyToolsSection

                    // Resources
                    resourcesSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Safety Center")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadSafetyData()
                safetyManager.calculateSafetyScore()
            }
        }
    }

    // MARK: - Safety Score Header

    private var safetyScoreHeader: some View {
        VStack(spacing: 16) {
            // Score Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(safetyManager.safetyScore) / 100)
                    .stroke(
                        LinearGradient(
                            colors: scoreColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(safetyManager.safetyScore)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: scoreColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Safety Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(scoreMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Improvement Tips
            if safetyManager.safetyScore < 80 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Improve your score:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    ForEach(improvementTips.prefix(2), id: \.self) { tip in
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)

                            Text(tip)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var scoreColors: [Color] {
        if safetyManager.safetyScore >= 80 {
            return [.green, .teal]
        } else if safetyManager.safetyScore >= 50 {
            return [.yellow, .orange]
        } else {
            return [.orange, .red]
        }
    }

    private var scoreMessage: String {
        if safetyManager.safetyScore >= 80 {
            return "Great job! Your account is well protected."
        } else if safetyManager.safetyScore >= 50 {
            return "Good start! Complete more steps to improve your safety."
        } else {
            return "Let's make your account safer. Complete the steps below."
        }
    }

    private var improvementTips: [String] {
        var tips: [String] = []
        if !verificationService.idVerified {
            tips.append("Verify your identity to build trust with language partners")
        }
        if !emergencyManager.hasContacts() {
            tips.append("Add trusted contacts for in-person practice sessions")
        }
        if !verificationService.photoVerified {
            tips.append("Complete photo verification")
        }
        return tips
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        HStack(spacing: 12) {
            QuickActionButton(
                icon: "phone.fill",
                title: "Emergency",
                color: .red
            ) {
                if let url = URL(string: "tel://911") {
                    UIApplication.shared.open(url)
                }
            }

            NavigationLink {
                DateCheckInView()
            } label: {
                QuickActionCard(
                    icon: "bell.badge.fill",
                    title: "Check-In",
                    color: .orange
                )
            }

            NavigationLink {
                EmergencyContactsView()
            } label: {
                QuickActionCard(
                    icon: "person.2.fill",
                    title: "Contacts",
                    color: .blue
                )
            }
        }
    }

    // MARK: - Verification Section

    private var verificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SafetySectionHeader(title: "Verification", icon: "checkmark.shield.fill")

            VStack(spacing: 12) {
                NavigationLink {
                    IDVerificationView()
                } label: {
                    SafetyOptionRow(
                        icon: "person.text.rectangle.fill",
                        title: "ID Verification",
                        subtitle: verificationService.idVerified ? "Verified" : "Verify your identity",
                        color: .teal,
                        isCompleted: verificationService.idVerified
                    )
                }

                NavigationLink {
                    PhoneVerificationView()
                } label: {
                    SafetyOptionRow(
                        icon: "phone.fill",
                        title: "Phone Verification",
                        subtitle: verificationService.phoneVerified ? "Verified" : "Verify your phone number",
                        color: .green,
                        isCompleted: verificationService.phoneVerified
                    )
                }

                NavigationLink {
                    SocialMediaVerificationView()
                } label: {
                    SafetyOptionRow(
                        icon: "link.circle.fill",
                        title: "Social Media",
                        subtitle: "Link your social accounts",
                        color: .blue,
                        isCompleted: false
                    )
                }
            }
        }
    }

    // MARK: - Trusted Contacts Section

    private var emergencyContactsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SafetySectionHeader(title: "Trusted Contacts", icon: "person.2.fill")

            NavigationLink {
                EmergencyContactsView()
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 50, height: 50)

                        Image(systemName: emergencyManager.hasContacts() ? "person.2.fill" : "person.badge.plus")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(emergencyManager.hasContacts() ? "Manage Contacts" : "Add Trusted Contacts")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(emergencyManager.hasContacts()
                             ? "\(emergencyManager.contacts.count) contact(s) added"
                             : "Set up contacts for in-person meetups")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if emergencyManager.hasContacts() {
                        Text("\(emergencyManager.contacts.count)")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Practice Safety Section

    private var dateSafetySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SafetySectionHeader(title: "Practice Safety", icon: "person.2.circle.fill")

            VStack(spacing: 12) {
                NavigationLink {
                    PracticeSessionCheckInView()
                } label: {
                    SafetyOptionRow(
                        icon: "bell.badge.fill",
                        title: "Session Check-In",
                        subtitle: "Safety reminders for meetups",
                        color: .teal
                    )
                }

                NavigationLink {
                    SafeStudyLocationsView()
                } label: {
                    SafetyOptionRow(
                        icon: "mappin.circle.fill",
                        title: "Safe Study Locations",
                        subtitle: "Recommended places for practice",
                        color: .green
                    )
                }
            }
        }
    }

    // MARK: - Safety Tools Section

    private var safetyToolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SafetySectionHeader(title: "Safety Tools", icon: "shield.fill")

            VStack(spacing: 12) {
                NavigationLink {
                    BlockedUsersView()
                } label: {
                    SafetyOptionRow(
                        icon: "hand.raised.fill",
                        title: "Blocked Users",
                        subtitle: "Manage blocked accounts",
                        color: .red,
                        badge: viewModel.blockedCount
                    )
                }

                NavigationLink {
                    ReportingCenterView()
                } label: {
                    SafetyOptionRow(
                        icon: "exclamationmark.triangle.fill",
                        title: "Report & Support",
                        subtitle: "Report issues or users",
                        color: .orange
                    )
                }

                NavigationLink {
                    PrivacySettingsView()
                } label: {
                    SafetyOptionRow(
                        icon: "lock.shield.fill",
                        title: "Privacy Settings",
                        subtitle: "Control your visibility",
                        color: .purple
                    )
                }
            }
        }
    }

    // MARK: - Resources Section

    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SafetySectionHeader(title: "Resources", icon: "book.fill")

            VStack(spacing: 12) {
                NavigationLink {
                    CommunityGuidelinesView()
                } label: {
                    SafetyOptionRow(
                        icon: "doc.text.fill",
                        title: "Community Guidelines",
                        subtitle: "Our rules and standards",
                        color: .blue
                    )
                }

                NavigationLink {
                    SafetyTipsView()
                } label: {
                    SafetyOptionRow(
                        icon: "lightbulb.fill",
                        title: "Safety Tips",
                        subtitle: "Best practices for language exchange",
                        color: .yellow
                    )
                }
            }
        }
        .padding(.bottom, 40)
    }
}

// MARK: - Quick Action Components

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            QuickActionCard(icon: icon, title: title, color: color)
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Safety Tips View

struct SafetyTipsView: View {
    @StateObject private var safetyManager = SafetyManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.1))
                            .frame(width: 100, height: 100)

                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                    }

                    Text("Safety Tips")
                        .font(.title.bold())

                    Text("Best practices for safe language exchange")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Tips by Category
                ForEach(TipCategory.allCases, id: \.self) { category in
                    SafetyTipCategoryView(category: category)
                }
            }
            .padding()
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Safety Tips")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SafetyTipCategoryView: View {
    let category: TipCategory
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: category.icon)
                        .font(.title3)
                        .foregroundColor(category.color)

                    Text(category.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(SafetyTip.tips(for: category)) { tip in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                                .padding(.top, 2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(tip.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Text(tip.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.leading, 32)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Section Header

struct SafetySectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.teal)

            Text(title)
                .font(.title3.bold())

            Spacer()
        }
    }
}

// MARK: - Safety Option Row

struct SafetyOptionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var isCompleted: Bool = false
    var badge: Int?

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Status
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            } else if let badge = badge, badge > 0 {
                Text("\(badge)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color)
                    .clipShape(Capsule())
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - View Model

@MainActor
class SafetyCenterViewModel: ObservableObject {
    @Published var blockedCount = 0

    private let db = Firestore.firestore()

    func loadSafetyData() async {
        // BUGFIX: Use effectiveId for reliable user identification
        guard let userId = AuthService.shared.currentUser?.effectiveId else { return }

        do {
            // Load blocked users count
            let blockedSnapshot = try await db.collection("blocked_users")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            blockedCount = blockedSnapshot.documents.count
        } catch {
            Logger.shared.error("Error loading safety data", category: .general, error: error)
        }
    }
}

#Preview {
    SafetyCenterView()
        .environmentObject(AuthService.shared)
}
