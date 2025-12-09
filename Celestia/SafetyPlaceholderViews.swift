//
//  SafetyPlaceholderViews.swift
//  LangSwap
//
//  Safety feature views for language exchange platform
//  These views provide essential safety tools for language learners
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

                    Text("Get a verified badge to build trust with language partners")
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
                        description: "Show language partners you're a real person",
                        color: .green
                    )

                    VerificationBenefitRow(
                        icon: "star.fill",
                        title: "More Partners",
                        description: "Verified profiles get up to 3x more language partner requests",
                        color: .yellow
                    )

                    VerificationBenefitRow(
                        icon: "person.2.fill",
                        title: "Build Trust",
                        description: "Language partners feel safer practicing with you",
                        color: .blue
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
        ("LinkedIn", "briefcase.fill", Color.blue),
        ("Instagram", "camera.fill", Color.purple),
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
        case fakeProfile = "Fake Profile"
        case bug = "Bug Report"
        case feedback = "Feedback"

        var icon: String {
            switch self {
            case .safety: return "shield.fill"
            case .harassment: return "hand.raised.fill"
            case .scam: return "exclamationmark.triangle.fill"
            case .fakeProfile: return "person.crop.circle.badge.exclamationmark"
            case .bug: return "ladybug.fill"
            case .feedback: return "text.bubble.fill"
            }
        }

        var color: Color {
            switch self {
            case .safety: return .red
            case .harassment: return .orange
            case .scam: return .yellow
            case .fakeProfile: return .purple
            case .bug: return .gray
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

                    Text("We're here to help keep the LangSwap community safe")
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

// MARK: - Practice Session Safety Views

struct SafeStudyLocationsView: View {
    @Environment(\.dismiss) var dismiss

    let safeLocations = [
        SafeLocation(name: "Coffee Shops", icon: "cup.and.saucer.fill", color: .brown, tips: ["Well-lit and busy", "WiFi usually available", "Natural conversation environment"]),
        SafeLocation(name: "Libraries", icon: "books.vertical.fill", color: .blue, tips: ["Quiet study areas", "Free WiFi", "Staff available"]),
        SafeLocation(name: "Language Schools", icon: "building.2.fill", color: .teal, tips: ["Educational setting", "Other learners around", "Professional environment"]),
        SafeLocation(name: "University Cafes", icon: "graduationcap.fill", color: .purple, tips: ["Academic atmosphere", "Diverse community", "Study-friendly"]),
        SafeLocation(name: "Co-working Spaces", icon: "desktopcomputer", color: .orange, tips: ["Professional setting", "Good WiFi", "Meeting rooms available"])
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

                    Text("Safe Study Locations")
                        .font(.title.bold())

                    Text("Recommended places for in-person language practice")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Safety Tips Banner
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)

                    Text("Always meet in public for first sessions and let someone know where you'll be!")
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
        .navigationTitle("Safe Study Locations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Keep original name for backward compatibility
struct SafeDateLocationsView: View {
    var body: some View {
        SafeStudyLocationsView()
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

struct PracticeSessionCheckInView: View {
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
                            .fill(Color.teal.opacity(0.1))
                            .frame(width: 100, height: 100)

                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.teal)
                    }

                    Text("Session Check-In")
                        .font(.title.bold())

                    Text("Set safety check-ins for in-person practice sessions")
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
                        title: "Schedule Your Session",
                        description: "Tell us when and where you're meeting your language partner"
                    )

                    CheckInStepRow(
                        step: 2,
                        title: "Get Reminders",
                        description: "We'll check in during your practice session"
                    )

                    CheckInStepRow(
                        step: 3,
                        title: "Stay Safe",
                        description: "Trusted contacts are notified if needed"
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
                            .foregroundColor(.teal)

                        Text("Add Trusted Contacts First")
                            .font(.headline)

                        Text("You need at least one trusted contact to use Session Check-In")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        NavigationLink {
                            EmergencyContactsView()
                        } label: {
                            Text("Add Trusted Contacts")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.teal)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.teal.opacity(0.1))
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
                                colors: [.teal, .blue],
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
        .navigationTitle("Session Check-In")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showScheduleSheet) {
            ScheduleCheckInView()
        }
    }
}

// Keep original name for backward compatibility
struct DateCheckInView: View {
    var body: some View {
        PracticeSessionCheckInView()
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
                    .fill(Color.teal)
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
                    Text("Practicing with \(checkIn.matchName)")
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
                    Text("Need Help")
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

    @State private var partnerName = ""
    @State private var location = ""
    @State private var scheduledTime = Date().addingTimeInterval(3600)
    @State private var checkInInterval: Double = 60
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Session Details") {
                    TextField("Language partner's name", text: $partnerName)
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

                Section("Trusted Contacts") {
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
                    .disabled(partnerName.isEmpty || location.isEmpty || isSubmitting)
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
                    matchName: partnerName,
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
            icon: "hand.wave.fill",
            color: .blue,
            rules: [
                "Treat all language learners with dignity and respect",
                "Be patient with learners of all levels",
                "No harassment, bullying, or discriminatory language"
            ]
        ),
        GuidelineSection(
            title: "Be Authentic",
            icon: "person.fill.checkmark",
            color: .green,
            rules: [
                "Accurately represent your language abilities",
                "Use real photos of yourself",
                "Be honest about your learning goals"
            ]
        ),
        GuidelineSection(
            title: "Stay Educational",
            icon: "book.fill",
            color: .purple,
            rules: [
                "Keep conversations focused on language learning",
                "Share helpful resources and feedback",
                "Respect the educational purpose of the platform"
            ]
        ),
        GuidelineSection(
            title: "Protect Privacy",
            icon: "lock.shield.fill",
            color: .orange,
            rules: [
                "Never share others' personal information",
                "Respect boundaries in conversations",
                "Report suspicious behavior immediately"
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

                    Text("Rules for a safe and productive learning community")
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
                        BulletPoint(text: "Reporting to authorities if applicable")
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

#Preview("Community Guidelines") {
    NavigationStack {
        CommunityGuidelinesView()
    }
}
