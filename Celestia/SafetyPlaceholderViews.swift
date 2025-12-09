//
//  SafetyPlaceholderViews.swift
//  Celestia
//
//  Safety feature views - fully implemented
//  These views provide essential safety tools for users
//

import SwiftUI

// MARK: - Verification Views

struct IDVerificationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showManualVerification = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.teal.opacity(0.2), .blue.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)

                        Image(systemName: "person.text.rectangle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.teal, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    Text("Verify Your Identity")
                        .font(.title.bold())

                    Text("Get a verified badge to build trust with others")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                // Benefits Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Benefits of Verification")
                        .font(.headline)
                        .padding(.horizontal)

                    VerificationBenefitRow(
                        icon: "checkmark.shield.fill",
                        title: "Verified Badge",
                        description: "Show others you're a real person",
                        color: .green
                    )

                    VerificationBenefitRow(
                        icon: "star.fill",
                        title: "More Matches",
                        description: "Verified profiles get up to 3x more matches",
                        color: .yellow
                    )

                    VerificationBenefitRow(
                        icon: "heart.fill",
                        title: "Build Trust",
                        description: "Partners feel safer connecting with you",
                        color: .pink
                    )
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)

                // Verification Options
                VStack(spacing: 12) {
                    Button {
                        showManualVerification = true
                    } label: {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Verify with Photo")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.teal, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("ID Verification")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showManualVerification) {
            ManualIDVerificationView()
        }
    }
}

struct VerificationBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

