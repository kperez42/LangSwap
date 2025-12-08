//
//  DiscoverFiltersView.swift
//  LangSwap
//
//  Filter settings for finding language exchange partners
//

import SwiftUI

struct DiscoverFiltersView: View {
    @ObservedObject var filters = DiscoveryFilters.shared
    @Environment(\.dismiss) var dismiss

    // Section expansion state
    @State private var expandedSections: Set<FilterSection> = [.languages, .learningPreferences]

    enum FilterSection: String, CaseIterable {
        case languages = "Languages"
        case learningPreferences = "Learning Preferences"
        case availability = "Availability & Topics"
        case other = "Other"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Active Filters Summary
                    if filters.hasActiveFilters {
                        activeFiltersSummary
                    }

                    // Filter Sections
                    VStack(spacing: 12) {
                        // Languages Section (most important for language exchange)
                        filterSection(
                            section: .languages,
                            icon: "globe",
                            content: {
                                VStack(spacing: 20) {
                                    teachingLanguagesSection
                                    Divider().padding(.horizontal)
                                    learningLanguagesSection
                                    Divider().padding(.horizontal)
                                    proficiencySection
                                    Divider().padding(.horizontal)
                                    complementaryMatchSection
                                }
                            }
                        )

                        // Learning Preferences Section
                        filterSection(
                            section: .learningPreferences,
                            icon: "graduationcap",
                            content: {
                                VStack(spacing: 20) {
                                    learningGoalsSection
                                    Divider().padding(.horizontal)
                                    practiceMethodsSection
                                }
                            }
                        )

                        // Availability & Topics Section
                        filterSection(
                            section: .availability,
                            icon: "clock",
                            content: {
                                VStack(spacing: 20) {
                                    availabilitySection
                                    Divider().padding(.horizontal)
                                    conversationTopicsSection
                                }
                            }
                        )

                        // Other Filters Section
                        filterSection(
                            section: .other,
                            icon: "slider.horizontal.3",
                            content: {
                                VStack(spacing: 20) {
                                    verificationSection
                                    Divider().padding(.horizontal)
                                    activitySection
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // Reset button
                    if filters.hasActiveFilters {
                        resetButton
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                            .padding(.bottom, 32)
                    } else {
                        Spacer().frame(height: 32)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Find Partners")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.impact(.medium)
                        filters.saveToUserDefaults()
                        dismiss()
                    } label: {
                        Text("Apply")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .teal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                    }
                }
            }
        }
    }

    // MARK: - Active Filters Summary

    private var activeFiltersSummary: some View {
        let activeCount = countActiveFilters()

        return HStack(spacing: 8) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .foregroundColor(.blue)

            Text("\(activeCount) filter\(activeCount == 1 ? "" : "s") active")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()

            Button {
                HapticManager.shared.impact(.light)
                withAnimation(.spring(response: 0.3)) {
                    filters.resetFilters()
                }
            } label: {
                Text("Clear All")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.blue.opacity(0.08))
    }

    // MARK: - Filter Section Container

    private func filterSection<Content: View>(
        section: FilterSection,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            // Section Header
            Button {
                HapticManager.shared.impact(.light)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if expandedSections.contains(section) {
                        expandedSections.remove(section)
                    } else {
                        expandedSections.insert(section)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32)

                    Text(section.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    // Section filter count badge
                    if let count = sectionFilterCount(section), count > 0 {
                        Text("\(count)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .teal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(expandedSections.contains(section) ? 90 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            // Section Content
            if expandedSections.contains(section) {
                content()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - Teaching Languages Section (Languages I want to learn)

    private var teachingLanguagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.blue)
                Text("I want to learn")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.teachingLanguages.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.teachingLanguages.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Text("Show partners who speak these languages natively")
                .font(.caption)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(Language.allCases, id: \.self) { language in
                    LanguageFilterChip(
                        language: language,
                        isSelected: filters.teachingLanguages.contains(language.rawValue)
                    ) {
                        toggleTeachingLanguage(language.rawValue)
                    }
                }
            }
        }
    }

    // MARK: - Learning Languages Section (Languages partner wants to learn)

    private var learningLanguagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.wave.2.fill")
                    .foregroundColor(.teal)
                Text("I can teach")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.learningLanguages.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.learningLanguages.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Text("Show partners who want to learn these languages")
                .font(.caption)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(Language.allCases, id: \.self) { language in
                    LanguageFilterChip(
                        language: language,
                        isSelected: filters.learningLanguages.contains(language.rawValue)
                    ) {
                        toggleLearningLanguage(language.rawValue)
                    }
                }
            }
        }
    }

