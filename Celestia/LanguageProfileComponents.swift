//
//  LanguageProfileComponents.swift
//  LangSwap
//
//  Components for displaying language proficiency and compatibility in profiles
//

import SwiftUI

// MARK: - Proficiency Level Badge

struct ProficiencyBadge: View {
    let level: ProficiencyLevel

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: level.icon)
                .font(.caption2)

            Text(level.shortName)
                .font(.caption2)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(level.color.opacity(0.15))
        .foregroundColor(level.color)
        .cornerRadius(12)
    }
}

// Extension to add color to ProficiencyLevel
extension ProficiencyLevel {
    var color: Color {
        switch self {
        case .a1: return .red
        case .a2: return .orange
        case .b1: return .yellow
        case .b2: return .green
        case .c1: return .blue
        case .c2: return .purple
        case .native: return .teal
        }
    }

    var icon: String {
        switch self {
        case .a1: return "1.circle.fill"
        case .a2: return "2.circle.fill"
        case .b1: return "3.circle.fill"
        case .b2: return "4.circle.fill"
        case .c1: return "5.circle.fill"
        case .c2: return "6.circle.fill"
        case .native: return "star.fill"
        }
    }
}

// MARK: - Language Chip with Proficiency

struct LanguageChipWithProficiency: View {
    let languageProficiency: LanguageProficiency
    let style: ChipStyle

    enum ChipStyle {
        case native       // Gold/teal - for native languages
        case learning     // Blue - for learning languages
        case compact      // Smaller version for lists
    }

    var body: some View {
        HStack(spacing: 6) {
            // Flag
            if let lang = languageProficiency.languageEnum {
                Text(lang.flag)
                    .font(style == .compact ? .caption : .body)
            }

            // Language name
            Text(languageProficiency.language)
                .font(style == .compact ? .caption : .subheadline)
                .fontWeight(.medium)

            // Proficiency badge
            ProficiencyBadge(level: languageProficiency.level)
        }
        .padding(.horizontal, style == .compact ? 10 : 14)
        .padding(.vertical, style == .compact ? 6 : 10)
        .background(backgroundGradient)
        .cornerRadius(style == .compact ? 16 : 20)
    }

    private var backgroundGradient: some View {
        Group {
            switch style {
            case .native:
                LinearGradient(
                    colors: [Color.teal.opacity(0.15), Color.green.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .learning:
                LinearGradient(
                    colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .compact:
                Color.gray.opacity(0.1)
            }
        }
    }
}

// MARK: - Language Section Card

struct LanguageSectionCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    let languages: [LanguageProficiency]
    let style: LanguageChipWithProficiency.ChipStyle
    let emptyMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(iconColor)

                Text(title)
                    .font(.headline)

                Spacer()

                Text("\(languages.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(iconColor)
                    .cornerRadius(10)
            }

            // Languages
            if languages.isEmpty {
                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                FlowLayoutLanguages(spacing: 8) {
                    ForEach(languages) { langProf in
                        LanguageChipWithProficiency(
                            languageProficiency: langProf,
                            style: style
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// Simple flow layout for languages
struct FlowLayoutLanguages: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.origin.x, y: bounds.minY + frame.origin.y),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            maxHeight = max(maxHeight, y + size.height)
        }

        return (CGSize(width: maxWidth, height: maxHeight), frames)
    }
}

// MARK: - Language Compatibility Card

struct LanguageCompatibilityCard: View {
    let currentUser: User
    let otherUser: User

    var compatibilityInfo: CompatibilityInfo {
        calculateCompatibility()
    }

    struct CompatibilityInfo {
        let canTeachThem: [String]      // Languages current user can teach other user
        let canLearnFrom: [String]      // Languages current user can learn from other user
        let isComplementary: Bool       // True if both can help each other
        let matchScore: Int             // 0-100 score
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with match score
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Language Match")
                        .font(.headline)

                    Text(compatibilityDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Match Score Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 50, height: 50)

                    Circle()
                        .trim(from: 0, to: CGFloat(compatibilityInfo.matchScore) / 100)
                        .stroke(matchScoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))

                    Text("\(compatibilityInfo.matchScore)%")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(matchScoreColor)
                }
            }

            // Compatibility Details
            if compatibilityInfo.isComplementary {
                // Perfect match - can help each other
                VStack(spacing: 12) {
                    if !compatibilityInfo.canTeachThem.isEmpty {
                        CompatibilityRow(
                            icon: "arrow.right.circle.fill",
                            title: "You can help with:",
                            languages: compatibilityInfo.canTeachThem,
                            color: .green
                        )
                    }

                    if !compatibilityInfo.canLearnFrom.isEmpty {
                        CompatibilityRow(
                            icon: "arrow.left.circle.fill",
                            title: "They can help you with:",
                            languages: compatibilityInfo.canLearnFrom,
                            color: .blue
                        )
                    }
                }
            } else if !compatibilityInfo.canTeachThem.isEmpty {
                CompatibilityRow(
                    icon: "arrow.right.circle.fill",
                    title: "You can help them with:",
                    languages: compatibilityInfo.canTeachThem,
                    color: .green
                )
            } else if !compatibilityInfo.canLearnFrom.isEmpty {
                CompatibilityRow(
                    icon: "arrow.left.circle.fill",
                    title: "They can help you with:",
                    languages: compatibilityInfo.canLearnFrom,
                    color: .blue
                )
            } else {
                Text("No direct language matches found")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            compatibilityInfo.isComplementary
                ? LinearGradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                : Color(.systemBackground)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(compatibilityInfo.isComplementary ? Color.teal.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }

    private var compatibilityDescription: String {
        if compatibilityInfo.isComplementary {
            return "Perfect exchange partner!"
        } else if !compatibilityInfo.canTeachThem.isEmpty || !compatibilityInfo.canLearnFrom.isEmpty {
            return "Partial language match"
        } else {
            return "Limited language overlap"
        }
    }

    private var matchScoreColor: Color {
        if compatibilityInfo.matchScore >= 70 {
            return .green
        } else if compatibilityInfo.matchScore >= 40 {
            return .orange
        } else {
            return .gray
        }
    }

    private func calculateCompatibility() -> CompatibilityInfo {
        var canTeach: [String] = []
        var canLearn: [String] = []

        // What current user can teach (their native languages that other is learning)
        for native in currentUser.nativeLanguages {
            for learning in otherUser.learningLanguages {
                if native.language.lowercased() == learning.language.lowercased() {
                    canTeach.append(native.language)
                }
            }
        }

        // What current user can learn (other's native languages that current is learning)
        for learning in currentUser.learningLanguages {
            for native in otherUser.nativeLanguages {
                if learning.language.lowercased() == native.language.lowercased() {
                    canLearn.append(native.language)
                }
            }
        }

        let isComplementary = !canTeach.isEmpty && !canLearn.isEmpty

        // Calculate score
        var score = 0
        if !canTeach.isEmpty { score += 30 }
        if !canLearn.isEmpty { score += 30 }
        if isComplementary { score += 40 }

        return CompatibilityInfo(
            canTeachThem: canTeach,
            canLearnFrom: canLearn,
            isComplementary: isComplementary,
            matchScore: score
        )
    }
}

struct CompatibilityRow: View {
    let icon: String
    let title: String
    let languages: [String]
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(languages.joined(separator: ", "))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
        }
    }
}