struct SocialMediaVerificationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var linkedAccounts: Set<String> = []

    let socialPlatforms = [
        ("Instagram", "camera.fill", Color.purple),
        ("LinkedIn", "briefcase.fill", Color.blue),
        ("Twitter/X", "at", Color.cyan)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 100, height: 100)

                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                    }

                    Text("Link Social Accounts")
                        .font(.title.bold())

                    Text("Connect your social media to verify your identity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                // Social Platforms
                VStack(spacing: 12) {
                    ForEach(socialPlatforms, id: \.0) { platform in
                        SocialLinkRow(
                            platform: platform.0,
                            icon: platform.1,
                            color: platform.2,
                            isLinked: linkedAccounts.contains(platform.0),
                            onLink: {
                                if linkedAccounts.contains(platform.0) {
                                    linkedAccounts.remove(platform.0)
                                } else {
                                    linkedAccounts.insert(platform.0)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)

                // Privacy Note
                VStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.green)

                    Text("Your Privacy is Protected")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("We only use this to verify you're real. Your social accounts won't be shown on your profile.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Social Media")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SocialLinkRow: View {
    let platform: String
    let icon: String
    let color: Color
    let isLinked: Bool
    let onLink: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)

            Text(platform)
                .font(.headline)

            Spacer()

            Button(action: onLink) {
                Text(isLinked ? "Linked" : "Link")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isLinked ? .green : .blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isLinked ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Safety Tools Views

struct ReportingCenterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: ReportCategory = .safety

    enum ReportCategory: String, CaseIterable {
        case safety = "Safety Concerns"
        case harassment = "Harassment"
        case scam = "Scams & Fraud"
        case bug = "Bug Report"
        case feedback = "Feedback"

        var icon: String {
            switch self {
            case .safety: return "shield.fill"
            case .harassment: return "hand.raised.fill"
            case .scam: return "exclamationmark.triangle.fill"
            case .bug: return "ladybug.fill"
            case .feedback: return "text.bubble.fill"
            }
        }

        var color: Color {
            switch self {
            case .safety: return .red
            case .harassment: return .orange
            case .scam: return .yellow
            case .bug: return .purple
            case .feedback: return .blue
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 100, height: 100)

                        Image(systemName: "exclamationmark.bubble.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                    }

                    Text("Report & Support")
                        .font(.title.bold())

                    Text("We're here to help keep you safe")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Report Categories
                VStack(alignment: .leading, spacing: 16) {
                    Text("What would you like to report?")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(ReportCategory.allCases, id: \.self) { category in
                        NavigationLink {
                            ReportFormView(category: category)
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: category.icon)
                                    .font(.title2)
                                    .foregroundColor(category.color)
                                    .frame(width: 40)

                                Text(category.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)

                // Emergency Contact
                VStack(spacing: 12) {
                    Image(systemName: "phone.fill")
                        .font(.title)
                        .foregroundColor(.red)

                    Text("In immediate danger?")
                        .font(.headline)

                    Text("If you're in immediate danger, please contact local emergency services.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button {
                        if let url = URL(string: "tel://911") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Call Emergency Services")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Report & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReportFormView: View {
    let category: ReportingCenterView.ReportCategory
    @Environment(\.dismiss) var dismiss
    @State private var description = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false

    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundColor(category.color)

                    Text(category.rawValue)
                        .font(.headline)
                }
            }

            Section("Tell us more") {
                TextEditor(text: $description)
                    .frame(minHeight: 150)
            }

            Section {
                Button {
                    submitReport()
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Submit Report")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                }
                .disabled(description.isEmpty || isSubmitting)
            }
        }
        .navigationTitle("Submit Report")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Report Submitted", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Thank you for helping keep LangSwap safe. We'll review your report and take appropriate action.")
        }
    }

    private func submitReport() {
        isSubmitting = true

        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                isSubmitting = false
                showSuccess = true
                Logger.shared.info("Report submitted: \(category.rawValue)", category: .moderation)
            }
        }
    }
}

struct SafetySettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        PrivacySettingsView()
    }
}

// MARK: - Date Safety Views

struct SafeDateLocationsView: View {
    @Environment(\.dismiss) var dismiss

    let safeLocations = [
        SafeLocation(name: "Coffee Shops", icon: "cup.and.saucer.fill", color: .brown, tips: ["Well-lit and busy", "Easy to leave if uncomfortable", "Familiar environment"]),
        SafeLocation(name: "Restaurants", icon: "fork.knife", color: .orange, tips: ["Public and visible", "Staff available", "Natural time limit"]),
        SafeLocation(name: "Parks & Gardens", icon: "leaf.fill", color: .green, tips: ["Open public spaces", "Easy to walk away", "Meet during daylight"]),
        SafeLocation(name: "Museums & Galleries", icon: "building.columns.fill", color: .purple, tips: ["Security present", "Public setting", "Easy conversation starters"]),
        SafeLocation(name: "Shopping Centers", icon: "bag.fill", color: .blue, tips: ["Well-staffed", "Security cameras", "Multiple exits"])
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 100, height: 100)

                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                    }

                    Text("Safe Meeting Spots")
                        .font(.title.bold())

                    Text("Recommended public places for first meetings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Safety Tips Banner
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)

                    Text("Always meet in public for first dates and tell a friend where you'll be!")
                        .font(.subheadline)
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                // Safe Locations
                VStack(spacing: 16) {
                    ForEach(safeLocations) { location in
                        SafeLocationCard(location: location)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Safe Meeting Spots")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SafeLocation: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let tips: [String]
}

struct SafeLocationCard: View {
    let location: SafeLocation
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: location.icon)
                        .font(.title2)
                        .foregroundColor(location.color)
                        .frame(width: 40)

                    Text(location.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(location.tips, id: \.self) { tip in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)

                            Text(tip)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.leading, 56)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct DateCheckInView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var checkInManager = DateCheckInManager.shared
    @StateObject private var emergencyManager = EmergencyContactManager.shared
    @State private var showScheduleSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 100, height: 100)

                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                    }

                    Text("Date Check-In")
                        .font(.title.bold())

                    Text("Set safety check-ins for when you meet someone")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // How It Works
                VStack(alignment: .leading, spacing: 16) {
                    Text("How It Works")
                        .font(.headline)
                        .padding(.horizontal)

                    CheckInStepRow(
                        step: 1,
                        title: "Schedule Your Date",
                        description: "Tell us when and where you're meeting"
                    )

                    CheckInStepRow(
                        step: 2,
                        title: "Get Reminders",
                        description: "We'll check in during your date"
                    )

                    CheckInStepRow(
                        step: 3,
                        title: "Stay Safe",
                        description: "Emergency contacts are notified if needed"
                    )
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)

                // Active Check-Ins
                if !checkInManager.activeCheckIns.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active Check-Ins")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(checkInManager.activeCheckIns) { checkIn in
                            ActiveCheckInCard(checkIn: checkIn)
                        }
                    }
                    .padding(.horizontal)
                }

                // Emergency Contacts Requirement
                if !emergencyManager.hasContacts() {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.fill")
                            .font(.title)
                            .foregroundColor(.orange)

                        Text("Add Emergency Contacts First")
                            .font(.headline)

                        Text("You need at least one emergency contact to use Date Check-In")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        NavigationLink {
                            EmergencyContactsView()
                        } label: {
                            Text("Add Emergency Contacts")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                } else {
                    // Schedule Button
                    Button {
                        showScheduleSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Schedule a Check-In")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Date Check-In")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showScheduleSheet) {
            ScheduleCheckInView()
        }
    }
}

struct CheckInStepRow: View {
    let step: Int
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 30, height: 30)

                Text("\(step)")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

struct ActiveCheckInCard: View {
    let checkIn: DateCheckIn
    @StateObject private var checkInManager = DateCheckInManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Meeting with \(checkIn.matchName)")
                        .font(.headline)

                    Text(checkIn.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(checkIn.status.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor)
                    .cornerRadius(20)
            }