    // MARK: - Proficiency Section

    private var proficiencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Minimum Proficiency Level")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if filters.minProficiencyLevel != nil {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.minProficiencyLevel = nil
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Text("Partner's proficiency in their teaching language")
                .font(.caption)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(ProficiencyLevel.allCases, id: \.self) { level in
                    SelectableFilterChip(
                        title: level.shortName,
                        isSelected: filters.minProficiencyLevel == level
                    ) {
                        HapticManager.shared.impact(.light)
                        if filters.minProficiencyLevel == level {
                            filters.minProficiencyLevel = nil
                        } else {
                            filters.minProficiencyLevel = level
                        }
                    }
                }
            }
        }
    }

    // MARK: - Complementary Match Section

    private var complementaryMatchSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Complementary Matches Only")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Only show partners where you can help each other")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $filters.complementaryMatchOnly)
                .labelsHidden()
                .tint(.blue)
        }
    }

    // MARK: - Learning Goals Section

    private var learningGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Learning Goals")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.learningGoals.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.learningGoals.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            FlowLayout(spacing: 8) {
                ForEach(LearningGoal.allCases, id: \.self) { goal in
                    SelectableFilterChip(
                        title: goal.displayName,
                        isSelected: filters.learningGoals.contains(goal.rawValue)
                    ) {
                        toggleLearningGoal(goal.rawValue)
                    }
                }
            }
        }
    }

    // MARK: - Practice Methods Section

    private var practiceMethodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Practice Methods")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.practiceMethodPreferences.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.practiceMethodPreferences.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            FlowLayout(spacing: 8) {
                ForEach(PracticeMethod.allCases, id: \.self) { method in
                    IconFilterChip(
                        title: method.displayName,
                        icon: method.icon,
                        isSelected: filters.practiceMethodPreferences.contains(method.rawValue)
                    ) {
                        togglePracticeMethod(method.rawValue)
                    }
                }
            }
        }
    }

    // MARK: - Availability Section

    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Availability")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.availabilities.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.availabilities.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            FlowLayout(spacing: 8) {
                ForEach(Availability.allCases, id: \.self) { availability in
                    IconFilterChip(
                        title: availability.displayName,
                        icon: availability.icon,
                        isSelected: filters.availabilities.contains(availability.rawValue)
                    ) {
                        toggleAvailability(availability.rawValue)
                    }
                }
            }
        }
    }

    // MARK: - Conversation Topics Section

    private var conversationTopicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Conversation Topics")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.conversationTopics.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.conversationTopics.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            FlowLayout(spacing: 8) {
                ForEach(ConversationTopic.allCases, id: \.self) { topic in
                    IconFilterChip(
                        title: topic.displayName,
                        icon: topic.icon,
                        isSelected: filters.conversationTopics.contains(topic.rawValue)
                    ) {
                        toggleConversationTopic(topic.rawValue)
                    }
                }
            }
        }
    }

    // MARK: - Verification Section

    private var verificationSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Verified Users Only")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Only show profiles with ID verification")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $filters.showVerifiedOnly)
                .labelsHidden()
                .tint(.blue)
        }
    }

    // MARK: - Activity Section

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Active")
                .font(.subheadline)
                .fontWeight(.medium)

            FlowLayout(spacing: 8) {
                SelectableFilterChip(
                    title: "Any Time",
                    isSelected: filters.activeInLastDays == nil
                ) {
                    HapticManager.shared.impact(.light)
                    filters.activeInLastDays = nil
                }

                SelectableFilterChip(
                    title: "Last Week",
                    isSelected: filters.activeInLastDays == 7
                ) {
                    HapticManager.shared.impact(.light)
                    filters.activeInLastDays = 7
                }

                SelectableFilterChip(
                    title: "Last Month",
                    isSelected: filters.activeInLastDays == 30
                ) {
                    HapticManager.shared.impact(.light)
                    filters.activeInLastDays = 30
                }

                SelectableFilterChip(
                    title: "Last 3 Months",
                    isSelected: filters.activeInLastDays == 90
                ) {
                    HapticManager.shared.impact(.light)
                    filters.activeInLastDays = 90
                }
            }
        }
    }

    // MARK: - Reset Button

    private var resetButton: some View {
        Button {
            HapticManager.shared.notification(.warning)
            withAnimation(.spring(response: 0.3)) {
                filters.resetFilters()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.body.weight(.medium))
                Text("Reset All Filters")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.red)
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Helper Functions

    private func countActiveFilters() -> Int {
        var count = 0
        count += filters.teachingLanguages.count
        count += filters.learningLanguages.count
        if filters.minProficiencyLevel != nil { count += 1 }
        if !filters.complementaryMatchOnly { count += 1 }
        count += filters.learningGoals.count
        count += filters.practiceMethodPreferences.count
        count += filters.availabilities.count
        count += filters.conversationTopics.count
        if filters.showVerifiedOnly { count += 1 }
        if filters.activeInLastDays != nil { count += 1 }
        return count
    }

    private func sectionFilterCount(_ section: FilterSection) -> Int? {
        switch section {
        case .languages:
            var count = 0
            count += filters.teachingLanguages.count
            count += filters.learningLanguages.count
            if filters.minProficiencyLevel != nil { count += 1 }
            if !filters.complementaryMatchOnly { count += 1 }
            return count > 0 ? count : nil
        case .learningPreferences:
            let count = filters.learningGoals.count + filters.practiceMethodPreferences.count
            return count > 0 ? count : nil
        case .availability:
            let count = filters.availabilities.count + filters.conversationTopics.count
            return count > 0 ? count : nil
        case .other:
            var count = 0
            if filters.showVerifiedOnly { count += 1 }
            if filters.activeInLastDays != nil { count += 1 }
            return count > 0 ? count : nil
        }
    }

    private func toggleTeachingLanguage(_ language: String) {
        HapticManager.shared.impact(.light)
        if filters.teachingLanguages.contains(language) {
            filters.teachingLanguages.remove(language)
        } else {
            filters.teachingLanguages.insert(language)
        }
    }

    private func toggleLearningLanguage(_ language: String) {
        HapticManager.shared.impact(.light)
        if filters.learningLanguages.contains(language) {
            filters.learningLanguages.remove(language)
        } else {
            filters.learningLanguages.insert(language)
        }
    }

    private func toggleLearningGoal(_ goal: String) {
        HapticManager.shared.impact(.light)
        if filters.learningGoals.contains(goal) {
            filters.learningGoals.remove(goal)
        } else {
            filters.learningGoals.insert(goal)
        }
    }

    private func togglePracticeMethod(_ method: String) {
        HapticManager.shared.impact(.light)
        if filters.practiceMethodPreferences.contains(method) {
            filters.practiceMethodPreferences.remove(method)
        } else {
            filters.practiceMethodPreferences.insert(method)
        }
    }

    private func toggleAvailability(_ availability: String) {
        HapticManager.shared.impact(.light)
        if filters.availabilities.contains(availability) {
            filters.availabilities.remove(availability)
        } else {
            filters.availabilities.insert(availability)
        }
    }

    private func toggleConversationTopic(_ topic: String) {
        HapticManager.shared.impact(.light)
        if filters.conversationTopics.contains(topic) {
            filters.conversationTopics.remove(topic)
        } else {
            filters.conversationTopics.insert(topic)
        }
    }
}

// MARK: - Language Filter Chip

struct LanguageFilterChip: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(language.flag)
                    .font(.caption)
                Text(language.displayName)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundColor(isSelected ? .white : .primary)
            .background(
                isSelected ?
                Color.blue :
                Color(.systemGray6)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Icon Filter Chip

struct IconFilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
            .background(
                isSelected ?
                Color.blue :
                Color(.systemGray6)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Quick Filter Chip

struct QuickFilterChip: View {
    let title: String
    let icon: String
    let isActive: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .foregroundColor(isActive ? .white : color)
            .background(
                isActive ?
                AnyShapeStyle(color) :
                AnyShapeStyle(color.opacity(0.1))
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(isActive ? 0 : 0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Selectable Filter Chip

struct SelectableFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : .primary)
                .background(
                    isSelected ?
                    Color.blue :
                    Color(.systemGray6)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - Interest Chip (Legacy support)

struct InterestChip: View {
    let interest: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        SelectableFilterChip(title: interest, isSelected: isSelected, action: action)
    }
}

#Preview {
    DiscoverFiltersView()
}
