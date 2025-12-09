//
//  EditProfileView.swift
//  LangSwap
//
//  Profile editing for language exchange - focused on languages and learning preferences
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import UniformTypeIdentifiers

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService

    // Basic Info
    @State private var fullName: String
    @State private var age: String
    @State private var bio: String
    @State private var location: String
    @State private var country: String
    @State private var timezone: String

    // Language Exchange Fields
    @State private var nativeLanguages: [LanguageProficiency]
    @State private var learningLanguages: [LanguageProficiency]
    @State private var learningGoals: [String]
    @State private var practiceMethodPreferences: [String]
    @State private var availabilities: [String]
    @State private var conversationTopics: [String]

    // Profile Content
    @State private var prompts: [ProfilePrompt]
    @State private var photos: [String] = []

    // UI State
    @State private var isLoading = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showNativeLanguagePicker = false
    @State private var showLearningLanguagePicker = false
    @State private var showPromptsEditor = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var isUploadingPhotos = false
    @State private var uploadProgress: Double = 0.0
    @State private var isUploadingProfilePhoto = false
    @State private var uploadingPhotoCount = 0
    @State private var draggingPhotoURL: String?
    @State private var userId: String = ""

    @ObservedObject var networkMonitor = NetworkMonitor.shared

    let availableCountries = [
        "United States", "Canada", "Mexico", "United Kingdom", "Australia",
        "Germany", "France", "Spain", "Italy", "Brazil", "Argentina",
        "Japan", "South Korea", "China", "India", "Philippines", "Vietnam",
        "Thailand", "Netherlands", "Sweden", "Norway", "Denmark", "Switzerland",
        "Ireland", "New Zealand", "Singapore", "Russia", "Poland", "Turkey",
        "Indonesia", "Malaysia", "Colombia", "Chile", "Peru", "Other"
    ]

    let timezoneOptions = [
        "UTC-12:00", "UTC-11:00", "UTC-10:00", "UTC-09:00", "UTC-08:00 (Pacific)",
        "UTC-07:00 (Mountain)", "UTC-06:00 (Central)", "UTC-05:00 (Eastern)",
        "UTC-04:00", "UTC-03:00", "UTC-02:00", "UTC-01:00", "UTC+00:00 (London)",
        "UTC+01:00 (Paris)", "UTC+02:00", "UTC+03:00 (Moscow)", "UTC+04:00",
        "UTC+05:00", "UTC+05:30 (India)", "UTC+06:00", "UTC+07:00 (Bangkok)",
        "UTC+08:00 (Singapore)", "UTC+09:00 (Tokyo)", "UTC+10:00 (Sydney)",
        "UTC+11:00", "UTC+12:00"
    ]

    init() {
        let user = AuthService.shared.currentUser

        _userId = State(initialValue: user?.id ?? "")
        _fullName = State(initialValue: user?.fullName ?? "")
        _age = State(initialValue: "\(user?.age ?? 18)")
        _bio = State(initialValue: user?.bio ?? "")
        _location = State(initialValue: user?.location ?? "")
        _country = State(initialValue: user?.country ?? "")
        _timezone = State(initialValue: user?.timezone ?? "")

        // Language Exchange Fields
        _nativeLanguages = State(initialValue: user?.nativeLanguages ?? [])
        _learningLanguages = State(initialValue: user?.learningLanguages ?? [])
        _learningGoals = State(initialValue: user?.learningGoals ?? [])
        _practiceMethodPreferences = State(initialValue: user?.practiceMethodPreferences ?? [])
        _availabilities = State(initialValue: user?.availabilities ?? [])
        _conversationTopics = State(initialValue: user?.conversationTopics ?? [])

        _prompts = State(initialValue: user?.prompts ?? [])
        _photos = State(initialValue: user?.photos ?? [])
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Photos Section
                        photosSection

                        // Profile Completion
                        profileCompletionProgress

                        // Basic Info
                        basicInfoSection

                        // About Me
                        aboutMeSection

                        // Native Languages (Languages I can teach)
                        nativeLanguagesSection

                        // Learning Languages (Languages I want to learn)
                        learningLanguagesSection

                        // Learning Goals
                        learningGoalsSection

                        // Practice Methods
                        practiceMethodsSection

                        // Availability
                        availabilitySection

                        // Conversation Topics
                        conversationTopicsSection

                        // Profile Prompts
                        promptsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                            Text("Cancel")
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveProfile()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.blue)
                        } else {
                            HStack(spacing: 4) {
                                Text("Save")
                                    .fontWeight(.semibold)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                            }
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .teal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        }
                    }
                    .disabled(isLoading || !isFormValid)
                }
            }
            .alert("Success!", isPresented: $showSuccessAlert) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your profile has been updated successfully!")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showNativeLanguagePicker) {
                LanguageProficiencyPickerView(
                    title: "Languages I Speak",
                    subtitle: "Add languages you can teach others",
                    languages: $nativeLanguages,
                    defaultLevel: .native
                )
            }
            .sheet(isPresented: $showLearningLanguagePicker) {
                LanguageProficiencyPickerView(
                    title: "Languages I'm Learning",
                    subtitle: "Add languages you want to practice",
                    languages: $learningLanguages,
                    defaultLevel: .a1
                )
            }
            .sheet(isPresented: $showPromptsEditor) {
                ProfilePromptsEditorView(prompts: $prompts)
            }
            .onAppear {
                if let currentUser = authService.currentUser,
                   let userIdValue = currentUser.id {
                    userId = userIdValue
                    photos = currentUser.photos
                } else if let firebaseAuthId = Auth.auth().currentUser?.uid {
                    userId = firebaseAuthId
                }
            }
        }
        .networkStatusBanner()
    }

    // MARK: - Form Validation

    private var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !nativeLanguages.isEmpty &&
        !learningLanguages.isEmpty
    }

    // MARK: - Profile Completion Progress

    private var profileCompletionProgress: some View {
        let completion = calculateProfileCompletion()

        return VStack(spacing: 12) {
            HStack {
                Text("Profile Strength")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(Int(completion * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(completion >= 0.8 ? .green : (completion >= 0.5 ? .orange : .red))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: completion >= 0.8 ? [.green, .teal] : (completion >= 0.5 ? [.orange, .yellow] : [.red, .orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * completion, height: 8)
                }
            }
            .frame(height: 8)

            if completion < 1.0 {
                Text(getCompletionTip())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private func calculateProfileCompletion() -> Double {
        var score: Double = 0
        let maxScore: Double = 10

        if !fullName.isEmpty { score += 1 }
        if !bio.isEmpty { score += 1 }
        if !location.isEmpty { score += 0.5 }
        if !country.isEmpty { score += 0.5 }
        if !nativeLanguages.isEmpty { score += 2 }
        if !learningLanguages.isEmpty { score += 2 }
        if !learningGoals.isEmpty { score += 1 }
        if !practiceMethodPreferences.isEmpty { score += 1 }
        if !availabilities.isEmpty { score += 0.5 }
        if !conversationTopics.isEmpty { score += 0.5 }

        return min(score / maxScore, 1.0)
    }

    private func getCompletionTip() -> String {
        if nativeLanguages.isEmpty { return "Add languages you speak natively to help others find you" }
        if learningLanguages.isEmpty { return "Add languages you want to learn to find partners" }
        if bio.isEmpty { return "Add a bio to introduce yourself" }
        if learningGoals.isEmpty { return "Add learning goals to match with like-minded partners" }
        if practiceMethodPreferences.isEmpty { return "Add preferred practice methods" }
        return "Complete your profile to get more connections!"
    }

    // MARK: - Photos Section

    private var photosSection: some View {
        VStack(spacing: 0) {
            HStack {
                SectionHeader(icon: "camera.fill", title: "Your Photos", color: .blue)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Profile Photo
            VStack(spacing: 12) {
                HStack {
                    Text("Profile Photo")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 20)

                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                        } else if let currentUser = authService.currentUser,
                                  let imageURL = URL(string: currentUser.profileImageURL),
                                  !currentUser.profileImageURL.isEmpty {
                            CachedAsyncImage(
                                url: imageURL,
                                content: { image in
                                    image.resizable().scaledToFill()
                                },
                                placeholder: { profilePlaceholderImage }
                            )
                        } else {
                            profilePlaceholderImage
                        }
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.blue, .teal],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    }
                    .shadow(color: .blue.opacity(0.25), radius: 12, y: 6)

                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 38, height: 38)
                                .shadow(color: .black.opacity(0.15), radius: 4)

                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .teal],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 34, height: 34)

                            if isUploadingProfilePhoto {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(isUploadingProfilePhoto)
                    .offset(x: 4, y: 4)
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .onChange(of: selectedImage) { _, newItem in
            guard let newItem = newItem else { return }
            Task {
                await uploadProfilePhoto(newItem)
            }
        }
    }

    private var profilePlaceholderImage: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.blue.opacity(0.6), .teal.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                if !fullName.isEmpty {
                    Text(fullName.prefix(1).uppercased())
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
    }

    // MARK: - Basic Info Section

    private var basicInfoSection: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "person.fill", title: "Basic Info", color: .blue)

            VStack(spacing: 16) {
                // Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Display Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    TextField("Your name", text: $fullName)
                        .textFieldStyle(ModernTextFieldStyle())
                }

                // Age
                VStack(alignment: .leading, spacing: 8) {
                    Text("Age")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    TextField("Age", text: $age)
                        .textFieldStyle(ModernTextFieldStyle())
                        .keyboardType(.numberPad)
                }

                // Location
                VStack(alignment: .leading, spacing: 8) {
                    Text("City")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    TextField("Your city", text: $location)
                        .textFieldStyle(ModernTextFieldStyle())
                }

                // Country
                VStack(alignment: .leading, spacing: 8) {
                    Text("Country")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Menu {
                        ForEach(availableCountries, id: \.self) { countryOption in
                            Button(countryOption) {
                                country = countryOption
                            }
                        }
                    } label: {
                        HStack {
                            Text(country.isEmpty ? "Select country" : country)
                                .foregroundColor(country.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }

                // Timezone
                VStack(alignment: .leading, spacing: 8) {
                    Text("Timezone (for scheduling)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Menu {
                        ForEach(timezoneOptions, id: \.self) { tz in
                            Button(tz) {
                                timezone = tz
                            }
                        }
                    } label: {
                        HStack {
                            Text(timezone.isEmpty ? "Select timezone" : timezone)
                                .foregroundColor(timezone.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    // MARK: - About Me Section

    private var aboutMeSection: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "text.quote", title: "About Me", color: .blue)

            VStack(alignment: .leading, spacing: 8) {
                Text("Introduce yourself to potential language partners")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextEditor(text: $bio)
                    .frame(minHeight: 100)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )

                Text("\(bio.count)/500 characters")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    // MARK: - Native Languages Section

    private var nativeLanguagesSection: some View {
        VStack(spacing: 16) {
            HStack {
                SectionHeader(icon: "person.wave.2.fill", title: "Languages I Speak", color: .teal)
                Spacer()
                Button {
                    showNativeLanguagePicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.teal)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Languages you can help others learn")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if nativeLanguages.isEmpty {
                    emptyLanguageState(message: "Add your native or fluent languages", action: { showNativeLanguagePicker = true })
                } else {
                    FlowLayout(spacing: 8) {
                        ForEach(nativeLanguages) { langProf in
                            LanguageProficiencyChip(
                                languageProficiency: langProf,
                                onRemove: {
                                    nativeLanguages.removeAll { $0.id == langProf.id }
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    // MARK: - Learning Languages Section

    private var learningLanguagesSection: some View {
        VStack(spacing: 16) {
            HStack {
                SectionHeader(icon: "book.fill", title: "Languages I'm Learning", color: .blue)
                Spacer()
                Button {
                    showLearningLanguagePicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Languages you want to practice")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if learningLanguages.isEmpty {
                    emptyLanguageState(message: "Add languages you want to learn", action: { showLearningLanguagePicker = true })
                } else {
                    FlowLayout(spacing: 8) {
                        ForEach(learningLanguages) { langProf in
                            LanguageProficiencyChip(
                                languageProficiency: langProf,
                                onRemove: {
                                    learningLanguages.removeAll { $0.id == langProf.id }
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private func emptyLanguageState(message: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle")
                    .foregroundColor(.blue)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    // MARK: - Learning Goals Section

    private var learningGoalsSection: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "target", title: "Learning Goals", color: .orange)

            VStack(alignment: .leading, spacing: 8) {
                Text("What do you want to achieve?")
                    .font(.caption)
                    .foregroundColor(.secondary)

                FlowLayout(spacing: 8) {
                    ForEach(LearningGoal.allCases, id: \.self) { goal in
                        ToggleChip(
                            title: goal.displayName,
                            icon: goal.icon,
                            isSelected: learningGoals.contains(goal.rawValue),
                            action: {
                                if learningGoals.contains(goal.rawValue) {
                                    learningGoals.removeAll { $0 == goal.rawValue }
                                } else {
                                    learningGoals.append(goal.rawValue)
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    // MARK: - Practice Methods Section

    private var practiceMethodsSection: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "bubble.left.and.bubble.right.fill", title: "Practice Methods", color: .teal)

            VStack(alignment: .leading, spacing: 8) {
                Text("How do you prefer to practice?")
                    .font(.caption)
                    .foregroundColor(.secondary)

                FlowLayout(spacing: 8) {
                    ForEach(PracticeMethod.allCases, id: \.self) { method in
                        ToggleChip(
                            title: method.displayName,
                            icon: method.icon,
                            isSelected: practiceMethodPreferences.contains(method.rawValue),
                            action: {
                                if practiceMethodPreferences.contains(method.rawValue) {
                                    practiceMethodPreferences.removeAll { $0 == method.rawValue }
                                } else {
                                    practiceMethodPreferences.append(method.rawValue)
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    // MARK: - Availability Section

    private var availabilitySection: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "clock.fill", title: "Availability", color: .green)

            VStack(alignment: .leading, spacing: 8) {
                Text("When are you usually available?")
                    .font(.caption)
                    .foregroundColor(.secondary)

                FlowLayout(spacing: 8) {
                    ForEach(Availability.allCases, id: \.self) { avail in
                        ToggleChip(
                            title: avail.displayName,
                            icon: avail.icon,
                            isSelected: availabilities.contains(avail.rawValue),
                            action: {
                                if availabilities.contains(avail.rawValue) {
                                    availabilities.removeAll { $0 == avail.rawValue }
                                } else {
                                    availabilities.append(avail.rawValue)
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    // MARK: - Conversation Topics Section

    private var conversationTopicsSection: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "text.bubble.fill", title: "Conversation Topics", color: .blue)

            VStack(alignment: .leading, spacing: 8) {
                Text("What do you like to talk about?")
                    .font(.caption)
                    .foregroundColor(.secondary)

                FlowLayout(spacing: 8) {
                    ForEach(ConversationTopic.allCases, id: \.self) { topic in
                        ToggleChip(
                            title: topic.displayName,
                            icon: topic.icon,
                            isSelected: conversationTopics.contains(topic.rawValue),
                            action: {
                                if conversationTopics.contains(topic.rawValue) {
                                    conversationTopics.removeAll { $0 == topic.rawValue }
                                } else {
                                    conversationTopics.append(topic.rawValue)
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    // MARK: - Prompts Section

    private var promptsSection: some View {
        VStack(spacing: 16) {
            HStack {
                SectionHeader(icon: "quote.bubble.fill", title: "About My Learning", color: .indigo)
                Spacer()
                Button {
                    showPromptsEditor = true
                } label: {
                    Text("Edit")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.indigo)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Share more about your language learning journey")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if prompts.isEmpty {
                    Button {
                        showPromptsEditor = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.indigo)
                            Text("Add prompts to stand out")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                } else {
                    ForEach(prompts) { prompt in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(prompt.question)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.indigo)

                            Text(prompt.answer)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    // MARK: - Save Profile

    private func saveProfile() {
        guard !userId.isEmpty else {
            errorMessage = "Unable to save profile. Please try again."
            showErrorAlert = true
            return
        }

        isLoading = true

        Task {
            do {
                var updatedUser = authService.currentUser ?? User(
                    id: userId,
                    email: Auth.auth().currentUser?.email ?? "",
                    fullName: fullName,
                    age: Int(age) ?? 18,
                    location: location,
                    country: country
                )

                updatedUser.fullName = fullName
                updatedUser.age = Int(age) ?? 18
                updatedUser.bio = bio
                updatedUser.location = location
                updatedUser.country = country
                updatedUser.timezone = timezone.isEmpty ? nil : timezone
                updatedUser.nativeLanguages = nativeLanguages
                updatedUser.learningLanguages = learningLanguages
                updatedUser.learningGoals = learningGoals
                updatedUser.practiceMethodPreferences = practiceMethodPreferences
                updatedUser.availabilities = availabilities
                updatedUser.conversationTopics = conversationTopics
                updatedUser.prompts = prompts
                updatedUser.photos = photos
                updatedUser.updateSearchFields()

                try await authService.updateUserProfile(updatedUser)

                await MainActor.run {
                    isLoading = false
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }

    // MARK: - Upload Profile Photo

    private func uploadProfilePhoto(_ item: PhotosPickerItem) async {
        isUploadingProfilePhoto = true

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not load image"])
            }

            await MainActor.run {
                profileImage = uiImage
            }

            // Upload to Firebase Storage
            let imageURL = try await authService.uploadProfileImage(data, userId: userId)

            // Update user with new profile image URL
            if var currentUser = authService.currentUser {
                currentUser.profileImageURL = imageURL
                try await authService.updateUserProfile(currentUser)
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to upload photo: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }

        await MainActor.run {
            isUploadingProfilePhoto = false
        }
    }
}

// MARK: - Supporting Views

struct LanguageProficiencyChip: View {
    let languageProficiency: LanguageProficiency
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            if let lang = languageProficiency.languageEnum {
                Text(lang.flag)
                    .font(.caption)
            }
            Text(languageProficiency.displayName)
                .font(.subheadline)
                .fontWeight(.medium)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [.blue, .teal],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(20)
    }
}

struct ToggleChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundColor(isSelected ? .white : .primary)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct SectionHeader: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

// MARK: - Language Proficiency Picker

struct LanguageProficiencyPickerView: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    let subtitle: String
    @Binding var languages: [LanguageProficiency]
    let defaultLevel: ProficiencyLevel

    @State private var selectedLanguage: Language?
    @State private var selectedLevel: ProficiencyLevel

    init(title: String, subtitle: String, languages: Binding<[LanguageProficiency]>, defaultLevel: ProficiencyLevel) {
        self.title = title
        self.subtitle = subtitle
        self._languages = languages
        self.defaultLevel = defaultLevel
        self._selectedLevel = State(initialValue: defaultLevel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Subtitle
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()

                // Language List
                List {
                    ForEach(Language.allCases, id: \.self) { language in
                        let isAdded = languages.contains { $0.language == language.rawValue }

                        Button {
                            if !isAdded {
                                selectedLanguage = language
                            }
                        } label: {
                            HStack {
                                Text(language.flag)
                                    .font(.title2)

                                VStack(alignment: .leading) {
                                    Text(language.displayName)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Text(language.nativeName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if isAdded {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .disabled(isAdded)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedLanguage) { language in
                ProficiencyLevelPicker(
                    language: language,
                    selectedLevel: $selectedLevel,
                    defaultLevel: defaultLevel,
                    onAdd: { level in
                        let newProficiency = LanguageProficiency(language: language, level: level)
                        languages.append(newProficiency)
                        selectedLanguage = nil
                    }
                )
            }
        }
    }
}

extension Language: Identifiable {
    public var id: String { rawValue }
}

struct ProficiencyLevelPicker: View {
    @Environment(\.dismiss) var dismiss
    let language: Language
    @Binding var selectedLevel: ProficiencyLevel
    let defaultLevel: ProficiencyLevel
    let onAdd: (ProficiencyLevel) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Language Info
                VStack(spacing: 8) {
                    Text(language.flag)
                        .font(.system(size: 60))
                    Text(language.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)

                Text("Select your proficiency level")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Level Selection
                VStack(spacing: 12) {
                    ForEach(ProficiencyLevel.allCases, id: \.self) { level in
                        Button {
                            selectedLevel = level
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(level.displayName)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Text(level.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if selectedLevel == level {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(selectedLevel == level ? Color.blue.opacity(0.1) : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Add Button
                Button {
                    onAdd(selectedLevel)
                    dismiss()
                } label: {
                    Text("Add \(language.displayName)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                }
                .padding()
            }
            .navigationTitle("Proficiency Level")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                selectedLevel = defaultLevel
            }
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthService.shared)
}