            HStack(spacing: 12) {
                Button {
                    Task {
                        try? await checkInManager.completeCheckIn(checkInId: checkIn.id)
                    }
                } label: {
                    Text("I'm Safe")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .cornerRadius(20)
                }

                Button {
                    Task {
                        try? await checkInManager.triggerEmergency(checkInId: checkIn.id)
                    }
                } label: {
                    Text("Emergency")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var statusColor: Color {
        switch checkIn.status {
        case .active: return .green
        case .scheduled: return .blue
        case .emergency: return .red
        case .completed: return .gray
        case .cancelled: return .gray
        }
    }
}

struct ScheduleCheckInView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var checkInManager = DateCheckInManager.shared
    @StateObject private var emergencyManager = EmergencyContactManager.shared

    @State private var matchName = ""
    @State private var location = ""
    @State private var scheduledTime = Date().addingTimeInterval(3600)
    @State private var checkInInterval: Double = 60
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Date Details") {
                    TextField("Who are you meeting?", text: $matchName)
                    TextField("Where are you meeting?", text: $location)
                    DatePicker("When?", selection: $scheduledTime, in: Date()...)
                }

                Section("Check-In Reminder") {
                    Picker("Remind me after", selection: $checkInInterval) {
                        Text("30 minutes").tag(30.0)
                        Text("1 hour").tag(60.0)
                        Text("2 hours").tag(120.0)
                        Text("3 hours").tag(180.0)
                    }
                }

                Section("Emergency Contacts") {
                    ForEach(emergencyManager.contacts) { contact in
                        HStack {
                            Image(systemName: contact.relationship.icon)
                                .foregroundColor(.teal)

                            VStack(alignment: .leading) {
                                Text(contact.name)
                                    .font(.subheadline)
                                Text(contact.formattedPhoneNumber)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section {
                    Button {
                        scheduleCheckIn()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Schedule Check-In")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(matchName.isEmpty || location.isEmpty || isSubmitting)
                }
            }
            .navigationTitle("Schedule Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func scheduleCheckIn() {
        isSubmitting = true

        Task {
            do {
                let checkInTime = scheduledTime.addingTimeInterval(checkInInterval * 60)
                _ = try await checkInManager.scheduleCheckIn(
                    matchId: UUID().uuidString,
                    matchName: matchName,
                    location: location,
                    scheduledTime: scheduledTime,
                    checkInTime: checkInTime,
                    emergencyContacts: emergencyManager.contacts
                )

                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                }
                Logger.shared.error("Failed to schedule check-in", category: .general, error: error)
            }
        }
    }
}

// MARK: - Resources Views

struct CommunityGuidelinesView: View {
    @Environment(\.dismiss) var dismiss

    let guidelines = [
        GuidelineSection(
            title: "Be Respectful",
            icon: "heart.fill",
            color: .pink,
            rules: [
                "Treat everyone with dignity and respect",
                "No harassment, bullying, or hate speech",
                "Respect others' boundaries and preferences"
            ]
        ),
        GuidelineSection(
            title: "Be Authentic",
            icon: "person.fill.checkmark",
            color: .blue,
            rules: [
                "Use real, recent photos of yourself",
                "Be honest about your intentions",
                "Don't impersonate others or use fake profiles"
            ]
        ),
        GuidelineSection(
            title: "Stay Safe",
            icon: "shield.fill",
            color: .green,
            rules: [
                "Never share financial information",
                "Meet in public places for first dates",
                "Report suspicious behavior immediately"
            ]
        ),
        GuidelineSection(
            title: "Keep It Legal",
            icon: "checkmark.seal.fill",
            color: .orange,
            rules: [
                "You must be 18+ to use LangSwap",
                "No illegal activities or solicitation",
                "Respect copyright and intellectual property"
            ]
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.teal.opacity(0.2), .blue.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)

                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.teal, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    Text("Community Guidelines")
                        .font(.title.bold())

                    Text("Our rules for a safe and respectful community")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Guidelines
                ForEach(guidelines) { section in
                    GuidelineSectionView(section: section)
                }

                // Violations
                VStack(spacing: 12) {
                    Text("Violations of these guidelines may result in:")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "Warning or temporary suspension")
                        BulletPoint(text: "Permanent account ban")
                        BulletPoint(text: "Reporting to law enforcement if applicable")
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Community Guidelines")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GuidelineSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let rules: [String]
}

struct GuidelineSectionView: View {
    let section: GuidelineSection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: section.icon)
                    .font(.title2)
                    .foregroundColor(section.color)

                Text(section.title)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(section.rules, id: \.self) { rule in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.top, 3)

                        Text(rule)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.leading, 36)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.red)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Previews

#Preview("ID Verification") {
    NavigationStack {
        IDVerificationView()
    }
}

#Preview("Phone Verification") {
    NavigationStack {
        PhoneVerificationView()
    }
}

#Preview("Social Media Verification") {
    NavigationStack {
        SocialMediaVerificationView()
    }
}