// MARK: - Proficiency Level Explanation

struct ProficiencyExplanation: View {
    let level: ProficiencyLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ProficiencyBadge(level: level)

                Text(level.displayName)
                    .font(.headline)
            }

            Text(level.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Proficiency Level Legend

struct ProficiencyLegend: View {
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)

                    Text("Proficiency Levels Explained")
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(ProficiencyLevel.allCases, id: \.self) { level in
                        HStack(spacing: 12) {
                            ProficiencyBadge(level: level)
                                .frame(width: 70, alignment: .leading)

                            Text(level.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Language Goals Display

struct LearningGoalsDisplay: View {
    let goals: [LearningGoal]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.orange)
                Text("Learning Goals")
                    .font(.headline)
            }

            FlowLayoutLanguages(spacing: 8) {
                ForEach(goals, id: \.self) { goal in
                    HStack(spacing: 4) {
                        Image(systemName: goal.icon)
                            .font(.caption)
                        Text(goal.displayName)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(16)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Practice Methods Display

struct PracticeMethodsDisplay: View {
    let methods: [PracticeMethod]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .foregroundColor(.purple)
                Text("Preferred Practice Methods")
                    .font(.headline)
            }

            FlowLayoutLanguages(spacing: 8) {
                ForEach(methods, id: \.self) { method in
                    HStack(spacing: 4) {
                        Image(systemName: method.icon)
                            .font(.caption)
                        Text(method.displayName)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.purple.opacity(0.1))
                    .foregroundColor(.purple)
                    .cornerRadius(16)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Previews

#Preview("Proficiency Badge") {
    HStack(spacing: 8) {
        ForEach(ProficiencyLevel.allCases, id: \.self) { level in
            ProficiencyBadge(level: level)
        }
    }
    .padding()
}

#Preview("Language Chip") {
    VStack(spacing: 16) {
        LanguageChipWithProficiency(
            languageProficiency: LanguageProficiency(language: "Spanish", level: .b2),
            style: .native
        )

        LanguageChipWithProficiency(
            languageProficiency: LanguageProficiency(language: "French", level: .a2),
            style: .learning
        )

        LanguageChipWithProficiency(
            languageProficiency: LanguageProficiency(language: "German", level: .c1),
            style: .compact
        )
    }
    .padding()
}

#Preview("Proficiency Legend") {
    ProficiencyLegend()
        .padding()
}
